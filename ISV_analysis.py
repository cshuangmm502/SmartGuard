import networkx as nx
import pprint
from collections import defaultdict, deque
from ACV_analysis import convert_func_call_path_to_block_calls, detect_access_control_violation, is_secure_barrier_deep
import itertools


# 1.比较不同调用路径的支配块数量
# 2.检查deposit_event，informing_event与实际行为的一致性
def ISV_analysis(artifacts_path, emitting_functions, df_opcodes, df_uses, df_defines, df_formalArgs):
    print(f"\n=======================================================")
    print(f"🎯 开始进行源链行为差异分析 ")
    print(f"=======================================================")
    # source_divergence_analysis(artifacts_path, df_functionCall, df_block_in_func, emitting_functions, func_call_graph,
    #              global_control_flow_graph, df_functionReturn,
    #              AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, checkBlock_des_dict)

    confused_results = source_divergence_analysis(emitting_functions)
    if len(confused_results) == 0:
        print("[*] 分析完成，源链行为不存在差异性混淆")
    else:
        print("[*] 分析完成，源链行为存在差异性混淆")
        print(confused_results)

    print(f"\n=======================================================")
    print(f"🎯 开始进行结算依赖分析 ")
    print(f"=======================================================")
    # print(emitting_functions)
    sd_results = settlement_dependency_analysis(emitting_functions, df_uses, df_defines, df_opcodes, df_formalArgs)
    print(sd_results)

    # results = extract_log_direct_args("0x848", df_opcodes, df_uses)
    # print(results)


def source_divergence_analysis(emitting_functions):
    event_groups = defaultdict(list)

    for item in emitting_functions:
        event_signature = item.get("event_signature", "")
        event_groups[event_signature].append(item)

    divergence_results = []
    reported_pairs = set()

    for event_signature, items in event_groups.items():
        if len(items) <= 1:
            continue

        for item1, item2 in itertools.combinations(items, 2):
            func1_id = str(item1["func_id"])
            func2_id = str(item2["func_id"])

            if func1_id == func2_id:
                continue

            func_pair = tuple(sorted([func1_id, func2_id]))
            result_key = (event_signature, func_pair)

            if result_key in reported_pairs:
                continue

            reported_pairs.add(result_key)

            divergence_results.append({
                "event_name": item1.get("event_name", ""),
                "event_signature": event_signature,
                "Function1_id": func_pair[0],
                "Function2_id": func_pair[1],
            })

    return divergence_results


def settlement_dependency_analysis(emitting_functions, df_uses, df_defines, df_opcodes, df_formalArgs):
    function_summaries = []

    for func in emitting_functions:
        event_func = func['func_id']
        args = df_formalArgs[df_formalArgs['func_entry_block'] == event_func]['var']

        excluded_args = find_private_return_args(
            function_args=args,
            uses=df_uses,
            tac_ops=df_opcodes,
        )
        args_status = []

        for arg in args:

            if arg in excluded_args: continue
            result = forward_trace_arg(arg, df_uses, df_defines, df_opcodes)
            # print(result)
            role = classify_function_arg(result)
            result['role'] = role
            args_status.append(result)

        func_summary = {
            "func_id": event_func,
            "event_name": func["event_name"],
            "event_stmtID": func["stmtID"],
            "business_args": args_status
        }
        function_summaries.append(func_summary)

    dependency_results = analyze_all_function_dependencies(function_summaries)

    return dependency_results


def analyze_all_function_dependencies(
        function_summaries
):
    results = []

    for func_summary in function_summaries:
        result = evaluate_function_dependency(
            func_summary
        )

        results.append(
            result
        )

    return results


