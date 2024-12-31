#计算1-100万的总和，创建1个列表，其中包含数字1-100 0000，再使用min和max核实该列表是从1开始，到100 0000结束的，另外对这个列表用函数sum()，看看相加需要多长时间。


value = list(range(1,1000000))

print('\n',min(value))

print('\n',max(value))

print('\n',sum(value))