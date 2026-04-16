# SC_extract.py: To extract the implemented potential security checks in contract.
# by Hauturier

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
    """
    提取相关语句状态变量使用情况，该实现是返回所有使用的状态变量，包括重复使用的
    返回形式：{带语义的状态变量名}:{对应stmtID}
    """
    related_blocks = []
    used_storage_info = []
    used_storage_row = Storage[Storage.iloc[:, 8].isin(BlockList)]
    if len(used_storage_row) != 0:
        for i in range(0, len(used_storage_row)):
            stor_semantic = used_storage_row.iloc[i, 3]
            # stor_variable = used_storage_row.iloc[i, 2]
            stor_stmt = used_storage_row.iloc[i, 0]
            related_block = used_storage_row.iloc[i, 8]
            related_blocks.append(related_block)
            used_storage = f'{stor_semantic}:{stor_stmt}'
            used_storage_info.append(used_storage)
        # print(f"该控制流使用的状态变量：{used_storage_info}")
    # else:
        # print("该控制流未使用状态变量")
    return used_storage_info, related_blocks


def extract_used_caller_in_controlFlow(BlockList, Caller):
    ## 提取public函数调用信息
    related_blocks = []
    used_caller_info = []
    used_caller_row = Caller[Caller.iloc[:, 4].isin(BlockList)]
    if len(used_caller_row) != 0:
        for i in range(0, len(used_caller_row)):
            caller_op = used_caller_row.iloc[i, 1]
            caller_def = used_caller_row.iloc[i, 2]
            related_block = used_caller_row.iloc[i, 4]
            related_blocks.append(related_block)
            used_caller = f'{caller_op}:{caller_def}'
            used_caller_info.append(used_caller)
    #     print(f"该控制流使用的调用者信息：{used_caller_infor}")
    # else:
    #     print('该控制流未使用调用者信息')

    return used_caller_info, related_blocks


def extract_used_callData_in_controlFlow(BlockList, CallData):
    ## 提取public函数CallData信息
    ## 返回形式：{操作码}:{产生的变量}
    related_blocks = []
    used_calldata_info = []
    used_calldata_row = CallData[CallData.iloc[:, 4].isin(BlockList)]
    if len(used_calldata_row) != 0:
        for i in range(0, len(used_calldata_row)):
            calldata_op = used_calldata_row.iloc[i, 1]
            calldata_def = used_calldata_row.iloc[i, 2]
            related_block = used_calldata_row.iloc[i, 4]
            related_blocks.append(related_block)
            used_calldata = f'{calldata_op}:{calldata_def}'
            used_calldata_info.append(used_calldata)
    #     print(f"该控制流使用的调用参数信息：{used_calldata_infor}")
    # else:
    #     print('该控制流未使用调用参数信息')

    return used_calldata_info, related_blocks


def extract_used_callPubArgs_in_controlFlow(BlockList, CallPubArgs):
    ## 提取public函数参数调用信息
    ## 返回形式：{变量名}:{语句stmtID}
    related_blocks = []
    used_publicargs_info = set()
    used_publicargs_row = CallPubArgs[CallPubArgs.iloc[:, 2].isin(BlockList)]
    if len(used_publicargs_row) != 0:
        for i in range(0, len(used_publicargs_row)):
            args_var = used_publicargs_row.iloc[i, 1]
            args_stmt = used_publicargs_row.iloc[i, 0]
            related_block = used_publicargs_row.iloc[i, 2]
            related_blocks.append(related_block)
            used_arg_info = f'{args_var}:{args_stmt}'
            used_publicargs_info.add(used_arg_info)
    #     print(f"该控制流使用的Public function Args信息：{used_publicargs_info}")
    # else:
    #     print('该控制流未使用Public function Args信息')

    return list(used_publicargs_info), related_blocks


def extract_used_callPriArgs_in_controlFlow(BlockList, CallPriArgs):
    ## 提取私有函数参数调用信息
    ## 返回形式：{变量名}:{语句stmtID}
    related_blocks = []
    used_formalargs_info = set()
    used_formalargs_row = CallPriArgs[CallPriArgs.iloc[:, 2].isin(BlockList)]
    if len(used_formalargs_row) != 0:
        for i in range(0, len(used_formalargs_row)):
            args_var = used_formalargs_row.iloc[i, 1]
            args_stmt = used_formalargs_row.iloc[i, 0]
            related_block = used_formalargs_row.iloc[i, 2]
            related_blocks.append(related_block)
            used_arg_info = f'{args_var}:{args_stmt}'
            used_formalargs_info.add(used_arg_info)
    #     print(f"该控制流使用的FormalArgs信息：{used_formalargs_info}")
    # else:
    #     print('该控制流未使用FormalArgs信息')

    return list(used_formalargs_info), related_blocks


def SecurityCheckExtraction_block(BlockList, Storage, Caller, CallData, CallPubArgs, CallFormalArgs):
    used_storage_info, related_blocks = extract_used_storage_in_controlflow(BlockList, Storage)
    used_caller_info = extract_used_caller_in_controlFlow(BlockList, Caller)
    used_callData_info = extract_used_callData_in_controlFlow(BlockList, CallData)
    used_publicArgs_info = extract_used_callPubArgs_in_controlFlow(BlockList, CallPubArgs)
    used_priArgs_info = extract_used_callPriArgs_in_controlFlow(BlockList, CallFormalArgs)
    return [used_storage_info, used_caller_info, used_callData_info, used_publicArgs_info, used_priArgs_info]