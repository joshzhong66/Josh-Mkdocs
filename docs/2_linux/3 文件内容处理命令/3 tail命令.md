# tail命令



> 欢迎阅读《每天一个Linux命令》系列！在本篇文章中，将说明tail命令用法。

## 一、简介

tail命令是Linux系统下的文件尾部查看命令，用于查看文件的末尾部分。



## 二、语法

```bash
tail [选项] 文件
```



## 三、选项

|  选项   |               说明               |
| :-----: | :------------------------------: |
| -c 数字 |        显示指定的字节数。        |
|   -f    | 循环读取文件，并显示最新的内容。 |
| -n 数字 |         显示指定的行数。         |
|   -q    |         不显示处理信息。         |
| -s 数字 |        显示指定的字符数。        |



## 四、示例

**例1：默认显示文件的末尾10行**

```bash
tail /etc/passwd
```

输出：

```bash
chrony:x:996:992::/var/lib/chrony:/sbin/nologin
ntp:x:38:38::/etc/ntp:/sbin/nologin
rpc:x:32:32:Rpcbind Daemon:/var/lib/rpcbind:/sbin/nologin
rpcuser:x:29:29:RPC Service User:/var/lib/nfs:/sbin/nologin
nfsnobody:x:65534:65534:Anonymous NFS User:/var/lib/nfs:/sbin/nologin
squid:x:23:23::/var/spool/squid:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin
grafana:x:995:991:grafana user:/usr/share/grafana:/sbin/nologin
prometheus:x:1001:1001::/home/prometheus:/sbin/nologin
elk:x:1002:1002::/home/elk:/sbin/nologin
```

**例2：显示文件的末尾2行**

```
tail -n 2 /etc/passwd
```

输出： 

```bash
prometheus:x:1001:1001::/home/prometheus:/sbin/nologin
elk:x:1002:1002::/home/elk:/sbin/nologin
```

**例3：循环读取文件，并显示最新的内容**

在终端1上执行以下命令开始监听文件：

```bash
tail -f test.txt
```

在终端2上执行以下命令将内容写入文件：

```bash
echo "Hello world" >> test.txt
echo "My name is josh." >> test.txt
```

终端1上的`tail`命令将实时显示`test.txt`文件的最新内容。输出将如下所示：

```python
Hello world
My name is josh.
```



## 五、注意事项

- tail命令只能显示文件的内容，不能显示文件的状态信息。

- **tail命令与more命令和less命令的区别：**

| 区别 |             tail命令             |            more命令             |               less命令               |
| :--: | :------------------------------: | :-----------------------------: | :----------------------------------: |
| 功能 |      只显示文件的末尾部分。      |      逐屏显示文件的内容。       | 逐屏显示文件的内容，支持更多的功能。 |
| 输出 | 默认情况下，显示文件的末尾10行。 | 显示文件的每一行，直到按q退出。 |   显示文件的每一行，直到按q退出。    |

- **tail命令的使用技巧：**

  - 使用tail命令查看日志文件时，可以使用选项 -f 来循环读取文件，并显示最新的内容。

  - 使用tail命令查看文件的末尾部分时，可以使用选项 -n 来指定显示的行数。

  - 使用tail命令查看文件的末尾部分时，可以使用选项 -c 来指定显示的字节数。




## 六、小结

tail命令是Linux系统下查看文件尾部内容的重要命令。在使用tail命令时，请注意以下几点：

- 文件必须存在。
- 文件必须具有可读权限。

