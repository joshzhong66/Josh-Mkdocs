#三个数，从小到大输出三个数

num1 = int(input("请输入第1个数："))
num2 = int(input("请输入第2个数："))
num3 = int(input("请输入第3个数："))
list1 = [num1,num2,num3]
list2 = sorted(list1)
print(f'从小到大排列数字：{list2[0]},{list2[1]},{list2[2]}')