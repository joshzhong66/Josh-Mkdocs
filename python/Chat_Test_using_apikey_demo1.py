import openai
import os
import asyncio
import nest_asyncio
from concurrent.futures import ThreadPoolExecutor


openai.api_key = os.getenv("OPEN_API_KEY")

#nest_asyncio.apply()

executor = ThreadPoolExecutor(max_workers=1)

async def getAnswerFromOpenAi(question):
    loop = asyncio.get_event_loop()
    try:
        # 使用线程池执行器在后台线程中运行同步代码
        response = await loop.run_in_executor(executor, lambda: openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "user", "content": question}
            ]
        ))
        return response.choices[0].message['content']
    except Exception as e:
        print(f"An error occurred: {e}")
        return "I'm sorry, there was an error processing your request."

async def main():
    try:
        while True:
            question = input('我: ')
            if question.lower() == 'exit':
                print("Exiting the program.")
                break
            print('openAi正在思考，请稍等...')
            
            answer = await getAnswerFromOpenAi(question)
            print('openAi: ' + answer)
            
            # other_result = await do_something_else()
    except KeyboardInterrupt:
        print("Program terminated by user.")

async def do_something_else():
    await asyncio.sleep(1)
    return '其他任务完成'

loop = asyncio.get_event_loop()

loop.run_until_complete(main())
