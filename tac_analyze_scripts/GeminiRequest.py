import http
import os

import httpx
import requests
import json
from pathlib import Path
import re
import time
from openai import OpenAI


COMMON_RULES = """
All provided guard blocks are JUMPI blocks that dominate the target bridge-event path.
Each guard_info item describes an actual branch predicate.

For each security obligation:
1. First decide whether the obligation is applicable to the current path.
2. Then decide whether it is satisfied.
3. Equivalent protection mechanisms may satisfy the same obligation.
4. Use MISSING only when the obligation is applicable and no equivalent protection appears.
5. Use UNKNOWN when the available TAC evidence is insufficient.
6. Use NOT_APPLICABLE when the path architecture does not require the obligation.
7. Do not infer semantics from unknown stor_x names alone.
8. External CALL or STATICCALL success checks alone do not prove a specific security obligation.
9. Error messages may be used as supporting evidence.
10. Output JSON only.
"""


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


def classify_event_with_agent(artifacts_path, event_signature, path="event_cache.json"):
    """
    使用 LLM 分析事件语义（带重试和暴力解析）。
    """
    out_dir = artifacts_path / "output_debug"
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
    max_retries = 1
    category = "OTHER"  # 默认值

    # 简单的去重处理，防止 Send(...) 和 Send( address...) 被当做两个
    clean_sig = event_signature.replace(" ", "")

    for attempt in range(max_retries):
        try:
            print(f"🤖 Agent Analyzing ({attempt + 1}/{max_retries}): {event_signature}")

            response = call_llm_api_event_analysis(event_signature)

            result = process_llm_response(response)

            category = result['category']

            print(f"   Success! Category: {category}")
            # print(result)

        except Exception as e:
            print(f"   Exception: {e}")
            time.sleep(1)

    # 4. 写入缓存
    cache[event_signature] = category
    with open(cache_file, 'w', encoding='utf-8') as f:
        json.dump(cache, f, indent=4)

    return category


def call_llm_api_event_analysis(prompt):
    conn = http.client.HTTPSConnection("jeniya.cn")

    payload = json.dumps({
        "model": "gpt-5.4",
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
        ]
    })

    # payload = {
    #     # 建议换用更听话的模型，Gemini-pro 有时还是会输出 markdown
    #     # 如果可以使用 gpt-3.5-turbo 或 gpt-4o-mini，格式会极其稳定
    #     "model": "gemini-3-pro-preview",
    #
    #     # 【关键】强制 JSON 模式 (如果是 OpenAI 兼容接口通常支持这个参数)
    #     "response_format": {"type": "json_object"},
    #
    #     "messages": [
    #         {
    #             "role": "system",
    #             "content": "You are a security expert. Output JSON only. {\"category\": \"...\", \"reason\": \"...\"}"
    #         },
    #         {
    #             "role": "user",
    #             "content": f"""
    #             Classify Solidity Event: "{prompt}"
    #
    #             Categories:
    #             - "DEPOSIT" (Funds entering bridge/lock/burn)
    #             - "WITHDRAWAL" (Funds leaving bridge/unlock/mint)
    #             - "OTHER" (Irrelevant)
    #
    #             JSON Format:
    #             {{
    #                 "category": "DEPOSIT" or "WITHDRAWAL" or "OTHER",
    #                 "reason": "short text"
    #             }}
    #             """
    #         }
    #     ],
    #     "temperature": 0.1,
    #     "max_tokens": 500
    # }

    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer sk-FKWJV2ihsuWQ4SJ8PW7T0mtYxJL9DyHnAxVod9kf8BuS1Mf3',
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/v1/chat/completions", payload, headers)
    res = conn.getresponse()
    return res


