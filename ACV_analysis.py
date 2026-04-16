from pathlib import Path
import pandas as pd
import networkx as nx
from SC_extract import (extract_used_storage_in_controlflow, extract_used_caller_in_controlFlow,
                        extract_used_callData_in_controlFlow, extract_used_callPubArgs_in_controlFlow,
                        extract_used_callPriArgs_in_controlFlow)


def convert_func_call_path_to_block_calls(func_path, df_func_calls):
    """
    描述：将函数级的调用路径转换为精确的tac block级别的调用路径
    参数:
        func_path: 函数级调用路径
        df_func_calls： 函数调用关系表
    返回:
        {
            "relevant_blocks": ...,
            "dominators": ...,
            "idom": ...,
            "control_blocks": ...,
            "must_pass_key_blocks": ...,
            "source_key_blocks": ...,
            "key_blocks": ...,
            "idom_chain": ...,
            "skeleton_chain": ...
        }
    """
    results = []
    for i in range(len(func_path) - 1):
        caller_func = str(func_path[i])
        callee_func = str(func_path[i + 1])

        matched = df_func_calls[
            (df_func_calls["caller_func"] == caller_func) &
            (df_func_calls["callee_func"] == callee_func)
            ]

        callsite_blocks = matched["caller_block"].dropna().unique().tolist()
        callee_entry_blocks = matched["callee_block"].dropna().unique().tolist()

        results.append({
            "caller_func": caller_func,
            "callee_func": callee_func,
            "callsite_blocks": callsite_blocks,  # 比如 ['0x8f410']
            "callee_entry_blocks": callee_entry_blocks,  # 比如 ['0x3d8']
            "num_edges": len(matched)
        })
    return results


# def extract_key_path_in_single_func(caller_block, callee_block, local_control_flow_graph):
#     # 假设图的入口点是函数的 entry_block
#     # 计算从 entry_block 开始，所有节点的支配者
#     dominators = nx.immediate_dominators(local_control_flow_graph, caller_block)
#     print(f"current function is:{caller_block}")
#     print(f"dominators:{dominators}")
#     # 找函数内部路径
#     # internal_paths = list(nx.all_simple_paths(local_control_flow_graph, caller_block, callee_block))
#     # print(f"interal_paths:{internal_paths}")


def detect_access_control_violation(G, entry_block, sensitive_blocks, auth_blocks):
    """
    使用支配树检测访问控制缺失漏洞
    G: 函数的控制流图
    entry_block: 函数入口块的ID
    auth_blocks: 包含鉴权逻辑（如 msg.sender 检查）的块ID集合 (Set)
    sensitive_blocks: 包含敏感操作（如转账、提款 SSTORE）的块ID集合 (Set)
    """
    if entry_block not in G:
        print("入口块不在图中")
        return []

    # 1. 计算支配者 (Dominators)
    # nx.immediate_dominators 返回一个字典，格式为 {node: its_immediate_dominator}
    # 含义：在控制流图中，从 entry_block 到达 node，必须经过的"最近的那个必经节点"
    idoms = nx.immediate_dominators(G, entry_block)

    vulnerabilities = []

    # 2. 检查每个敏感块是否受到保护
    for sensitive_block in sensitive_blocks:
        if sensitive_block not in G:
            continue

        is_protected = False
        current_block = sensitive_block

        # 3. 顺着支配树向上回溯，直到函数的入口点
        while current_block != entry_block:
            # 获取当前块的直接支配者
            current_block = idoms.get(current_block)

            # 如果到达了图的连通分量之外（不连通），跳出
            if current_block is None:
                break

            # 如果回溯过程中遇到了鉴权块，说明到达该敏感块的所有路径都必须经过鉴权！
            if current_block in auth_blocks:
                is_protected = True
                break

        # 4. 如果回溯到了入口点都没遇到 auth_blocks，说明存在绕过路径！
        if not is_protected:
            vulnerabilities.append({
                "sensitive_block": sensitive_block,
                "reason": "未被任何已知的鉴权节点支配 (存在绕过路径)"
            })

    return vulnerabilities


def ACV_analysis(df_functionCall, df_block_in_func, emitting_functions, informing_functions, func_call_graph,
                 global_control_flow_graph, storage, caller, callData, callPubArgs, callPriArgs):
    # 预加载分析文件

    df_func_calls = df_functionCall
    df_in_func = df_block_in_func
    block_to_func = dict(zip(df_in_func.iloc[:, 0].astype(str), df_in_func.iloc[:, 1].astype(str)))

    df_func_calls["caller_block"] = df_func_calls["caller_block"].astype(str)
    df_func_calls["callee_block"] = df_func_calls["callee_block"].astype(str)
    df_func_calls["caller_func"] = df_func_calls["caller_block"].map(block_to_func)
    df_func_calls["callee_func"] = df_func_calls["callee_block"].map(block_to_func)

    source_func = "0x0"
    # 分析外部调用入口到关键资源的调用路径上的访问控制漏洞
    for target_func in emitting_functions:
        print(f"The current processing function is :{target_func}")
        if source_func not in func_call_graph.nodes or target_func not in func_call_graph.nodes:
            print(f"Source function or target function not in function call graph")
            continue

        # 核心：寻找所有独立路径，cutoff=6 防止指数级爆炸导致卡死
        paths = list(nx.all_simple_paths(func_call_graph, source_func, target_func, cutoff=6))

        for func_path in paths:
            print(f"func_path: {func_path}")
            block_call_chain = convert_func_call_path_to_block_calls(func_path, df_func_calls)
            print(f"block_call_chain:{block_call_chain}")
            for hop in block_call_chain:
                caller_func = hop["caller_func"]
                func_blocks = df_in_func[df_in_func['func_id'] == caller_func]['block'].tolist()
                # 构造函数子图 (Subgraph) -> 这样可以防止路径跑到其他函数去
                sub_G = global_control_flow_graph.subgraph(func_blocks)
                # 可能有多个调用点，比如 if 和 else 里各调了一次
                for callsite in hop["callsite_blocks"]:
                    used_storage_info, storage_blocks = extract_used_storage_in_controlflow(func_blocks, storage)
                    used_caller_info, caller_blocks = extract_used_caller_in_controlFlow(func_blocks, caller)
                    used_callData_info, callData_blocks = extract_used_callData_in_controlFlow(func_blocks, callData)
                    used_pubArgs_info, callPubArgs_blocks = extract_used_callPubArgs_in_controlFlow(func_blocks,
                                                                                                    callPubArgs)
                    used_priArgs_info, callPriArgs_blocks = extract_used_callPriArgs_in_controlFlow(func_blocks,
                                                                                                    callPriArgs)
                    # 获取该函数的入口块 (通常可以通过 public function csv 查到，或者近似认为就是 caller_func 本身)
                    func_entry_block = caller_func

                    detect_access_control_violation(sub_G, func_entry_block, callsite, )

                    # 找函数内部路径
                    # internal_paths = list(nx.all_simple_paths(global_control_flow_graph, func_entry_block, callsite))
                    # print(f"interal_paths:{internal_paths}")
                    # for p in internal_paths:
                    #     # 检查这条具体的内部路径上，有没有安检印章
                    #     is_secure = False
                    #     for blk in p:
                    #         if blk in model_dict and model_dict[blk]['msg'] == 1:
                    #             is_secure = True
                    #             break
                    #
                    #     if not is_secure:
                    #         print(
                    #             f"🚨 漏洞警告！在函数 {caller_func} 中，通往调用点 {callsite} 的某条路径没有任何权限检查！")
