import re
import pandas as pd
from pathlib import Path
from typing import Tuple

def generate_ListandGraph(tac_file) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """
       Parse `contract.tac` under out_dir and build:
         - b: dataframe of 3IR lines with extracted fields
         - graph_index: dataframe of (current, prev, succ) edges from 'prev' lines
    """
    full_tac = tac_file

    # Initialize columns
    full_tac.columns = ["3IR"]
    full_tac["blockname"] = "0"
    full_tac["leftvariable"] = "0"
    full_tac["rightvariable"] = "0"
    full_tac["option"] = "0"
    full_tac["function"] = "0"

    current_block = "0"

    graph_index = pd.DataFrame(columns=["current", "prev", "succ"])

    rows = []

    for i in range(len(full_tac)):
        line = str(full_tac.iloc[i, 0])

        # block name extraction
        tag = line.find("function")
        if tag >= 0:
            current_block = "0"
        blockindex = line.find("block")
        if blockindex > 0:
            current_block = line[(blockindex + 6):]  # keep original logic
        full_tac.iloc[i, 1] = current_block

        # tokenize
        bsplit = re.split(r"(?:[, :\s()])", line)

        if bsplit.count("=") > 0:
            eindex = bsplit.index("=")
            # option
            if eindex + 1 < len(bsplit):
                full_tac.iloc[i, 4] = bsplit[eindex + 1]
            # 这种提取方法会将类似v115(0xf45ad43)的括号中的内容忽略
            # leftvariable: first token containing 'v' before '='
            for p in range(eindex):
                findvar = bsplit[p]
                if "v" in findvar:
                    full_tac.iloc[i, 2] = findvar

            # rightvariable: concat tokens containing 'v' after '='
            right_vars = []
            for p in range(eindex, len(bsplit)):
                if "v" in bsplit[p]:
                    right_vars.append(bsplit[p])
            if right_vars:
                full_tac.iloc[i, 3] = "," + ",".join(right_vars)

        else:
            if len(bsplit) > 7 and "succ" not in line:
                # option (keep original index 6)
                full_tac.iloc[i, 4] = bsplit[6] if len(bsplit) > 6 else full_tac.iloc[i, 4]

                right_vars = []
                for tok in bsplit:
                    if "v" in tok:
                        right_vars.append(tok)
                if right_vars:
                    full_tac.iloc[i, 3] = "," + ",".join(right_vars)

        # function name extraction
        if "function" in line:
            fun_split = re.split(r"(?:[() ])", line)
            # guard index
            if len(fun_split) > 1:
                full_tac.iloc[i, 5] = fun_split[1]
        else:
            if i > 0:
                full_tac.iloc[i, 5] = full_tac.iloc[i - 1, 5]

        if "prev" in line:
            graph_split = re.split(r"(?:[=\[\]])", line)
            if len(graph_split) > 6:
                rows.append(
                    {"current": full_tac.iloc[i, 1], "prev": graph_split[2], "succ": graph_split[5]}
                )
    if rows:
        graph_index = pd.concat([graph_index, pd.DataFrame(rows)], ignore_index=True)

    return full_tac, graph_index
    # print(b)

    # Head=pd.read_table("IfThenElseHead.csv",delimiter='\t',header=None)
    # Predicate=pd.read_table("IfThenElsePredicate.csv",delimiter='\t',header=None)
    # Consequent=pd.read_table("IfThenElseConsequent.csv",delimiter='\t',header=None)
    # Alternative=pd.read_table("IfThenElseAlternative.csv",delimiter='\t',header=None)


def generate_IfThenElseHead(b):
    """
    通过分析 TAC 指令表 b，找出所有包含条件跳转 (JUMPI) 的 Block。
    这些 Block 就是 IfThenElse 的头部。
    """
    # 1. 筛选出所有包含 "JUMPI" 指令的行
    # b.iloc[:, 0] 是 3IR 指令列
    # b.iloc[:, 1] 是 blockname 列

    # 确保转为字符串处理
    jumpi_rows = b[b.iloc[:, 0].astype(str).str.contains("JUMPI", case=False, na=False)]

    # 2. 提取这些行的 blockname
    head_blocks = jumpi_rows.iloc[:, 1].unique()

    # 3. 构建与原 CSV 格式一致的 DataFrame
    Head = pd.DataFrame(head_blocks, columns=["Block"])

    return Head