def call_llm_api_supportness_check(guard_blocks, guard_info):
    conn = http.client.HTTPSConnection("jeniya.cn")
    payload = json.dumps({
        "model": "gpt-5.4",
        "messages": [
            {
                "role": "system",
                "content": """
                You are a smart contract static-analysis agent.

                Task:
                Given guard blocks extracted from dominator-tree analysis of a TAC path, decide whether the path is protected by a SUPPORTNESS_CHECK.

                SUPPORTNESS_CHECK means a guarding condition validates whether a cross-chain operation is supported or valid, such as:
                - supported source/destination chain or domain
                - resourceID to contract address mapping
                - contract address to resourceID mapping
                - contract whitelist
                - supported token ID/address/index
                - burn/mint/lock token support list
                - available router/handler
                - deposit/processed record used for replay or duplicate prevention

                Known supportness indicators:
                domainID, chainID, support, resourceIDToContractAddress,
                contractAddressToResourceID, contractWhitelist, allTokenIDs,
                tokenByEVMAddress, tokenIndex, burnList, availableRouters,
                depositRecords.

                Decision rules:
                1. A SUPPORTNESS_CHECK requires a guard condition, not just variable occurrence.
                2. If a guard uses a recovered supportness variable, output YES.
                3. If a guard uses only generic SLOAD such as stor_7 without recovered semantic name, output POSSIBLE only when the constraint looks like chain/resource/token/router support validation.
                4. CALLER/msg.sender checks are authorization checks, not supportness checks.
                5. msg.value checks are payment/business constraints, not supportness checks.
                6. fee, owner, admin, role, pause, relayer, signer, oracle, threshold, and generic amount checks are not supportness checks.
                7. If evidence is insufficient, output NO or POSSIBLE conservatively.

                Output JSON only.
                """
            },
            {
                "role": "user",
                "content": f"""
                Protected guard blocks:
                {guard_blocks}

                Guard block details:
                {guard_info}

                Return exactly:
                {{
                  "semantic_supportness_check": "YES|NO",
                  "confidence": "HIGH|MEDIUM|LOW",
                  "supportness_evidence": [
                    {{
                      "block": "block id",
                      "constraint": "short constraint",
                      "variable": "variable or storage name",
                      "role": "CHAIN_SUPPORT|RESOURCE_MAPPING|CONTRACT_WHITELIST|TOKEN_SUPPORT|ROUTER_SUPPORT|RECORD_CHECK|GENERIC_SUPPORT_MAP",
                      "strength": "HIGH|MEDIUM|LOW"
                    }}
                  ],
                  "non_support_guards": [
                    {{
                      "block": "block id",
                      "type": "AUTHORIZATION|PAYMENT|BUSINESS_CONSTRAINT|UNKNOWN_STORAGE|OTHER",
                      "reason": "short reason"
                    }}
                  ],
                  "reason": "short reason"
                }}
                """
            }
        ]
    })
    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer sk-FKWJV2ihsuWQ4SJ8PW7T0mtYxJL9DyHnAxVod9kf8BuS1Mf3',
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/v1/chat/completions", payload, headers)
    res = conn.getresponse()
    return res


