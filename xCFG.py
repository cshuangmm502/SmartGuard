import re
import pandas as pd
from pathlib import Path
import networkx as nx
from typing import Tuple
import matplotlib.pyplot as plt
import logging
from event_analysis import analyze_events, convert_events_to_func
from tac_analysis import extract_all_events
from tac_analyze_scripts.help_function import output_Graph_to_file, decode_hex_string

PROJECT_ROOT = Path(__file__).resolve().parent
OUT_DIR = PROJECT_ROOT / "contracts/ChainSwap/TokenMapped/out"
CONTRACT_NAME = "TokenMapped"
CONTRACT_ARTIFACTS_PATH = OUT_DIR.parent

logger = logging.getLogger(__name__)

def build_global_cfg(artifacts_path, df_blockEdge, df_functionCall, df_functionReturn, df_publicFuncs, events):
    logger.info("开始构建全局控制流图")
    emitting_events, informing_events = analyze_events(events, artifacts_path)
    informing_blocks = informing_events['blockID'].tolist()
    emitting_blocks = emitting_events['blockID'].tolist()

    G = nx.DiGraph()

    # ==========================================================
    # 1. 加载所有 CSV 文件 (Batch Loading)
    # ==========================================================

    # LocalBlockEdge: Source -> Target
    df_local = df_blockEdge
    # df_local = read_gigahorse_csv_as_csv(out_dir, "LocalBlockEdge.csv", columns=[0, 1])

    # IRFunctionCall: CallerBlock -> CalleeEntryBlock
    df_call = df_functionCall
    # df_call = read_gigahorse_csv_as_csv(out_dir, "IRFunctionCall.csv", columns=[0, 1])
    # df_call.columns = ["caller", "callee_entry"]

    # IRFunction_Return: FunctionEntryBlock -> ReturnBlock
    df_return = df_functionReturn
    # df_return = read_gigahorse_csv_as_csv(out_dir, "IRFunction_Return.csv", columns=[0, 1])
    # df_return.columns = ["func_entry", "return_block"]

    # PublicFunction: EntryBlock
    df_public = df_publicFuncs
    # df_public = read_gigahorse_csv_as_csv(out_dir, "PublicFunction.csv", columns=[0])

    # ==========================================================
    # 2. 构建图 - 本地控制流 (Intra-procedural)
    # ==========================================================
    if not df_local.empty:
        # 批量添加边: (col 0, col 1)
        # 转换为 list of tuples 是最快的方式之一
        G.add_edges_from(df_local.values)

    # ==========================================================
    # 3. 构建图 - 函数调用与返回 (Inter-procedural)
    # ==========================================================

    # A. 添加调用边: Caller -> CalleeEntry
    if not df_call.empty:
        G.add_edges_from(df_call.values)

    # B. 添加返回边: ReturnBlock -> Caller (关键优化!)
    # 逻辑: Caller 调用了 CalleeEntry, CalleeEntry 结束于 ReturnBlock.
    # 路径: Caller -> CalleeEntry -> ... -> ReturnBlock -> Caller (闭环)
    # 操作: 将 df_call 和 df_return 基于 "CalleeEntry" 进行合并

    if not df_call.empty and not df_return.empty:
        # Merge: df_call['callee_entry'] == df_return['func_entry']
        merged_df = pd.merge(
            df_call,
            df_return,
            left_on="callee_entry",
            right_on="func_entry",
            how="inner"
        )

        # 合并后我们需要的边是: return_block -> caller
        if not merged_df.empty:
            return_edges = merged_df[["return_block", "caller"]].values
            # print(f"return_edges:{return_edges}")
            G.add_edges_from(return_edges)

    # ==========================================================
    # 4. 构建图 - 外部入口 (Extern)
    # ==========================================================
    # 逻辑: extern_node -> Public Function Entry
    if not df_public.empty:
        public_entries = df_public.iloc[:, 0].tolist()
        # 构造边列表 [("extern_node", "0x..."), ...]
        extern_edges = [("extern_node", str(block)) for block in public_entries]
        G.add_edges_from(extern_edges)

    # ==========================================================
    # 5. 构建图 - 跨链交互 (Cross-chain)
    # ==========================================================

    # Deposit: EmittingBlock -> Relayer
    if emitting_blocks:
        # 确保去重并转为字符串
        emit_edges = [(str(blk), "relayer") for blk in set(emitting_blocks)]
        G.add_edges_from(emit_edges)

    # Withdraw: Relayer -> InformingBlock
    if informing_blocks:
        inform_edges = [("relayer", str(blk)) for blk in set(informing_blocks)]
        G.add_edges_from(inform_edges)

    logger.info("🎯 合约全局控制流图构建完成！")
    return G, emitting_events, informing_events


def build_fcg(artifacts_path, df_functionCall, df_block_in_func, emitting_events, informing_events):
    logger.info("针对跨链event，开始构建函数级调用图")
    # print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
    functioncalls = df_functionCall
    block_func_relations = df_block_in_func

    block_to_func = dict(zip(block_func_relations.iloc[:, 0], block_func_relations.iloc[:, 1]))

    Call_G = nx.DiGraph()  # 创建有向图

    for m in range(len(functioncalls)):
        # 假设 csv 格式为: CallerBlock \t CalleeBlock
        caller_blk = functioncalls.iloc[m, 0]
        callee_blk = functioncalls.iloc[m, 1]

        # 快速查找对应的函数名
        caller_func = block_to_func.get(caller_blk, "0")
        callee_func = block_to_func.get(callee_blk, "0")

        if caller_func != "0" and callee_func != "0" and caller_func != callee_func:
            Call_G.add_edge(caller_func, callee_func)

    # emitting_events, informing_events = analyze_events(events, artifacts_path)

    # 处理 Deposit (Emitting) -> Relayer
    emitting_funcs = convert_events_to_func(block_func_relations, emitting_events)
    # print(emitting_funcs)

    # 处理 Withdrawal (Informing) -> Client
    informing_funcs = convert_events_to_func(block_func_relations, informing_events)
    # print(informing_funcs)

    logger.info("🎯 函数级调用图构建完成！")

    return Call_G, emitting_funcs, informing_funcs


def build_data_dependency_graph(df_defines, df_uses):
    """
        通过 Def 和 Use 构建语句级别的数据依赖图 (DDG)
        """
    logger.info("开始构建数据流依赖图")
    df_def = df_defines
    df_use = df_uses

    # 我们要找的是: Stmt_A 定义了 var_X，Stmt_B 使用了 var_X
    # 那么就存在一条数据流边: Stmt_A -> Stmt_B
    # 相当于 SQL: SELECT A.stmt_id as from_stmt, B.stmt_id as to_stmt FROM df_def A JOIN df_use B ON A.var_id = B.var_id
    df_flow = pd.merge(df_def, df_use, on='var', suffixes=('_def', '_use'))

    # 构建有向图
    DDG = nx.DiGraph()
    edges = list(zip(df_flow['stmtID_def'], df_flow['stmtID_use']))
    DDG.add_edges_from(edges)

    logger.info("🎯 数据流依赖图构建完成！")

    return DDG


def get_true_auth_blocks_with_debug(DDG, df_opcodes, df_stmt_block, debug_limit=60):
    """
    带调试功能的数据流跟踪，打印具体的污点传播路径
    """
    # 1. 加载映射并创建一个方便查询的字典: stmt_id -> opcode
    df_opcode = df_opcodes
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmt')['opcode'].to_dict()

    df_block = df_stmt_block

    # 2. 定义 Sources 和 Sinks
    sources_df = df_opcode[df_opcode['opcode'].isin(['CALLER', 'ORIGIN', 'SLOAD'])]
    source_stmts = set(sources_df['stmt'])
    sink_df = df_opcode[df_opcode['opcode'] == 'JUMPI']
    sink_stmts = set(sink_df['stmt'])

    COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}

    valid_sources = [s for s in source_stmts if s in DDG]
    valid_sinks = set([s for s in sink_stmts if s in DDG])

    print(f"[*] 开始数据流污点跟踪... (有效起点: {len(valid_sources)}, 有效终点: {len(valid_sinks)})\n")

    true_auth_stmts = set()
    precise_paths = []  # 存放符合严格条件的精细路径
    path_count = 0

    # 3. 寻找并打印路径
    for source in valid_sources:
        # 为了提高效率，先检查是否可达 (descendants 是轻量级的)
        reachable_stmts = nx.descendants(DDG, source)
        hit_sinks = reachable_stmts.intersection(valid_sinks)

        if not hit_sinks:
            continue

        true_auth_stmts.update(hit_sinks)

        # 针对每个命中的终点，提取具体路径进行打印
        for sink in hit_sinks:
            # 使用 cutoff 防止数据流图中的循环导致路径爆炸 (一般数据流深度不会超过 15)
            paths = nx.all_simple_paths(DDG, source=source, target=sink, cutoff=15)

            for path in paths:
                path_opcodes = [opcode_dict.get(stmt, "UNKNOWN") for stmt in path]

                # 【核心校验】: 这条路径必须包含比较指令，否则跳过！(过滤掉非条件校验的数据流)
                if not any(op in COMPARES for op in path_opcodes):
                    continue

                # 记录这是一条合法的鉴权路径
                true_auth_stmts.add(sink)
                precise_paths.append(path)

                path_count += 1
                if path_count <= debug_limit:
                    # 将 Statement ID 转换为带 Opcode 的易读格式
                    readable_path = []
                    for stmt in path:
                        op = opcode_dict.get(stmt, "UNKNOWN")
                        readable_path.append(f"[{op}]({stmt})")
                    print(f"🔍 发现鉴权路径 #{path_count}:")
                    print("  ->  ".join(readable_path))
                    print("-" * 60)


                elif path_count == debug_limit + 1:
                    print(f"... 调试输出已达到上限 ({debug_limit} 条)，隐藏剩余路径的打印以保持整洁 ...\n")

    # 4. 映射回 Block ID
    auth_blocks_df = df_block[df_block['stmt'].isin(true_auth_stmts)]
    TRUE_AUTH_BLOCKS = set(auth_blocks_df['block'].unique())

    return TRUE_AUTH_BLOCKS


