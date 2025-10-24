# basename命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `basename` 命令的用法。

## 一、简介

`basename` 命令用于从路径中提取文件名部分，即去除路径前缀，只保留最末尾的文件名（或目录名）。

常用于脚本中获取不带路径的文件名，或者去掉文件扩展名。



## 二、语法

```bash
basename [字符串] [后缀]
```



## 三、参数说明

|  参数  |                            说明                            |
| :----: | :--------------------------------------------------------: |
| 字符串 |             完整路径字符串，或包含路径的文件名             |
|  后缀  | 可选参数，若指定，将从结果中剥离指定后缀（仅当文件名匹配） |

## 四、示例

**例1：提取路径中的文件名**

```bash
basename /usr/local/bin/test.sh
```

输出：

```
test.sh
```

**例2：提取路径中的目录名（最后一级）**

```bash
basename /usr/local/share/
```

输出：

```
share
```

**例3：去除扩展名 `.sh`**

```bash
basename /usr/local/bin/test.sh .sh
```

输出：

```
test
```

**例4：配合 `dirname` 命令使用**

```bash
filepath="/etc/nginx/nginx.conf"
filename=$(basename "$filepath")
directory=$(dirname "$filepath")

echo "文件名: $filename"
echo "目录路径: $directory"
```

输出：

```
文件名: nginx.conf
目录路径: /etc/nginx
```



## 五、其他说明

- `basename` 只处理字符串，不检查文件是否存在。
- 可在 shell 脚本中结合变量使用，非常方便。
- 与 `dirname` 是一对常用工具，分别用于提取文件名和目录路径。
