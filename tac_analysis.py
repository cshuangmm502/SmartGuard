from pathlib import Path
import pandas as pd


# def extract_all_events(path: Path):
#     artifacts_dir = Path(path).resolve()
#     out_dir = artifacts_dir / "out"
#
#     print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
#     opcodes = pd.read_csv(out_dir / "TAC_Op.csv", names=['stmt', 'opcode'], sep='\t')
#     var_value = pd.read_csv(out_dir / "TAC_Variable_Value.csv", names=['var', 'value'], sep='\t')
#     uses = pd.read_csv(out_dir / "TAC_Use.csv", names=['stmt', 'var', 'index'], sep='\t')
#     sign_eventname = pd.read_csv(out_dir / "EventSignatureInContract.csv", names=['signature', 'event_name'], sep='\t')
#     stmt_block = pd.read_csv(out_dir / "TAC_Block.csv", names=['stmt', 'blockID'], sep='\t')
#
#     # print("\n🔍 正在提取 event 使用情况...\n")
#
#     event_stmts = opcodes[opcodes['opcode'].isin(['LOG1', 'LOG2', 'LOG3', 'LOG4'])].copy()
#
#     topic0_vars = uses[
#         (uses['stmt'].isin(event_stmts['stmt'])) &
#         (uses['index'] == 2)
#         ].copy()
#
#     topic0_with_sign = topic0_vars.merge(var_value, on='var', how='left')
#     topic0_with_sign = topic0_with_sign.rename(columns={'value': 'signature'})
#     topic0_with_name = topic0_with_sign.merge(sign_eventname, on='signature', how='left')
#     events = topic0_with_name.merge(stmt_block, on='stmt', how='left')
#     events = events[['stmt', 'signature', 'event_name', 'blockID']]
#
#     return events
#