# def analyze_settlement_dependency(tac_list, log_stmt_id, target_vars):
#     """
#     :param tac_list: 按执行顺序排列的 TAC 字典列表
#     :param log_stmt_id: 触发 deposit event 的 log 指令 ID
#     :param target_vars: 需要追踪的变量名列表 (如 'v_amount')
#     :return: 发现的依赖路径
#     """
#     worklist = set(target_vars)
#     dependency_chain = []
#
#     # 找到 log 语句在列表中的索引
#     log_idx = next(i for i, stmt in enumerate(tac_list) if stmt["stmt_id"] == log_stmt_id)
#
#     # 从 log 语句的上一行开始，反向遍历（倒序）
#     for i in range(log_idx - 1, -1, -1):
#         stmt = tac_list[i]
#
#         # 获取当前行的 def 和 use
#         defs, uses = get_def_use(stmt)
#
#         # 如果当前行“定义”的变量，正是我们正在追踪的变量
#         intersection = worklist.intersection(defs)
#         if intersection:
#             # 记录这行关键代码
#             dependency_chain.append(stmt)
#
#             # 判断这行代码是否是我们想要的“结算标志”
#             if stmt["opcode"] == "CALL":
#                 print(f"[!] 找到外部调用依赖: {stmt['raw_stmt']}")
#                 # 这里可以进一步判断调用的目标函数签名是不是 transfer/transferFrom
#
#             elif stmt["opcode"] in ["ADD", "SUB"]:
#                 print(f"[!] 找到状态计算依赖: {stmt['raw_stmt']}")
#
#             # 核心更新逻辑：追踪溯源
#             # 把已经找到源头的变量从 worklist 移除
#             worklist.difference_update(intersection)
#             # 把产生这个变量所依赖的上一层变量加进 worklist
#             worklist.update(uses)
#
#         # 如果追踪的变量都找到了源头（比如全是函数参数了），提前退出
#         if not worklist:
#             break
#
#     return dependency_chain


def extract_log_direct_args(log_stmt, tac_ops, uses):
    """
    提取 LOGx 指令的直接操作数。

    对于：
    LOG4 memory_offset, memory_size, topic0, topic1, topic2, topic3

    返回：
    - data 内存区域
    - Event Signature
    - indexed 参数
    """

    op_rows = tac_ops[tac_ops["stmtID"] == log_stmt]

    if op_rows.empty:
        raise ValueError("Cannot find LOG stmt: {}".format(log_stmt))

    op = str(op_rows.iloc[0]["opcode"]).upper()

    arg_rows = uses[uses["stmtID"] == log_stmt].copy()
    arg_rows = arg_rows.sort_values("index")

    operands = arg_rows["var"].tolist()

    if not op.startswith("LOG"):
        raise ValueError("{} is not a LOG opcode".format(op))

    topic_count = int(op[-1])
    expected_num = 2 + topic_count

    if len(operands) != expected_num:
        raise ValueError(
            "{} expects {} operands, but found {}: {}".format(
                op,
                expected_num,
                len(operands),
                operands,
            )
        )

    topic_vars = operands[2:]

    return {
        "log_stmt": log_stmt,
        "log_op": op,

        "data_offset_var": operands[0],
        "data_size_var": operands[1],

        "event_signature_var": topic_vars[0],
        "indexed_arg_vars": topic_vars[1:],
    }


