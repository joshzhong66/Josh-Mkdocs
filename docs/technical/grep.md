# grep

## 一、grep概述

文本搜索工具，根据用户指定的模式（过滤条件），对目标文本进行逐行进行匹配检查，打印匹配到的行。



模式：由正则表达式的元字符及文本字符所编写出的过滤条件

grep命令里的匹配模式就是你想要找的东西，可以是普通字符，也可以是正则表达式。



## 二、grep语法

```
grep    [选项]    “搜索内容”    文件
命令    参数      匹配模式    文件数据
         -i 忽略大小写
         -o 只输出匹配的内容
         -n 输出行号
         -c 只统计匹配的行数
         -E 使用egrep命令
         -w 只匹配过滤的单词
         -v 显示不能被模式匹配到的行
         -color=auto 搜索出的关键字用颜色显示
         
         [a-z] 匹配所有小写字母
         [A-Z] 匹配所有大写字母
         [a-zA-Z] 所有字母
         [0-9]  匹配单个数字0-9
         [a-zA-Z0-9] 所有字母与数字
```



## 三、grep用法

### 1.贪婪匹配

```
grep "^.*o" chang-ip.sh 
```

> **Modify the netwo**rk ip script
>
> **Network configuratio**n file

贪婪匹配含义： ^以某字符开头，任意0或多个字符 *代表匹配所有 o普通字符，直到字母o结束

### 2.匹配从s开始，o结束

```
grep "s.*o" chang-ip.sh
```

>[root@zhongjl-51-64 /root]# grep "s.*o" chang-ip.sh 
>ethfile="/etc/**sysconfig/netwo**rk-scripts/ifcfg-eth0"
>                echo "IP addre**ss format is wro**ng, please re-enter!"
>                echo "Gateway addre**ss format is wro**ng, please re-enter!"
>**service netwo**rk restart

### 3.计算匹配次数

```
grep "s.*o" chang-ip.sh | wc -l
```

>4