def get_precise_auth_info(DDG, df_opcodes, df_stmt_block, debug_limit=60):
    """
    精确提取鉴权块，同时捕获比较指令和相关的 SLOAD
    result = get_precise_auth_info(ddg, df_opcodes, df_stmts_in_block)
    print(f"\n[+] 分析完毕！")
    print(f" - 发现合法鉴权路径数量: {result['path_count']}")
    print(f" - 提取出强关联的 AUTH_BLOCKS 数量: {len(result['auth_blocks'])}")
    print(f" - 捕获到用于鉴权的 SLOAD 语句数量: {len(result['sload_stmts'])}")
    """
    # 1. 基础映射准备
    df_opcode = df_opcodes
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmt')['opcode'].to_dict()
    df_block = df_stmt_block

    # 定义敏感指令集合
    SOURCES = {'CALLER', 'ORIGIN'}
    SINKS = {'JUMPI'}
    # 定义比较指令
    COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT', 'ISZERO'}

    source_stmts = set(df_opcode[df_opcode['opcode'].isin(SOURCES)]['stmt'])
    sink_stmts = set(df_opcode[df_opcode['opcode'].isin(SINKS)]['stmt'])

    valid_sources = [s for s in source_stmts if s in DDG]
    valid_sinks = set([s for s in sink_stmts if s in DDG])

    true_auth_stmts = set()
    extracted_sloads = set()  # 专门用来存放找出来的 SLOAD 语句
    precise_paths = []  # 存放符合严格条件的精细路径

    path_count = 0

    print(f"[*] 开始精准鉴权路径提取... \n")

    # 2. 遍历数据流路径
    for source in valid_sources:
        reachable = nx.descendants(DDG, source)
        hit_sinks = reachable.intersection(valid_sinks)

        for sink in hit_sinks:
            paths = nx.all_simple_paths(DDG, source=source, target=sink, cutoff=15)

            for path in paths:
                path_opcodes = [opcode_dict.get(stmt, "UNKNOWN") for stmt in path]

                # 【核心校验】: 这条路径必须包含比较指令，否则跳过！(过滤掉非条件校验的数据流)
                if not any(op in COMPARES for op in path_opcodes):
                    continue

                # 记录这是一条合法的鉴权路径
                true_auth_stmts.add(sink)
                precise_paths.append(path)

                # 【核心提取】: 找寻与比较相关的 SLOAD
                path_sloads_for_this_auth = set()

                for stmt in path:
                    op = opcode_dict.get(stmt, "UNKNOWN")

                    # 场景 A: SLOAD 本身就在路径中 (比如 require(balances[msg.sender] > 0))
                    if op == 'SLOAD':
                        path_sloads_for_this_auth.add(stmt)

                    # 场景 B: 遇到了比较指令，寻找它的其他输入端 (比如 require(msg.sender == owner))
                    elif op in COMPARES:
                        # 查找 DDG 中，指向这个比较指令的所有直接前驱节点
                        predecessors = list(DDG.predecessors(stmt))
                        for pred in predecessors:
                            pred_op = opcode_dict.get(pred, "UNKNOWN")
                            # 如果输入端是 SLOAD
                            if pred_op == 'SLOAD':
                                path_sloads_for_this_auth.add(pred)
                            # 如果输入端经过了 SHA3 (常见于读取 mapping 的情况)
                            elif pred_op == 'SHA3':
                                # 再往上找一层
                                for sha3_pred in DDG.predecessors(pred):
                                    if opcode_dict.get(sha3_pred) == 'SLOAD':
                                        path_sloads_for_this_auth.add(sha3_pred)

                # 将找到的 SLOAD 汇入全局集合
                extracted_sloads.update(path_sloads_for_this_auth)

                # ================= 调试打印 =================
                path_count += 1
                if path_count <= debug_limit:
                    readable_path = [f"[{opcode_dict.get(s, 'UNKNOWN')}]({s})" for s in path]
                    print(f"✅ 精确路径 #{path_count}:")
                    print("  ->  ".join(readable_path))
                    if path_sloads_for_this_auth:
                        sload_strs = [f"[SLOAD]({s})" for s in path_sloads_for_this_auth]
                        print(f"  📌 绑定的状态变量 (SLOAD): {', '.join(sload_strs)}")
                    else:
                        print("  📌 绑定的状态变量 (SLOAD): 无 (可能是常量或跨合约调用)")
                    print("-" * 60)

    # 3. 映射回 Block ID
    auth_blocks_df = df_block[df_block['stmt'].isin(true_auth_stmts)]
    TRUE_AUTH_BLOCKS = set(auth_blocks_df['block'].unique())

    # 将 SLOAD 映射回 Block ID (可选，如果你后续需要的话)
    sload_blocks_df = df_block[df_block['stmt'].isin(extracted_sloads)]
    SLOAD_BLOCKS = set(sload_blocks_df['block'].unique())

    return {
        "auth_blocks": TRUE_AUTH_BLOCKS,
        "sload_stmts": extracted_sloads,
        "sload_blocks": SLOAD_BLOCKS,
        "path_count": len(precise_paths)
    }


def extract_sload_to_jumpi_paths(DDG, df_opcodes, df_stmt_block, debug_limit=60):
    """
    直线提取：从 SLOAD 到 JUMPI，且必须包含比较指令的路径
    """
    # 1. 加载映射字典
    df_opcode = df_opcodes
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmt')['opcode'].to_dict()
    df_block = df_stmt_block

    # 2. 定义起点、终点和必须经过的比较指令
    COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}

    source_stmts = set(df_opcode[df_opcode['opcode'] == 'SLOAD']['stmt'])
    sink_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmt'])

    valid_sources = [s for s in source_stmts if s in DDG]
    valid_sinks = set([s for s in sink_stmts if s in DDG])

    true_auth_stmts = set()
    path_count = 0

    print(f"[*] 开始直线追踪: SLOAD -> 比较指令 -> JUMPI ...")
    print(f"    (有效 SLOAD 起点: {len(valid_sources)}, 有效 JUMPI 终点: {len(valid_sinks)})\n")

    # 3. 遍历提取
    for source in valid_sources:
        # 快速判断可达性，减少不必要的路径搜索
        reachable = nx.descendants(DDG, source)
        hit_sinks = reachable.intersection(valid_sinks)

        if not hit_sinks:
            continue

        for sink in hit_sinks:
            # 搜索简单路径
            paths = nx.all_simple_paths(DDG, source=source, target=sink, cutoff=15)

            for path in paths:
                # 把路径上的 Statement 翻译成 Opcode
                path_opcodes = [opcode_dict.get(stmt, "UNKNOWN") for stmt in path]

                # 【核心校验】如果路径里没有比较指令，直接丢弃
                if not any(op in COMPARES for op in path_opcodes):
                    continue

                # 记录合法的鉴权 JUMPI 语句
                true_auth_stmts.add(sink)
                path_count += 1

                # 打印调试信息
                if path_count <= debug_limit:
                    readable_path = [f"[{opcode_dict.get(s, 'UNKNOWN')}]({s})" for s in path]
                    print(f"🔍 鉴权路径 #{path_count}:")
                    print("  ->  ".join(readable_path))
                    print("-" * 60)

    # 4. 将合法的 JUMPI 语句映射回 Block ID
    auth_blocks_df = df_block[df_block['stmt'].isin(true_auth_stmts)]
    TRUE_AUTH_BLOCKS = set(auth_blocks_df['block'].unique())

    if path_count > debug_limit:
        print(f"... 已隐藏后续 {path_count - debug_limit} 条路径的打印 ...\n")

    return TRUE_AUTH_BLOCKS


