import pandas as pd
from tac_analyze_scripts.GeminiRequest import classify_event_with_agent
from pathlib import Path


def analyze_events(events, artifacts_path):
    # 5. 关键词分类 (Deposit / Withdrawal)
    # -----------------------------------------------------------
    emitting_block = []
    informing_block = []
    # print(f"event include: {event}")

    emitting_events = pd.DataFrame(columns=['stmtID', 'signature', 'event_name', 'blockID'])
    informing_events = pd.DataFrame(columns=['stmtID', 'signature','event_name', 'blockID'])

    # 获取所有唯一的事件签名 (减少 LLM 调用次数)
    unique_signatures = events['event_name'].unique()
    # print(f"unique event include: {unique_signatures}")

    # LLM分析
    sig_classification = {}
    for sig in unique_signatures:
        if sig == "0" or pd.isna(sig):
            continue
        category = classify_event_with_agent(artifacts_path, str(sig))
        sig_classification[sig] = category

    # 根据分类结果填充 Block 列表
    for i in range(len(events)):
        full_sig = str(events.iloc[i, 2])  # event_name

        # 查表获取分类
        category = sig_classification.get(full_sig, "OTHER")

        if category == "DEPOSIT":
            line = pd.Series({'stmtID': events.iloc[i, 0],
                              'signature': events.iloc[i, 1],
                              'event_name': events.iloc[i, 2],
                              'blockID': events.iloc[i, 3]})
            emitting_events = emitting_events.append(line, ignore_index=True)
            # emitting_block.append(Events.iloc[i, 3])  # tac中的block索引
        elif category == "WITHDRAWAL":
            line = pd.Series({'stmtID': events.iloc[i, 0],
                              'signature': events.iloc[i, 1],
                              'event_name': events.iloc[i, 2],
                              'blockID': events.iloc[i, 3]})
            informing_events = informing_events.append(line, ignore_index=True)
            # informing_block.append(Events.iloc[i, 3])

    # informing_blocks = informing_events['blockID'].tolist()
    # emitting_blocks = emitting_events['blockID'].tolist()

    # print(f"informing_blocks:{informing_blocks}")
    # print(f"emitting_blocks:{emitting_blocks}")
    return emitting_events, informing_events


# def convert_events_to_func(df_block_in_func, events):
#     events_blocks = events['blockID'].tolist()
#     events_function = []
#     emit_sign = []
#
#     block_func_relations = df_block_in_func
#     block_to_func = dict(zip(block_func_relations.iloc[:, 0], block_func_relations.iloc[:, 1]))
#
#     for blk in events_blocks:
#         func_name = block_to_func.get(blk, "0")
#         if func_name != "0":
#             events_function.append(func_name)
#
#     # 找到相关的 emit Event 签名 (用于后续判断是否频繁触发)
#     # event 表: col 0 is block, col 1 is hash/sign (取决于之前的步骤)
#     # 假设 event.iloc[:, 0] 是 block
#     event_block_sign_map = dict(zip(events.iloc[:, 2], events.iloc[:, 3]))
#     for blk in events_blocks:
#         if blk in event_block_sign_map:
#             emit_sign.append(event_block_sign_map[blk])
#
#     print(events_function)
#     print(emit_sign)
#     return events_function, emit_sign

def convert_events_to_func(df_block_in_func, events, verbose=True):
    """
    将 events 映射到其所在函数。

    Parameters
    ----------
    df_block_in_func : pd.DataFrame
        columns = ['block', 'func_id']

    events : pd.DataFrame
        columns = ['stmtID', 'signature', 'event_name', 'blockID']

    Returns
    -------
    events_function : list[dict]
        每个元素包含：
        - func_id
        - event_name
        - event_signature
        - stmt
        - blockID

    emit_sign : list
        所有映射成功的 event signature
    """

    required_event_cols = {'stmtID', 'signature', 'event_name', 'blockID'}
    required_func_cols = {'block', 'func_id'}

    missing_event_cols = required_event_cols - set(events.columns)
    missing_func_cols = required_func_cols - set(df_block_in_func.columns)

    if missing_event_cols:
        raise ValueError(f"events 缺少必要列: {missing_event_cols}")

    if missing_func_cols:
        raise ValueError(f"df_block_in_func 缺少必要列: {missing_func_cols}")

    events_df = events.copy()
    block_func_df = df_block_in_func.copy()

    # 防止 blockID 和 block 一个是 int、一个是 str 导致 merge 失败
    events_df['_block_key'] = events_df['blockID'].astype(str)
    block_func_df['_block_key'] = block_func_df['block'].astype(str)

    # block -> func_id
    block_func_df = block_func_df[['func_id', '_block_key']].drop_duplicates(
        subset=['_block_key']
    )

    merged = events_df.merge(
        block_func_df,
        on='_block_key',
        how='left'
    )

    # 过滤掉没有映射到函数的 event
    merged = merged[
        merged['func_id'].notna() &
        (merged['func_id'].astype(str) != "0")
    ].copy()

    events_function = []

    for _, row in merged.iterrows():
        events_function.append({
            "func_id": row["func_id"],
            "event_name": row["event_name"],
            "event_signature": row["signature"],
            "stmtID": row["stmtID"],
            "blockID": row["blockID"],
        })

    return events_function
