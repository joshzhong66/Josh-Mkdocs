#8_求列表每个参数的立方根

#三种写法
#1、不使用map函数，求列表每个参数的立方根

def pow_number(num_list):
    rest_list = []
    for i in num_list:
        rest_list.append(i * i * i)
    return rest_list

if __name__=='__main__':
    l = [1,2,3,4,5,6,7,8,9]
    rest = pow_number(l)
    print(rest) 





# map函数的使用
# 创建一个列表，其中包含对指定序列包含的项执行指定函数返回的值
# 方法定义：map(function,sequence,...)
# #sequence表示序列






#2、使用map函数，求列表每个参数的立方根
def pow_number1(num):
    return num * num * num
def map_num(num_list):
    return map(pow_number1,num_list)
if __name__ == '__main__':
    num_list = [1,2,3,4,5,6,7,8,9]
    rest_map = map_num(num_list)
    print(list(rest_map))







#3、使用map函数和lambda表达式，计算列表的每一项立方根
def pow_num_use_lambda(l):
    return map(lambda n: n * n * n,l)

if __name__ == '__main__':
    l = [1,2,3,4,5,6,7,8,9]
    rest_lambda =  pow_num_use_lambda(l)
    print(list(rest_lambda))