def extract_caller_to_jumpi_paths(DDG, df_opcodes, df_stmt_block, debug_limit=60):
    """
    直线提取：从 SLOAD 到 JUMPI，且必须包含比较指令的路径
    """
    # 1. 加载映射字典
    df_opcode = df_opcodes
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmt')['opcode'].to_dict()
    df_block = df_stmt_block

    # 2. 定义起点、终点和必须经过的比较指令
    COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}

    sources_df = df_opcode[df_opcode['opcode'].isin(['CALLER', 'ORIGIN'])]
    source_stmts = set(sources_df['stmt'])

    # source_stmts = set(df_opcode[df_opcode['opcode'] == 'CALLER']['stmt'])
    sink_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmt'])

    valid_sources = [s for s in source_stmts if s in DDG]
    valid_sinks = set([s for s in sink_stmts if s in DDG])

    true_auth_stmts = set()
    path_count = 0

    print(f"[*] 开始直线追踪: SLOAD -> 比较指令 -> JUMPI ...")
    print(f"    (有效 SLOAD 起点: {len(valid_sources)}, 有效 JUMPI 终点: {len(valid_sinks)})\n")

    # 3. 遍历提取
    for source in valid_sources:
        # 快速判断可达性，减少不必要的路径搜索
        reachable = nx.descendants(DDG, source)
        hit_sinks = reachable.intersection(valid_sinks)

        if not hit_sinks:
            continue

        for sink in hit_sinks:
            # 搜索简单路径
            paths = nx.all_simple_paths(DDG, source=source, target=sink, cutoff=15)

            for path in paths:
                # 把路径上的 Statement 翻译成 Opcode
                path_opcodes = [opcode_dict.get(stmt, "UNKNOWN") for stmt in path]

                # 【核心校验】如果路径里没有比较指令，直接丢弃
                if not any(op in COMPARES for op in path_opcodes):
                    continue

                # 记录合法的鉴权 JUMPI 语句
                true_auth_stmts.add(sink)
                path_count += 1

                # 打印调试信息
                if path_count <= debug_limit:
                    readable_path = [f"[{opcode_dict.get(s, 'UNKNOWN')}]({s})" for s in path]
                    print(f"🔍 鉴权路径 #{path_count}:")
                    print("  ->  ".join(readable_path))
                    print("-" * 60)

    # 4. 将合法的 JUMPI 语句映射回 Block ID
    auth_blocks_df = df_block[df_block['stmt'].isin(true_auth_stmts)]
    TRUE_AUTH_BLOCKS = set(auth_blocks_df['block'].unique())

    if path_count > debug_limit:
        print(f"... 已隐藏后续 {path_count - debug_limit} 条路径的打印 ...\n")

    return TRUE_AUTH_BLOCKS


def extract_function_args_to_jumpi(DDG, df_defines, df_publicArgs, df_opcodes, df_stmt_block, debug_limit=155):
    """
    基于 PublicFunctionArg 进行高级语义追踪：函数参数 -> 比较指令 -> JUMPI
    """
    # 1. 基础映射
    df_opcode = df_opcodes
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmt')['opcode'].to_dict()
    df_block = df_stmt_block

    # 2. 解析 PublicFunctionArg (获取：函数、参数索引、变量ID)
    # 注意：列名可能因 Gigahorse 版本不同略有差异，通常是这三列
    df_pub_args = df_publicArgs

    # 3. 找到定义这些参数变量的 Statement ID (将其作为追踪起点)
    df_def = df_defines

    # 将参数变量映射到对应的定义语句 (Statement)
    # 相当于 SQL: SELECT stmt_id, func_id, arg_index FROM df_def JOIN df_pub_args ON var_id
    args_sources_df = pd.merge(df_pub_args, df_def, on='var')

    # 建立一个字典，方便打印时知道这个语句代表哪个函数的哪个参数
    source_to_info = {}
    print("合并后的 DataFrame 列名有:", args_sources_df.columns)
    for _, row in args_sources_df.iterrows():
        source_to_info[row['stmt']] = f"函数[{row['func_entry_block']}] 的参数[{row['index_x']}]"

    source_stmts = set(args_sources_df['stmt'])

    # 4. 定义终点和校验规则
    sink_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmt'])
    COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT', 'ISZERO'}

    valid_sources = [s for s in source_stmts if s in DDG]
    valid_sinks = set([s for s in sink_stmts if s in DDG])

    true_args_check_stmts = set()
    path_count = 0

    print(f"[*] 开始高级语义追踪: 函数参数(PublicFunctionArg) -> 比较 -> JUMPI ...")
    print(f"    (找到的有效参数起点: {len(valid_sources)} 个)\n")

    # 在循环开始前，增加一个集合用来记录已经打印过的 JUMPI
    printed_sinks = set()
    path_count = 0

    for source in valid_sources:
        reachable = nx.descendants(DDG, source)
        hit_sinks = reachable.intersection(valid_sinks)

        if not hit_sinks:
            continue

        for sink in hit_sinks:
            # ==== 核心改动 1：去重，如果这个 JUMPI 已经分析过并打印了，就跳过 ====
            if sink in printed_sinks:
                continue

            paths = nx.all_simple_paths(DDG, source=source, target=sink, cutoff=15)

            for path in paths:
                path_opcodes = [opcode_dict.get(stmt, "UNKNOWN") for stmt in path]

                if not any(op in COMPARES for op in path_opcodes):
                    continue

                # 记录为有效的鉴权块
                true_args_check_stmts.add(sink)

                # ==== 核心改动 2：视觉净化，在打印字符串中剔除 PHI 节点 ====
                readable_path = []
                for s, op in zip(path, path_opcodes):
                    if op != 'PHI':  # 只有不是 PHI 时才加入打印列表
                        readable_path.append(f"[{op}]({s})")

                path_count += 1
                if path_count <= debug_limit:
                    arg_info = source_to_info.get(source, "未知参数")
                    print(f"🌟 独立参数校验点 #{path_count}:")
                    print(f"  📌 来源: {arg_info}")
                    print("  ->  ".join(readable_path))
                    print("-" * 60)

                # 标记这个 sink (JUMPI) 已经处理过了，跳出当前 paths 循环，不再看其他到达这里的路径
                printed_sinks.add(sink)
                break

    # 6. 映射回 Block ID
    auth_blocks_df = df_block[df_block['stmt'].isin(true_args_check_stmts)]
    ARGS_CHECK_BLOCKS = set(auth_blocks_df['block'].unique())

    if path_count > debug_limit:
        print(f"... 已隐藏后续 {path_count - debug_limit} 条路径的打印 ...\n")

    return ARGS_CHECK_BLOCKS


def extract_arg_state_rendezvous(DDG, df_def, df_pub_args, df_opcode, df_block):
    """
    终极语义提取：寻找 SLOAD 和 Args(参数) 数据流交汇的比较指令，并确认其流入 JUMPI。
    """
    logger.info("开始基于 SLOAD 和 Args(参数) 数据流交汇的比较指令进行守护区块提取")
    # 1. 基础映射准备
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmtID')['opcode'].to_dict()
    df_block_dict = df_block.set_index('stmtID')['blockID'].to_dict()

    # 2. 提取 SLOAD 起点
    sload_stmts = set(df_opcode[df_opcode['opcode'] == 'SLOAD']['stmtID'])
    valid_sloads = [s for s in sload_stmts if s in DDG]

    # 3. 提取 Args 起点 (带有高级语义)
    args_sources_df = pd.merge(df_pub_args, df_def, on='var')
    valid_args = []
    arg_to_info = {}
    for _, row in args_sources_df.iterrows():
        stmt = row['stmtID']
        if stmt in DDG:
            valid_args.append(stmt)
            # 兼容之前合并产生的 index_x
            arg_num = row.get('index_x', row.get('index', '?'))
            arg_to_info[stmt] = f"函数[{row['func_entry_block']}] 的参数[{arg_num}]"

    # 4. 定义目标：二元比较指令 和 JUMPI
    # 注意：ISZERO 是单元的，通常在比较之后，所以真正的交汇点一定是下面这些二元操作符
    BINARY_COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}
    jumpi_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmtID'])
    valid_jumpis = set([s for s in jumpi_stmts if s in DDG])

    # print(f"[*] 开始进行数据流交汇分析 (Rendezvous Analysis)...")
    # print(f"    - SLOAD 起点: {len(valid_sloads)} 个")
    # print(f"    - Args  起点: {len(valid_args)} 个\n")
    logger.info("[*] 开始进行数据流交汇分析 (Rendezvous Analysis)...")
    logger.info("    - SLOAD 起点: %s 个", len(valid_sloads))
    logger.info("    - Args  起点: %s 个", len(valid_args))
    # 5. 分别计算 SLOAD 和 Args 能到达的比较指令
    sload_to_compares = {}  # 比较指令 -> 哪些 SLOAD 到达了它
    for sload in valid_sloads:
        for desc in nx.descendants(DDG, sload):
            if opcode_dict.get(desc) in BINARY_COMPARES:
                sload_to_compares.setdefault(desc, set()).add(sload)

    args_to_compares = {}  # 比较指令 -> 哪些 Args 到达了它
    for arg in valid_args:
        for desc in nx.descendants(DDG, arg):
            if opcode_dict.get(desc) in BINARY_COMPARES:
                args_to_compares.setdefault(desc, set()).add(arg)

    # ================= 核心：寻找交汇点 (Intersection) =================
    # 只要一个比较指令既在 sload_to_compares 里，又在 args_to_compares 里，它就是我们要找的！
    shared_compares = set(sload_to_compares.keys()).intersection(set(args_to_compares.keys()))

    true_auth_blocks = set()
    found_count = 0

    for comp_stmt in shared_compares:
        # 验证这个交汇点是否最终流入了 JUMPI (防止死代码或无意义的比较)
        reachable_from_comp = nx.descendants(DDG, comp_stmt)
        hit_jumpis = reachable_from_comp.intersection(valid_jumpis)

        if not hit_jumpis:
            continue  # 没有流入 JUMPI，说明不是条件分支，跳过

        # 记录成功的 Block
        for j in hit_jumpis:
            if j in df_block_dict:
                true_auth_blocks.add(df_block_dict[j])

        found_count += 1
        comp_op = opcode_dict.get(comp_stmt)

        # 获取具体的来源信息用于打印
        sloads_involved = sload_to_compares[comp_stmt]
        args_involved = args_to_compares[comp_stmt]

        arg_descriptions = [arg_to_info.get(a, "未知参数") for a in args_involved]
        sload_descriptions = [f"[SLOAD]({s})" for s in sloads_involved]
        jumpi_descriptions = [f"[JUMPI]({j})" for j in hit_jumpis]

        # 打印语义
        # print(f"🎯 完美安全校验 (参数 vs 状态) #{found_count}:")
        # print(f"  📌 业务逻辑: 正在将 {', '.join(arg_descriptions)} ")
        # print(f"               与 {', '.join(sload_descriptions)} 进行比较！")
        # print(f"  ⚔️ 交汇指令: [{comp_op}]({comp_stmt})")
        # print(f"  🛡️ 守护区块: 跳转判断 {', '.join(jumpi_descriptions)}")
        # print("-" * 70)
        logger.debug("提取到的守护区块")
        logger.debug("🎯 安全校验 (参数 vs 状态) #%s:", found_count)
        logger.debug("📌 业务逻辑: 正在将: %s 与 %s 进行比较！", ', '.join(arg_descriptions), ', '.join(sload_descriptions))
        logger.debug("⚔️ 交汇指令: [%s](%s)", comp_op, comp_stmt)
        logger.debug("🛡️ 守护区块: 跳转判断 %s", ', '.join(jumpi_descriptions))
        logger.debug("-" * 70)

    # print(f"\n[+] 交汇分析完毕！共发现 {found_count} 个极高置信度的业务逻辑校验点。")
    logger.info("[+] SLOAD 和 Args(参数) 数据流交汇分析完毕！共发现 %s 个极高置信度的业务逻辑校验点。", found_count)
    return true_auth_blocks