def forward_trace_arg(
        start_var,
        uses,
        defines,
        tac_ops,
        max_depth=30,
):
    """
    从函数参数出发执行正向数据流追踪。

    返回：
    - Event sinks；
    - 当前合约的直接 storage 写入；
    - 外部合约调用；
    - 内部辅助函数调用；
    - 中间语义操作。
    """

    EVENT_SINKS = {
        "LOG0",
        "LOG1",
        "LOG2",
        "LOG3",
        "LOG4",
    }

    STATE_SINKS = {
        "SSTORE",
    }

    EXTERNAL_CALL_SINKS = {
        "CALL",
    }

    PRIVATE_CALL_SINKS = {
        "CALLPRIVATE",
    }

    SEMANTIC_OPS = {
        "ADD",
        "SUB",
        "MUL",
        "DIV",
        "EQ",
        "LT",
        "GT",
        "AND",
        "OR",
        "SHA3",
        "MSTORE",
    }

    queue = deque([
        (start_var, 0)
    ])

    visited_vars = set()
    visited_stmts = set()

    event_sinks = []
    state_sinks = []
    external_call_sinks = []
    private_call_sinks = []
    semantic_ops = []

    while queue:
        var_id, depth = queue.popleft()

        if var_id in visited_vars:
            continue

        if depth > max_depth:
            continue

        visited_vars.add(var_id)

        use_rows = uses[
            uses["var"] == var_id
            ]

        for _, use_row in use_rows.iterrows():
            stmt_id = use_row["stmtID"]

            if stmt_id in visited_stmts:
                continue

            visited_stmts.add(stmt_id)

            op_rows = tac_ops[
                tac_ops["stmtID"] == stmt_id
                ]

            if op_rows.empty:
                continue

            opcode = str(
                op_rows.iloc[0]["opcode"]
            ).upper()

            sink_item = {
                "stmtID": stmt_id,
                "opcode": opcode,
            }

            if opcode in EVENT_SINKS:
                event_sinks.append(
                    sink_item
                )

            if opcode in STATE_SINKS:
                state_sinks.append(
                    sink_item
                )

            if opcode in EXTERNAL_CALL_SINKS:
                external_call_sinks.append(
                    sink_item
                )

            if opcode in PRIVATE_CALL_SINKS:
                private_call_sinks.append(
                    sink_item
                )

            if opcode in SEMANTIC_OPS:
                semantic_ops.append(
                    sink_item
                )

            # 对当前语句定义的新变量继续追踪。
            defined_rows = defines[
                defines["stmtID"] == stmt_id
                ]

            for _, defined_row in defined_rows.iterrows():
                queue.append(
                    (
                        defined_row["var"],
                        depth + 1,
                    )
                )

    return {
        "source_var": start_var,
        "event_sinks": event_sinks,
        "state_sinks": state_sinks,
        "external_call_sinks": (
            external_call_sinks
        ),
        "private_call_sinks": (
            private_call_sinks
        ),
        "semantic_ops": semantic_ops,
    }


