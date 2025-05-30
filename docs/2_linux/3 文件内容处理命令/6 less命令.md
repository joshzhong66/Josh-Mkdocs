# less命令



> 欢迎阅读《每天一个Linux命令》系列 ！在本篇文章中，将说明less命令用法。

## 一、简介

less命令是Linux系统下的文件逐屏显示命令，用于逐屏显示文件的内容，功能与more命令类似。

- 英文原意：opposite of more

- 所在路径：/usr/bin/less

- 执行权限：所有用户

通过命令which可以查看到less命令的路径：

```bash
[root@localhost tmp]# which less
/usr/bin/less
```



## 二、语法

```bash
less [选项] 文件
```



## 三、选项

| 选项 |              说明              |
| :--: | :----------------------------: |
|  -N  |            显示行号            |
|  -m  |    显示类似more命令的百分比    |
|  -i  | 忽略大小写（搜索关键字时用到） |



## 四、示例

**例1：显示文件的内容**

```bash
less /etc/passwd
```

输出：

```
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
```

**例2：显示类似more命令的百分比**

```bash
less -m /etc/passwd
```

**例3：显示行号**

```bash
less -N /etc/passwd
```

输出：

```bash
1 root:x:0:0:root:/root:/bin/bash
2 bin:x:1:1:bin:/bin:/sbin/nologin
3 daemon:x:2:2:daemon:/sbin:/sbin/nologin
```



## 五、注意事项

- less命令只能显示文件的内容，不能显示文件的状态信息。
- less命令的输出格式可以根据需要进行调整。



## 六、快捷键

在使用less命令时，可以使用以下快捷键进行操作：

| 快捷键 |             说明             |
| :----: | :--------------------------: |
| 空格键 |         向下翻一行。         |
|   b    |         向上翻一行。         |
| 回车键 |         向下翻一屏。         |
|   q    |        退出less命令。        |
|   /    |       查找指定字符串。       |
|   n    |        重复上次查找。        |
|   ?    | 查找指定字符串（逆向查找）。 |

使用less命令时，可以使用快捷键来进行操作，方便快捷。

