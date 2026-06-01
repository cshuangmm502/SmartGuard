import json
from pathlib import Path
import pandas as pd
import networkx as nx
from SC_extract import (extract_used_storage_in_controlflow, extract_used_caller_in_controlFlow,
                        extract_used_callData_in_controlFlow, extract_used_callPubArgs_in_controlFlow,
                        extract_used_callPriArgs_in_controlFlow)
from tac_analyze_scripts.GeminiRequest import call_llm_api_supportness_check, process_llm_response, \
    call_llm_api_repeat_check


def ACV_analysis(artifacts_path, df_functionCall, df_block_in_func, emitting_functions, informing_functions, func_call_graph,
                 global_control_flow_graph, df_functionReturn,
                 AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, checkBlock_des_dict):
    # 逻辑标志，源链函数为0，目标链为1
    func_tag = 0
    print(f"\n=======================================================")
    print(f"🎯 开始分析源链关键函数 ")
    print(f"=======================================================")
    detect_incomplete_AC(artifacts_path, df_functionCall, df_block_in_func, emitting_functions, func_call_graph,
                 global_control_flow_graph, df_functionReturn,
                 AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, checkBlock_des_dict, func_tag)

    print(f"\n=======================================================")
    print(f"🎯 开始分析目标链关键函数 ")
    print(f"=======================================================")
    func_tag = 1
    detect_incomplete_AC(artifacts_path, df_functionCall, df_block_in_func, informing_functions, func_call_graph,
                         global_control_flow_graph, df_functionReturn,
                         AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, checkBlock_des_dict, func_tag)


