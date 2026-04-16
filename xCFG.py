import re
import pandas as pd
from pathlib import Path
import networkx as nx
from typing import Tuple
import matplotlib.pyplot as plt

from event_analysis import analyze_events, convert_events_to_func
from tac_analysis import extract_all_events
from tac_analyze_scripts.GeminiRequest import classify_event_with_agent
from tac_analyze_scripts.help_function import output_Graph_to_file

PROJECT_ROOT = Path(__file__).resolve().parent
OUT_DIR = PROJECT_ROOT / "contracts/ChainSwap/TokenMapped/out"
CONTRACT_NAME = "TokenMapped"
CONTRACT_ARTIFACTS_PATH = OUT_DIR.parent


def build_global_cfg(df_blockEdge, df_functionCall, df_functionReturn, df_publicFuncs, events):
    emitting_events, informing_events = analyze_events(events)
    informing_blocks = informing_events['block'].tolist()
    emitting_blocks = emitting_events['block'].tolist()

    """
    高性能构建扩展控制流图 (xCFG)。
    利用 Pandas Merge 替代嵌套循环。
    """
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

    return G


def build_fcg(df_functionCall, df_block_in_func, events):

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

    emitting_events, informing_events = analyze_events(events)
    # 处理 Deposit (Emitting) -> Relayer
    emitting_funcs, emit_sign = convert_events_to_func(block_func_relations, emitting_events)
    # 去重
    emitting_function = list(set(emitting_funcs))

    # 添加边: Deposit Function -> Relayer
    if emitting_function:
        for func in emitting_function:
            Call_G.add_edge(func, "relayer")

    # 处理 Withdrawal (Informing) -> Client
    informing_funcs, inform_sign = convert_events_to_func(block_func_relations, informing_events)
    # 去重
    informing_function = list(set(informing_funcs))

    # 添加边: Withdrawal Function -> Client
    if informing_function:
        for func in informing_function:
            Call_G.add_edge(func, "client")

    emitting_function = list(set(emitting_function))

    # 生成 Re_fun (Resource Functions List)关键资源函数
    # ---------------------------------------------------------
    # 逻辑：涉及存取的函数 + (如果有重复签名则加上 relayer/client)
    Re_fun = list(set(emitting_function + informing_function))

    # 原作者逻辑：如果 event 签名有重复 (len(set) < len(raw))，说明发生了多次相同的事件
    # 这通常意味着高频跨链，所以把 relayer/client 加入关键节点列表
    if len(set(emit_sign)) < len(emit_sign):
        Re_fun.append("relayer")

    if len(set(inform_sign)) < len(inform_sign):
        Re_fun.append("client")

    # 确保唯一性
    Re_fun = list(set(Re_fun))

    return Re_fun, Call_G, emitting_function, informing_function


def build_data_dependency_graph(df_defines, df_uses):
    """
        通过 Def 和 Use 构建语句级别的数据依赖图 (DDG)
        """
    df_def = df_defines
    df_use = df_uses

    # 我们要找的是: Stmt_A 定义了 var_X，Stmt_B 使用了 var_X
    # 那么就存在一条数据流边: Stmt_A -> Stmt_B
    # 相当于 SQL: SELECT A.stmt_id as from_stmt, B.stmt_id as to_stmt FROM df_def A JOIN df_use B ON A.var_id = B.var_id
    df_flow = pd.merge(df_def, df_use, on='var', suffixes=('_def', '_use'))

    # 构建有向图
    DDG = nx.DiGraph()
    edges = list(zip(df_flow['stmt_def'], df_flow['stmt_use']))
    DDG.add_edges_from(edges)

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