def call_llm_api_repeat_check(guard_blocks, guard_info):
    conn = http.client.HTTPSConnection("jeniya.cn")
    payload = json.dumps({
        "model": "gpt-5.4",
        "messages": [
            {
                "role": "system",
                "content": """
                    You are a smart contract static-analysis agent.

                    Task:
                    Given guard blocks extracted from dominator-tree analysis of a TAC path, decide whether the path is protected by a REPETITIVENESS_CHECK.

                    REPETITIVENESS_CHECK means a guarding condition prevents repeated or replayed operations, including:
                    - repeated cross-chain withdrawal or execution
                    - repeated handling of the same deposit/request/message
                    - repeated use of the same nonce
                    - repeated voting on the same proposal
                    - duplicate claim, redeem, release, or message execution

                    Known repetitiveness knowledge:
                    list, account, hasVotedOnProposal, depositRecords, nonces.

                    Roles:
                    - VOTE_RECORD: hasVotedOnProposal or proposal vote record
                    - DEPOSIT_RECORD: depositRecords or deposit/request processing record
                    - NONCE_RECORD: nonces or used nonce record
                    - PROCESSED_RECORD: processed/executed/claimed/used/completed message or tx record
                    - GENERIC_RECORD: list, account, generic mapping/list used as a duplicate record
                    - NON_REPETITIVENESS: owner, admin, fee, pause, relayer, signer, threshold, amount, token, msg.value, msg.sender authorization

                    Decision rules:
                    1. A REPETITIVENESS_CHECK requires a guard condition, not just variable occurrence.
                    2. If a guard uses hasVotedOnProposal, depositRecords, or nonces, output YES.
                    3. If a guard uses processed, executed, claimed, used, completed, consumed, handled, or message record variables, output YES or POSSIBLE even if they are not in the SmartAxe list.
                    4. If a guard uses only generic names such as list or account, output POSSIBLE unless the constraint clearly indicates duplicate/replay prevention.
                    5. CALLER/msg.sender checks are authorization checks, not repetitiveness checks.
                    6. msg.value checks are payment/business constraints, not repetitiveness checks.
                    7. Fee, owner, admin, role, pause, relayer, signer, oracle, threshold, and generic amount checks are not repetitiveness checks.
                    8. If evidence is insufficient, output NO or POSSIBLE conservatively.
                    
                    Output JSON only.
                    """
            },
            {
                "role": "user",
                "content": f"""
                    Protected guard blocks:
                    {guard_blocks}

                    Guard block details:
                    {guard_info}

                    Return exactly:
                    {{
                      "semantic_repetitiveness_check": "YES|NO",
                      "confidence": "HIGH|MEDIUM|LOW",
                      "repetitiveness_evidence": [
                        {{
                          "block": "block id",
                          "constraint": "short constraint",
                          "variable": "variable or storage name",
                          "role": "VOTE_RECORD|DEPOSIT_RECORD|NONCE_RECORD|PROCESSED_RECORD|GENERIC_RECORD",
                          "strength": "HIGH|MEDIUM|LOW"
                        }}
                      ],
                      "non_repetitiveness_guards": [
                        {{
                          "block": "block id",
                          "type": "AUTHORIZATION|PAYMENT|BUSINESS_CONSTRAINT|UNKNOWN_STORAGE|OTHER",
                          "reason": "short reason"
                        }}
                      ],
                      "reason": "short reason"
                    }}
                    """
            }
        ]
    })
    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer sk-FKWJV2ihsuWQ4SJ8PW7T0mtYxJL9DyHnAxVod9kf8BuS1Mf3',
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/v1/chat/completions", payload, headers)
    res = conn.getresponse()
    return res


def call_llm_api_balance_check(guard_blocks, guard_info):
    conn = http.client.HTTPSConnection("jeniya.cn")
    payload = json.dumps({
        "model": "gpt-5.4",
        "messages": [
            {
                "role": "system",
                "content": """
                        You are a smart contract static-analysis agent.

                        Task:
                        Given guard blocks extracted from dominator-tree analysis of a TAC path, decide whether the path is protected by a BALANCE_CHECK.

                        BALANCE_CHECK means a dominating guard validates whether a deposit, lock, burn, or transfer-out operation has sufficient assets or liquidity, including:
                        - user balance compared with deposit amount
                        - allowance compared with transfer amount
                        - bridge balance after deposit compared with balance before deposit
                        - bridge liquidity or reserve compared with amount or threshold
                        - min/max token amount constraints

                        Known balance knowledge (from SmartAxe):
                        balance, allowance, deposit, balanceOf, depositETH, redeem, vaultAllowance,
                        minStakedTokens, minAmounts, depositCounts, unlockedBalanceOf, lockedBalanceOf,
                        minTokenAmount, maxTokenAmount, released, allowed, totalSupply, bridgeSend,
                        transferOut, minterAllowance, eTHReserve, tokenBalance, swapStorage.

                        Decision rules:
                        1. A semantic BALANCE_CHECK requires a dominating comparison guard.
                        2. Variable occurrence alone is only a knowledge-base match.
                        3. Generic balance, deposit, fee, totalSupply, or transferOut occurrence without 
                        comparison does not prove BALANCE_CHECK.
                        4. msg.value != 0 alone is only POSSIBLE.
                        5. CALLER checks are authorization, not BALANCE_CHECK.
                        6. Unknown stor_x comparisons are POSSIBLE conservatively.
                        7. Output yes when the comparison clearly resembles amount, balance, reserve, or liquidity validation.

                        Output JSON only.
                        """
            },
            {
                "role": "user",
                "content": f"""
                        Protected guard blocks:
                        {guard_blocks}

                        Guard block details:
                        {guard_info}

                        Return exactly:
                        {{
                          "knowledge_base_match": "YES|NO",
                          "semantic_balance_check": "YES|POSSIBLE|NO",
                          "confidence": "HIGH|MEDIUM|LOW",
                          "evidence": [],
                          "non_balance_guards": [],
                          "reason": "short reason"
                        }}
                        """
            }
        ]
    })
    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer sk-FKWJV2ihsuWQ4SJ8PW7T0mtYxJL9DyHnAxVod9kf8BuS1Mf3',
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/v1/chat/completions", payload, headers)
    res = conn.getresponse()
    return res


