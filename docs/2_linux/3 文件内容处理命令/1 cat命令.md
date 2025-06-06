# cat命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明cat命令用法。

## 一、简介

cat命令是Linux系统下的文件查看命令，用于显示文件的内容。



## 二、语法

```bash
cat [选项] 文件
```



## 三、选项

| 选项 |                  说明                  |
| :--: | :------------------------------------: |
| `-n` |       `--number`显示每一行的行号       |
| `-b` |  `--number-nonblank`显示非空行的行号   |
| `-s` | `--squeeze-blank`压缩连续的空行为一行  |
| `-v` |   `--show-nonprinting`显示非打印字符   |
| `-E` |   `--show-ends`在每行结尾显示符号`$`   |
| `-T` |    `--show-tabs`将制表符显示为 `^I`    |
| `-A` | `-show-all`： 位于`-vET`组合选项之后。 |
| `-e` |        位于的`-vE`组合选项之后         |
| `-t` |       位于的`-vT`组合选项之后。        |
| `-u` |              禁止缓冲输出              |



## 四、示例

**例1：显示文件的内容**

```bash
cat test.txt
```

输出：

```
This is my drives.


thinks
```

**例2：`-b`或`--number-nonblank`：显示非空行的行号**

```bash
cat -b test.txt
```

输出：

```bash
     1  This is my drives.

     2
     3  thinks
```

**例3：在特定字符处添加特殊字符$**

```
cat -e test.txt
```

输出：

```bash
This is my drives.$
$
        $
thinks$
```

**例4：在特定字符处添加特殊字符$，并将输出格式设置为“DOS”**

```
cat -E test.txt 
```

输出：

```bash
This is my drives.$
$
        $
thinks$
```

**例5：`--number`：显示每一行的行号。**

```
cat -n test.txt 
```

输出：

```bash
     1  This is my drives.
     2
     3
     4  thinks
```

**例6：`-s`或`--squeeze-blank`：压缩连续的空行为一行。**

```python
cat -s test.txt 
```

输出：

```bash
This is my drives.


thinks
```



## 五、注意事项

- cat命令只能显示文件的内容，不能显示文件的状态信息。
- cat命令的输出格式可以根据需要进行调整。



## 六、小结

cat命令是Linux系统下查看文件内容的重要命令。在使用cat命令时，请注意以下几点：

- 文件必须存在。
- 文件必须具有可读权限。