# def source_divergence_semantic_analysis(artifacts_path, df_functionCall, df_block_in_func, target_funcs_info, func_call_graph,
#                          global_control_flow_graph,
#                          df_functionReturn, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, checkBlock_des_dict):
#     # ==========================================
#     # 1. 预加载与数据清洗
#     # ==========================================
#     df_func_calls = df_functionCall.copy()
#     df_in_func = df_block_in_func.copy()
#     df_func_entry_return = df_functionReturn.copy()
#
#     block_to_func = dict(zip(df_in_func.iloc[:, 0].astype(str), df_in_func.iloc[:, 1].astype(str)))
#     df_func_calls["caller"] = df_func_calls["caller"].astype(str)
#     df_func_calls["callee_entry"] = df_func_calls["callee_entry"].astype(str)
#     df_func_calls["caller_func"] = df_func_calls["caller"].map(block_to_func)
#     df_func_calls["callee_func"] = df_func_calls["callee_entry"].map(block_to_func)
#
#     callsite_to_callee_entry = dict(zip(df_func_calls["caller"], df_func_calls["callee_entry"]))
#
#     analysis_report = []
#     source_func = "0x0"
#
#     # ==========================================
#     # 2. 遍历所有目标敏感操作
#     # ==========================================
#     for target_info in target_funcs_info:
#         target_func = str(target_info['func_id'])
#         sensitive_block = str(target_info['blockID'])
#         event_name = target_info.get('event_name', 'UnknownEvent')
#
#         print(f"\n=======================================================")
#         print(f"🎯 开始分析目标: 函数 {target_func} -> 敏感块 {sensitive_block} ({event_name})")
#         print(f"=======================================================")
#
#         if source_func not in func_call_graph.nodes or target_func not in func_call_graph.nodes:
#             print(f"⚠️ 源函数或目标函数不在调用图中，跳过。")
#             continue
#
#         paths = list(nx.all_simple_paths(func_call_graph, source_func, target_func, cutoff=6))
#         if (len(paths)>1):
#             for func_path in paths:
#                 print(f"\n🚀 正在检测调用路径: {' -> '.join(func_path)} -> {sensitive_block}")
#                 block_call_chain = convert_func_call_path_to_block_calls(func_path, df_func_calls)
#
#                 is_path_safe = False
#                 protecting_blocks = set()
#
#                 path_check_blocks = []
#                 # ==========================================
#                 # 3. 逐段分析跳跃 (Hop) - 强制分析每一段
#                 # ==========================================
#                 for hop_idx, hop in enumerate(block_call_chain):
#                     # 【移除】：去掉了原本的 if is_path_safe: break，强制进行分析！
#
#                     print(f"  🔍 分析第 {hop_idx + 1} 段路径: {hop['caller_func']} -> {hop['callee_func']}")
#                     caller_func = hop["caller_func"]
#                     func_blocks = df_in_func[df_in_func['func_id'] == caller_func]['block'].tolist()
#                     sub_G = global_control_flow_graph.subgraph(func_blocks)
#
#                     all_callsites_protected = True
#                     current_hop_auth_blocks = set()  # 记录当前hop发现的防御块
#
#                     for callsite in hop["callsite_blocks"]:
#                         ACV, potential_private_calls = detect_access_control_violation(
#                             sub_G, caller_func, callsite, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS)
#
#                         callsite_is_safe = False
#                         current_callsite_auths = set()
#
#                         for res in ACV:
#                             if res['status'] == "NEEDS_POLICY_CHECK" and len(res['found_auths']) > 0:
#                                 current_callsite_auths.update(res['found_auths'])
#                                 callsite_is_safe = True
#
#                         if callsite_is_safe:
#                             current_hop_auth_blocks.update(current_callsite_auths)
#
#                         elif len(potential_private_calls) > 0:
#                             for potential_call_block in potential_private_calls:
#                                 callee_entry = callsite_to_callee_entry.get(potential_call_block)
#                                 if not callee_entry: continue
#
#                                 is_safe, deep_auth_blocks = is_secure_barrier_deep(
#                                     callee_entry, global_control_flow_graph, df_in_func,
#                                     df_func_entry_return, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS,
#                                     callsite_to_callee_entry, set()
#                                 )
#
#                                 if is_safe:
#                                     callsite_is_safe = True
#                                     current_hop_auth_blocks.update(deep_auth_blocks)
#                                     break
#
#                         if not callsite_is_safe:
#                             all_callsites_protected = False
#                             break  # 如果这个hop里有一个调用点没护住，整个hop被击穿，无需再查其余callsite
#
#                     # 【修改】：记录本段 hop 的分析结果
#                     if all_callsites_protected:
#                         print(f"    ✅ 第 {hop_idx + 1} 段路径受到保护！关联区块: {current_hop_auth_blocks}")
#                         is_path_safe = True
#                         protecting_blocks.update(current_hop_auth_blocks)
#                     else:
#                         print(f"    ❌ 第 {hop_idx + 1} 段路径存在绕过风险 (无有效保护)。")
#
#                     path_check_blocks.extend(current_hop_auth_blocks)
#
#                 # ==========================================
#                 # 4. 分析最终目标函数内部本身 - 强制执行
#                 # ==========================================
#                 # 【移除】：去掉了原本的 if not is_path_safe:，无论前面怎样，必查目标函数内部！
#                 print(f"  🔍 分析最终目标函数 {target_func} 内部通往敏感块 {sensitive_block} 的路径:")
#                 func_blocks = df_in_func[df_in_func['func_id'] == target_func]['block'].tolist()
#                 sub_G = global_control_flow_graph.subgraph(func_blocks)
#
#                 target_func_is_safe = False
#                 target_auth_blocks = set()
#
#                 ACV, final_potential_calls = detect_access_control_violation(
#                     sub_G, target_func, sensitive_block, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS)
#
#                 # 4.1 提取并收集所有的直接鉴权
#                 for res in ACV:
#                     if res['status'] == "NEEDS_POLICY_CHECK" and len(res['found_auths']) > 0:
#                         target_func_is_safe = True
#                         target_auth_blocks.update(res['found_auths'])
#
#                 # 4.2 提取并收集所有的深层鉴权（移除 if not target_func_is_safe 的限制，强制执行）
#                 if len(final_potential_calls) > 0:
#                     for p_call in final_potential_calls:
#                         c_entry = callsite_to_callee_entry.get(p_call)
#                         if c_entry:
#                             is_safe, deep_auths = is_secure_barrier_deep(
#                                 c_entry, global_control_flow_graph, df_in_func,
#                                 df_func_entry_return, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS,
#                                 callsite_to_callee_entry, set()
#                             )
#                             if is_safe:
#                                 target_func_is_safe = True
#                                 target_auth_blocks.update(deep_auths)
#                                 # 【重要】：这里去掉了原先的 break，即使找到了一个，也要继续找，确保收集该路径上所有的外部鉴权保护！
#
#                 if target_func_is_safe:
#                     print(f"    ✅ 目标块 {sensitive_block} 在函数内部受到了鉴权保护！关联区块: {target_auth_blocks}")
#                     is_path_safe = True
#                     protecting_blocks.update(target_auth_blocks)
#                 else:
#                     print(f"    ❌ 最终目标函数内部未对敏感块 {sensitive_block} 提供保护。")
#
#                 path_check_blocks.extend(target_auth_blocks)
#
#                 # ==========================================
#                 # 5. 记录并输出详细结果
#                 # ==========================================
#                 if is_path_safe:
#                     # 只要前面的所有跳跃或者最后函数中，有任意一个卡点是安全的，这条路就安全
#                     print(f"🟢 结论：路径存在安全检查！提供保护的所有区块: {protecting_blocks}")
#                 else:
#                     print(f"🔴 结论：警告！到达 {event_name} 的路径存在绕过风险 (全程无有效鉴权)")
#
#                 # 记录整条执行路径的守卫块及守卫信息
#                 print(f"func_path: {func_path} suffered check blocks: {path_check_blocks}")
#                 checks_block_info = []
#                 for block in path_check_blocks:
#                     checks_block_info.append(checkBlock_des_dict[block])