def call_llm_api_signature_check(guard_blocks, guard_info):
    conn = http.client.HTTPSConnection("jeniya.cn")
    payload = json.dumps({
        "model": "gpt-5.4",
        "messages": [
            {
                "role": "system",
                "content": """
                            You are a smart contract static-analysis agent.

                            Task:
                            Given guard blocks extracted from dominator-tree analysis of a destination-side TAC path, decide whether the path is protected by a SIGNATURE_CHECK.
                            
                            SIGNATURE_CHECK means a guarding condition or verification operation validates the authenticity of a cross-chain authorization before withdrawal, unlock, mint, release, claim, or message execution, including:
                            - cryptographic signature verification
                            - recovered signer validation
                            - signer, validator, or relayer authorization
                            - multisignature or relayer threshold validation
                            - signature or authorization expiry validation
                            - binding the signed message to withdrawal parameters
                            
                            Known SmartAxe signature knowledge:
                            contractAddressToDepositFunctionSignature, kappaExists, nonces,
                            contractAddressToExecuteFunctionSignature, expiry, gsnTrustedSigner,
                            resourceIDToHandlerAddress, totalProposals, cancelProposal, signer, relayer.
                            
                            Roles:
                            - CRYPTO_VERIFY: ecrecover, recover, verifySignature, isValidSignature, signature verification, cryptographic proof verification
                            - SIGNER_AUTHORIZATION: signer, relayer, validator, gsnTrustedSigner, isSigner, isRelayer, authorizedSigner
                            - THRESHOLD_CHECK: threshold, relayerThreshold, signatureCount, validSignatures, requiredSignatures, quorum
                            - EXPIRY_CHECK: expiry, deadline, validUntil, timestamp bound
                            - MESSAGE_BINDING: signed hash, digest, message hash, withdrawal hash, nonce bound to signed message
                            - GENERIC_AUTH_STATE: kappaExists or protocol-specific authorization state
                            - NON_SIGNATURE: routing mappings, function-selector mappings, proposal lifecycle variables, replay records, admin variables
                            
                            Decision rules:
                            1. A semantic SIGNATURE_CHECK requires a guarding condition or a clear cryptographic verification operation. Variable occurrence alone is insufficient.
                            2. If the path contains ecrecover, recover, verifySignature, isValidSignature, or an equivalent cryptographic verification operation, treat it as strong CRYPTO_VERIFY evidence.
                            3. If a guard validates signer, relayer, validator, or gsnTrustedSigner membership, treat it as SIGNER_AUTHORIZATION evidence.
                            4. If a guard compares valid signature count, relayer count, or proposal approval count against a threshold, treat it as THRESHOLD_CHECK evidence.
                            5. expiry or deadline checks are supporting evidence but do not prove signature verification by themselves.
                            6. nonces are supporting MESSAGE_BINDING or replay-prevention evidence. Nonces alone do not prove SIGNATURE_CHECK.
                            7. kappaExists is weak protocol-specific evidence unless the guard clearly indicates authorization validation.
                            8. contractAddressToDepositFunctionSignature and contractAddressToExecuteFunctionSignature are function-selector or dispatch mappings, not cryptographic signature checks by themselves.
                            9. resourceIDToHandlerAddress is a routing/supportness mapping, not signature verification.
                            10. totalProposals and cancelProposal are proposal lifecycle variables, not signature verification by themselves.
                            11. CALLER/msg.sender equality checks are ordinary caller authorization unless linked to signer, validator, or relayer semantics.
                            12. If evidence is insufficient, output NO or POSSIBLE conservatively.

                            Output JSON only.
                            """
            },
            {
                "role": "user",
                "content": f"""
                            Protected guard blocks:
                            {guard_blocks}

                            Guard block details:
                            {guard_info}
                            
                            123
                            {{
                            "knowledge_base_match": "YES|NO",
                            "semantic_signature_check": "YES|POSSIBLE|NO",
                            "is_path_relevant": true,
                            "confidence": "HIGH|MEDIUM|LOW",
                            "signature_evidence": [
                            {{
                            "block": "block id or operation id",
                            "constraint": "short constraint or operation",
                            "variable": "variable, call, or operation name",
                            "role": "CRYPTO_VERIFY|SIGNER_AUTHORIZATION|THRESHOLD_CHECK|EXPIRY_CHECK|MESSAGE_BINDING|GENERIC_AUTH_STATE",
                            "strength": "HIGH|MEDIUM|LOW"
                            }}
                            ],
                            "non_signature_guards": [
                            {{
                            "block": "block id",
                            "type": "ROUTING|REPLAY_RECORD|PROPOSAL_LIFECYCLE|CALLER_AUTHORIZATION|ADMIN|UNKNOWN_STORAGE|OTHER",
                            "reason": "short reason"
                            }}
                            ],
                            "reason": "short reason"
                            }}

                            """
            }
        ]
    })
    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer sk-FKWJV2ihsuWQ4SJ8PW7T0mtYxJL9DyHnAxVod9kf8BuS1Mf3',
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/v1/chat/completions", payload, headers)
    res = conn.getresponse()
    return res