def extract_all_storage(df_opcodes, df_defines, df_uses, df_var_values, df_mapping_slot, df_stmts_in_block,
                        storage_semantic):
    """
    基于tac facts提取所有使用的storage状态
    :param df_opcodes: 基于TAC_Op.csv的dataframe
    :param df_defines: TAC_Def.csv的dataframe
    :param df_uses: TAC_Use.csv的dataframe
    :param df_var_values: 基于TAC_Variable_Value.csv的dataframe
    :param df_mapping_slot: 基于MappingBaseSlot.csv的dataframe
    :param df_stmts_in_block: 基于TAC_Block.csv的dataframe
    :param storage_semantic: 基于反编译代码提取的状态语义表的dataframe
    :return: 输入合约使用到的存储状态信息
    """
    opcodes = df_opcodes
    defines = df_defines
    uses = df_uses
    var_values = df_var_values
    mapping_slots = df_mapping_slot
    stmt_block = df_stmts_in_block

    # --- 辅助函数：根据变量名获取常量值 ---
    def get_constant_value(var_name):
        match = var_values[var_values['var'] == var_name]['value']
        return str(match.values[0]).strip() if not match.empty else None

    # print("\n🔍 正在提取并分类所有的 SLOAD 操作及 Slot...\n")
    # print(f"{'指令 ID':<12} | {'Key 变量':<10} | {'解析出的 Slot (十六进制)':<30} | {'变量类型':<12} | {'是否打包'} | {'slot偏移量'} | {'描述'} ")
    # print("-" * 90)

    sload_stmts = opcodes[opcodes['opcode'] == 'SLOAD']['stmtID'].tolist()

    storage = pd.DataFrame(
        columns=['stmtID', 'variable', 'slot', 'semantic', 'var_type', 'is_package', 'slot_Offset', 'describe',
                 'blockID'])

    for sload_stmt in sload_stmts:
        key_vars = uses[uses['stmtID'] == sload_stmt]['var'].tolist()
        if not key_vars: continue
        key_var = key_vars[0]
        sload_type = -1
        sload_type_info = "未知 (Unknown)"
        is_package_slot = False
        is_constant = False
        base_slot = "0"

        # 1. 检查是否为普通变量
        val_match = var_values[var_values['var'] == key_var]['value']
        if not val_match.empty:
            base_slot = str(val_match.values[0]).strip()
            # slot_info = f"Slot: {base_slot}"
            sload_type = 0
            sload_type_info = f"🟢 普通变量 (Normal)-> Slot: {base_slot}"
            is_constant = True

        # 2. 如果不是常量，使用 Datalog 跑出的结果！
        if not is_constant:
            # 去 Datalog 的结果表里查一下，这个 SLOAD 在不在里面？
            dl_match = mapping_slots[mapping_slots['stmtID'] == sload_stmt]
            if not dl_match.empty:
                base_slot = str(dl_match['base_slot'].values[0]).strip()
                # slot_info = f"Base Slot: {base_slot} ({key_var})"
                sload_type = 1
                sload_type_info = f"🔵 Mapping (Datalog 跨块追踪)-> Base Slot: {base_slot} ({key_var})"
            else:
                # Datalog 也没找到？那我们只能退回到基本推导，看它是不是 SHA3 或 ADD
                def_stmts = defines[defines['var'] == key_var]['stmtID'].tolist()
                if def_stmts:
                    def_opcode_series = opcodes[opcodes['stmtID'] == def_stmts[0]]['opcode']
                    if not def_opcode_series.empty:
                        def_opcode = def_opcode_series.values[0]
                        if def_opcode == 'SHA3':
                            sload_type = 2
                            sload_type_info = f"🔵 Mapping (嵌套或动态)-> 由 SHA3 计算得出 ({key_var})"
                            # slot_info = f"由 SHA3 计算得出 ({key_var})"
                        elif def_opcode == 'ADD':
                            sload_type = 3
                            sload_type_info = f"🟡 结构体/数组偏移 (ADD)-> 基址 + 偏移量 ({key_var})"
                            # slot_info = f"基址 + 偏移量 ({key_var})"
        pack_info = "32-byte 全槽 (uint256/bytes32)"
        # ========================================================
        # 🚀 进阶挖掘：解析 Slot Packing (Offset 和 类型截断)
        # ========================================================
        # 1. 找到 SLOAD "定义(Defines)" 了哪个变量 (读出来的 32 bytes 原始数据)
        # 🚀 进阶挖掘：转换为反编译器视角的 bytes X to Y
        # ========================================================
        sload_def_vars = defines[defines['stmtID'] == sload_stmt]['var'].tolist()

        byte_offset = 0
        byte_size = 32

        # 辅助函数：解析掩码的 offset 和 size
        def parse_target_mask(m):
            if m == 0: return None, None
            # 找尾部连续的 0 的个数 (以位计算)
            trailing_zeros = (m & -m).bit_length() - 1
            # 右移去掉 0，剩下的应该全是 1
            m_shifted = m >> trailing_zeros
            size_bits = m_shifted.bit_length()
            # 严格校验：移位后是否为完美的连续 1
            if m_shifted == (1 << size_bits) - 1:
                return trailing_zeros // 8, size_bits // 8
            return None, None

        if sload_def_vars:
            sload_val_var = sload_def_vars[0]
            uses_of_sload = uses[uses['var'] == sload_val_var]['stmtID'].tolist()

            for u_stmt in uses_of_sload:
                u_op_series = opcodes[opcodes['stmtID'] == u_stmt]['opcode']
                if u_op_series.empty: continue
                u_op = u_op_series.values[0]

                try:
                    # 模式 A: 读取模式 (发生了移位 SHR 或 DIV)
                    if u_op in ['SHR', 'DIV']:
                        shift_args = uses[uses['stmtID'] == u_stmt]
                        for _, row in shift_args.iterrows():
                            if row['var'] != sload_val_var:
                                val = get_constant_value(row['var'])
                                if val:
                                    if u_op == 'SHR':
                                        byte_offset = int(val, 16) // 8
                                    elif u_op == 'DIV':
                                        divisor = int(val, 16)
                                        if divisor > 0:
                                            byte_offset = (divisor.bit_length() - 1) // 8
                                    break

                        # 继续寻找后续的 AND 截断以确定 Size
                        shifted_defs = defines[defines['stmtID'] == u_stmt]['var'].tolist()
                        if shifted_defs:
                            shifted_var = shifted_defs[0]
                            uses_of_shifted = uses[uses['var'] == shifted_var]['stmtID'].tolist()
                            for uu_stmt in uses_of_shifted:
                                uu_op_series = opcodes[opcodes['stmtID'] == uu_stmt]['opcode']
                                if not uu_op_series.empty and uu_op_series.values[0] == 'AND':
                                    and_args = uses[uses['stmtID'] == uu_stmt]
                                    for _, row in and_args.iterrows():
                                        if row['var'] != shifted_var:
                                            val = get_constant_value(row['var'])
                                            if val:
                                                mask_int = int(val, 16)
                                                byte_size = (mask_int.bit_length() + 7) // 8
                                            break

                    # 模式 B: 写入模式 (Clear Mask) 或无移位的读取模式
                    elif u_op == 'AND':
                        and_args = uses[uses['stmtID'] == u_stmt]
                        for _, row in and_args.iterrows():
                            if row['var'] != sload_val_var:
                                val = get_constant_value(row['var'])
                                if val:
                                    c_int = int(val, 16)

                                    # 解析直接掩码 (假设是 Read) 和 取反掩码 (假设是 Write)
                                    offset1, size1 = parse_target_mask(c_int)
                                    inv_c = (1 << 256) - 1 - c_int
                                    offset2, size2 = parse_target_mask(inv_c)

                                    # EVM 黄金铁律：
                                    # Read Mask 一定是右对齐的 (c_int 的最低位必须是 1，即 c_int & 1 != 0)
                                    if offset1 is not None and (c_int & 1 != 0):
                                        byte_offset = offset1
                                        byte_size = size1
                                    # 否则只要取反后是正常的块，就绝对是 Clear Mask (Write)
                                    elif offset2 is not None:
                                        byte_offset = offset2
                                        byte_size = size2
                                break

                except Exception as e:
                    pass

                    # 🎯 最终格式化为 反编译器的 `bytes X to Y`
        if sload_type == 1 or sload_type == 2:
            pack_info = "bytes 0 to 31"
        elif byte_size == 32 and byte_offset == 0:
            pack_info = "bytes 0 to 31"
        else:
            is_package_slot = True
            start_byte = byte_offset
            end_byte = byte_offset + byte_size - 1
            pack_info = f"bytes {start_byte} to {end_byte}"
        # print(f"{sload_stmt:<12} | {key_var:<10} | {base_slot:<35} | {sload_type:<12} | {is_package_slot} | {pack_info} | {sload_type_info} " )
        line = pd.Series(
            {'stmtID': sload_stmt, 'variable': key_var, 'slot': base_slot, 'semantic': "None", 'var_type': sload_type,
             'is_package': is_package_slot, 'slot_Offset': pack_info, 'describe': sload_type_info, 'blockID': '0'})
        storage = storage.append(line, ignore_index=True)

    original_cols = storage.columns.tolist()
    storage_semantic = storage_semantic.set_index(['slot', 'slot_Offset'])
    storage = storage.set_index(['slot', 'slot_Offset'])
    storage['semantic'].update(storage_semantic['semantic'])
    storage = storage.reset_index()

    stmt_block = stmt_block.set_index(['stmtID'])
    storage = storage.set_index(['stmtID'])

    storage['blockID'].update(stmt_block['blockID'])
    storage = storage.reset_index()
    storage = storage[original_cols]
    # print("\n🎯 分析完成！")
    return storage


