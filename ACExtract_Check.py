from Procession import *
from pathlib import Path

def parsefromdecompiledcode(decompiledcode_file) \
        -> pd.DataFrame:
    """
    解析反编译的 .sol 文件以提取 mapping 和状态变量的语义信息。
    返回: Storage_semantic
    """
    decompiledcode = decompiledcode_file

    decompiledcode.columns = ["decompiledcode"]
    # 2. 初始化 DataFrame (新增 "Name" 列)
    # Semantic: 存储 0x... (Slot ID)
    # Name:     存储 变量名 (如 _owner, _balances)
    Stor_semantic = pd.DataFrame(columns=["describtion", "state_variable", "Semantic", "Name"])
    Map_semantic = pd.DataFrame(columns=["describtion", "mapping_variable", "Semantic", "Name"])

    Storage_semantic = pd.DataFrame(columns=['description', 'semantic','var_type', 'slot', 'slot_Offset'])

    in_variable_zone = True

    for m in range(len(decompiledcode)):
        line = str(decompiledcode.iloc[m, 0]).strip()

        # 3. 终止条件 (Function / Event)
        if line.startswith("function ") or line.startswith("constructor") or line.startswith(
                "modifier ") or line.startswith("// Events"):
            in_variable_zone = False
            break

        if not in_variable_zone:
            continue

        # 忽略无效行
        if not line or (line.startswith("//") and "STORAGE" not in line):
            continue

        # 4. 提取 Slot ID (核心语义)
        # 优先匹配 Dedaub 的 // STORAGE[0x...] 格式
        # slot_match = re.search(r'//\s*STORAGE\[(0x[0-9a-fA-F]+)\]', line)
        slot_match = re.search(r'//\s*STORAGE\[(0x[0-9a-fA-F]+)\](?:\s+(bytes\s+\d+\s+to\s+\d+))?', line)
        if not slot_match:
            # 备用匹配简单的 // 0x...
            slot_match = re.search(r'//\s*(0x[0-9a-fA-F]+)\s*$', line)

        current_slot_id = slot_match.group(1) if slot_match else None


        slot_Offset = "bytes 0 to 31"
        if slot_match and slot_match.group(2):
            slot_Offset = slot_match.group(2)


        # 如果没有 Slot ID，通常意味着它是常量(constant)或不可变变量(immutable)
        # 这种变量不占用 Storage Slot，通常不参与存储碰撞漏洞，这里选择跳过
        if current_slot_id is None:
            continue

            # --- 解析 Mapping ---
        if "mapping" in line:
            # 提取变量名：_balances
            map_match = re.search(r'mapping\s*\(.*\)\s*(?:public|private|internal|external)?\s*([a-zA-Z0-9_]+);', line)

            if map_match:
                var_name = map_match.group(1)

                # new_row = pd.Series({
                #     "describtion": line,
                #     "mapping_variable": var_name,  # 保持原格式
                #     "Semantic": current_slot_id,  # 存 Slot ID (0x...)
                #     "Name": var_name  # 【新增】存变量名
                # })
                new_row = pd.Series({
                    "description": line,  # 原语句
                    "semantic": var_name,  # 带语义的变量名
                    "var_type": 1,  # 变量状态类型：0 -> 普通状态变量，1 -> mapping
                    "slot": current_slot_id,  # 【新增】存变量名
                    "slot_Offset": slot_Offset # 存储槽内的存储地址
                })

                # Map_semantic = Map_semantic.append(new_row, ignore_index=True)
                Storage_semantic = Storage_semantic.append(new_row, ignore_index=True)

        # --- 解析 普通状态变量 ---
        else:
            # 提取变量名：_owner
            var_match = re.search(
                r'^\s*([a-zA-Z0-9_\[\]\.]+)\s+(?:public|private|internal|external|constant|immutable)?\s*([a-zA-Z0-9_]+)\s*(?:=.*?)?;',
                line)

            if var_match:
                var_type = var_match.group(1)
                var_name = var_match.group(2)

                if var_type not in ["event", "error", "using", "mapping"]:
                    new_row = pd.Series({
                        "description": line,  # 原语句
                        "semantic": var_name,  # 带语义的变量名
                        "var_type": 0,  # 变量状态类型：0 -> 普通状态变量，1 -> mapping
                        "slot": current_slot_id,  # 【新增】存变量名
                        "slot_Offset": slot_Offset  # 存储槽内的存储地址
                    })
                    # Stor_semantic = Stor_semantic.append(new_row, ignore_index=True)
                    Storage_semantic = Storage_semantic.append(new_row, ignore_index=True)

    return Storage_semantic