def detect_incomplete_AC(artifacts_path, df_functionCall, df_block_in_func, target_funcs_info, func_call_graph,
                         global_control_flow_graph,
                         df_functionReturn, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, checkBlock_des_dict, func_tag):
    # ==========================================
    # 1. 预加载与数据清洗
    # ==========================================
    df_func_calls = df_functionCall.copy()
    df_in_func = df_block_in_func.copy()
    df_func_entry_return = df_functionReturn.copy()

    block_to_func = dict(zip(df_in_func.iloc[:, 0].astype(str), df_in_func.iloc[:, 1].astype(str)))
    df_func_calls["caller"] = df_func_calls["caller"].astype(str)
    df_func_calls["callee_entry"] = df_func_calls["callee_entry"].astype(str)
    df_func_calls["caller_func"] = df_func_calls["caller"].map(block_to_func)
    df_func_calls["callee_func"] = df_func_calls["callee_entry"].map(block_to_func)

    callsite_to_callee_entry = dict(zip(df_func_calls["caller"], df_func_calls["callee_entry"]))

    source_func = "0x0"
    analysis_report = []
    LOG_FILE = artifacts_path / "output_debug" / "semantic_analysis.txt"
    # ==========================================
    # 2. 遍历所有目标敏感操作
    # ==========================================
    for target_info in target_funcs_info:
        target_func = str(target_info['func_id'])
        sensitive_block = str(target_info['blockID'])
        event_name = target_info.get('event_name', 'UnknownEvent')

        print(f"\n=======================================================")
        print(f"🎯 开始分析目标: 函数 {target_func} -> 敏感块 {sensitive_block} ({event_name})")
        print(f"=======================================================")

        if source_func not in func_call_graph.nodes or target_func not in func_call_graph.nodes:
            print(f"⚠️ 源函数或目标函数不在调用图中，跳过。")
            continue

        paths = list(nx.all_simple_paths(func_call_graph, source_func, target_func, cutoff=6))


        for func_path in paths:
            print(f"\n🚀 正在检测调用路径: {' -> '.join(func_path) } -> {sensitive_block}")
            block_call_chain = convert_func_call_path_to_block_calls(func_path, df_func_calls)

            is_path_safe = False
            protecting_blocks = set()

            # 【新增】：用于记录每一段的详细情况
            hop_details = []
            path_check_blocks = []
            # ==========================================
            # 3. 逐段分析跳跃 (Hop) - 强制分析每一段
            # ==========================================
            for hop_idx, hop in enumerate(block_call_chain):
                # 【移除】：去掉了原本的 if is_path_safe: break，强制进行分析！

                print(f"  🔍 分析第 {hop_idx + 1} 段路径: {hop['caller_func']} -> {hop['callee_func']}")
                caller_func = hop["caller_func"]
                func_blocks = df_in_func[df_in_func['func_id'] == caller_func]['block'].tolist()
                sub_G = global_control_flow_graph.subgraph(func_blocks)

                all_callsites_protected = True
                current_hop_auth_blocks = set()  # 记录当前hop发现的防御块

                for callsite in hop["callsite_blocks"]:
                    ACV, potential_private_calls = detect_access_control_violation(
                        sub_G, caller_func, callsite, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS)

                    callsite_is_safe = False
                    current_callsite_auths = set()

                    for res in ACV:
                        if res['status'] == "NEEDS_POLICY_CHECK" and len(res['found_auths']) > 0:
                            current_callsite_auths.update(res['found_auths'])
                            callsite_is_safe = True

                    if callsite_is_safe:
                        current_hop_auth_blocks.update(current_callsite_auths)

                    elif len(potential_private_calls) > 0:
                        for potential_call_block in potential_private_calls:
                            callee_entry = callsite_to_callee_entry.get(potential_call_block)
                            if not callee_entry: continue

                            is_safe, deep_auth_blocks = is_secure_barrier_deep(
                                callee_entry, global_control_flow_graph, df_in_func,
                                df_func_entry_return, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS,
                                callsite_to_callee_entry, set()
                            )

                            if is_safe:
                                callsite_is_safe = True
                                current_hop_auth_blocks.update(deep_auth_blocks)
                                break

                    if not callsite_is_safe:
                        all_callsites_protected = False
                        break  # 如果这个hop里有一个调用点没护住，整个hop被击穿，无需再查其余callsite

                # 【修改】：记录本段 hop 的分析结果
                if all_callsites_protected:
                    print(f"    ✅ 第 {hop_idx + 1} 段路径受到保护！关联区块: {current_hop_auth_blocks}")
                    is_path_safe = True
                    protecting_blocks.update(current_hop_auth_blocks)
                else:
                    print(f"    ❌ 第 {hop_idx + 1} 段路径存在绕过风险 (无有效保护)。")

                hop_details.append({
                    "hop_index": hop_idx + 1,
                    "caller_func": hop['caller_func'],
                    "callee_func": hop['callee_func'],
                    "is_safe": all_callsites_protected,
                    "auth_blocks": list(current_hop_auth_blocks) if all_callsites_protected else []
                })

                path_check_blocks.extend(current_hop_auth_blocks)

            # ==========================================
            # 4. 分析最终目标函数内部本身 - 强制执行
            # ==========================================
            # 【移除】：去掉了原本的 if not is_path_safe:，无论前面怎样，必查目标函数内部！
            print(f"  🔍 分析最终目标函数 {target_func} 内部通往敏感块 {sensitive_block} 的路径:")
            func_blocks = df_in_func[df_in_func['func_id'] == target_func]['block'].tolist()
            sub_G = global_control_flow_graph.subgraph(func_blocks)

            target_func_is_safe = False
            target_auth_blocks = set()

            ACV, final_potential_calls = detect_access_control_violation(
                sub_G, target_func, sensitive_block, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS)

            # 4.1 提取并收集所有的直接鉴权
            for res in ACV:
                if res['status'] == "NEEDS_POLICY_CHECK" and len(res['found_auths']) > 0:
                    target_func_is_safe = True
                    target_auth_blocks.update(res['found_auths'])

            # 4.2 提取并收集所有的深层鉴权（移除 if not target_func_is_safe 的限制，强制执行）
            if len(final_potential_calls) > 0:
                for p_call in final_potential_calls:
                    c_entry = callsite_to_callee_entry.get(p_call)
                    if c_entry:
                        is_safe, deep_auths = is_secure_barrier_deep(
                            c_entry, global_control_flow_graph, df_in_func,
                            df_func_entry_return, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS,
                            callsite_to_callee_entry, set()
                        )
                        if is_safe:
                            target_func_is_safe = True
                            target_auth_blocks.update(deep_auths)
                            # 【重要】：这里去掉了原先的 break，即使找到了一个，也要继续找，确保收集该路径上所有的外部鉴权保护！

            if target_func_is_safe:
                print(f"    ✅ 目标块 {sensitive_block} 在函数内部受到了鉴权保护！关联区块: {target_auth_blocks}")
                is_path_safe = True
                protecting_blocks.update(target_auth_blocks)
            else:
                print(f"    ❌ 最终目标函数内部未对敏感块 {sensitive_block} 提供保护。")

            hop_details.append({
                "hop_index": "Final",
                "caller_func": target_func,
                "callee_func": "Sensitive_Block",
                "is_safe": target_func_is_safe,
                "auth_blocks": list(target_auth_blocks) if target_func_is_safe else []
            })

            path_check_blocks.extend(target_auth_blocks)

            # ==========================================
            # 5. 记录并输出详细结果
            # ==========================================
            if is_path_safe:
                # 只要前面的所有跳跃或者最后函数中，有任意一个卡点是安全的，这条路就安全
                print(f"🟢 结论：路径存在安全检查！提供保护的所有区块: {protecting_blocks}")
            else:
                print(f"🔴 结论：警告！到达 {event_name} 的路径存在绕过风险 (全程无有效鉴权)")


            # 记录整条执行路径的守卫块及守卫信息
            print(f"func_path: {func_path} suffered check blocks: {path_check_blocks}")
            checks_block_info = []
            for block in path_check_blocks:
                checks_block_info.append(checkBlock_des_dict[block])


            # 调用LLM接口执行supportness检查
            response = call_llm_api_supportness_check(path_check_blocks, checks_block_info)
            # 提取结果
            support_check_result = process_llm_response(response)
            # print(support_check_result)

            # 写入 semantic_analysis.txt
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write("=" * 100 + "\n")
                f.write(f"func_path: {func_path}\n")
                f.write(f"suffered check blocks: {path_check_blocks}\n\n")

                f.write("checks_block_info:\n")
                for block in path_check_blocks:
                    f.write(f"check block {str(block)} {str(checkBlock_des_dict[block])} \n")

                f.write("\nsupport_check_analysis_result:\n")
                f.write(json.dumps(support_check_result, ensure_ascii=False, indent=2))
                f.write("\n\n")

            # repeat分析只作用于目标链逻辑
            if func_tag == 1:
                response = call_llm_api_repeat_check(path_check_blocks, checks_block_info)
                repeat_check_result = process_llm_response(response)
                # print(repeat_check_result)
                with open(LOG_FILE, "a", encoding="utf-8") as f:
                    f.write("repeat_check_analysis_result:\n")
                    f.write(json.dumps(repeat_check_result, ensure_ascii=False, indent=2))
                    f.write("\n\n")

            analysis_report.append({
                "target_func": target_func,
                "event_name": event_name,
                "sensitive_block": sensitive_block,
                "path": func_path,
                "is_path_safe": is_path_safe,
                "all_protecting_blocks": list(protecting_blocks),
                "hop_details": hop_details  # 【新增】完整的每段鉴权汇报数据
            })

    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write("=" * 100 + "\n")
        f.write(f"🏁 扫描完成。共分析了 {len(analysis_report)} 条路径。\n")
    # print(analysis_report)
    return analysis_report



