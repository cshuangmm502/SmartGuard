# SmartGuard: to detect the cross-chain contracts vulnerability by static analysis.
# by Hauturier

from pathlib import Path
import pandas as pd
from SC_extract import parsefromdecompiledcode
from ACV_analysis import ACV_analysis
from tac_analysis import (extract_all_events, extract_all_storage, extract_all_publicFunc_call,
                          extract_all_privateFunc_args, extract_all_publicFunc_args)
from tac_analyze_scripts.help_function import output_Graph_to_file
from xCFG import build_global_cfg, build_fcg, build_data_dependency_graph, \
    get_true_auth_blocks_with_debug, get_precise_auth_info, extract_sload_to_jumpi_paths, extract_caller_to_jumpi_paths, \
    extract_function_args_to_jumpi, extract_arg_state_rendezvous, extract_caller_state_rendezvous, \
    extract_value_state_rendezvous, extract_predicate_slices


def load_csv_from_gig(artifacts_dir, contract_name):
    artifacts_dir = Path(artifacts_dir).resolve()
    out_dir = artifacts_dir / "out"
    df_opcodes = pd.read_csv(out_dir / "TAC_Op.csv", names=['stmtID', 'opcode'], sep='\t')
    df_defines = pd.read_csv(out_dir / "TAC_Def.csv", names=['stmtID', 'var', 'index'], sep='\t')
    df_uses = pd.read_csv(out_dir / "TAC_Use.csv", names=['stmtID', 'var', 'index'], sep='\t')
    df_stmts_in_block = pd.read_csv(out_dir / "TAC_Block.csv", names=['stmtID', 'blockID'], sep='\t')
    df_var_values = pd.read_csv(out_dir / "TAC_Variable_Value.csv", names=['var', 'value'], sep='\t')
    df_tac_file = pd.read_csv(out_dir / "contract.tac", sep="\n", header=None, engine="python")
    df_mapping_slot = pd.read_csv(out_dir / "MappingBaseSlot.csv", names=['stmtID', 'base_slot'], sep='\t')
    df_block_in_func = pd.read_csv(out_dir / "InFunction.csv", names=['block', 'func_id'], sep='\t')
    # df_function_calls = pd.read_csv(out_dir / "IRFunctionCall.csv", delimiter='\t', header=None, engine='python')
    # df_function_calls = pd.read_csv(out_dir / "IRFunctionCall.csv", names=['caller_block', 'callee_block'], sep='\t')
    df_publicArgs = pd.read_csv(out_dir / "PublicFunctionArg.csv", names=['func_entry_block', 'var', 'index'], sep='\t')
    df_formalArgs = pd.read_csv(out_dir / "FormalArgs.csv", names=['func_entry_block', 'var', 'index'], sep='\t')
    df_sign_eventName = pd.read_csv(out_dir / "EventSignatureInContract.csv", names=['signature', 'event_name'],
                                    sep='\t')
    df_blockEdge = pd.read_csv(out_dir / "LocalBlockEdge.csv", sep="\t", header=None, engine="python")
    df_functionCall = pd.read_csv(out_dir / "IRFunctionCall.csv", names=['caller', 'callee_entry'], sep="\t",
                                  header=None, engine="python")
    df_functionReturn = pd.read_csv(out_dir / "IRFunction_Return.csv", names=['func_entry', 'return_block'], sep="\t",
                                     header=None, engine="python")
    df_publicFunction = pd.read_csv(out_dir / "PublicFunction.csv", sep="\t", header=None, engine="python")
    sol_file_path = artifacts_dir / f"{contract_name}.sol"
    df_decompiled_codes = pd.read_csv(sol_file_path, sep="\t", header=None, engine="python", skip_blank_lines=False)
    return (df_opcodes, df_defines, df_uses, df_stmts_in_block, df_var_values, df_mapping_slot,
            df_block_in_func, df_formalArgs, df_publicArgs, df_sign_eventName, df_blockEdge,
            df_functionCall, df_functionReturn, df_publicFunction, df_decompiled_codes)