def extract_caller_state_rendezvous(DDG, df_opcode, df_block):
    """
    经典权限提取：寻找 SLOAD 和 CALLER 数据流交汇的比较指令，并确认其流入 JUMPI。
    (捕获 msg.sender == owner 模式)
    """
    logger.info("开始基于 SLOAD 和 CALLER 数据流交汇的比较指令进行守护区块提取")
    # 1. 基础映射准备
    # 确保 opcode 转为大写并去除了空白字符
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmtID')['opcode'].to_dict()
    df_block_dict = df_block.set_index('stmtID')['blockID'].to_dict()

    # 2. 提取 SLOAD 起点
    sload_stmts = set(df_opcode[df_opcode['opcode'] == 'SLOAD']['stmtID'])
    valid_sloads = [s for s in sload_stmts if s in DDG]

    # 3. 提取 CALLER / ORIGIN 起点
    # 在有些恶意合约或特定业务中，也会用 tx.origin 进行鉴权
    caller_stmts = set(df_opcode[df_opcode['opcode'].isin(['CALLER', 'ORIGIN'])]['stmtID'])
    valid_callers = [s for s in caller_stmts if s in DDG]

    # 4. 定义目标：二元比较指令 和 JUMPI
    # EQ (等于) 是权限校验中最常见的
    BINARY_COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}
    jumpi_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmtID'])
    valid_jumpis = set([s for s in jumpi_stmts if s in DDG])

    # print(f"[*] 开始经典权限交汇分析 (msg.sender vs SLOAD) ...")
    # print(f"    - SLOAD  起点: {len(valid_sloads)} 个")
    # print(f"    - CALLER 起点: {len(valid_callers)} 个\n")
    logger.info("[*] 开始经典权限交汇分析 (msg.sender vs SLOAD) ...")
    logger.info("    - SLOAD  起点: %s 个", len(valid_sloads))
    logger.info("    - CALLER 起点: %s 个", len(valid_callers))

    # 5. 分别计算 SLOAD 和 CALLER 能到达的比较指令
    sload_to_compares = {}  # 比较指令 -> 哪些 SLOAD 到达了它
    for sload in valid_sloads:
        for desc in nx.descendants(DDG, sload):
            if opcode_dict.get(desc) in BINARY_COMPARES:
                sload_to_compares.setdefault(desc, set()).add(sload)

    caller_to_compares = {}  # 比较指令 -> 哪些 CALLER 到达了它
    for caller in valid_callers:
        for desc in nx.descendants(DDG, caller):
            if opcode_dict.get(desc) in BINARY_COMPARES:
                caller_to_compares.setdefault(desc, set()).add(caller)

    # ================= 核心：寻找交汇点 (Intersection) =================
    # 只要一个比较指令既在 sload_to_compares 里，又在 caller_to_compares 里，它就是权限控制！
    shared_compares = set(sload_to_compares.keys()).intersection(set(caller_to_compares.keys()))

    true_auth_blocks = set()
    found_count = 0

    for comp_stmt in shared_compares:
        # 验证这个交汇点是否最终流入了 JUMPI
        reachable_from_comp = nx.descendants(DDG, comp_stmt)
        hit_jumpis = reachable_from_comp.intersection(valid_jumpis)

        if not hit_jumpis:
            continue  # 死代码，跳过

        # 记录成功的 Block
        for j in hit_jumpis:
            if j in df_block_dict:
                true_auth_blocks.add(df_block_dict[j])

        found_count += 1
        comp_op = opcode_dict.get(comp_stmt)

        # 获取具体的来源信息用于打印
        sloads_involved = sload_to_compares[comp_stmt]
        callers_involved = caller_to_compares[comp_stmt]

        caller_descriptions = [f"[{opcode_dict.get(c)}]({c})" for c in callers_involved]
        sload_descriptions = [f"[SLOAD]({s})" for s in sloads_involved]
        jumpi_descriptions = [f"[JUMPI]({j})" for j in hit_jumpis]

        # 打印直观的安全语义
        # print(f"👑 身份鉴权点 (CALLER vs 状态) #{found_count}:")
        # print(f"  📌 身份提取: {', '.join(caller_descriptions)}")
        # print(f"  📌 状态读取: {', '.join(sload_descriptions)}")
        # print(f"  ⚔️ 交汇比对: [{comp_op}]({comp_stmt})")
        # print(f"  🛡️ 守护区块: 跳转判断 {', '.join(jumpi_descriptions)}")
        # print("-" * 70)

        logger.debug("提取到的守护区块")
        logger.debug("👑 身份鉴权点 (CALLER vs 状态) #%s:", found_count)
        logger.debug("  📌 身份提取: %s", ', '.join(caller_descriptions))
        logger.debug("  📌 状态读取: %s", ', '.join(sload_descriptions))
        logger.debug("⚔️ 交汇指令: [%s](%s)", comp_op, comp_stmt)
        logger.debug("🛡️ 守护区块: 跳转判断 %s", ', '.join(jumpi_descriptions))
        logger.debug("-" * 70)

    # print(f"\n[+] 身份鉴权提取完毕！共发现 {found_count} 个基于调用者的严格身份校验点。")
    logger.info("[+] 身份鉴权提取完毕！共发现 %s 个基于调用者的严格身份校验点。", found_count)

    # === 补充：Mapping (白名单) 模式检查 ===
    # print("\n[*] 正在补充检查 Mapping 模式 (如 whitelist[msg.sender]) ...")
    logger.info("[*] 正在补充检查 Mapping 模式 (如 whitelist[msg.sender]) ...")

    # CALLER 到 JUMPI 的所有路线
    caller_to_jumpis = set()
    for caller in valid_callers:
        hit = nx.descendants(DDG, caller).intersection(valid_jumpis)
        caller_to_jumpis.update(hit)

    # SLOAD 到 JUMPI 的所有路线
    sload_to_jumpis = set()
    for sload in valid_sloads:
        hit = nx.descendants(DDG, sload).intersection(valid_jumpis)
        sload_to_jumpis.update(hit)

    # 直接在 JUMPI 处交汇！
    mapping_auth_jumpis = caller_to_jumpis.intersection(sload_to_jumpis)

    # 排除已经通过二元比较找到的，剩下的就是 Mapping 模式独有的
    pure_mapping_jumpis = mapping_auth_jumpis - set(
        [j for sinks in [nx.descendants(DDG, c).intersection(valid_jumpis) for c in shared_compares] for j in sinks])

    for j in pure_mapping_jumpis:
        if j in df_block_dict:
            true_auth_blocks.add(df_block_dict[j])
        # print(f"📖 发现映射鉴权点 (Mapping Check) 流向: [JUMPI]({j})")
        logger.info("📖 发现映射鉴权点 (Mapping Check) 流向: [JUMPI](%s)", j)

    # print(f"[+] 补充发现 {len(pure_mapping_jumpis)} 个 Mapping 鉴权点。")
    logger.info("[+] 补充发现 %s 个 Mapping 鉴权点。", len(pure_mapping_jumpis))

    logger.info("[+] SLOAD 和 CALLER 数据流交汇分析完毕！")
    return true_auth_blocks


