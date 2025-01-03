# awk

awk是处理文本文件的一个应用程序，几乎所有 Linux 系统都自带这个程序。它依次处理文件的每一行，并读取里面的每一个字段。对于日志、CSV 那样的每行格式相同的文本文件，awk可能是最方便的工具。



## 一、awk格式

**awk     参数    '条件动作'  文件**



Action 指的是动作，awk擅长文本格式化，且输出格式化的后果，常用用的动作就是print和printf

## 二、内置参数

| 内置变量 | 解释                                                 |
| -------- | ---------------------------------------------------- |
| $n       | 指定分隔符后，当前记录的第n个字段                    |
| $0       | 完整的输入记录                                       |
| NF       | 分割后，当前行一共又多少个字段                       |
| NR       | 当前记录数，行数                                     |
| FILENAME | 当前文件名                                           |
| FS       | 字段分隔符，默认是空格和制表符。                     |
| RS       | 行分隔符，用于分割每一行，默认是换行符。             |
| OFS      | 输出字段的分隔符，用于打印时分隔字段，默认为空格。   |
| ORS      | 输出记录的分隔符，用于打印时分隔记录，默认为换行符。 |
| OFMT     | 数字输出的格式，默认为％.6g。                        |

## 三、函数

| 函数      | 解释             |
| --------- | ---------------- |
| tolower() | 字符转为小写。   |
| length()  | 返回字符串长度。 |
| substr()  | 返回子字符串。   |
| sin()     | 正弦。           |
| cos()     | 余弦。           |
| sqrt()    | 平方根           |
| rand()    | 随机数           |



## 四、应用场景

### 1./etc/passwd

**把/etc/passwd文件保存成demo.txt**

```
awk -F ':' '{print $1}' demo.txt    			# 文件的字段分隔符是冒号（:），所以要用-F参数指定分隔符为冒号。提取它的第一个字段
echo 'this is a test' | awk '{print $NF}'		# NF表示当前行有多少字段，$NF代表最后1个字段
awk -F ':' '{print NR ")" $1}' demo.txt			# NR表示当前处理第几行
awk -F ':' '{print toupper($1)}' demo.txt		# 函数toupper()用于将字符转为大写
awk -F ':' 'NR % 2 ==1 {print $1}' demo.txt    	# 只输出奇数行
awk -F 'F' 'NR > 3 {print $1}' demo.txt         # 只输出第3行以后的行  
cat j666 | awk '{print $2}'     				# 打印第二列
```



### 2.提取系统负载

```
system_load=$(uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1}')    #提取1分钟平均负载值
```

>17:05 up 1 day,  3:22,  2 users,  load average: 0.52, 0.47, 0.45 
>
>awk -F'load average: '   将 uptime 的输出用 load average: 分隔成两部分：  第一部分是 17:05 up 1 day,  3:22,  2 users,  第二部分是 0.52, 0.47, 0.45（负载值）。   
>
>{print $2}提取分隔后的第二部分，即 0.52, 0.47, 0.45。 awk -F', '再次用 , 分隔负载值部分：   第一部分为  0.52（1分钟负载）   第二部分为  0.47（5分钟负载）   第三部分为  0.45（15分钟负载）。   {print $1} 提取第一个值，即 1分钟平均负载值。 
>
>system_load=$(...)   将最终提取的  1分钟负载值 存储在变量 system_load 中。



### 3.提取`PRETTY_NAME`

从系统的 `/etc/*-release` 文件中提取操作系统的`PRETTY_NAME`字段的值

```
awk '/^PRETTY_NAME=/' /etc/*-release 2>/dev/null | awk -F'=' '{gsub("\"","");print $2}'
```



awk '/^PRETTY_NAME=/' /etc/*-release  `awk`会在所有匹配的文件中搜索以 `PRETTY_NAME=` 开头的行，再通过管道：`|`，将第一部分的输出（即匹配到的 `PRETTY_NAME=...` 的内容）传递到下一条 `awk` 命令，awk -F'=' '{gsub("\"","");print $2 }'，

- `-F'='`: 将等号 `=` 作为分隔符，将字段分为两部分。

- `{gsub("\"","");print $2}`:

  - `gsub("\"","")`: 去掉字段中的双引号。

    `print $2`: 打印等号右边的内容，即 `PRETTY_NAME` 的值。

