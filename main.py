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
    extract_function_args_to_jumpi, extract_arg_state_rendezvous, extract_caller_state_rendezvous


def load_csv_from_gig(artifacts_dir, contract_name):
    artifacts_dir = Path(artifacts_dir).resolve()
    out_dir = artifacts_dir / "out"
    df_opcodes = pd.read_csv(out_dir / "TAC_Op.csv", names=['stmt', 'opcode'], sep='\t')
    df_defines = pd.read_csv(out_dir / "TAC_Def.csv", names=['stmt', 'var', 'index'], sep='\t')
    df_uses = pd.read_csv(out_dir / "TAC_Use.csv", names=['stmt', 'var', 'index'], sep='\t')
    df_stmts_in_block = pd.read_csv(out_dir / "TAC_Block.csv", names=['stmt', 'block'], sep='\t')
    df_var_values = pd.read_csv(out_dir / "TAC_Variable_Value.csv", names=['var', 'value'], sep='\t')
    df_tac_file = pd.read_csv(out_dir / "contract.tac", sep="\n", header=None, engine="python")
    df_mapping_slot = pd.read_csv(out_dir / "MappingBaseSlot.csv", names=['stmt', 'base_slot'], sep='\t')
    df_block_in_func = pd.read_csv(out_dir / "InFunction.csv", delimiter='\t', header=None, engine='python')
    df_function_calls = pd.read_csv(out_dir / "IRFunctionCall.csv", delimiter='\t', header=None, engine='python')
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
            df_block_in_func, df_function_calls, df_formalArgs, df_publicArgs, df_sign_eventName, df_blockEdge,
            df_functionCall, df_functionReturn, df_publicFunction, df_decompiled_codes)


def vulnerability_analysis(artifacts_path, contract_name):
    (df_opcodes, df_defines, df_uses, df_stmts_in_block, df_var_values, df_mapping_slot, df_block_in_func,
     df_function_calls, df_formalArgs, df_publicArgs, df_sign_eventName, df_blockEdge,
     df_functionCall, df_functionReturn, df_publicFunction, df_decompiled_codes) = (
        load_csv_from_gig(artifacts_path, contract_name))
    # storage_semantic = parsefromdecompiledcode(df_decompiled_codes)
    # storage = extract_all_storage(df_opcodes, df_defines, df_uses, df_var_values, df_mapping_slot, df_stmts_in_block,
    #                               storage_semantic)
    # caller, callData = extract_all_publicFunc_call(df_opcodes, df_defines, df_uses, df_var_values, df_stmts_in_block)
    # callPubArgs = extract_all_publicFunc_args(df_publicArgs, df_uses, df_stmts_in_block)
    # callPriArgs = extract_all_privateFunc_args(df_formalArgs, df_uses, df_stmts_in_block)
    # # # b, graph_index = generate_ListandGraph(tac_file)
    #
    # events = extract_all_events(df_opcodes, df_var_values, df_uses, df_sign_eventName, df_stmts_in_block)
    #
    # global_cfg = build_global_cfg(artifacts_path, df_blockEdge, df_functionCall, df_functionReturn, df_publicFunction, events)
    # re_funcs, fcg, emitting_functions, informing_functions = build_fcg(artifacts_path, df_functionCall, df_block_in_func, events)
    #
    # ACV_analysis(df_functionCall, df_block_in_func, emitting_functions, informing_functions, fcg, global_cfg,
    #              storage, caller, callData, callPubArgs, callPriArgs)
    ddg = build_data_dependency_graph(df_defines, df_uses)
    output_Graph_to_file(ddg, "Data_dependency_graph", artifacts_path)
    # result = get_true_auth_blocks_with_debug(ddg, df_opcodes, df_stmts_in_block)
    # AUTH_BLOCKS_SLOAD = extract_sload_to_jumpi_paths(ddg, df_opcodes, df_stmts_in_block)
    # print(AUTH_BLOCKS_SLOAD)
    # AUTH_BLOCKS_CALLER = extract_caller_to_jumpi_paths(ddg, df_opcodes, df_stmts_in_block)
    # print(AUTH_BLOCKS_CALLER)
    # AUTH_BLOCKS_PUBLICARGS = extract_function_args_to_jumpi(ddg, df_defines, df_publicArgs, df_opcodes, df_stmts_in_block)
    # print(AUTH_BLOCKS_PUBLICARGS)
    # 提取arg和状态交汇的检查块
    df_allArgs = pd.concat([df_publicArgs, df_formalArgs], ignore_index=True)
    TRUE_AUTH_BLOCKS_PUBLICARGS = extract_arg_state_rendezvous(ddg, df_defines, df_allArgs, df_opcodes, df_stmts_in_block)
    print(TRUE_AUTH_BLOCKS_PUBLICARGS)
    # 提取caller和状态交汇的检查块
    # CALLER_STATE_AUTH_BLOCKS = extract_caller_state_rendezvous(ddg, df_opcodes, df_stmts_in_block)
    # print(CALLER_STATE_AUTH_BLOCKS)
    # # print(f"Re_fun:{re_funcs}")
    # # print(f"cfg:{cfg}")
    # # print(f"emitting_function:{emitting_function}")
    # # print(f"informing_function:{informing_function}")
    # # block_path_fcg


# python3 main.py
if __name__ == "__main__":
    PROJECT_ROOT = Path(__file__).resolve().parent
    CONTRACTS_PATH = PROJECT_ROOT / "contracts"
    CONTRACT_NAME = "UnifiedRouterV2_0xfa43DE785dd3Cd0ef3dAE0dD2b8bE3F1B5112d1a_DB"
    CONTRACT_ARTIFACTS_PATH = CONTRACTS_PATH / CONTRACT_NAME
    vulnerability_analysis(CONTRACT_ARTIFACTS_PATH, CONTRACT_NAME)
    # readFile(CONTRACT_ARTIFACTS_PATH)