def extract_value_state_rendezvous(DDG, df_opcode, df_block):
    """
    资金约束提取：寻找 (SLOAD / CALL / MLOAD) 与 msg.value 交汇的比较指令。
    捕获内部状态、外部配置拉取、内存参数的资金校验
    """
    logger.info("开始基于 (SLOAD / CALL / MLOAD) 与 msg.value 数据流交汇的比较指令进行守护区块提取")
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmtID')['opcode'].to_dict()
    df_block_dict = df_block.set_index('stmtID')['blockID'].to_dict()

    # ================= 核心修复 =================
    # 增加 MLOAD (捕获外部调用解码后的值)
    # 增加 RETURNDATASIZE (有的极简合约直接比较返回大小)
    STATE_OPCODES = {'SLOAD', 'CALL', 'STATICCALL', 'MLOAD', 'RETURNDATASIZE'}
    state_stmts = set(df_opcode[df_opcode['opcode'].isin(STATE_OPCODES)]['stmtID'])
    valid_states = [s for s in state_stmts if s in DDG]
    # ============================================

    value_stmts = set(df_opcode[df_opcode['opcode'] == 'CALLVALUE']['stmtID'])
    valid_values = [s for s in value_stmts if s in DDG]

    BINARY_COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}
    jumpi_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmtID'])
    valid_jumpis = set([s for s in jumpi_stmts if s in DDG])

    # print(f"[*] 开始资金交汇分析 (跨越内存断层) ...")
    logger.info("开始资金交汇分析 (跨越内存断层) ..")

    # 寻路
    state_to_compares = {}
    for state in valid_states:
        for desc in nx.descendants(DDG, state):
            if opcode_dict.get(desc) in BINARY_COMPARES:
                state_to_compares.setdefault(desc, set()).add(state)

    value_to_compares = {}
    for val in valid_values:
        for desc in nx.descendants(DDG, val):
            if opcode_dict.get(desc) in BINARY_COMPARES:
                value_to_compares.setdefault(desc, set()).add(val)

    # 交汇
    shared_compares = set(state_to_compares.keys()).intersection(set(value_to_compares.keys()))

    true_auth_blocks = set()
    found_count = 0

    for comp_stmt in shared_compares:
        reachable_from_comp = nx.descendants(DDG, comp_stmt)
        hit_jumpis = reachable_from_comp.intersection(valid_jumpis)

        if not hit_jumpis:
            continue

        for j in hit_jumpis:
            if j in df_block_dict:
                true_auth_blocks.add(df_block_dict[j])

        found_count += 1
        comp_op = opcode_dict.get(comp_stmt)

        states_involved = state_to_compares[comp_stmt]
        values_involved = value_to_compares[comp_stmt]

        value_descriptions = [f"[CALLVALUE]({v})" for v in values_involved]

        state_descriptions = []
        for s in states_involved:
            op = opcode_dict.get(s)
            if op == 'MLOAD':
                state_descriptions.append(f"[内存提取/外部返回值 MLOAD]({s})")
            else:
                state_descriptions.append(f"[{op}]({s})")

        jumpi_descriptions = [f"[JUMPI]({j})" for j in hit_jumpis]

        # print(f"💎 业务约束点 #{found_count}:")
        # print(f"  📌 传入资金: {', '.join(value_descriptions)}")
        # print(f"  📌 对照标准: {', '.join(state_descriptions)}")
        # print(f"  ⚖️ 交汇比对: [{comp_op}]({comp_stmt})")
        # print(f"  🛡️ 守护区块: 跳转判断 {', '.join(jumpi_descriptions)}")
        # print("-" * 70)

        logger.debug("提取到的守护区块")
        logger.debug("💎 业务约束点 #%s:", found_count)
        logger.debug("  📌 传入资金: %s", ', '.join(value_descriptions))
        logger.debug("  📌 对照标准: %s", ', '.join(state_descriptions))
        logger.debug("⚔️ 交汇比对: [%s](%s)", comp_op, comp_stmt)
        logger.debug("🛡️ 守护区块: 跳转判断 %s", ', '.join(jumpi_descriptions))
        logger.debug("-" * 70)


    # print(f"\n[+] 提取完毕！共发现 {found_count} 个约束点。")

    logger.info("[+] (SLOAD / CALL / MLOAD) 与 msg.value 数据流交汇分析完毕！共发现 %s 个约束点。", found_count)
    return true_auth_blocks

# 宽松的检查块提取方法
def extract_predicate_slices(DDG, df_opcode, df_block, sload_semantics_dict, const_value_dict):
    """
    基于向后切片 (Backward Slicing) 提取所有依赖关键变量的条件谓词区域。
    """
    logger.info("开始基于JUMPI语句进行守护区块提取")
    df_opcode['opcode'] = df_opcode['opcode'].astype(str).str.strip().str.upper()
    opcode_dict = df_opcode.set_index('stmtID')['opcode'].to_dict()
    df_block_dict = df_block.set_index('stmtID')['blockID'].to_dict()
    checkBlock_des_dict = dict()
    # diagnose_jumpi(DDG, opcode_dict, '0xec1')
    # 1. 定义我们关心的所有关键数据源
    CRITICAL_SOURCES = {'CALLER', 'ORIGIN', 'CALLVALUE', 'SLOAD', 'CALLDATALOAD', 'CALLDATACOPY', 'CALL', 'STATICCALL', 'CALLPRIVATE'}
    logger.info("关键数据源：CALLER, ORIGIN, CALLVALUE, SLOAD, CALLDATALOAD, CALLDATACOPY, CALL, STATICCALL")
    source_stmts = set(df_opcode[df_opcode['opcode'].isin(CRITICAL_SOURCES)]['stmtID'])
    valid_sources = [s for s in source_stmts if s in DDG]

    jumpi_stmts = set(df_opcode[df_opcode['opcode'] == 'JUMPI']['stmtID'])
    valid_jumpis = set([s for s in jumpi_stmts if s in DDG])

    # 2. 前向追踪：找到所有受关键变量影响的 JUMPI
    affected_jumpis = set()
    for source in valid_sources:
        hit_jumpis = nx.descendants(DDG, source).intersection(valid_jumpis)
        affected_jumpis.update(hit_jumpis)

    logger.info("[*] 发现 %s 个受关键数据影响的条件跳转 (JUMPI)。", len(affected_jumpis))
    # print(f"[*] 发现 {len(affected_jumpis)} 个受关键数据影响的条件跳转 (JUMPI)。")
    # print(f"[*] 正在进行向后切片 (Backward Slicing) 提取谓词区域...\n")
    logger.info("开始进行向后切片 (Backward Slicing) 提取谓词区域...")
    extracted_predicates = []

    # 3. 后向切片：提取决策该 JUMPI 的所有指令
    for jumpi in affected_jumpis:
        # nx.ancestors 返回所有能流向该 JUMPI 的节点
        ancestors = nx.ancestors(DDG, jumpi)

        # 将 JUMPI 自身也加入切片
        slice_nodes = set(ancestors)
        slice_nodes.add(jumpi)

        # 提取切片的子图 (这就是完整的“谓词区域”)
        predicate_subgraph = DDG.subgraph(slice_nodes)

        # 统计这个切片中包含哪些关键数据源
        involved_sources = slice_nodes.intersection(valid_sources)
        involved_opcodes = [opcode_dict.get(s) for s in involved_sources]

        # ==== 轻量级噪音过滤策略 ====
        # 如果切片中只包含 CALLDATALOAD，且没有 SLOAD/CALLER/CALLVALUE
        # 这极有可能是 数组长度检查(循环) 或 纯参数检查(非权限)
        is_only_args = all(op in {'CALLDATALOAD', 'CALLDATACOPY'} for op in involved_opcodes)
        if is_only_args:
            # 你可以选择记录下来，但赋予较低的置信度，或者直接跳过
            continue

        # semantic_summary = analyze_slice_semantics(predicate_subgraph, jumpi, DDG, opcode_dict)
        # semantic_summary = analyze_slice_semantics_accurate(predicate_subgraph, jumpi, DDG, opcode_dict, sload_semantics_dict)
        semantic_summary = analyze_slice_semantics_accurate_with_const(predicate_subgraph, jumpi, DDG, opcode_dict,
                                                            sload_semantics_dict, const_value_dict)
            # 记录切片信息
        block_id = df_block_dict.get(jumpi)
        extracted_predicates.append({
            'jumpi_stmt': jumpi,
            'block_id': block_id,
            'involved_sources': involved_opcodes,
            'slice_size': len(slice_nodes),  # 切片包含的指令数量
            'graph': predicate_subgraph
        })

        # 打印直观的谓词构成
        source_str = ", ".join(set(involved_opcodes))
        # print(f"🎯 提取谓词区域 (守护区块: {block_id}):")
        # print(f"  📌 业务约束逻辑: {semantic_summary}")
        # print(f"  📌 驱动此判断的数据源: {source_str}")
        # print(f"  📌 谓词复杂度: {len(slice_nodes)} 条指令")
        # print("-" * 60)
        des = f"业务约束逻辑: {semantic_summary},"+f"驱动此判断的数据源: {source_str},"
        checkBlock_des_dict.setdefault(block_id, des)

        logger.debug("提取到的守护区块")
        logger.debug("🎯 提取谓词区域 (守护区块: %s):", block_id)
        logger.debug("📌 业务约束逻辑: %s", semantic_summary)
        logger.debug("📌 驱动此判断的数据源: %s", source_str)
        logger.debug("📌 谓词复杂度: %s", len(slice_nodes))
        logger.debug("-" * 60)

    # 提取所有合法的 Block ID
    auth_blocks = set(p['block_id'] for p in extracted_predicates if p['block_id'])

    # print(f"\n[+] 切片提取完毕！共输出 {len(auth_blocks)} 个宽松但有效的守护区块 (AUTH_BLOCKS)。")
    logger.info("[+] 切片提取完毕！共输出 %s 个宽松但有效的守护区块 (AUTH_BLOCKS)。", len(auth_blocks))
    return auth_blocks, checkBlock_des_dict

