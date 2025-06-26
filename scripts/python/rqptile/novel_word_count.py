#使用Python的内置函数 len() 来计算一个txt文档中的字符数量，这个函数可以返回字符串的长度
#会计算文件中的所有字符，包括空格和换行符


def count_in_file(filename):
    with open(filename,'r',encoding='utf-8') as f:
        content = f.read()
    return len(content)

print(count_in_file(r'C:\Users\Josh\Desktop\Python Scripts\Python_Notes\项目练习\斗罗大陆.txt'))


#只计算单词的数量，你需要先使用 split() 函数将字符串分割为单词列表，然后使用 len() 函数计算单词的数量

def count_file1(filename1):
    with open(filename1,'r',encoding='utf-8') as f:
        content = f.read()
    words = content.split()
    return len(words)

print(count_file1(r'C:\Users\Josh\Desktop\Python Scripts\Python_Notes\项目练习\斗罗大陆.txt'))