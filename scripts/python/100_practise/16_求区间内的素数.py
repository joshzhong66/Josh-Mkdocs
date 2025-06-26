#输入整数a、b表示一个闭区间，找出该区间内的所有素数并打印。（闭区间指的是左右两端数值都能取到）


# #写法1
# def is_prime(n):
#     if n <=1:
#         return False
#     if n <=3:
#         return True
#     if n % 2 == 0 or n % 3 == 0 :
#         return False
#     i = 5
#     while i * i  <= n :
#         if n % i == 0 or n % (i + 2) == 0 :
#             return False
#         i += 6
#     return True
# a = int(input("输入区间起点数："))
# b = int(input("输入区间终点数："))
# if a > b:
#     a,b = b,a
# print(f"{a}~{b}之间的素数是：")
# for num in range(a,b+1):
#     if is_prime(num):
#         print(num,end=" ")



#写法2
# def prime(n):
#     if n <= 1:
#         return False
#     for i in range(2,int(n ** 0.5) +1):
#         if n % i == 0:
#             return False
#     return True

# a = int(input("请输入左端点："))
# b = int(input("请输入右端点："))

# list1 = []
# for i in range(a,b + 1):
#     if prime(i):
#         list1.append(i)
# print("闭区间[a,b]的素数是：",list1)