# print(graph_index)


# HeadSearch
def find_succ_block(Headblock, graph_index):
    """
    查找从 Headblock 开始的所有可达后续块 (Reachability Analysis)。

    改进点：
    1. 移除了 depth 参数：只要是逻辑上连通的后续块，都会被找到，不再会有漏报。
    2. 使用 DFS (栈) 替代 BFS (层)：便于全路径遍历。
    3. 结果排序：保证每次运行输出顺序一致。
    """
    start_block = str(Headblock).strip()

    # 使用集合记录已访问节点，防止死循环
    visited = set()
    visited.add(start_block)

    # 使用栈 (Stack) 进行遍历 -> 这实际上是 DFS 的非递归实现
    # 如果你想用 BFS，把 stack.pop() 改成 stack.pop(0) 即可，结果集是一样的
    stack = [start_block]

    while stack:
        current_block = stack.pop()

        # 优化：一次性在 graph_index 中找到当前块的所有后继记录
        # graph_index 的列结构: [current, prev, succ]
        matches = graph_index[graph_index['current'] == current_block]

        for _, row in matches.iterrows():
            # 兼容性处理：优先用列名，防错
            if 'succ' in row:
                succ_val = row['succ']
            else:
                succ_val = row.iloc[2]

            succ_str = str(succ_val).strip()

            # 有效性检查
            if succ_str and succ_str.lower() != 'nan' and succ_str != 'None' and succ_str != '0':
                # 分割字符串 "0xd, 0x94e10"
                succ_split = re.split(r'[,]', succ_str)

                for element in succ_split:
                    next_block = element.strip()
                    if next_block and next_block not in visited:
                        visited.add(next_block)
                        stack.append(next_block)

    # 返回排序后的列表，解决顺序不一致问题
    return sorted(list(visited))

# PredicateSearch

def find_succ_predicate(Predicate, depth, b, graph_index):
    # [b, graph_index] = generate_ListandGraph(path)
    Predicate_succ = []
    Predicate_block = []
    Predicate_succ.append(Predicate)
    for m in range(0, depth):
        for k in range(0, len(Predicate_succ)):
            # print(Head_succ[k])
            # print(Head_succ)
            for n in range(0, len(b)):
                if (b.iloc[n, 2] == Predicate_succ[k]):
                    if (len(b.iloc[n, 3]) != 0):
                        succ_split = re.split(r'(?:[,])', b.iloc[n, 3])
                        for p in range(1, len(succ_split)):
                            Predicate_succ.append(succ_split[p])
    for q in range(0, len(b)):
        for y in range(0, len(Predicate_succ)):
            if (Predicate_succ[y] == b.iloc[q, 2]):
                Predicate_block.append(b.iloc[q, 1])
    return [list(set(Predicate_succ)), list(set(Predicate_block))]


# test
# [b, graph_index] = generate_ListandGraph(OUT_DIR)
# print(b)

# A=find_succ_block("0x230",3,b,graph_index)
# print(A)

# [B,C]=find_succ_predicate("v24c",3,b,graph_index)
# print(B)
# print(C)


# python3 Procession.py
# test
if __name__ == "__main__":
    tes, graph_index = generate_ListandGraph(OUT_DIR.parent)
    a = find_succ_block("0x0",graph_index)
    print(a)
    # out_dir = Path("output_debug")
    # out_dir.mkdir(parents=True, exist_ok=True)
    #
    # b.to_csv(out_dir / "b.csv", index=False, encoding="utf-8")
    # graph_index.to_csv(out_dir / "graph_index.csv", index=False, encoding="utf-8")
    # b.to_excel(out_dir / "b.xlsx", index=False)
    # graph_index.to_excel(out_dir / "graph_index.xlsx", index=False)

    # print("Saved to:", out_dir.resolve())
    # print(b)
