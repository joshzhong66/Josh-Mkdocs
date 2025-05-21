# 14 dirname命令

> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 dirname 命令的用法。

## 一、简介

`dirname` 命令用于从给定的路径字符串中去除文件名部分，仅保留目录路径。

常用于脚本中获取文件所在的目录路径，与 `basename` 命令互补使用。

## 二、语法

```bash
dirname [字符串]
```

## 三、参数说明

| 参数   | 说明                                     |
| ------ | ---------------------------------------- |
| 字符串 | 完整路径字符串，或包含路径的文件路径信息 |

> 注意：dirname 并不会判断路径中是否真的存在文件，只对字符串进行处理。

## 四、示例

**例1：提取文件路径中的目录部分**

```bash
dirname /usr/local/bin/test.sh
```

输出：

```
/usr/local/bin
```

**例2：去除路径最后的目录名**

```bash
dirname /etc/nginx/sites-available/
```

输出：

```
/etc/nginx
```

**例3：配合 basename 获取完整路径和文件名**

```bash
filepath="/opt/scripts/deploy.sh"
filename=$(basename "$filepath")
directory=$(dirname "$filepath")

echo "文件名: $filename"
echo "目录路径: $directory"
```

输出：

```
文件名: deploy.sh
目录路径: /opt/scripts
```

**例4：使用相对路径**

```bash
dirname ./a/b/c/file.txt
```

输出：

```
./a/b/c
```

## 五、其他说明

- `dirname` 是处理路径字符串的工具，不依赖实际文件存在。
- 在脚本自动化和路径处理逻辑中非常常用。
- 可与 `basename` 结合使用，分别获取路径和文件名两部分。

