# rmdir命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明 `rmdir` 命令的用法。

## 一、简介

`rmdir` 命令是 Linux 系统下用于删除空目录的命令。它只能删除**为空的目录**，若目录中含有文件或子目录，将无法删除。



## 二、语法

```bash
rmdir [选项] 目录
```



## 三、选项

| 参数 |                   说明                   |
| :--: | :--------------------------------------: |
| 目录 |            要删除的空目录路径            |
| `-p` | 递归删除空的父目录（前提是它们也是空的） |



## 四、示例

**例1：删除一个空目录**

```bash
mkdir testdir
rmdir testdir
```

执行后，`testdir` 目录被删除。

**例2：删除多个空目录**

```bash
mkdir dir1 dir2 dir3
rmdir dir1 dir2 dir3
```

输出为空，三个目录被依次删除。

**例3：尝试删除非空目录**

```bash
mkdir nonempty
touch nonempty/file.txt
rmdir nonempty
```

输出：

```bash
rmdir: failed to remove 'nonempty': Directory not empty
```

**例4：使用 `-p` 删除空的嵌套目录结构**

```bash
mkdir -p a/b/c
rmdir -p a/b/c
```

执行后，`c`、`b`、`a` 都将被删除（前提是它们全为空）。



## 五、其他说明

- `rmdir` 只能删除空目录，若需要删除包含内容的目录，请使用 `rm -r`。
- 使用 `rmdir -p` 可以一次性清除多个层级的空目录，非常适合清理临时嵌套结构。
- 删除目录前，建议用 `ls` 或 `tree` 检查目录是否为空，避免误操作。