def call_llm_api_PATH_CHECK(message):
    conn = http.client.HTTPSConnection("jeniya.cn")
    payload = json.dumps({
        "model": "gpt-5.4",
        "messages": message
    })
    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer sk-FKWJV2ihsuWQ4SJ8PW7T0mtYxJL9DyHnAxVod9kf8BuS1Mf3',
        'Content-Type': 'application/json'
    }
    conn.request("POST", "/v1/chat/completions", payload, headers)
    res = conn.getresponse()
    return res


def build_source_path_check_messages(
    func_path,
    guard_blocks,
    guard_info,
    external_calls=None,
    state_updates=None
):
    external_calls = external_calls or []
    state_updates = state_updates or []

    return [
        {
            "role": "system",
            "content": """
You are a smart-contract static-analysis agent.

Analyze one SOURCE-SIDE cross-chain deposit, lock, burn, swap-out, or transfer-out path.

All provided guard blocks are JUMPI blocks that dominate the target bridge-event path.
Each guard_info item describes an actual branch predicate.
Error messages extracted from the revert branch may be used as supporting evidence.

For each obligation:
1. First decide whether it is applicable to the current path.
2. Then decide whether it is satisfied.
3. Equivalent protection mechanisms may satisfy the same obligation.
4. Use MISSING only when the obligation is clearly applicable and no explicit or
   equivalent protection appears in the provided evidence.
5. Use UNKNOWN when the available TAC evidence is insufficient.
6. Use NOT_APPLICABLE when the current path architecture does not require the obligation.
7. Do not infer storage semantics from unknown stor_x names alone.
8. External CALL or STATICCALL success checks alone do not prove a specific obligation.

Classify the following obligations:

P1. DEPOSIT_SUCCESS:
The path confirms that assets are genuinely deposited, locked, burned, or transferred out.
Equivalent mechanisms include:
- bridge balance after deposit compared with balance before deposit
- user balance compared with deposit amount
- allowance or asset-ownership validation
- bridge reserve or liquidity compared with required amount
- guarded transferFrom or SafeERC20 asset-transfer operation
- burn or escrow commitment

Rules for P1:
- A SafeERC20 error message is supporting evidence of a token operation.
- Do not mark P1 as SATISFIED unless the asset-operation semantics are sufficiently clear.
- msg.value fee validation alone is not P1.

P2. ARGUMENT_VALIDATION:
Sensitive user-controlled inputs are validated before affecting storage, asset operations,
cross-chain payloads, or bridge events.
Relevant inputs include calldata arguments, msg.sender, and msg.value.

Rules for P2:
- msg.value compared with a required fee is a MESSAGE_VALUE_VALIDATION check.
- CALLER or msg.sender predicates are argument or caller-validation checks.
- Amount-range checks are P2 unless explicitly linked to balance or liquidity.

P3. SUPPORT_VALIDATION:
Dynamic chain, domain, token, resourceID, router, or handler inputs are validated through:
- whitelist checks
- supported-list checks
- mapping-existence checks
- trusted configuration bindings

Rules for P3 support validation:
- Do not mark this obligation as MISSING unless dynamic routing inputs are identified.
- Fixed or trusted configuration may make the obligation NOT_APPLICABLE.

P3. EXTERNAL_TARGET_VALIDATION:
A dynamic external-call target is validated through:
- non-zero-address check
- contract-code or call-to-contract check
- whitelist check
- trusted configuration binding

Rules for P3 external-target validation:
- token, vault, factory, router, or handler existence checks may satisfy this obligation.
- CALL success checks alone are supporting evidence only.

Output valid JSON only.
Do not output markdown, comments, or additional text.
"""
        },
        {
            "role": "user",
            "content": f"""
func_path={func_path}
guard_blocks={guard_blocks}
guard_info={guard_info}
optional_external_calls={external_calls}
optional_state_updates={state_updates}

Return exactly:
{{
  "path_role": "SOURCE",
  "checks": {{
    "P1_DEPOSIT_SUCCESS": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [
        {{
          "block": "block id or operation id",
          "type": "short evidence type",
          "strength": "HIGH|MEDIUM|LOW",
          "reason": "short reason"
        }}
      ],
      "reason": "short reason"
    }},
    "P2_ARGUMENT_VALIDATION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }},
    "P3_SUPPORT_VALIDATION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }},
    "P3_EXTERNAL_TARGET_VALIDATION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }}
  }},
  "coverage": "STRONG|PARTIAL|WEAK|UNKNOWN",
  "limitations": [],
  "reason": "short summary"
}}
"""
        }
    ]


