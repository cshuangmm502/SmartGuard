from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = PROJECT_ROOT / "contracts/ChainSwap/TokenMapped/out"
CONTRACT_NAME = "TokenMapped"
CONTRACT_ARTIFACTS_PATH = OUT_DIR.parent
out_dir = Path("output_debug")

def read_gigahorse_csv_as_csv(file_path: Path, filename, columns):
    """
    辅助函数：健壮地读取 Gigahorse CSV 文件。
    尝试从 path 和 path/out 读取，处理空文件情况。
    """
    file_path = Path(file_path).resolve()
    target_file = file_path / filename

    if target_file.exists() and target_file.stat().st_size > 0:
        try:
            # 使用 tab 分隔符 (Gigahorse 默认)，无表头
            df = pd.read_csv(target_file, delimiter='\t', header=None, engine='python')
            # 确保列数足够，否则补充
            if df.shape[1] < len(columns):
                return pd.DataFrame(columns=columns)
            return df.iloc[:, :len(columns)]
        except:
            return pd.DataFrame(columns=columns)
    else:
        return pd.DataFrame(columns=columns)

def read_gigahorse_csv_as_table(file_path: Path, filename, columns):
    """
    辅助函数：健壮地读取 Gigahorse CSV 文件。
    尝试从 path 和 path/out 读取，处理空文件情况。
    """
    file_path = Path(file_path).resolve()
    target_file = file_path / filename

    if target_file.exists() and target_file.stat().st_size > 0:
        try:
            # 使用 tab 分隔符 (Gigahorse 默认)，无表头
            df = pd.read_csv(target_file, delimiter='\t', header=None, engine='python')
            # 确保列数足够，否则补充
            if df.shape[1] < len(columns):
                return pd.DataFrame(columns=columns)
            return df.iloc[:, :len(columns)]
        except:
            return pd.DataFrame(columns=columns)
    else:
        return pd.DataFrame(columns=columns)

def output_Graph_to_file(G,file_name):
    out_dir = Path("output_debug")
    node_rows = []
    node_attr_keys = set()
    # 先收集所有节点属性key
    for n, attr in G.nodes(data=True):
        node_attr_keys.update(attr.keys())

    node_attr_keys = sorted(list(node_attr_keys))

    for n, attr in G.nodes(data=True):
        row = {"node_id": n}
        for k in node_attr_keys:
            row[k] = attr.get(k, None)
        node_rows.append(row)

    nodes_df = pd.DataFrame(node_rows)
    nodes_df.to_csv(out_dir / f"{file_name}_nodes.csv", index=False, encoding="utf-8-sig")

    # =====================
    # 导出边
    # =====================
    edge_rows = []
    edge_attr_keys = set()

    # 先收集所有边属性key
    for u, v, attr in G.edges(data=True):
        edge_attr_keys.update(attr.keys())

    edge_attr_keys = sorted(list(edge_attr_keys))

    for u, v, attr in G.edges(data=True):
        row = {"src": u, "dst": v}
        for k in edge_attr_keys:
            row[k] = attr.get(k, None)
        edge_rows.append(row)

    edges_df = pd.DataFrame(edge_rows)
    edges_df.to_csv(out_dir / f"{file_name}_edges.csv", index=False, encoding="utf-8-sig")

    print("Export finished: nodes.csv and edges.csv")

def output_dataFrame_to_file(data,file_name):
    out_dir = Path("output_debug")
    out_dir.mkdir(parents=True, exist_ok=True)
    data.to_excel(out_dir / f"{file_name}.xlsx", index=False)
    print("Saved to:", out_dir.resolve())

def convert_sloadVar_to_statement(path,var_stor):
    artifacts_dir = Path(path).resolve()
    out_dir = artifacts_dir / "out"

    print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
    # 1. 加载数据 (注意：Gigahorse 默认是 \t 分隔符，如果是逗号请改成 sep=',')
    opcodes = pd.read_csv(out_dir / "TAC_Op.csv", names=['stmt', 'opcode'], sep='\t')
    defines = pd.read_csv(out_dir / "TAC_Def.csv", names=['stmt', 'var', 'index'], sep='\t')
    uses = pd.read_csv(out_dir / "TAC_Use.csv", names=['stmt', 'var', 'index'], sep='\t')

#将tac变量转换为实际的值: 0x1349 -> 0x0 (ps:在tac中打印为v1349)
def convert_tacVar_to_value(path,variable):
    artifacts_dir = Path(path).resolve()
    out_dir = artifacts_dir / "out"

    print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
    variable_value = pd.read_csv(out_dir / "TAC_Variable_Value.csv", names=['variable', 'value'], sep='\t')

    values = variable_value[variable_value['variable'] == variable]['value'].tolist()
    value = values[0]

    return value

#将tac状态变量转换为带语义的状态变量： v1349(0x0) bytes 1 to 1 -> ___TokenMapped_init
def convert_tacNormalVar_to_solVar(path,variable):
    artifacts_dir = Path(path).resolve()
    out_dir = artifacts_dir / "out"

    print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")

#检查变量类型，普通类型返回 0，mapping/array 返回 1.
def check_storage_type_by_tacVar(path,variable):
    type_tag = 0
    artifacts_dir = Path(path).resolve()
    out_dir = artifacts_dir / "out"

    print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
    opcodes = pd.read_csv(out_dir / "TAC_Op.csv", names=['stmt', 'opcode'], sep='\t')
    defines = pd.read_csv(out_dir / "TAC_Def.csv", names=['stmt', 'var', 'index'], sep='\t')

    def_stmts = defines[defines['var'] == variable]['stmt'].tolist()

    sload_type = "普通状态变量 (Normal/Constant Key)"

    if def_stmts:
        def_stmt = def_stmts[0]
        # 3. 查看定义这个 Key 的指令到底是什么 Opcode
        def_opcode_series = opcodes[opcodes['stmt'] == def_stmt]['opcode']
        if not def_opcode_series.empty:
            def_opcode = def_opcode_series.values[0]

            # 核心逻辑：如果 Key 是由 SHA3 计算出来的，那就是 Mapping 或是动态数组
            if def_opcode == 'SHA3':
                sload_type = "Mapping / 动态数组 (SHA3 Hash Key)"
            # 如果是 ADD，且进一步是由 SHA3 计算的（结构体内的字段），也会呈现为 ADD
            elif def_opcode == 'ADD':
                sload_type = "可能为 Mapping 内的 Struct 字段 (ADD Offset)"
            type_tag = 1
    print(f" Key 变量: {variable:<5} | 预测类型: {sload_type}")
    return type_tag



if __name__ == "__main__":
    # [b, graph_index] = generate_ListandGraph(CONTRACT_ARTIFACTS_PATH)
    # find_SVD(CONTRACT_ARTIFACTS_PATH,b)
    # track_sload(CONTRACT_ARTIFACTS_PATH)
    value = convert_tacVar_to_value(CONTRACT_ARTIFACTS_PATH,'0x769')
    print(value)
    # convert_tacNormalVar_to_solVar(CONTRACT_ARTIFACTS_PATH,'')
    # tag = check_storage_type_by_tacVar(CONTRACT_ARTIFACTS_PATH, '0x5a7')
    # print(tag)