def diagnose_jumpi(DDG, opcode_dict, target_jumpi_stmt):
    print(f"\n[诊断] 正在分析目标 JUMPI: {target_jumpi_stmt}")

    if target_jumpi_stmt not in DDG:
        print("错误：该 JUMPI 不在数据依赖图中！")
        return

    ancestors = nx.ancestors(DDG, target_jumpi_stmt)
    ancestor_opcodes = set()

    for a in ancestors:
        op = opcode_dict.get(a, "UNKNOWN")
        ancestor_opcodes.add(op)

    print(f"该 JUMPI 的所有上游指令种类: {ancestor_opcodes}")

    CRITICAL = {'CALLER', 'ORIGIN', 'CALLVALUE', 'SLOAD', 'CALLDATALOAD', 'CALLDATACOPY', 'CALL', 'STATICCALL', 'MLOAD'}
    hits = ancestor_opcodes.intersection(CRITICAL)
    print(f"命中的关键数据源: {hits}")


def analyze_slice_semantics_accurate_with_const(predicate_subgraph, jumpi_stmt, DDG, opcode_dict, sload_semantics_dict,
                                                const_value_dict):
    """
    终极解析器：支持边界阻断，支持 SLOAD 语义恢复，支持 CONST 值提取！
    """
    if const_value_dict is None:
        const_value_dict = {}

    BINARY_COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}

    STATIC_SEMANTIC_SOURCES = {
        'CALLER': 'msg.sender',
        'ORIGIN': 'tx.origin',
        'CALLVALUE': 'msg.value',
        'CALLDATALOAD': 'Args',
        'CALLDATACOPY': 'Args',
        'MLOAD': 'Memory_Variable/Array_Length'
    }

    # ================= 核心：带常量提取的 BFS 边界追踪器 =================
    # ================= 核心：带严格常量过滤的 BFS 边界追踪器 =================
    def trace_semantic_boundary(start_node):
        queue = [start_node]
        visited = set()
        found_semantics = set()

        # 【核心修复 1】：只检查起点 (start_node) 是不是 CONST
        # 如果起点就是 CONST (例如 EQ v1, CONST)，这才是真正的硬编码比较值！
        direct_const_val = None
        if opcode_dict.get(start_node) == 'CONST':
            direct_const_val = const_value_dict.get(start_node)

        while queue:
            curr = queue.pop(0)
            if curr in visited:
                continue
            visited.add(curr)

            op = opcode_dict.get(curr, "UNKNOWN")

            if op == 'SLOAD':
                storage_name = sload_semantics_dict.get(curr, "Unknown_Slot")
                found_semantics.add(f"Storage[{storage_name}]")
                continue

            elif op in {'CALL', 'STATICCALL'}:
                found_semantics.add("External_Call")
                continue

            elif op in STATIC_SEMANTIC_SOURCES:
                found_semantics.add(STATIC_SEMANTIC_SOURCES[op])
                continue

            elif op == 'CONST':
                # 【核心修复 2】：在 BFS 遍历途中遇到的 CONST (非起点)，
                # 都是参与掩码/偏移计算的“工具常量”，直接忽略，不阻断回溯！
                pass

                # 继续向上回溯
            for pred in predicate_subgraph.predecessors(curr):
                queue.append(pred)

        # 结果汇总逻辑
        if not found_semantics:
            # 如果没有找到高维语义，优先看看起点是不是真正的常量
            if direct_const_val is not None:
                return f"CONST({direct_const_val})"

            # 如果起点不是常量，且没有高维语义 (比如上游是函数传进来的未知变量 v99c_0)
            return "Computed_Value"

        return " + ".join(list(found_semantics))

    # ============================================================

    # 1. 向上寻找核心比较指令
    current_nodes = list(predicate_subgraph.predecessors(jumpi_stmt))
    comparator_stmt = None
    comparator_op = None

    depth = 0
    while current_nodes and depth < 3:
        next_nodes = []
        for node in current_nodes:
            op = opcode_dict.get(node, "UNKNOWN")
            if op in BINARY_COMPARES:
                comparator_stmt = node
                comparator_op = op
                break
            if op in {'ISZERO', 'AND', 'OR', 'NOT'}:
                next_nodes.extend(list(predicate_subgraph.predecessors(node)))

        if comparator_stmt:
            break
        current_nodes = next_nodes
        depth += 1

    # 2. 如果找到了二元比较
    if comparator_stmt:
        operands = list(predicate_subgraph.predecessors(comparator_stmt))
        operand_semantics = []

        for operand in operands:
            sem = trace_semantic_boundary(operand)
            operand_semantics.append(sem)

        if len(operand_semantics) == 2:
            return f"[{operand_semantics[0]} {comparator_op} {operand_semantics[1]}]"
        elif len(operand_semantics) == 1:
            return f"[{operand_semantics[0]} {comparator_op} ?]"
        else:
            return f"[Complex_Comparison {comparator_op}]"

    # 3. 如果没找到二元比较 (布尔单目运算)
    else:
        boolean_sources = set()
        for pred in predicate_subgraph.predecessors(jumpi_stmt):
            sem = trace_semantic_boundary(pred)
            if sem != "Hardcoded_Constant" and not sem.startswith("CONST(") and sem != "Computed_Value":
                boolean_sources.add(sem)

        if boolean_sources:
            sources_str = ', '.join(boolean_sources)
            if "Storage" in sources_str or "Args" in sources_str or "msg." in sources_str:
                return f"[Existence/Non-Zero Check on: {sources_str}]"
            elif "External_Call" in sources_str:
                return f"[Success/Failure Check on: {sources_str}]"
            else:
                return f"[Boolean Check on: {sources_str}]"
        else:
            return "[Unknown Boolean Check]"

def analyze_slice_semantics_accurate(predicate_subgraph, jumpi_stmt, DDG, opcode_dict, sload_semantics_dict):
    """
    基于“语义边界阻断”的终极解析器。
    完美解决 CALL 参数、SLOAD 哈希计算中混入其他变量导致的语义漂移。
    """
    BINARY_COMPARES = {'EQ', 'LT', 'GT', 'SLT', 'SGT'}

    STATIC_SEMANTIC_SOURCES = {
        'CALLER': 'msg.sender',
        'ORIGIN': 'tx.origin',
        'CALLVALUE': 'msg.value',
        'CALLDATALOAD': 'Args',
        'CALLDATACOPY': 'Args',
        'MLOAD': 'Memory_Data'
    }

    # ================= 核心：局部 BFS 边界追踪器 =================
    def trace_semantic_boundary(start_node):
        """
        从某个操作数开始向上回溯，碰到高维语义节点就记录并停止该分支。
        """
        queue = [start_node]
        visited = set()
        found_semantics = set()

        while queue:
            curr = queue.pop(0)
            if curr in visited:
                continue
            visited.add(curr)

            op = opcode_dict.get(curr, "UNKNOWN")

            # 【边界 1】：如果碰到状态读取，立刻停止当前分支的向上探索
            if op == 'SLOAD':
                storage_name = sload_semantics_dict.get(curr, "Unknown_Slot")
                found_semantics.add(f"Storage[{storage_name}]")
                continue  # 核心！不把 predecessors 加入 queue，阻断回溯！

            # 【边界 2】：如果碰到外部调用，立刻停止
            elif op in {'CALL', 'STATICCALL'}:
                found_semantics.add("External_Call")
                continue  # 阻断回溯！不再去分析 CALL 的输入参数

            # 【普通语义】：如果是基础数据源，记录并停止
            elif op in STATIC_SEMANTIC_SOURCES:
                found_semantics.add(STATIC_SEMANTIC_SOURCES[op])
                continue

            # 【常量兜底】：如果是 CONST，我们不阻断（因为它可能是位掩码），留到最后判断
            elif op == 'CONST':
                pass

                # 如果是中间计算节点 (如 ADD, SHA3, ISZERO, AND)，继续向上回溯其前驱节点
            for pred in predicate_subgraph.predecessors(curr):
                queue.append(pred)

        # 结果汇总
        if not found_semantics:
            if any(opcode_dict.get(n) == 'CONST' for n in visited):
                return "Hardcoded_Constant"
            return "Computed_Value"

        return " + ".join(list(found_semantics))

    # ============================================================

    # 1. 向上寻找核心比较指令
    current_nodes = list(predicate_subgraph.predecessors(jumpi_stmt))
    comparator_stmt = None
    comparator_op = None

    depth = 0
    while current_nodes and depth < 3:
        next_nodes = []
        for node in current_nodes:
            op = opcode_dict.get(node, "UNKNOWN")
            if op in BINARY_COMPARES:
                comparator_stmt = node
                comparator_op = op
                break
            if op in {'ISZERO', 'AND', 'OR', 'NOT'}:
                next_nodes.extend(list(predicate_subgraph.predecessors(node)))

        if comparator_stmt:
            break
        current_nodes = next_nodes
        depth += 1

    # 2. 如果找到了二元比较 (如 LT, EQ)
    if comparator_stmt:
        operands = list(predicate_subgraph.predecessors(comparator_stmt))
        operand_semantics = []

        for operand in operands:
            # 使用追踪器解析每个输入端
            sem = trace_semantic_boundary(operand)
            operand_semantics.append(sem)

        if len(operand_semantics) == 2:
            return f"[{operand_semantics[0]} {comparator_op} {operand_semantics[1]}]"
        elif len(operand_semantics) == 1:
            return f"[{operand_semantics[0]} {comparator_op} ?]"
        else:
            return f"[Complex_Comparison {comparator_op}]"

    # 3. 如果没找到二元比较，说明是布尔单目运算 (比如 JUMPI 判断 CALL 的返回值)
    else:
        boolean_sources = set()
        for pred in predicate_subgraph.predecessors(jumpi_stmt):
            sem = trace_semantic_boundary(pred)
            if sem != "Hardcoded_Constant" and sem != "Computed_Value":
                boolean_sources.add(sem)

        if boolean_sources:
            # ==== 锦上添花：区分常规变量和外部调用 ====
            sources_str = ', '.join(boolean_sources)
            if "Storage" in sources_str or "Args" in sources_str or "msg." in sources_str:
                return f"[Existence/Non-Zero Check on: {sources_str}]"
            elif "External_Call" in sources_str:
                return f"[Success/Failure Check on: {sources_str}]"
            else:
                return f"[Boolean Check on: {sources_str}]"
        else:
            return "[Unknown Boolean Check]"