def build_destination_path_check_messages(
    func_path,
    guard_blocks,
    guard_info,
    external_calls=None,
    verification_operations=None,
    state_writebacks=None,
    receiver_flows=None,
):
    external_calls = external_calls or []
    verification_operations = verification_operations or []
    state_writebacks = state_writebacks or []
    receiver_flows = receiver_flows or []

    return [
        {
            "role": "system",
            "content": """
You are a smart-contract static-analysis agent.

Analyze one DESTINATION-SIDE cross-chain withdrawal, unlock, mint, release,
claim, swap-in, or message-execution path.

All provided guard blocks are JUMPI blocks that dominate the target bridge-event path.
Each guard_info item describes an actual branch predicate.
Error messages extracted from revert branches may be used as supporting evidence.

For each obligation:
1. First decide whether it is applicable to the current path.
2. Then decide whether it is satisfied.
3. Equivalent protection mechanisms may satisfy the same obligation.
4. Use MISSING only when the obligation is clearly applicable and no explicit or
   equivalent protection appears in the provided evidence.
5. Use UNKNOWN when the available TAC evidence is insufficient.
6. Use NOT_APPLICABLE when the current path architecture does not require the obligation.
7. Do not infer storage semantics from unknown stor_x names alone.
8. External CALL or STATICCALL success checks alone do not prove a specific obligation.
9. A guard may provide evidence for more than one obligation when justified.

Classify the following obligations:

P3. SUPPORT_VALIDATION:
Dynamic chain, domain, token, resourceID, router, or handler inputs are validated through:
- whitelist checks
- supported-list checks
- mapping-existence checks
- trusted configuration bindings

Rules for P3 support validation:
- Mapping checks such as resourceID-to-handler or token-to-contract may satisfy this obligation.
- Do not mark this obligation as MISSING unless dynamic routing inputs are identified.
- Fixed or trusted configuration may make the obligation NOT_APPLICABLE.

P3. EXTERNAL_TARGET_VALIDATION:
A dynamic external-call target is validated through:
- non-zero-address checks
- contract-code or call-to-contract checks
- whitelist checks
- trusted configuration bindings

Rules for P3 external-target validation:
- token, vault, factory, router, or handler existence checks may satisfy this obligation.
- SafeERC20 call-to-non-contract errors support this obligation.
- CALL success checks alone are supporting evidence only.

P4. AUTHORIZATION_VERIFICATION:
The path validates legitimate cross-chain authorization before asset release or execution.
Equivalent mechanisms include:
- cryptographic signature verification, such as ecrecover, recover, isValidSignature,
  verifySignature, or proof verification
- signer, relayer, validator, or trusted-caller authorization
- multisignature, relayer-vote, or approval-threshold checks
- trusted bridge-caller validation
- timeout or expiry checks as supporting evidence

Rules for P4:
- A signature-count or relayer-vote threshold is authorization evidence.
- An error such as "too few signatures" proves a threshold check, but does not prove
  cryptographic validity, signer authorization, or message binding by itself.
- expiry or deadline checks alone do not satisfy P4.
- Ordinary msg.sender checks satisfy P4 only when clearly linked to a trusted bridge,
  validator, relayer, signer, or handler role.

P5. REPETITIVENESS_PROTECTION:
The path prevents repeated withdrawal, repeated claim, or repeated message execution.
Equivalent mechanisms include:
- processed, received, executed, handled, claimed, withdrawn, used, or nonce records
- depositRecords or hasVotedOnProposal checks
- record-like mappings or lists checked against an unprocessed state
- record checks followed by write-back to a processed state
- an idempotent state machine

Rules for P5:
- Do not require recovered parameter names such as nonce or messageId.
- A record-like mapping compared with 0 or false is possible replay-prevention evidence.
- If a revert message clearly indicates duplicate processing, such as "withdrawn already",
  the corresponding dominating record check may satisfy P5.
- A later write-back to a processed state strengthens the evidence.
- Unknown stor_x comparisons alone do not prove P5.

P6. RELEASE_CORRECTNESS:
The path ensures that released assets are sent to a valid receiver.
Equivalent mechanisms include:
- receiver compared with zero address
- receiver bound to a verified message, request, signed payload, or trusted source
- receiver derived from trusted configuration

Rules for P6:
- Do not mark this obligation as MISSING unless a dynamic receiver is identified.
- If receiver data flow is unavailable, use UNKNOWN rather than MISSING.
- A token-target validity check is P3 external-target validation, not P6.

Output valid JSON only.
Do not output markdown, comments, or additional text.
"""
        },
        {
            "role": "user",
            "content": f"""
func_path={func_path}
guard_blocks={guard_blocks}
guard_info={guard_info}
optional_external_calls={external_calls}
optional_verification_operations={verification_operations}
optional_state_writebacks={state_writebacks}
optional_receiver_flows={receiver_flows}

Return exactly:
{{
  "path_role": "DESTINATION",
  "checks": {{
    "P3_SUPPORT_VALIDATION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [
        {{
          "block": "block id or operation id",
          "type": "short evidence type",
          "strength": "HIGH|MEDIUM|LOW",
          "reason": "short reason"
        }}
      ],
      "reason": "short reason"
    }},
    "P3_EXTERNAL_TARGET_VALIDATION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }},
    "P4_AUTHORIZATION_VERIFICATION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }},
    "P5_REPETITIVENESS_PROTECTION": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }},
    "P6_RELEASE_CORRECTNESS": {{
      "applicability": "APPLICABLE|UNCERTAIN|NOT_APPLICABLE",
      "status": "SATISFIED|MISSING|UNKNOWN|NOT_APPLICABLE",
      "evidence": [],
      "reason": "short reason"
    }}
  }},
  "coverage": "STRONG|PARTIAL|WEAK|UNKNOWN",
  "limitations": [],
  "reason": "short summary"
}}
"""
        }
    ]