def classify_function_arg(
        trace_result
):
    flows_to_event = bool(
        trace_result["event_sinks"]
    )

    flows_to_mstore = has_opcode(
        trace_result["semantic_ops"],
        "MSTORE",
    )

    # 第一版中，MSTORE 被视为潜在 Event data 编码。
    event_related = (
            flows_to_event
            or flows_to_mstore
    )

    flows_to_state = bool(
        trace_result["state_sinks"]
    )

    flows_to_external_call = bool(
        trace_result["external_call_sinks"]
    )

    flows_to_private_call = bool(
        trace_result["private_call_sinks"]
    )

    if event_related and flows_to_state:
        return "EVENT_AND_STATE_RELATED"

    if event_related and flows_to_external_call:
        return (
            "EVENT_AND_EXTERNAL_CALL_RELATED"
        )

    if event_related and flows_to_private_call:
        return (
            "EVENT_AND_PRIVATE_CALL_RELATED"
        )

    if flows_to_event:
        return "EVENT_RELATED"

    if flows_to_state:
        return "STATE_RELATED"

    if flows_to_external_call:
        return "EXTERNAL_CALL_RELATED"

    if flows_to_private_call:
        return "PRIVATE_CALL_RELATED"

    if flows_to_mstore:
        return "MEMORY_RELATED"

    return "UNKNOWN"


def find_private_return_args(
        function_args,
        uses,
        tac_ops,
):
    private_return_args = set()

    return_rows = tac_ops[
        tac_ops["opcode"].str.upper()
        == "RETURNPRIVATE"
        ]
    # print(return_rows)
    for _, row in return_rows.iterrows():
        stmt_id = row["stmtID"]

        used_rows = uses[
            uses["stmtID"] == stmt_id
            ].copy()

        if used_rows.empty:
            continue

        if "index" in used_rows.columns:
            used_rows = used_rows.sort_values(
                "index"
            )

        # RETURNPRIVATE 的第一个参数是返回地址。
        return_address_var = (
            used_rows.iloc[0]["var"]
        )

        if return_address_var in function_args.values:
            private_return_args.add(
                return_address_var
            )

    return private_return_args


