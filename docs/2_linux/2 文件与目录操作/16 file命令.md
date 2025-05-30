# file命令



> 欢迎阅读《每天一个Linux命令》系列 ！在本篇文章中，将说明file命令用法。

## 一、简介

file命令是Linux系统下的文件类型识别命令，用于识别文件的类型。



## 二、语法

```
file [选项] 文件
```



## 三、选项

|        选项        |                             说明                             |
| :----------------: | :----------------------------------------------------------: |
|        `-b`        |               列出辨识结果时，不显示文件名称。               |
|        `-c`        |     详细显示指令执行过程，便于排错或分析程序执行的情形。     |
|   `-f<名称文件>`   | 指定名称文件，其内容有一个或多个文件名称时，让 `file` 依序辨识这些文件，格式为每列一个文件名称。 |
|        `-L`        |             直接显示符号连接所指向的文件的类别。             |
| `-m<魔法数字文件>` |                      指定魔法数字文件。                      |
|        `-v`        |                        显示版本信息。                        |
|        `-z`        |                  尝试去解读压缩文件的内容。                  |



|       参数        |                             说明                             |
| :---------------: | :----------------------------------------------------------: |
| `[文件或目录...]` | 要确定类型的文件列表，多个文件之间使用空格分开，可以使用 shell 通配符匹配多个文件。 |



## 四、示例

**1.列出当前目录下所有文件的类型**

```
file *
```

输出：

```bash
anaconda-ks.cfg:                      ASCII text
file_backup:                          directory
frp_0.32.1_linux_amd64.tar.gz:        gzip compressed data, from Unix, last modified: Fri Apr  3 01:32:50 2020
frp_0.35.1_linux_amd64.tar.gz:        gzip compressed data, from Unix, last modified: Mon Jan 25 16:25:11 2021
nginx-1.21.6.tar.gz:                  gzip compressed data, from Unix, last modified: Tue Jan 25 23:04:02 2022
nginx-1.22.1.tar.gz:                  gzip compressed data, from Unix, last modified: Wed Oct 19 16:02:28 2022
```

**2.列出指定文件的类型**

```bash
file /etc/passwd
```

输出：

```bash
/etc/passwd: ASCII text
```

**3.使用魔法数字文件指定文件类型**

```bash
file -m /etc/magic /etc/passwd
```

输出：

```bash
/etc/passwd: ASCII text
```

**4.使用符号连接的文件的类型**

```bash
file -L /usr/bin/ls
```

输出：

```bash
/usr/bin/ls: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.32, BuildID[sha1]=c8ada1f7095f6b2bb7ddc848e088c2d615c3743e, stripped
```

**5.显示版本信息**

```bash
file -v
```

输出：

```bash
file-5.11
magic file from /etc/magic:/usr/share/misc/magic
```

**6.尝试去解读压缩文件的内容**

```bash
file -z nginx-1.22.1.tar.gz 
```

输出：

```bash
nginx-1.22.1.tar.gz: POSIX tar archive (gzip compressed data, from Unix, last modified: Wed Oct 19 16:02:28 2022)
```



## 五、file命令的使用技巧

- 使用file命令可以快速识别文件类型，避免误操作。
- 使用file命令的选项可以根据需要进行更精细的识别。