def extract_all_publicFunc_call(df_opcodes, df_defines, df_uses, df_var_values, df_stmts_in_block):
    opcodes = df_opcodes
    defines = df_defines
    uses = df_uses

    Caller_Info = pd.DataFrame(columns=['stmtID', 'opcode', 'defVar', 'description', 'blockID'])
    Calldata_Info = pd.DataFrame(columns=['stmtID', 'opcode', 'defVar', 'description', 'blockID'])

    # 尝试加载常量表
    var_values = df_var_values

    def get_constant_value(var_name):
        match = var_values[var_values['var'] == var_name]['value']
        return str(match.values[0]).strip() if not match.empty else None

    # 定义我们要抓取的目标操作码
    target_opcodes = ['CALLER', 'CALLVALUE', 'ORIGIN', 'CALLDATALOAD', 'CALLDATASIZE', 'CALLDATACOPY']
    target_stmts = opcodes[opcodes['opcode'].isin(target_opcodes)]

    # print("\n🔍 正在提取调用者 (Caller) 与调用参数 (Calldata) ...\n")
    # print(f"{'指令 ID':<12} | {'操作码':<15} | {'产生变量(Def)':<15} | {'语义解析 (Semantic)'}")
    # print("-" * 85)

    for _, row in target_stmts.iterrows():
        stmt = row['stmtID']
        op = row['opcode']

        # 查找该指令产生了哪个变量 (Def)
        def_vars = defines[defines['stmtID'] == stmt]['var'].tolist()
        def_var = def_vars[0] if def_vars else "无 (N/A)"

        semantic = "未知"
        tag = 0
        # 1. 身份与价值相关
        if op == 'CALLER':
            semantic = "👤 获取 msg.sender (直接调用者)"
        elif op == 'ORIGIN':
            semantic = "🕵️‍♂️ 获取 tx.origin (交易最原始的发起人)"
        elif op == 'CALLVALUE':
            semantic = "💰 获取 msg.value (附带的 ETH wei 数量)"
        elif op == 'CALLDATASIZE':
            tag = 1
            semantic = "📏 获取 Calldata 总长度"
        # 2. 调用参数加载相关
        elif op == 'CALLDATALOAD':
            tag = 1
            # CALLDATALOAD 的第 0 个参数 (index 0) 就是它的读取偏移量 offset
            use_vars = uses[(uses['stmtID'] == stmt) & (uses['index'] == 0)]['var'].tolist()
            if use_vars:
                offset_var = use_vars[0]
                offset_val_hex = get_constant_value(offset_var)

                if offset_val_hex:
                    try:
                        # 尝试将十六进制字符串转为整数以计算参数位置
                        offset_int = int(offset_val_hex, 16)
                        if offset_int == 0:
                            semantic = "🔑 加载 Calldata[0x00] (通常提取 msg.sig 函数签名)"
                        elif offset_int >= 4:
                            # 根据 ABI 编码规则，每 32 字节为一个参数，去掉开头的 4 字节
                            param_idx = (offset_int - 4) // 32
                            semantic = f"📦 加载 第 {param_idx + 1} 个参数 (Offset: {hex(offset_int)})"
                        else:
                            semantic = f"📦 加载 Calldata (非标 Offset: {hex(offset_int)})"
                    except ValueError:
                        semantic = f"📦 加载 Calldata (异常 Offset: {offset_val_hex})"
                else:
                    semantic = f"🔄 动态加载 Calldata (基于动态变量 {offset_var}，通常为数组解析)"
            else:
                semantic = "📦 加载 Calldata (未知 Offset)"

        # 3. 大块数据拷贝相关 (动态数组、字符串)
        elif op == 'CALLDATACOPY':
            tag = 1
            semantic = "📋 拷贝 Calldata 进内存 (通常用于 bytes 或 string 参数)"

        line = pd.Series({'stmtID': stmt,
                          'opcode': op,
                          'defVar': def_var,
                          'description': semantic,
                          'blockID': '0'
                          })
        if tag == 0:
            Caller_Info = Caller_Info.append(line, ignore_index=True)
        else:
            Calldata_Info = Calldata_Info.append(line, ignore_index=True)
        # print(f"{stmt:<12} | {op:<15} | {def_var:<15} | {semantic}")

    original_caller_cols = Caller_Info.columns.tolist()
    original_calldata_cols = Calldata_Info.columns.tolist()

    stmt_block = df_stmts_in_block
    stmt_block = stmt_block.set_index(['stmtID'])
    Caller_Info = Caller_Info.set_index(['stmtID'])
    Calldata_Info = Calldata_Info.set_index(['stmtID'])

    Caller_Info['blockID'].update(stmt_block['blockID'])
    Calldata_Info['blockID'].update(stmt_block['blockID'])
    Caller_Info = Caller_Info.reset_index()
    Calldata_Info = Calldata_Info.reset_index()
    Caller_Info = Caller_Info[original_caller_cols]
    Calldata_Info = Calldata_Info[original_calldata_cols]

    # print("\n🎯 Caller & Calldata 提取完成！")
    return Caller_Info, Calldata_Info


