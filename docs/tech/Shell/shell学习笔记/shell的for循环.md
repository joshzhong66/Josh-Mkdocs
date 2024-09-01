## shell 的 for 循环

### 概述

for 循环是 shell 中常用的循环控制结构，用于重复执行一段代码。for 循环的语法如下：

```
for variable in list
do
    commands
done
```

其中：

- variable 是循环变量，每次循环会从 list 中取出一个值赋给 variable。
- list 是循环的对象，可以是字符串、文件名、数字序列等。
- commands 是循环体，循环会重复执行 commands 指定的代码。

### 列表 for 循环

列表 for 循环是 for 循环最常见的一种形式，list 可以是字符串、文件名、数字序列等。

#### 例1：输出当前目录下的所有文件

```
#!/bin/bash

for file in *
do
    echo "$file"
done
```

#### 例2：读取/etc/passwd文件，获取用户名

```
#!/bin/bash

for username in `awk -F: '{print $1}' /etc/passwd`
do
    echo "$username"
done
```

### 不带列表的 for 循环

不带列表的 for 循环是指循环变量 variable 的值由命令行参数指定。

#### 例1：输出命令行参数

```
#!/bin/bash

for arg
do
    echo "$arg"
done
```

### break 和 continue

break 和 continue 是 shell 中用于控制 for 循环的两个关键字。

- break 用于强行退出当前循环。
- continue 用于忽略本次循环的剩余部分，回到循环的顶部，继续下一次循环。

#### 例1：使用 break 退出循环

```
#!/bin/bash

i=1
for day in Mon Tue Wed Thu Fri
do
    echo "Weekday $((i++)) : $day"
    if [ $i -eq 3 ]; then
        break
    fi
done
```

#### 例2：使用 continue 跳过周末

```
#!/bin/bash

i=1
for day in Mon Tue Wed Thu Fri Sat Sun
do
    echo -n "Day $((i++)) : $day"
    if [ $i -eq 7 -o $i -eq 8 ]; then
        echo "(WEEKEND)"
        continue
    fi
    echo "(weekday)"
done
```





### 类C语言for循环

shell 的类 C 语言 for 语法与 C 语言的 for 语法相似，都是用于重复执行一段代码的结构。shell 的类 C 语言 for 语法的语法如下：

```
for (( variable = start; condition; increment ))
do
    commands
done
```

其中：

- variable 是循环变量，每次循环会从 start 的值开始，根据 condition 的判断进行循环。
- start 是循环变量的初始值。
- condition 是循环的条件，如果条件为真，则继续循环，否则退出循环。
- increment 是循环变量的步进值，每次循环后，循环变量会增加 increment 的值。

### 演示示例

**1. 10秒倒计时**

```
#!/bin/bash

echo "10秒倒计时:"
echo

for (( i=10; i>0; i-- ))
do
    echo $i
    sleep 1
done
```

该脚本输出：

```
10秒倒计时:

10
9
8
7
6
5
4
3
2
1
```





### 扩展知识

- for 循环也可以嵌套使用，即在 for 循环中嵌套另一个 for 循环。
- for 循环还可以使用 range 函数，range 函数可以生成一个数字序列。



### 总结

shell 的类 C 语言 for 语法可以简化 for 循环的语法，使其更加接近 C 语言的语法。在实际开发中，可以根据实际情况选择合适的语法。

for 循环是 shell 中非常重要的一个循环控制结构，掌握 for 循环的使用方法，可以帮助我们更加高效地编写 shell 脚本。



## 



## 其他举例

#### 1.例1 所有文件名大写替换为小写

脚本的功能是将当前目录下的所有的大写文件名改为小写文件名

```bash
#!/bin/bash
##filename:for5.sh
for fname in * ;do
fn=$(echo $fname | tr A-Z a-z)
if [[ $fname != $fn ]] ; then mv $fname $fn ; fi
done
```

> 技巧：脚本中的*表示当前目录下的文件和目录。首先使用命令替换生成小写的文件名，赋予新的变量f，如果新生成的小写文件名与原文件名不同，则改为小写的文件名。


#### 2. 例2 读取/etc/passwd文件，依次输出ip段

```bash
#!/bin/bash
##filename:for6.sh
i=1
for username in `awk -F: '{print $1}' /etc/passwd`
do
	echo "Username $((i++)) : $username"
done

for suffix in $(seq 10)
do
	echo "192.168.0.${suffix}"
done
```

> 脚本实现两个功能: 
> 1、读取/etc/passwd 文件，通过awk 获取第1列的内容作为 list，注意in后面命令的写法，是个反引号，也就是键盘(Esc)下面的那个键，
> 2、通过seq 指定数字list，从1~10，然后依次输出一个IP范围段

![在这里插入图片描述](https://img-blog.csdnimg.cn/61dd2b2a8e5f462cb904fa5a6437aa25.png)
#### 3. 例3 读取/etc/hosts内容for循环，执行ping

```bash
#!/bin/bash
#filename:for7_host.sh

for host in $(cat /etc/hosts)
do
	if ping -c1 -w2 $host &>/dev/null
	then
		echo "host ($host) is active."
	else
		echo "host ($host) is down."
	fi
done
```
这个脚本的功能是通过读取/etc/hosts 的内容作为 for循环的list，然后对读取到的内容进行ping 操作，如果能够ping通，显示active，否则显示DOWN。
![在这里插入图片描述](https://img-blog.csdnimg.cn/213903cf26bc454ca29c52cd8834d25c.png)

#### 4. 例4 循环ip列表，输出对应编号

```bash
#!/bin/bash
#filename:for8.sh
mynet="192.168.0"
for num in {1..6}
do
echo "IP Address $num: $mynet.$num"
done

for num in {1..10..2}
do
echo "Number: $num"
done
```

这个脚本是通过数值范围作为 for 循环的 lit 列表，1.6表示从1~6，而110..2是使用包含步长(increment)的数值范围作为for 循环的list，表示从1~10，每隔2个步长，执行脚本，输出如下:
![在这里插入图片描述](https://img-blog.csdnimg.cn/6384549ac45d478fb1b0e2f161dd7543.png)

#### 5. 例5 批量添加用户

```bash
#！/bin/bash
#filename:for9.sh
for x in {1..10}
do
useradd user${x}
echo "centos"|passwd --stdin user${x}
chage -d 0 user${x}
done
```
这个脚本功能是批量添加10个Linux系统用户。需要注意的是，stdin 是接受echo后面的字符串作为密码，stdin 表示非交互，直接传入密码，passwd 默认是要用终端作为标准输入，加上--stdin 表示可以用任意文件做标准输入，于是这里用管道作为标准输入。最后的chage命令是强制新建用户第1次登录时修改密码。
![在这里插入图片描述](https://img-blog.csdnimg.cn/165785ccd61948ff9075dbcda12e3b38.png)