# =====================================================================
# 辅助函数 1：深度递归检查函数 【返回签名修改】
# =====================================================================
def is_secure_barrier_deep(func_entry, global_control_flow_graph, df_in_func, df_func_entry_return,
                           AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS, callsite_to_callee_entry, visited_funcs):
    """
    返回: (bool 是否安全屏障, set 收集到的鉴权区块)
    """
    if func_entry in visited_funcs:
        return False, set()
    visited_funcs.add(func_entry)

    func_blocks = df_in_func[df_in_func['func_id'] == func_entry]['block'].tolist()
    if not func_blocks:
        return False, set()

    sub_G = global_control_flow_graph.subgraph(func_blocks)
    return_blocks = df_func_entry_return[df_func_entry_return['func_entry'] == func_entry]['return_block'].tolist()

    if not return_blocks:
        # 必然中断的函数，属于绝对安全，但因为它没有实际走到真正的业务代码，所以也不涉及后续变量，返回空集合
        return True, set()

    all_collected_auths = set()

    for ret_block in return_blocks:
        ACV, potential_private_calls = detect_access_control_violation(
            sub_G, func_entry, ret_block, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS)

        path_is_safe = False
        current_ret_auths = set()

        # 提取当前 return 分支的原生保护
        for res in ACV:
            if res['status'] == "NEEDS_POLICY_CHECK" and len(res['found_auths']) > 0:
                path_is_safe = True
                current_ret_auths.update(res['found_auths'])

        # 如果没有原生保护，去提取嵌套调用的保护
        if not path_is_safe and len(potential_private_calls) > 0:
            for potential_call_block in potential_private_calls:
                next_callee_entry = callsite_to_callee_entry.get(potential_call_block)
                if not next_callee_entry: continue

                is_safe, deep_auths = is_secure_barrier_deep(
                    next_callee_entry, global_control_flow_graph, df_in_func,
                    df_func_entry_return, AUTH_BLOCKS, POTENTIAl_AUTH_BLOCKS,
                    callsite_to_callee_entry, visited_funcs
                )
                if is_safe:
                    path_is_safe = True
                    current_ret_auths.update(deep_auths)
                    break

        # 只要有一条 return 路径没有防住，整个函数的防线就崩溃了
        if not path_is_safe:
            return False, set()

        # 这个 return 分支防住了，把用到的鉴权区块加入总集合
        all_collected_auths.update(current_ret_auths)

    return True, all_collected_auths


