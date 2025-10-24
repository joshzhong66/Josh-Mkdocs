# find命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `find` 命令的用法。

## 一、简介

`find` 命令用于在目录中递归查找文件或目录，英文原意为 “search for files in a directory hierarchy”，适合按条件查找文件，比如名称、类型、时间、大小、权限等。

- 命令路径：`/bin/find` 
- 执行权限：所有用户

**提示：** 在生产环境尤其是服务器高峰期，不推荐频繁使用 find 命令查找全系统文件，因为会消耗较多系统资源。



## 二、语法

```bash
find [搜索路径] [选项] [匹配条件]
```



## 三、常用选项

|     参数      |                    说明                     |
| :-----------: | :-----------------------------------------: |
|    `-name`    |        按名称精确匹配（区分大小写）         |
|   `-iname`    |         按名称匹配（不区分大小写）          |
|    `-type`    | 按类型查找（f：普通文件，d：目录，l：链接） |
|    `-size`    |    按大小查找，如：`+100M`, `-2k`, `25k`    |
|   `-mtime`    |       按**修改时间**查找（单位：天）        |
|   `-atime`    |       按**访问时间**查找（单位：天）        |
|   `-ctime`    |     按**状态改变时间**查找（单位：天）      |
|    `-user`    |           查找属于指定用户的文件            |
|   `-group`    |            查找属于指定组的文件             |
|   `-nouser`   |         查找没有所有者的“孤儿”文件          |
|    `-perm`    |     按权限匹配（精确、部分、任意权限）      |
|    `-exec`    |           对查找到的文件执行命令            |
|     `-ok`     |    类似 `-exec`，但在执行前要求用户确认     |
|  `-a` / `-o`  |               逻辑与 / 逻辑或               |
| `!` 或 `-not` |                   逻辑非                    |
|   `-prune`    |        排除路径（用于忽略某些目录）         |



## 四、示例

**例1：按文件名查找**

```bash
find / -name yum.conf
```

查找 `/` 目录下名为 `yum.conf` 的文件。

**例2：查找当前目录下大小为25KB的文件**

```bash
find . -size 25k
```

**例3：查找根目录下大于100MB的文件**

```bash
find / -size +100M
```

**例4：查找5天内修改的文件**

```bash
find . -mtime -5
```

**例5：按文件类型查找**

```bash
find /etc -type f    # 普通文件
find /etc -type d    # 目录
find /etc -type l    # 软链接
```

**例6：组合查找（大于2KB 且是普通文件）**

```bash
find /etc -size +2k -a -type f
```

**例7：按所有者查找**

```bash
find . -user root
find / -nouser    # 查找无主文件
```

**例8：通配符匹配**

```bash
find /etc -name "*init*"
find /etc -name "init???"
```

**例9：查找所有 `.bz2` 文件**

```bash
find . -name "*.bz2" -print
```

**例10：查找大小为0的普通文件**

```bash
find / -type f -size 0 -exec ls -al {} \;
```

**例11：查找 `/var/log` 中 7 天前的文件并交互删除**

```bash
find /var/log -type f -mtime +7 -ok rm {} \;
```

**例12：查找指定目录中文件属主为 root 的文件**

```bash
find /etc -user root -print
```

**例13：排除 `/usr/bin`，查找文件名为 main.c 的旧文件**

```bash
find / -path "/usr/bin" -prune -o -name "main.c" -user root -type f -mtime +2 -print
```

**例14：上例基础上执行删除操作**

```bash
find / -path "/usr/bin" -prune -o -name "main.c" -user root -type f -mtime +2 -exec rm {} \;
```

**例15：删除当前目录中非 `.sh` 的文件**

```bash
find . -type f ! -name "*.sh" -exec rm {} +
```



## 五、其他说明

- `find` 是强大的搜索工具，支持非常多的组合条件。
- 时间单位是**天**，以文件属性最后变化时间为基准。
- 使用 `-exec` 时注意转义 `{}` 和 `\;`。
- 若对性能有要求，避免在根目录 `/` 下频繁查找。
- `-prune` 是用于排除路径的利器，结合 `-o` 使用效果最佳。