def extract_business_block(df_var_values, df_defines, df_stmts_in_block, df_opcodes, df_uses, global_cfg):
    error_selector = (
        "0x8c379a000000000000000000000000000000000000000000000000000000000"
    )

    # 1. 找到 selector 对应变量
    selector_vars = df_var_values[
        df_var_values["value"] == error_selector
        ][["var"]].copy()

    selector_vars = selector_vars.rename(
        columns={
            "var": "selector_var",
        }
    )

    # 2. 找到定义 selector 变量的 stmtID
    selector_stmts = selector_vars.merge(
        df_defines[["stmtID", "var"]],
        left_on="selector_var",
        right_on="var",
        how="inner",
    )

    selector_stmts = selector_stmts.rename(
        columns={
            "stmtID": "selector_stmtID",
        }
    )

    selector_stmts = selector_stmts[
        [
            "selector_var",
            "selector_stmtID",
        ]
    ]

    # 3. 找到 selector stmtID 所在的 blockID
    selector_blocks = selector_stmts.merge(
        df_stmts_in_block[["stmtID", "blockID"]],
        left_on="selector_stmtID",
        right_on="stmtID",
        how="inner",
    )

    # merge 后 stmtID 与 selector_stmtID 含义相同，删除重复列
    selector_blocks = selector_blocks.drop(
        columns=["stmtID"]
    )

    selector_blocks = selector_blocks.rename(
        columns={
            "blockID": "selector_blockID",
        }
    )

    selector_blocks.drop_duplicates().reset_index(drop=True)

    # 4. 通过全局控制流图查找 selector block 的前驱 block
    selector_blocks["guard_blockID"] = selector_blocks[
        "selector_blockID"
    ].apply(
        lambda block_id: (
            list(global_cfg.predecessors(block_id))
            if block_id in global_cfg
            else []
        )
    )

    # 一个 selector block 可能存在多个前驱 block
    # 使用 explode() 将每个前驱节点展开为独立记录
    selector_blocks = selector_blocks.explode(
        "guard_blockID"
    )

    # 5，6步作为debug，经验上错误处理函数的构建块的前序块一定是JUMPI
    # ---------------------------------------------------------
    # 5. 找到包含 JUMPI 的 blockID
    # ---------------------------------------------------------
    jumpi_blocks = df_stmts_in_block[
        ["stmtID", "blockID"]
    ].merge(
        df_opcodes[["stmtID", "opcode"]],
        on="stmtID",
        how="inner",
    )

    jumpi_blocks = set(
        jumpi_blocks[
            jumpi_blocks["opcode"] == "JUMPI"
            ]["blockID"]
    )

    # ---------------------------------------------------------
    # 6. 验证候选 guard block 是否包含 JUMPI
    # ---------------------------------------------------------
    selector_blocks["guard_has_jumpi"] = selector_blocks[
        "guard_blockID"
    ].apply(
        lambda block_id: block_id in jumpi_blocks
    )

    error_message_mstores = extract_error_message_mstores(
        selector_blocks,
        df_var_values,
        df_uses,
        df_stmts_in_block,
        df_opcodes,
        global_cfg,
    )

    return error_message_mstores


# 经验主义归纳的结果，硬编码错误处理过程是连续的，也就是在函数签名后的第四个block中写入错误信息，暂时先这样做
# 目前发现有极少部分由于编译器的内联优化，把错误信息提到了函数开头
def extract_error_message_mstores(
        selector_blocks,
        df_var_values,
        df_uses,
        df_stmts_in_block,
        df_opcodes,
        global_cfg,
):
    """
    从 selector_blockID 出发，沿全局 CFG 向后遍历四个 block，
    找到写入错误信息的 block，并提取其中 MSTORE 写入的字符串内容。

    参数：
        selector_blocks:
            extract_error_selector_blocks() 的输出结果。
            至少包含：
                selector_var
                selector_stmtID
                selector_blockID
                guard_blockID
                guard_has_jumpi

        df_var_values:
            TAC_Variable_Value.csv 对应的 DataFrame。
            需要包含：
                var
                value

        df_uses:
            TAC_Use.csv 对应的 DataFrame。
            需要包含：
                stmtID
                var
                index

        df_stmts_in_block:
            TAC_Block.csv 对应的 DataFrame。
            需要包含：
                stmtID
                blockID

        df_opcodes:
            TAC_Op.csv 对应的 DataFrame。
            需要包含：
                stmtID
                opcode

        global_cfg:
            全局控制流图。

    返回：
        DataFrame，每一行对应一个 selector block。
    """

    results = []

    for _, selector_row in selector_blocks.iterrows():
        current_block = selector_row["selector_blockID"]
        forward_path = []

        path_status = "found"

        # -----------------------------------------------------
        # 1. 从 selector_blockID 沿 CFG 向后遍历四个 block
        # -----------------------------------------------------
        for _ in range(4):
            if current_block not in global_cfg:
                path_status = "block_not_in_cfg"
                break

            successors = list(
                global_cfg.successors(current_block)
            )

            if len(successors) == 0:
                path_status = "no_successor"
                break

            if len(successors) > 1:
                path_status = "multiple_successors"
                break

            current_block = successors[0]
            forward_path.append(current_block)

        result = selector_row.to_dict()

        result["forward_path"] = forward_path

        # 无法走到第四个 block 时，保留记录用于调试
        if path_status != "found":
            result.update(
                {
                    "error_message_blockID": None,
                    "mstore_stmtIDs": [],
                    "mstore_details": [],
                    "error_message": None,
                    "error_message_status": path_status,
                }
            )

            results.append(result)
            continue

        # selector block 后的第四个 block
        error_message_block = current_block

        # -----------------------------------------------------
        # 2. 找到第四个 block 中的所有语句
        # -----------------------------------------------------
        block_stmts = df_stmts_in_block[
            df_stmts_in_block["blockID"].astype(str)
            == str(error_message_block)
        ][["stmtID"]].copy()

        # 保留 block 内语句原始顺序
        block_stmts["stmt_order"] = range(
            len(block_stmts)
        )

        # -----------------------------------------------------
        # 3. 提取其中所有 MSTORE 语句
        # -----------------------------------------------------
        mstore_rows = block_stmts.merge(
            df_opcodes[["stmtID", "opcode"]],
            on="stmtID",
            how="inner",
        )

        mstore_rows = mstore_rows[
            mstore_rows["opcode"].astype(str).str.upper()
            == "MSTORE"
        ].sort_values(
            "stmt_order"
        )

        if mstore_rows.empty:
            result.update(
                {
                    "error_message_blockID": error_message_block,
                    "mstore_stmtIDs": [],
                    "mstore_details": [],
                    "error_message": None,
                    "error_message_status": "mstore_not_found",
                }
            )

            results.append(result)
            continue

        # -----------------------------------------------------
        # 4. 提取每条 MSTORE 的第二个操作数
        # -----------------------------------------------------
        mstore_details = []
        message_chunks = []

        for _, mstore_row in mstore_rows.iterrows():
            mstore_stmt_id = mstore_row["stmtID"]

            # 查询 MSTORE 使用的变量，并按照参数位置排序
            mstore_uses = df_uses[
                df_uses["stmtID"].astype(str)
                == str(mstore_stmt_id)
            ].copy()

            mstore_uses = mstore_uses.sort_values(
                "index"
            )

            # MSTORE 应当至少包含两个操作数：
            #   第一个：内存偏移量
            #   第二个：写入内容
            if len(mstore_uses) < 2:
                mstore_details.append(
                    {
                        "mstore_stmtID": mstore_stmt_id,
                        "value_var": None,
                        "value": None,
                        "decoded_chunk": None,
                        "status": "missing_operand",
                    }
                )

                continue

            value_var = mstore_uses.iloc[1]["var"]

            # -------------------------------------------------
            # 5. 通过 df_var_values 恢复第二个操作数的常量值
            # -------------------------------------------------
            value_rows = df_var_values[
                df_var_values["var"].astype(str)
                == str(value_var)
            ]

            if value_rows.empty:
                value = None
            else:
                value = value_rows.iloc[0]["value"]

            decoded_chunk = decode_hex_string(
                value
            )

            if decoded_chunk is not None:
                message_chunks.append(
                    decoded_chunk
                )

            mstore_details.append(
                {
                    "mstore_stmtID": mstore_stmt_id,
                    "value_var": value_var,
                    "value": value,
                    "decoded_chunk": decoded_chunk,
                    "status": (
                        "decoded"
                        if decoded_chunk is not None
                        else "not_string_constant"
                    ),
                }
            )

        # -----------------------------------------------------
        # 6. 拼接同一 block 中的字符串片段
        # -----------------------------------------------------
        error_message = (
            "".join(message_chunks)
            if message_chunks
            else None
        )

        result.update(
            {
                "error_message_blockID": error_message_block,
                "mstore_stmtIDs": mstore_rows[
                    "stmtID"
                ].tolist(),
                "mstore_details": mstore_details,
                "error_message": error_message,
                "error_message_status": (
                    "decoded"
                    if error_message is not None
                    else "string_not_decoded"
                ),
            }
        )

        results.append(result)

    return pd.DataFrame(results)