# =====================================================================
# 辅助函数 2：局部支配树分析
# =====================================================================
def detect_access_control_violation(G, entry_block, sensitive_block, auth_blocks, potential_auth_blocks):
    # 【容错增强】：防止提取的子图断裂导致报错
    if entry_block not in G or sensitive_block not in G:
        return [], []

    privateCall = []
    idoms = nx.immediate_dominators(G, entry_block)
    analysis_results = []

    current_block = sensitive_block
    dominating_auths = set()

    # 顺着支配树往回找
    while current_block != entry_block:
        current_block = idoms.get(current_block)
        if current_block is None:
            break

        if current_block in auth_blocks:
            dominating_auths.add(current_block)
        if current_block in potential_auth_blocks:
            privateCall.append(current_block)

    # 结果定性
    if len(dominating_auths) == 0 and len(privateCall) == 0:
        analysis_results.append({"status": "CRITICAL_VULNERABILITY", "found_auths": []})
    elif len(dominating_auths) != 0 and len(privateCall) == 0:
        analysis_results.append({"status": "NEEDS_POLICY_CHECK", "found_auths": list(dominating_auths)})
    elif len(dominating_auths) == 0 and len(privateCall) != 0:
        analysis_results.append({"status": "NEEDS_POLICY_CHECK", "found_auths": []})
    elif len(dominating_auths) != 0 and len(privateCall) != 0:
        analysis_results.append({"status": "NEEDS_POLICY_CHECK", "found_auths": list(dominating_auths)})

    return analysis_results, privateCall


# =====================================================================
# 辅助函数 3：宏观路径切割为代码块跳转
# =====================================================================
def convert_func_call_path_to_block_calls(func_path, df_func_calls):
    results = []
    for i in range(len(func_path) - 1):
        caller_func = str(func_path[i])
        callee_func = str(func_path[i + 1])

        matched = df_func_calls[
            (df_func_calls["caller_func"] == caller_func) &
            (df_func_calls["callee_func"] == callee_func)
            ]

        callsite_blocks = matched["caller"].dropna().unique().tolist()
        callee_entry_blocks = matched["callee_entry"].dropna().unique().tolist()

        results.append({
            "caller_func": caller_func,
            "callee_func": callee_func,
            "callsite_blocks": callsite_blocks,
            "callee_entry_blocks": callee_entry_blocks,
            "num_edges": len(matched)
        })
    return results