def extract_used_storage_in_controlflow(BlockList, Storage):
    ## 提取相关语句状态变量使用情况，该实现是返回所有使用的状态变量，包括重复使用的
    ## 返回形式：{带语义的状态变量名}:{对应stmtID}
    used_storage_info = []
    used_storage_row = Storage[Storage.iloc[:, 8].isin(BlockList)]
    if len(used_storage_row) != 0:
        for i in range(0, len(used_storage_row)):
            stor_semantic = used_storage_row.iloc[i, 3]
            # stor_variable = used_storage_row.iloc[i, 2]
            stor_stmt = used_storage_row.iloc[i, 0]
            used_storage = f'{stor_semantic}:{stor_stmt}'
            used_storage_info.append(used_storage)
        # print(f"该控制流使用的状态变量：{used_storage_info}")
    # else:
        # print("该控制流未使用状态变量")
    return used_storage_info

def extract_used_Caller_in_controlflow(BlockList, Caller):
    ## 提取public函数调用信息
    used_caller_infor = []
    used_caller_row = Caller[Caller.iloc[:, 4].isin(BlockList)]
    if len(used_caller_row) != 0:
        for i in range(0, len(used_caller_row)):
            caller_op = used_caller_row.iloc[i, 1]
            caller_def = used_caller_row.iloc[i, 2]
            used_caller = f'{caller_op}:{caller_def}'
            used_caller_infor.append(used_caller)
    #     print(f"该控制流使用的调用者信息：{used_caller_infor}")
    # else:
    #     print('该控制流未使用调用者信息')

    return used_caller_infor

def extract_used_CallData_in_controlflow(BlockList, CallData):
    ## 提取public函数CallData信息
    ## 返回形式：{操作码}:{产生的变量}
    used_calldata_infor = []
    used_calldata_row = CallData[CallData.iloc[:, 4].isin(BlockList)]
    if len(used_calldata_row) != 0:
        for i in range(0, len(used_calldata_row)):
            calldata_op = used_calldata_row.iloc[i, 1]
            calldata_def = used_calldata_row.iloc[i, 2]
            used_calldata = f'{calldata_op}:{calldata_def}'
            used_calldata_infor.append(used_calldata)
    #     print(f"该控制流使用的调用参数信息：{used_calldata_infor}")
    # else:
    #     print('该控制流未使用调用参数信息')

    return used_calldata_infor

def extract_used_CallPubArgs_in_controlflow(BlockList, CallPubArgs):
    ## 提取public函数参数调用信息
    ## 返回形式：{变量名}:{语句stmtID}
    used_publicargs_info = set()

    used_publicargs_row = CallPubArgs[CallPubArgs.iloc[:, 2].isin(BlockList)]
    if len(used_publicargs_row) != 0:
        for i in range(0, len(used_publicargs_row)):
            args_var = used_publicargs_row.iloc[i, 1]
            args_stmt = used_publicargs_row.iloc[i, 0]
            used_arg_info = f'{args_var}:{args_stmt}'
            used_publicargs_info.add(used_arg_info)
    #     print(f"该控制流使用的Public function Args信息：{used_publicargs_info}")
    # else:
    #     print('该控制流未使用Public function Args信息')

    return list(used_publicargs_info)

def extract_used_CallFormalArgs_in_controlflow(BlockList, CallFormalArgs):
    ## 提取私有函数参数调用信息
    ## 返回形式：{变量名}:{语句stmtID}
    used_formalargs_info = set()

    used_formalargs_row = CallFormalArgs[CallFormalArgs.iloc[:, 2].isin(BlockList)]
    if len(used_formalargs_row) != 0:
        for i in range(0, len(used_formalargs_row)):
            args_var = used_formalargs_row.iloc[i, 1]
            args_stmt = used_formalargs_row.iloc[i, 0]
            used_arg_info = f'{args_var}:{args_stmt}'
            used_formalargs_info.add(used_arg_info)
    #     print(f"该控制流使用的FormalArgs信息：{used_formalargs_info}")
    # else:
    #     print('该控制流未使用FormalArgs信息')

    return list(used_formalargs_info)

