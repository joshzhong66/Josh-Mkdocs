## shell 的if判断

### 概述

if 判断是 shell 编程中使用频率最高的语法结构，用于根据条件执行不同的操作。

### 简单if结构

最简单的 if 执行结构如下所示:

```
if expression
then
	command
	command
	...
fi
```

expression 表示测试条件，如果 expression 的值为真，则执行 then 语句块中的命令，否则不执行。

例如，以下脚本会询问用户今天的心情如何，然后根据用户的回答做出不同的回应：

```
#!/bin/bash

echo "你好！你今天心情如何？（请输入 '好' 或 '不好'）"
read mood

if [[ $mood == [好好]* ]]; then
  echo "很高兴听到你心情不错！"
else
  echo "抱歉听到你心情不好，有什么我可以帮助你的吗？"
fi
```

运行该脚本，输入 "好"，会得到以下输出：

```
你好！你今天心情如何？（请输入 '好' 或 '不好'）
好
很高兴听到你心情不错！
```

### if/else结构

if/else 结构也是经常使用的，这个结构是双向选择语句，如果用户执行脚本时如果不满足 if 后的表达式，就会执行 else 后的命令，所以有很好的交互性。

```
if	expression1
then
	command
	...
	command
else
	command
	...
	command
fi
```

例如，以下脚本会判断用户是否输入了参数，如果没有输入参数，则显示使用说明：

```
#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage:$0<username>"
  exit
else
  echo "Hello, $1!"
fi
```

运行该脚本，不输入参数，会得到以下输出：

```
Usage:$0<username>
```

### if/elif/else 结构

if/elif/else 结构用于更复杂的判断，它针对多个条件执行不同操作，语法结构如下：

```
if	expr1
then
	commands1
elif expr2
then
	commands2
......
else
	commands4
fi
```

例如，以下脚本会根据用户的输入，显示不同的提示：

```
#!/bin/bash

read -p "What's your name? " name

if [[ $name == "Bard" ]]; then
  echo "Hello, Bard!"
elif [[ $name == "Alice" ]]; then
  echo "Hello, Alice!"
else
  echo "Hello, stranger!"
fi
```

运行该脚本，输入 "Bard"，会得到以下输出：

```
What's your name? Bard
Hello, Bard!
```

### 使用注意事项

if/else 语句使用时需要注意以下几点：

- if 语句必须以 if 开头，以 fi 结束。
- elif 可以有任意多个 (0 个或多个)。
- else 最多只能有一个 (0 个或 1 个)。
- commands 为可执行语句块，如果为空，需使用 shell 提供的空命令 :，即冒号。该命令不做任何事情，只返回一个退出状态 0。
- expr 通常为条件测试表达式；也可以是多个命令，以最后一个命令的退出状态为条件值。
- if 语句可以嵌套使用。

### 总结

if 判断是 shell 编程中非常重要的语法结构，可以用于根据条件执行不同的操作。通过掌握 if 判断的使用方法，可以编写出更灵活、更高效的 shell 脚本。