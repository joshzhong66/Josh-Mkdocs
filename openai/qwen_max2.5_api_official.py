# sk-21c191dd76cf4d6683d8db1109c475e9

import os
from openai import OpenAI

client = OpenAI(
    # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",
    api_key="sk-21c191dd76cf4d6683d8db1109c475e9", 
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
)
completion = client.chat.completions.create(
    model="qwen-max-2025-01-25", # 此处以qwen-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models
    messages=[
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {'role': 'user', 'content': '你是qwen 2.5吗'}],
    )
    
print(completion.model_dump_json())



# 回答：
'''
{"id":"chatcmpl-4a21261b-5107-909f-9328-82bd353d4942","choices":[{"finish_reason":"stop","index":0,"logprobs":null,"message":
{"content":"是的，我是基于Qwen2.5的大模型，我叫Qwen-Max，是通义千问系列中的一个闭源模型，我具有超大规模的参数量，适合处理复杂、多步骤的
任务。如果你有任何问题或需要帮助，我会尽力为你提供支持！","refusal":null,"role":"assistant","audio":null,"function_call":null,"tool
_calls":null}}],"created":1738994387,"model":"qwen-max-2025-01-25","object":"chat.completion","service_tier":null,"system_fing
erprint":null,"usage":{"completion_tokens":61,"prompt_tokens":27,"total_tokens":88,"completion_tokens_details":null,"prompt_tok
ens_details":null}}
'''