def merge_check_blocks(
    BASE_CHECK_BLOCKS,
    checkBlock_des_dict,
    SUPPLY_CHECK_BLOCKS,
    supplyBlock_des_dict,
):
    """
    合并宽松检查块与错误驱动检查块，并将错误处理信息
    拼接到原有的业务逻辑约束描述之后。

    参数：
        BASE_CHECK_BLOCKS:
            宽松方法提取出的检查块集合或列表。

        checkBlock_des_dict:
            宽松方法生成的检查块描述字典。
            例如：
                {
                    "0xd45": "Hardcoded_Constant EQ Storage[_received]"
                }

        ERROR_DRIVED_CHECK_BLOCKS:
            错误驱动方法提取出的检查块集合或列表。

        block_error_dict:
            错误驱动方法恢复出的错误信息。
            例如：
                {
                    "0xd45": "already processed"
                }

    返回：
        FINAL_CHECK_BLOCKS:
            两类检查块的并集。

        merged_checkBlock_des_dict:
            融合错误信息后的检查块描述字典。
    """

    # ---------------------------------------------------------
    # 1. 两类检查块取并集，并尽量保留原始顺序
    # ---------------------------------------------------------
    FINAL_CHECK_BLOCKS = list(
        dict.fromkeys(
            list(BASE_CHECK_BLOCKS)
            + list(SUPPLY_CHECK_BLOCKS)
        )
    )

    # ---------------------------------------------------------
    # 2. 复制原有描述，避免直接修改输入字典
    # ---------------------------------------------------------
    merged_checkBlock_des_dict = dict(
        checkBlock_des_dict
    )

    # ---------------------------------------------------------
    # 3. 将错误信息拼接至原有描述之后
    # ---------------------------------------------------------
    for block_id in SUPPLY_CHECK_BLOCKS:
        error_message = supplyBlock_des_dict.get(
            block_id
        )

        # 跳过未成功恢复的错误信息
        if (
            error_message is None
            or not str(error_message).strip()
        ):
            continue

        error_description = (
            f"基于后续逻辑提取的错误处理信息："
            f"{str(error_message).strip()}"
        )

        original_description = merged_checkBlock_des_dict.get(
            block_id
        )

        # 情况 1：该 block 同时被宽松方法提取到
        if (
            original_description is not None
            and str(original_description).strip()
        ):
            original_description = str(
                original_description
            ).strip()

            # 避免函数被重复调用时反复追加相同内容
            if error_description not in original_description:
                merged_checkBlock_des_dict[
                    block_id
                ] = (
                    f"{original_description}\n"
                    f"{error_description}"
                )

        # 情况 2：该 block 仅被错误驱动方法提取到
        else:
            merged_checkBlock_des_dict[
                block_id
            ] = error_description

    return (
        FINAL_CHECK_BLOCKS,
        merged_checkBlock_des_dict,
    )

# todo 提取call指令所在区块检查块，没有添加相关的语义描述，或者说应该对call指令区块进行特殊处理：
# 1.对callprivate抽取函数名进行补充，并且尽量提取内部的检查块
# 2.对call/staticcall进行精细化区分
# 发现了一点问题，if-else类型的分支控制流可能不携带错误信息（待确认）
# 一个思路，把检查块的提取分为严格的（带有错误信息）和宽松的（现在的提取方式）
# 然后取一个并集，并且使用严格块的错误信息来补充检查块语义
def build_AC_check_blocks(artifacts_path, df_defines, df_uses, df_opcodes, df_stmts_in_block, storage,
                          df_publicArgs, df_formalArgs, df_functionCall, df_var_values, global_cfg):

    logger.info("开始构建授权检查块")
    sload_semantics_dict = storage.set_index('stmtID')['semantic_with_type'].to_dict()
    print(sload_semantics_dict)

    const_value_dict = df_var_values.set_index('var')['value'].to_dict()

    df_block_with_error = extract_business_block(df_var_values, df_defines, df_stmts_in_block, df_opcodes, df_uses, global_cfg)
    df_block_with_error.to_excel(artifacts_path / "output_debug" / "block_with_error.xlsx", index=False)
    # 错误驱动的检查块-错误信息dict
    ERROR_DRIVED_CHECK_BLOCKS = df_block_with_error['guard_blockID'].tolist()
    # print(ERROR_DRIVED_CHECK_BLOCKS)
    block_error_dict = df_block_with_error.set_index('guard_blockID')['error_message'].to_dict()

    # #谓词（CALL、SLOAD、CALLVALUE等）授权块（宽松的检查块）
    ddg = build_data_dependency_graph(df_defines, df_uses)
    BASE_CHECK_BLOCKS, checkBlock_des_dict = extract_predicate_slices(ddg, df_opcodes, df_stmts_in_block,
                                                                      sload_semantics_dict, const_value_dict)

    # print(checkBlock_des_dict)

    # 使用错误驱动检查块补充宽松检查块的错误信息
    final_check_blocks, final_checkBlock_des_dict = merge_check_blocks(BASE_CHECK_BLOCKS, checkBlock_des_dict,
                                                                       ERROR_DRIVED_CHECK_BLOCKS, block_error_dict)

    # # 提取arg和状态交汇的检查块(严格的检查块规则)
    # df_allArgs = pd.concat([df_publicArgs, df_formalArgs], ignore_index=True)
    # TRUE_AUTH_BLOCKS_PUBLICARGS = extract_arg_state_rendezvous(ddg, df_defines, df_allArgs, df_opcodes,
    #                                                            df_stmts_in_block)
    # # 提取caller和状态交汇的检查块(严格的检查块规则)
    # CALLER_STATE_AUTH_BLOCKS = extract_caller_state_rendezvous(ddg, df_opcodes, df_stmts_in_block)
    # # print(CALLER_STATE_AUTH_BLOCKS)
    #
    # # 提取msg.value和状态交汇的检查块(严格的检查块规则)
    # CALLVALUE_STATE_AUTH_BLOCKS = extract_value_state_rendezvous(ddg, df_opcodes, df_stmts_in_block)
    # # print(CALLVALUE_STATE_AUTH_BLOCKS)
    # # 调试用手动注入检查块
    # # Manual_check_block = ['0x31eaB0x2327B0x253dB0xe96']
    # Manual_check_block = []
    # AUTH_BLOCKS = list(TRUE_AUTH_BLOCKS_PUBLICARGS) + list(CALLER_STATE_AUTH_BLOCKS) + list(
    #     CALLVALUE_STATE_AUTH_BLOCKS) + Manual_check_block + list(final_check_blocks)

    # 提取call指令所在区块视作潜在的检查块（检查逻辑存在于调用函数中的情况），考虑要不要进一步细分外部合约调用
    POTENTIAL_AUTH_BLOCKS = list(df_functionCall.iloc[:, 0])

    # print(POTENTIAL_AUTH_BLOCKS)
    return final_check_blocks, final_checkBlock_des_dict, POTENTIAL_AUTH_BLOCKS



if __name__ == "__main__":
    # b, graph_index = generate_ListandGraph(CONTRACT_ARTIFACTS_PATH)
    # print(graph_index)
    # Storage_semantic =parsefromdecompiledcode(CONTRACT_ARTIFACTS_PATH,CONTRACT_NAME)
    # print(f"Map_semantic:{Map_semantic}")
    # print(f"Stor_semantic:{Stor_semantic}")
    # Caller, CallData = extract_All_PublicFunc_Caller(CONTRACT_ARTIFACTS_PATH, CONTRACT_NAME)
    # CallFormalArgs = extract_All_Formal_Args(CONTRACT_ARTIFACTS_PATH, CONTRACT_NAME)
    # CallPubArgs = extract_All_PublicFunc_Args(CONTRACT_ARTIFACTS_PATH, CONTRACT_NAME)
    # Storage = extract_All_Storage(CONTRACT_ARTIFACTS_PATH, Storage_semantic, CONTRACT_NAME)
    Events = extract_all_events(CONTRACT_ARTIFACTS_PATH, CONTRACT_NAME)

    # Model_normal = extraction_all(b, graph_index, Storage, Caller, CallData, CallPubArgs, CallFormalArgs)
    # Re_fun, annotation, Call_G, emitting_function, informing_function = Build_call_graph(CONTRACT_ARTIFACTS_PATH, Model_normal, Events)
    # print(f"Re_fun:{Re_fun}")
    # print(f"emitting_function:{emitting_function}")
    # print(f"informing_function:{informing_function}")
    G = build_global_cfg(CONTRACT_ARTIFACTS_PATH, Events)
    output_Graph_to_file(G, "G_new")

    path_generator = nx.all_simple_paths(G, "0x3d8", "0xc10B0x3ed")
    # path_generator = nx.shortest_path(G, "0x0", "0x840")
    Paths = list(path_generator)
    # print("The shortest paths from source_node: 0x0 to target_node: 0x840 is listed:")
    # print(f"path is {Paths}")
    for m in range(0, len(Paths)):
        print("The shortest paths from source_node: 0x0 to target_node: 0x840 is listed:")
        print(f"path[{m}] is {Paths[m]}")

    # analyze_cfg(G)
    # Build_call_graph(CONTRACT_ARTIFACTS_PATH)
