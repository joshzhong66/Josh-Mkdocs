from openai import OpenAI

client = OpenAI(
    api_key="sk-4d8a1dffc0284d039d20af1f6f9ad29a",  
    base_url="https://api.deepseek.com"
)

response = client.chat.completions.create(
    model="deepseek-chat",
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "今天深圳会下雨嘛？"},
    ],
    stream=False
)

print(response.choices[0].message.content)