def has_opcode(items, opcode):
    return any(
        item.get("opcode") == opcode
        for item in items
    )


def evaluate_function_dependency(
        func_summary
):
    business_args = func_summary.get(
        "business_args",
        []
    )

    strong_supporting_args = []
    indirect_supporting_args = []

    event_related_args = []
    state_related_args = []
    external_call_related_args = []
    private_call_related_args = []

    for arg in business_args:
        source_var = arg["source_var"]

        event_related = (
                bool(arg.get("event_sinks"))
                or has_opcode(
            arg.get("semantic_ops", []),
            "MSTORE",
        )
        )

        flows_to_state = bool(
            arg.get("state_sinks")
        )

        flows_to_external_call = bool(
            arg.get(
                "external_call_sinks"
            )
        )

        flows_to_private_call = bool(
            arg.get(
                "private_call_sinks"
            )
        )

        if event_related:
            event_related_args.append(
                source_var
            )

        if flows_to_state:
            state_related_args.append(
                source_var
            )

        if flows_to_external_call:
            external_call_related_args.append(
                source_var
            )

        if flows_to_private_call:
            private_call_related_args.append(
                source_var
            )

        if (
                event_related
                and (
                flows_to_state
                or flows_to_external_call
        )
        ):
            strong_supporting_args.append(
                source_var
            )

        elif (
                event_related
                and flows_to_private_call
        ):
            indirect_supporting_args.append(
                source_var
            )

    if strong_supporting_args:
        status = "DEPENDENCY_FOUND"
        confidence = "HIGH"
        supporting_args = (
            strong_supporting_args
        )

    elif indirect_supporting_args:
        status = (
            "DEPENDENCY_FOUND_VIA_PRI VATE_CALL"
        )
        confidence = "MEDIUM"
        supporting_args = (
            indirect_supporting_args
        )

    elif event_related_args:
        status = "DEPENDENCY_MISSING"
        confidence = "MEDIUM"
        supporting_args = []

    else:
        status = "DEPENDENCY_UNKNOWN"
        confidence = "LOW"
        supporting_args = []

    return {
        "func_id": func_summary.get(
            "func_id"
        ),
        "event_name": func_summary.get(
            "event_name"
        ),
        "event_stmtID": func_summary.get(
            "event_stmtID"
        ),

        "dependency_status": status,
        "confidence": confidence,

        "supporting_args": (
            supporting_args
        ),
        "event_related_args": sorted(
            set(event_related_args)
        ),
        "state_related_args": sorted(
            set(state_related_args)
        ),
        "external_call_related_args": sorted(
            set(external_call_related_args)
        ),
        "private_call_related_args": sorted(
            set(private_call_related_args)
        ),
    }


if __name__ == "__main__":
    # ========== 测试数据演示 ==========
    sample_data = [
        {"func_id": "F1", "event_name": "IncreaseAuthQuota(address,uint256,uint256)",
         "event_signature": "Transfer(address,address,uint256)",
         "stmt": "emit Transfer(a, b, 10)", "blockID": "0xbf50x39b"},
        {"func_id": "F2", "event_name": "IncreaseAuthQuota(address,uint256,uint256)",
         "event_signature": "Transfer(address,address,uint256)",
         "stmt": "emit Transfer(x, y, 20)", "blockID": "0xbf50x5b7B0x1ef"},
        {"func_id": "F3", "event_name": "Approve", "event_signature": "Approve(address,uint256)",
         "stmt": "emit Approve(a, 10)", "blockID": 3}
    ]
    results = source_divergence_analysis(sample_data)
    pprint.pprint(results)
