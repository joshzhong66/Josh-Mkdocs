## shell 的case选择

### 概述

case 选择语句是 shell 编程中一种多分支选择结构，类似于其他语言中的 switch·.case 语句。case 选择语句匹配一个值或一个模式，如果匹配成功，执行相匹配的命令。

### case 语法结构

case 语法结构如下：

```
case expr in
	pattern1)
		commands1
		;;
	pattern2)
		commands2
		;;
	......
	*)
		commands
		;;
esac
```

- expr 为表达式，关键词 in 不要忘
- pattern1、pattern2 等为模式，用来匹配 expr 的值
- commands1、commands2 等为命令块，如果 expr 与 pattern1 匹配，则执行 commands1 命令块，以此类推
- ;; 为分隔符，表示匹配成功后退出 case 结构

### case 选择语句的几点说明

在使用 case 选择语句的时候，需要注意如下几点：

- expr 按顺序匹配每个模式，一旦有一个模式匹配成功，则执行该模式后面的所有命令，然后退出 case。
- 如果 expr 没有找到匹配的模式，则执行默认值 *) 后面的命令块(类似于 if 中的 else)。*)可以不出现。
- 匹配模式 pattern 中可以含有通配符和。
- 每个命令块的最后必须有一个双分号，可以独占一行，或放在最后一个命令的后面。

### 实验示例

以下是一些使用 case 选择语句的实验示例：

**实验 1：根据用户输入的数字，显示相应的脚本语言**

```
#!/bin/bash

echo "what is your preferred scripting language?"
read -p "1)bash 2)perl 3)python 4)ruby:" lang

case $lang in
	1)	echo "you selected bash" ;;
	2)	echo "you selected perl" ;;
	3)	echo "you selected python" ;;
	4)	echo "you selected ruby" ;;
esac
```

运行该脚本，输入以下内容：

```
1
```

将输出以下结果：

```
you selected bash
```

**实验 2：根据用户输入的水果，显示相应的提示**

```
#!/bin/bash

echo "which is your preferred fruit?"
read -p "Apple,Pear,Kiwi,Lemon,Orange,Banana:" pi #读取输入内容，赋值给变量pi

case $pi in
	[Aa]*|[Pp]*)	echo "You selected Apple/Pear." ;;	#是Aa/Pp输出"You selected Apple/Pear."
	[Kk]*|[Ll]*)	echo "You selected Kiwi/Lemon." ;;
	[Oo]*|[Bb]*)	echo "You selected Orange/Banana" ;;
	*) echo "No fruit i like." ;;						#输入内容非以上选项，则表示没有喜欢的水果
esac
```

运行该脚本，输入以下内容：

```
Apple
```

将输出以下结果：

```
You selected Apple/Pear.
```



**实验3：根据用户输入的天气状况，显示相应的提示**

```
#!/bin/bash

echo "what is the weather today?"
read -p "1)Sunny 2)Rainy 3)Snowy 4)Cloudy:" weather

case $weather in
	1)	echo "It's a sunny day today. Have a nice day!" ;;
	2)	echo "It's a rainy day today. Bring an umbrella." ;;
	3)	echo "It's a snowy day today. Be careful not to slip." ;;
	4)	echo "It's a cloudy day today. The sun is hiding." ;;
esac
```

运行该脚本，输入以下内容：

```
1
```

将输出以下结果：

```python
It's a sunny day today. Have a nice day!
```





### 扩展知识

- case 选择语句的匹配模式可以使用正则表达式。
- case 选择语句可以用来实现复杂的逻辑判断。

### 总结

case 选择语句是 shell 编程中一种强大的多分支选择结构，可以用于根据不同的条件执行不同的操作。在实际使用中，可以根据需要灵活地使用 case 选择语句。