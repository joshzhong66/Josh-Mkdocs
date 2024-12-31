# import random
# from datetime import datetime

# #记录日志

# def write_user_log1():
#     rest1 = "用户{0}-{1}".format(random.randint(1,999),datetime.now().strftime("%Y:%m:%d %H-%M-%S"))
#     print(rest1)
#     file_name1 = r"C:\Users\Josh\Desktop\Python Scripts\Python_Notes\web_user_log.txt"
#     with open(file_name1,'a',encoding="utf-8") as f:
#         f.write(rest1)
#         f.write("\n")
#         f.close()
# if __name__ == "__main__":
#     for i in range(1,100):
#         write_user_log1()

import random
from datetime import datetime

def write_user_log4():
    "记录访问日志，即日志时间+访问id"
    rest3 = '用户：{0}-访问时间{1}'.format(random.randint(1, 999), datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print(rest3)

    file_user_log4 = r'C:\Users\Josh\Desktop\Python Scripts\Python_Notes\web_user_log.txt'
    
    try:
        with open(file_user_log4, 'a', encoding='utf-8') as f:
            f.write(rest3)
            f.write("\n")
    except Exception as e:
        print(f"发生错误：{e}")

if __name__ == '__main__':
    write_user_log4()
