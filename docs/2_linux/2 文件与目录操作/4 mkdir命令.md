# mkdir命令



> 欢迎阅读《每天一个Linux命令》系列 ！在本篇文章中，将说明mkdir命令用法。

## 一、简介

mkdir命令是Linux系统下的目录创建命令，用于创建指定的目录。

- 英文原意：make directories
- 所在路径：/bin/mkdir
- 执行权限：所有用户

通过命令which可以查看到mkdir命令的路径：
```bash
[root@localhost /]# which mkdir
/usr/bin/mkdir
```



## 二、语法

```bash
mkdir [选项] 目录
```



## 三、选项

| 参数 |      说明      |
| :--: | :------------: |
| 目录 | 要创建的目录。 |

**命令选项：**

| 选项 |      说明      |
| :--: | :------------: |
|  -p  | 递归创建目录。 |



## 四、示例

**例1：在tmp目录创建一个test文件夹**

```bash
cd /tmp
mkdir test
```

进入test目录：
```bash
cd test
```
查看目录路径：
```bash
pwd
```

**例2：在/tmp目录，递归创建一个/Nginx/conf/html目录**

```bash
mkdir -p /tmp/Nginx/conf/html
```



## 五、注意事项

- 默认情况下，mkdir命令会创建一个空的目录。

- 可以使用选项 -p 递归创建目录。

  



**mkdir命令的使用技巧**

- 使用mkdir命令可以方便地创建目录。
- 可以使用选项 -p 递归创建目录，方便创建多级目录。
- mkdir命令可以用于创建包含分隔符的目录。
- 可以使用管道将mkdir命令的输出连接到其他命令。