def extract_all_publicFunc_args(df_publicArgs, df_uses, df_stmts_in_block):
    # print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
    args = df_publicArgs
    uses = df_uses

    # print("\n🔍 正在提取public函数与参数使用关系...\n")

    pubFunc_args_row = uses[uses.iloc[:, 1].isin(args.iloc[:, 1])]
    pubFunc_args = pd.DataFrame(columns=['stmtID', 'var', 'blockID'])

    for _, row in pubFunc_args_row.iterrows():
        stmt = row['stmtID']
        var = row['var']
        line = pd.Series({'stmtID': stmt,
                          'var': var,
                          'blockID': '0'
                          })
        pubFunc_args = pubFunc_args.append(line, ignore_index=True)

    # print(pubFunc_args)

    original_pubfuncargs_cols = pubFunc_args.columns.tolist()

    stmt_block = df_stmts_in_block
    stmt_block = stmt_block.set_index(['stmtID'])
    pubFunc_args = pubFunc_args.set_index(['stmtID'])

    pubFunc_args['blockID'].update(stmt_block['blockID'])

    pubFunc_args = pubFunc_args.reset_index()

    pubFunc_args = pubFunc_args[original_pubfuncargs_cols]

    # print("\n🎯 Public Function Args 提取完成！")
    return pubFunc_args