def process_llm_response(result):
    raw = result.read().decode("utf-8")
    # 第一层：解析 API 返回的整体 JSON
    resp = json.loads(raw)
    # 可选：先检查 HTTP/API 层是否异常
    if result.status != 200:
        print("HTTP Error:", result.status)
        print(resp)
        raise RuntimeError("API request failed")

    # 第二层：取出模型实际回复内容
    content = resp["choices"][0]["message"]["content"]

    # 第三层：清理 markdown json 代码块
    def extract_json_text(text: str) -> str:
        text = text.strip()

        # 匹配 ```json ... ``` 或 ``` ... ```
        m = re.match(r"^```(?:json)?\s*(.*?)\s*```$", text, re.DOTALL)
        if m:
            return m.group(1).strip()

        return text

    json_text = extract_json_text(content)

    # 第四层：解析模型返回的 JSON 内容
    result = json.loads(json_text)

    print(result)
    return result


# 上下文中补充storage的语义
# python3 main.py
if __name__ == "__main__":
    os.environ["http_proxy"] = "http://localhost:7890"
    os.environ["https_proxy"] = "http://localhost:7890"
    guard_info = ("\"0x0\": \"业务约束逻辑: [Existence/Non-Zero Check on: msg.value]; 业务约束逻辑: [Existence/Non-Zero Check on: "
                  "msg.value]\",\"0x60b\": \"业务约束逻辑: [Storage[stor_7] LT Computed_Value]; 驱动此判断的数据源: SLOAD\","
                  "\"0x99d\": \"业务约束逻辑: [Hardcoded_Constant EQ msg.sender]; 驱动此判断的数据源: CALLER\"")
    guard_blocks = "0x99d", "0x60b", "0x0"

    result = call_llm_api_supportness_check(guard_blocks, guard_info)

    raw = result.read().decode("utf-8")
    # 第一层：解析 API 返回的整体 JSON
    resp = json.loads(raw)
    # 可选：先检查 HTTP/API 层是否异常
    if result.status != 200:
        print("HTTP Error:", result.status)
        print(resp)
        raise RuntimeError("API request failed")

    # 第二层：取出模型实际回复内容
    content = resp["choices"][0]["message"]["content"]


    # 第三层：清理 markdown json 代码块
    def extract_json_text(text: str) -> str:
        text = text.strip()

        # 匹配 ```json ... ``` 或 ``` ... ```
        m = re.match(r"^```(?:json)?\s*(.*?)\s*```$", text, re.DOTALL)
        if m:
            return m.group(1).strip()

        return text


    json_text = extract_json_text(content)

    # 第四层：解析模型返回的 JSON 内容
    result = json.loads(json_text)

    print(result)
    print(result["semantic_supportness_check"])
    print(result["confidence"])
    print(result["reason"])
