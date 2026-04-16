import requests
import json
from pathlib import Path
import re
import time


def robust_extract_category(text):
    """
    双重保险解析策略：
    1. 尝试标准 JSON 解析。
    2. 如果失败，使用正则直接匹配 "category": "VALUE"。
    """
    text = text.strip()

    # 策略 A: 尝试清洗 Markdown 后解析 JSON
    try:
        # 移除 ```json 和 ```
        clean_text = re.sub(r'```json\s*', '', text, flags=re.IGNORECASE)
        clean_text = re.sub(r'```', '', clean_text)

        # 尝试寻找最外层的 {}
        match = re.search(r'\{.*\}', clean_text, re.DOTALL)
        if match:
            json_str = match.group(0)
            data = json.loads(json_str)
            return data.get("category", "OTHER").upper(), data.get("reason", "")
    except:
        pass  # JSON 解析失败，进入策略 B

    # 策略 B: 正则暴力匹配 (不依赖 JSON 格式的完整性)
    # 匹配模式: "category" : "DEPOSIT" (允许各种空格和换行)
    try:
        # 查找 "category" 字段，捕获冒号后的值
        # 模式解释：
        # \"category\"\s*:\s*  -> 匹配 "category" :
        # \"([^\"]+)\"         -> 捕获双引号内的内容
        cat_match = re.search(r'"category"\s*:\s*"([^"]+)"', text, re.IGNORECASE)
        reason_match = re.search(r'"reason"\s*:\s*"([^"]+)"', text, re.IGNORECASE)

        if cat_match:
            category = cat_match.group(1).upper()
            # 做一下简单的清洗，防止提取到 weird stuff
            if "DEPOSIT" in category: return "DEPOSIT", reason_match.group(1) if reason_match else ""
            if "WITHDRAWAL" in category: return "WITHDRAWAL", reason_match.group(1) if reason_match else ""
            if "OTHER" in category: return "OTHER", reason_match.group(1) if reason_match else ""
            return category, reason_match.group(1) if reason_match else ""

    except:
        pass

    return None, None

def classify_event_with_agent(event_signature, path="event_cache.json"):
    """
    使用 LLM 分析事件语义（带重试和暴力解析）。
    """
    out_dir = Path("output_debug")
    if not out_dir.exists():
        out_dir.mkdir(parents=True)

    cache_file = out_dir / path

    # 1. 读取缓存
    if cache_file.exists() and cache_file.stat().st_size > 0:
        try:
            with open(cache_file, 'r', encoding='utf-8') as f:
                cache = json.load(f)
        except:
            cache = {}
    else:
        cache = {}

    if event_signature in cache:
        return cache[event_signature]

    # 2. 重试机制
    max_retries = 3
    category = "OTHER"  # 默认值

    # 简单的去重处理，防止 Send(...) 和 Send( address...) 被当做两个
    clean_sig = event_signature.replace(" ", "")

    for attempt in range(max_retries):
        try:
            print(f"🤖 Agent Analyzing ({attempt + 1}/{max_retries}): {event_signature}")

            response = call_llm_api(event_signature)

            if response.status_code != 200:
                print(f"   API Error: {response.status_code}")
                time.sleep(1)
                continue

            result_dict = response.json()
            raw_content = result_dict['choices'][0]['message']['content']

            # 【核心修改】使用双重保险解析
            extracted_cat, extracted_reason = robust_extract_category(raw_content)

            if extracted_cat:
                category = extracted_cat
                print(f"   Success! Category: {category}")
                # print(f"   Reason: {extracted_reason}")
                break
            else:
                print(f"   Failed to extract category. Raw: {raw_content[:50]}...")

        except Exception as e:
            print(f"   Exception: {e}")
            time.sleep(1)

    # 4. 写入缓存
    cache[event_signature] = category
    with open(cache_file, 'w', encoding='utf-8') as f:
        json.dump(cache, f, indent=4)

    return category

def call_llm_api(prompt):
    url = "http://jeniya.cn/v1/chat/completions"
    headers = {
        'Accept': 'application/json',
        'Authorization': 'sk-l783v1MYK4BqECPOCTdNDvzeuTatDqDhyzZy9WmsI3meVUOh',  # 填入你的 Key
        'Content-Type': 'application/json'
    }

    payload = {
        # 建议换用更听话的模型，Gemini-pro 有时还是会输出 markdown
        # 如果可以使用 gpt-3.5-turbo 或 gpt-4o-mini，格式会极其稳定
        "model": "gemini-3-pro-preview",

        # 【关键】强制 JSON 模式 (如果是 OpenAI 兼容接口通常支持这个参数)
        "response_format": {"type": "json_object"},

        "messages": [
            {
                "role": "system",
                "content": "You are a security expert. Output JSON only. {\"category\": \"...\", \"reason\": \"...\"}"
            },
            {
                "role": "user",
                "content": f"""
                Classify Solidity Event: "{prompt}"

                Categories:
                - "DEPOSIT" (Funds entering bridge/lock/burn)
                - "WITHDRAWAL" (Funds leaving bridge/unlock/mint)
                - "OTHER" (Irrelevant)

                JSON Format:
                {{
                    "category": "DEPOSIT" or "WITHDRAWAL" or "OTHER",
                    "reason": "short text"
                }}
                """
            }
        ],
        "temperature": 0.1,
        "max_tokens": 500
    }

    response = requests.post(url, headers=headers, json=payload, timeout=30)
    return response


# python3 main.py
if __name__ == "__main__":
    result = call_llm_api("Send(address,uint256,address,uint256,uint256)")
    print(result)
