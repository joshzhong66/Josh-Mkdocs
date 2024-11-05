#编写一个程序，当用户输入 q 或 quit 时，程序退出，否则一直等待用户输入。

""" while True:
    i = input("请输入命令，如果是q 或者 quit，程序都会退出")
    if i.lower() in ['q','quit']:
        print("bye")
        break """


while True:
    n = input("请输入q或者quit，以退出程序：")

    if n.lower() in ['q','quit']:
        print("程序结束")
        break
    elif n.lower() in ['Q','QUIT']:
        print("程序退出")
        break



""" 
while True:
    user_input = input("请输入 'q' 或 'quit' 以退出程序: ")
    
    if user_input.lower() in ['q', 'quit']:
        print("程序退出。")
        break
    elif user_input.upper() in ['Q', 'QUIT']:
        print("程序退出。")
        break """