def vulnerability_analysis(artifacts_path, contract_name):
    # out_dir = Path(artifacts_path / "output_debug")
    (df_opcodes, df_defines, df_uses, df_stmts_in_block, df_var_values, df_mapping_slot, df_block_in_func,
     df_formalArgs, df_publicArgs, df_sign_eventName, df_blockEdge,
     df_functionCall, df_functionReturn, df_publicFunction, df_decompiled_codes) = (
        load_csv_from_gig(artifacts_path, contract_name))
    storage_semantic = parsefromdecompiledcode(df_decompiled_codes)
    # storage_semantic.to_excel(out_dir / "storage_semantic.xlsx", index=False)
    storage = extract_all_storage(df_opcodes, df_defines, df_uses, df_var_values, df_mapping_slot, df_stmts_in_block,
                                  storage_semantic)
    # storage.to_excel(out_dir / "storage.xlsx", index=False)
    caller, callData = extract_all_publicFunc_call(df_opcodes, df_defines, df_uses, df_var_values, df_stmts_in_block)
    # caller.to_excel(out_dir / "caller.xlsx", index=False)
    # callData.to_excel(out_dir / "callData.xlsx", index=False)
    callPubArgs = extract_all_publicFunc_args(df_publicArgs, df_uses, df_stmts_in_block)
    # callPubArgs.to_excel(out_dir / "callPubArgs.xlsx", index=False)
    callPriArgs = extract_all_privateFunc_args(df_formalArgs, df_uses, df_stmts_in_block)
    # callPriArgs.to_excel(out_dir / "callPriArgs.xlsx", index=False)
    # # # b, graph_index = generate_ListandGraph(tac_file)
    #
    events = extract_all_events(df_opcodes, df_var_values, df_uses, df_sign_eventName, df_stmts_in_block)
    # events.to_excel(out_dir / "events.xlsx", index=False)
    global_cfg = build_global_cfg(artifacts_path, df_blockEdge, df_functionCall, df_functionReturn, df_publicFunction, events)
    output_Graph_to_file(global_cfg, 'global_cfg', artifacts_path)
    fcg, emitting_functions, informing_functions = build_fcg(artifacts_path, df_functionCall, df_block_in_func, events)
    # #支配树授权块
    ddg = build_data_dependency_graph(df_defines, df_uses)
    sload_semantics_dict = storage.set_index('stmtID')['semantic'].to_dict()
    test = extract_predicate_slices(ddg, df_opcodes, df_stmts_in_block, sload_semantics_dict)

    # print(test)

    # # 提取arg和状态交汇的检查块(严格的检查块规则)
    df_allArgs = pd.concat([df_publicArgs, df_formalArgs], ignore_index=True)
    TRUE_AUTH_BLOCKS_PUBLICARGS = extract_arg_state_rendezvous(ddg, df_defines, df_allArgs, df_opcodes,
                                                               df_stmts_in_block)
    # print(TRUE_AUTH_BLOCKS_PUBLICARGS)
    # 提取caller和状态交汇的检查块(严格的检查块规则)
    CALLER_STATE_AUTH_BLOCKS = extract_caller_state_rendezvous(ddg, df_opcodes, df_stmts_in_block)
    # print(CALLER_STATE_AUTH_BLOCKS)
    # 提取CALLPRIVATE调用块作为备选检查块（因为检查可能委托给另一函数内部进行）

    # 提取msg.value和状态交汇的检查块(严格的检查块规则)
    CALLVALUE_STATE_AUTH_BLOCKS = extract_value_state_rendezvous(ddg, df_opcodes, df_stmts_in_block)
    # print(CALLVALUE_STATE_AUTH_BLOCKS)
    Manual_check_block = ['0x31eaB0x2327B0x253dB0xe96']
    AUTH_BLOCKS = list(TRUE_AUTH_BLOCKS_PUBLICARGS) + list(CALLER_STATE_AUTH_BLOCKS) +list(CALLVALUE_STATE_AUTH_BLOCKS) + Manual_check_block + list(test)
    # print(AUTH_BLOCKS)
    POTENTIAL_AUTH_BLOCKS = list(df_functionCall.iloc[:, 0])
    print(POTENTIAL_AUTH_BLOCKS)

    ACV_analysis(df_functionCall, df_block_in_func, emitting_functions, informing_functions, fcg, global_cfg,
                df_functionReturn, AUTH_BLOCKS, POTENTIAL_AUTH_BLOCKS)


# def function extract_Auth_Blocks()

# python3 main.py
if __name__ == "__main__":
    PROJECT_ROOT = Path(__file__).resolve().parent
    CONTRACTS_PATH = PROJECT_ROOT / "contracts"
    # CONTRACT_NAME = "0x0cD79409eD80d8a153A3c729aa1f8b5D44A29282"
    CONTRACT_NAME = "ChainSwap"
    CONTRACT_ARTIFACTS_PATH = CONTRACTS_PATH / CONTRACT_NAME
    vulnerability_analysis(CONTRACT_ARTIFACTS_PATH, CONTRACT_NAME)
    # readFile(CONTRACT_ARTIFACTS_PATH)

