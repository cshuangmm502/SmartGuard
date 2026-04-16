import pandas as pd
from tac_analyze_scripts.GeminiRequest import classify_event_with_agent
from pathlib import Path


def analyze_events(events):
    # 5. 关键词分类 (Deposit / Withdrawal)
    # -----------------------------------------------------------
    emitting_block = []
    informing_block = []
    # print(f"event include: {event}")

    emitting_events = pd.DataFrame(columns=['stmt', 'event_name', 'block'])
    informing_events = pd.DataFrame(columns=['stmt', 'event_name', 'block'])

    # 获取所有唯一的事件签名 (减少 LLM 调用次数)
    unique_signatures = events['event_name'].unique()
    # print(f"unique event include: {unique_signatures}")

    # LLM分析
    sig_classification = {}
    for sig in unique_signatures:
        if sig == "0" or pd.isna(sig):
            continue
        category = classify_event_with_agent(str(sig))
        sig_classification[sig] = category

    # 根据分类结果填充 Block 列表
    for i in range(len(events)):
        full_sig = str(events.iloc[i, 2])  # event_name

        # 查表获取分类
        category = sig_classification.get(full_sig, "OTHER")

        if category == "DEPOSIT":
            line = pd.Series({'stmt': events.iloc[i, 0],
                              'signature': events.iloc[i, 1],
                              'event_name': events.iloc[i, 2],
                              'block': events.iloc[i, 3]})
            emitting_events = emitting_events.append(line, ignore_index=True)
            # emitting_block.append(Events.iloc[i, 3])  # tac中的block索引
        elif category == "WITHDRAWAL":
            line = pd.Series({'stmt': events.iloc[i, 0],
                              'signature': events.iloc[i, 1],
                              'event_name': events.iloc[i, 2],
                              'block': events.iloc[i, 3]})
            informing_events = informing_events.append(line, ignore_index=True)
            # informing_block.append(Events.iloc[i, 3])

    # informing_blocks = informing_events['blockID'].tolist()
    # emitting_blocks = emitting_events['blockID'].tolist()

    # print(f"informing_blocks:{informing_blocks}")
    # print(f"emitting_blocks:{emitting_blocks}")
    return emitting_events, informing_events


def convert_events_to_func(df_block_in_func, events):
    events_blocks = events['block'].tolist()
    events_function = []
    emit_sign = []

    block_func_relations = df_block_in_func
    block_to_func = dict(zip(block_func_relations.iloc[:, 0], block_func_relations.iloc[:, 1]))

    for blk in events_blocks:
        func_name = block_to_func.get(blk, "0")
        if func_name != "0":
            events_function.append(func_name)

    # 找到相关的 emit Event 签名 (用于后续判断是否频繁触发)
    # event 表: col 0 is block, col 1 is hash/sign (取决于之前的步骤)
    # 假设 event.iloc[:, 0] 是 block
    event_block_sign_map = dict(zip(events.iloc[:, 2], events.iloc[:, 3]))
    for blk in events_blocks:
        if blk in event_block_sign_map:
            emit_sign.append(event_block_sign_map[blk])

    return events_function, emit_sign
