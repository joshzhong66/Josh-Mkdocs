# head命令



> 欢迎阅读《每天一个Linux命令》系列 ！在本篇文章中，将说明head命令用法。

## 一、简介

head命令是一个常用的Linux命令，用于显示文件的前几行内容。它的英文原意是"output the first part of files"，可以帮助我们快速查看文件的开头部分。

- 英文原意：output the first part of files
- 所在路径：/usr/bin/head
- 执行权限：所有用户

通过命令which可以查看到head命令的路径：

```bash
[root@chatgpt-test tmp]# which head
/usr/bin/head
```



## 二、语法

```shell
head [选项] 文件名
```



## 三、选项

|  选项   |                      说明                      |
| :-----: | :--------------------------------------------: |
| -n 行数 | 从文件头开始，显示指定行数，默认为显示前10行。 |
|   -v    |                  显示文件名。                  |



## 四、示例

**例1：显示文件开头的10行**

```shell
head 文件名
```

**例2：显示文件开头的20行**

```shell
head -n 20 文件名
```

**例3：显示文件开头的10行，并显示文件名**

```shell
head -v test.txt
```

输出：

```bash
==> test.txt <==
Hello world
My name is josh.
```

**例4：通过head帮助命令，查看更多选项**

```bash
[root@chatgpt-test tmp]# man head

NAME
       head - output the first part of files

SYNOPSIS
       head [OPTION]... [FILE]...

DESCRIPTION
       Print  the  first 10 lines of each FILE to standard output.  With more than one FILE, precede each with a header giving the file
       name.  With no FILE, or when FILE is -, read standard input.

       Mandatory arguments to long options are mandatory for short options too.

       -c, --bytes=[-]K
              print the first K bytes of each file; with the leading '-', print all but the last K bytes of each file

       -n, --lines=[-]K
              print the first K lines instead of the first 10; with the leading '-', print all but the last K lines of each file

       -q, --quiet, --silent
              never print headers giving file names

       -v, --verbose
              always print headers giving file names

       --help display this help and exit
```



## 五、实际应用

head命令在日常的Linux系统管理和文件处理中非常有用。以下是一些常见的应用场景：

- 查看日志文件的前几行，以了解文件的内容和结构。
- 快速浏览大型文本文件的开头部分，以确定文件的格式和内容。
- 预览配置文件的开头部分，以查看文件的配置信息。



## 六、小结

通过本文，我们了解了head命令的基本用法和常见选项。它是一个方便实用的工具，可以帮助我们快速查看文件的前几行内容。在日常的Linux系统管理和文件处理中，head命令是一个必备的工具。