def SecurityCheckExtraction_block(BlockList, Storage, Caller, CallData, CallPubArgs, CallFormalArgs):
    used_storage_info = extract_used_storage_in_controlflow(BlockList, Storage)
    used_caller_infor = extract_used_Caller_in_controlflow(BlockList, Caller)
    used_calldata_infor = extract_used_CallData_in_controlflow(BlockList, CallData)
    used_publicargs_info = extract_used_CallPubArgs_in_controlflow(BlockList, CallPubArgs)
    used_formalargs_info = extract_used_CallFormalArgs_in_controlflow(BlockList, CallFormalArgs)
    return [used_storage_info, used_caller_infor, used_calldata_infor, used_publicargs_info, used_formalargs_info]


# ==========================================
# 主控函数
# ==========================================
def extraction_all(b, graph_index, Storage, Caller, CallData, CallPubArgs, CallFormalArgs):

    # 1. 自动生成所有JUMPI语句所在块号，不再读取不存在的 csv,回头可以使用tac_analyze_scripts中的代码进行替换
    Head = generate_IfThenElseHead(b)
    # print(len(Head))
    out_dir = Path("output_debug")
    out_dir.mkdir(parents=True, exist_ok=True)
    Head.to_excel(out_dir / "JUMPI_block.xlsx", index=False)
    if len(Head) == 0:
        # 如果没找到 JUMPI，说明合约可能很简单，没有分支
        return pd.DataFrame(columns=["Block", "Storage", "Caller", "Calldata", "Args", "signature", "transfer"])

    Model_normal = pd.DataFrame(columns=["Block", "Storage", "Caller", "Calldata", "PublicArgs", "FormalArgs", "signature", "transfer"])
    # 2. 遍历每个分支入口
    for m in range(0, len(Head)):
        start_block = Head.iloc[m, 0]
        # print(f"start_block is {start_block}")
        # 3. 查找后续块
        head_list = find_succ_block(start_block, graph_index)
        # print(f"{start_block} later blocks:{head_list}")
        # 4. 执行检测
        [stor, caller, calldata, publicargs, formalargs] = SecurityCheckExtraction_block(head_list, Storage, Caller, CallData, CallPubArgs, CallFormalArgs, b)

        # 5. 记录有效结果
        if len(stor) != 0 or len(caller) != 0 or len(calldata) != 0 or len(publicargs) != 0 or len(formalargs) != 0:
            line1 = pd.Series({
                "Block": start_block,
                "Storage": stor,
                "Caller": caller,
                "Calldata": calldata,
                "PublicArgs": publicargs,
                "FormalArgs": formalargs,
                "signature": 0,
                "transfer": 0
            })
            Model_normal = Model_normal.append(line1, ignore_index=True)

    # 去重
    # Model_normal.drop_duplicates(inplace=True)
    return Model_normal



#test
if __name__ == "__main__":
    print("1")
    # [b, graph_index] = generate_ListandGraph(CONTRACT_ARTIFACTS_PATH)
    # Storage_semantic = parsefromdecompiledcode(CONTRACT_ARTIFACTS_PATH,CONTRACT_NAME)

    # [Storage, Mapping] = extract_storage(CONTRACT_ARTIFACTS_PATH, Map_semantic, Stor_semantic, CONTRACT_NAME)

    # out_dir = Path("output_debug")
    # out_dir.mkdir(parents=True, exist_ok=True)
    # Map_semantic.to_excel(out_dir / "Map_semantic.xlsx", index=False)
    # Storage.to_excel(out_dir / "Storage_ne.xlsx", index=False)
    # Mapping.to_excel(out_dir / "Mapping.xlsx", index=False)
    # Storage.to_excel(out_dir / "Storage.xlsx", index=False)
    # Model_normal.to_excel(out_dir / "Model_normal.xlsx", index=False)