def extract_all_privateFunc_args(df_formalArgs, df_uses, df_stmts_in_block):
    args = df_formalArgs
    uses = df_uses

    # print("\n🔍 正在提取私有函数与参数使用关系...\n")

    privFunc_args_row = uses[uses.iloc[:, 1].isin(args.iloc[:, 1])]
    privFunc_args = pd.DataFrame(columns=['stmtID', 'var', 'blockID'])

    for _, row in privFunc_args_row.iterrows():
        stmt = row['stmtID']
        var = row['var']
        line = pd.Series({'stmtID': stmt,
                          'var': var,
                          'blockID': '0'
                          })
        privFunc_args = privFunc_args.append(line, ignore_index=True)

    # print(privFunc_args)

    original_formalargs_cols = privFunc_args.columns.tolist()

    stmt_block = df_stmts_in_block
    stmt_block = stmt_block.set_index(['stmtID'])
    privFunc_args = privFunc_args.set_index(['stmtID'])

    privFunc_args['blockID'].update(stmt_block['blockID'])

    privFunc_args = privFunc_args.reset_index()

    privFunc_args = privFunc_args[original_formalargs_cols]

    # print("\n🎯 FormalArgs 提取完成！")
    return privFunc_args


def extract_all_events(df_opcodes, df_var_values, df_uses, df_sign_eventName, df_stmts_in_block):
    # print("🚀 正在加载 Gigahorse 提取的 TAC 数据库...")
    opcodes = df_opcodes
    var_value = df_var_values
    uses = df_uses
    sign_eventName = df_sign_eventName
    stmt_block = df_stmts_in_block

    # print("\n🔍 正在提取 event 使用情况...\n")
    event_stmts = opcodes[opcodes['opcode'].isin(['LOG1', 'LOG2', 'LOG3', 'LOG4'])].copy()

    topic0_vars = uses[
        (uses['stmtID'].isin(event_stmts['stmtID'])) &
        (uses['index'] == 2)
        ].copy()

    topic0_with_sign = topic0_vars.merge(var_value, on='var', how='left')
    topic0_with_sign = topic0_with_sign.rename(columns={'value': 'signature'})
    topic0_with_name = topic0_with_sign.merge(sign_eventName, on='signature', how='left')
    events = topic0_with_name.merge(stmt_block, on='stmtID', how='left')
    events = events[['stmtID', 'signature', 'event_name', 'blockID']]

    return events
