# grep命令



> 欢迎阅读《每天一个Linux命令》系列 ！在本篇文章中，将说明grep命令用法。

## 一、简介

`grep`（Global Regular Expression Print）是 Linux/Unix 系统中强大的文本搜索工具，用于在文件或输入流中查找匹配指定模式（正则表达式）的行，并输出结果。

**核心功能：**

- 搜索文件内容；
- 支持正则表达式（基本和扩展）；
- 可递归搜索目录；
- 支持多种输出控制（如只显示匹配部分、行号、上下文等）。



## 二、常用选项

|  选项  |                  作用                  |                    示例                    |
| :----: | :------------------------------------: | :----------------------------------------: |
|  `-i`  |               忽略大小写               |         `grep -i "error" log.txt`          |
|  `-v`  |   **反向匹配**（显示不包含模式的行）   |        `grep -v "success" data.log`        |
|  `-n`  |            显示匹配行的行号            |        `grep -n "warning" file.txt`        |
|  `-c`  |       统计匹配行数（不显示内容）       |         `grep -c "404" access.log`         |
|  `-o`  |    **只输出匹配的部分**（而非整行）    |    `grep -oP '\d{3}-\d{4}' phones.txt`     |
|  `-P`  | 启用 **Perl 兼容正则**（支持高级语法） |    `grep -oP '(?<=user: )\w+' log.txt`     |
| `-A n` |   显示匹配行及其后 **n 行**（After）   |       `grep -A 2 "panic" system.log`       |
| `-B n` |  显示匹配行及其前 **n 行**（Before）   | `grep -B 1 "segmentation fault" error.log` |
| `-C n` | 显示匹配行及其前后 **n 行**（Context） |      `grep -C 3 "timeout" debug.log`       |
|  `-r`  |            **递归搜索目录**            |          `grep -r "main()" /src/`          |
|  `-l`  |         只显示包含匹配的文件名         |           `grep -l "TODO" *.py`            |
|  `-w`  |        全词匹配（避免部分匹配）        |        `grep -w "port" config.txt`         |
|  `-e`  |              指定多个模式              |    `grep -e "error" -e "fail" logs.txt`    |



## 三、常用正则

|  模式   |            含义            |
| :-----: | :------------------------: |
|   `^`   |          行首锚定          |
|   `$`   |          行尾锚定          |
|  `\w`   | 单词字符（`[a-zA-Z0-9_]`） |
|  `\d`   |      数字（`[0-9]`）       |
|  `\s`   | 空白字符（空格、制表符等） |
|   `*`   |  前导元素出现 0 次或多次   |
|   `+`   |  前导元素出现 1 次或多次   |
| `{n,m}` |       出现 n 到 m 次       |
|   `(a   |            b)`             |
|  `\K`   |     丢弃之前匹配的内容     |



## 四、常用语句

### 1.提取系统版本

```bash
[root@localhost /root]# grep -oP '(?<=release )\d+' /etc/redhat-release
7
[root@localhost /root]# grep -oP 'release \K\d+' /etc/redhat-release
7
```

