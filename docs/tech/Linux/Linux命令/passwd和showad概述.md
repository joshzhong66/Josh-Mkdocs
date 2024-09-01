# 19. passwd和shadow概述



## 一、简介
在Linux系统中，`passwd`和`shadow`是两个重要的文件，用于管理用户账户和密码信息。`passwd`文件存储用户的基本信息，而`shadow`文件则用于存储用户的加密密码和其他安全相关的信息。本文将对这两个文件的结构和字段进行概述，并提供一些实验示例和扩展知识。



## 二、用户和组示例

以下是一个简单的实验示例，演示如何使用`/etc/passwd`和`/etc/shadow`文件来创建用户账户和设置密码。

创建一个新用户账户：

```bash
useradd -m -s /bin/bash newuser
```

设置新用户的密码：

```bash
passwd newuser
```

查看`/etc/passwd`文件中的用户信息：

```bash
cat /etc/passwd | grep newuser
```

查看`/etc/shadow`文件中的用户密码信息：

```bash
cat /etc/shadow | grep newuser
```

创建用户组：

```bash
 groupadd newgroup
```

加入用户组：

```bash
gpasswd -a newuser newgroup
```

输出：

```bash
正在将用户“newuser”加入到“newgroup”组中
```

还可以使用`useradd -g group user`，在创建用户时加入组：

```bash
useradd -g newgroup newuser1
```



## 三、/etc/passwd文件
`/etc/passwd`文件是一个文本文件，用于存储用户账户的基本信息。下面是`/etc/passwd`文件的字段说明：

```
[root@localhost shell]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
```

- 第1字段：用户名称（用户名）；
- 第2字段：密码标志（在现代系统中已废弃，通常为`x`）；
- 第3字段：用户ID（UID），用于唯一标识用户；
  - 0：超级用户（root）；
  - 1-499：系统用户；
  - 500-65535：普通用户。
- 第4字段：用户初始组ID（GID）；
- 第5字段：用户说明（通常是用户的全名）；
- 第6字段：家目录路径；
  - 对于普通用户：`/home/用户名`；
  - 对于超级用户：`/root/`；
- 第7字段：登录后的shell（命令解释器）。



## 四、/etc/shadow文件

`/etc/shadow`文件是一个具有严格权限（0-0-0）的文件，用于存储用户的加密密码和其他安全相关的信息。下面是`/etc/shadow`文件的字段说明：

```bash
[root@localhost shell]# cat /etc/shadow
root:$6$F8CH0BXfQxw6..::0:99999:7:::
bin:*:18353:0:99999:7:::
daemon:*:18353:0:99999:7:::
adm:*:18353:0:99999:7:::
lp:*:18353:0:99999:7:::
sync:*:18353:0:99999:7:::
shutdown:*:18353:0:99999:7:::
```

- 第1字段：用户名；
- 第2字段：加密密码；
  - 加密算法升级为SHA512散列加密算法；
  - `!!`或`*`表示没有密码，禁止登录；
- 第3字段：密码最后一次修改日期（时间戳）；
- 第4字段：两次密码的修改间隔时间（与第3字段相比）；
- 第5字段：密码有效期（与第3字段相比）；
- 第6字段：密码修改到期前的警告天数（与第5字段相比）；
- 第7字段：密码过期后的宽限天数（与第5字段相比）；
  - 0：密码过期后立即失效；
  - -1：密码永远不会失效；
- 第8字段：账号失效时间（时间戳）；
- 第9字段：保留字段。



## 五、/etc/group文件

`/etc/group`文件是一个文本文件，用于存储组的信息。下面是`/etc/group`文件的字段说明：

```bash
[root@localhost shell]# cat /etc/group
root:x:0:
bin:x:1:
daemon:x:2:
sys:x:3:
```

- 第1字段：组名；
- 第2字段：组密码标志（在现代系统中已废弃，通常为`x`）；
- 第3字段：组ID（GID）；
- 第4字段：组中附加用户。



## 六、/etc/gshadow文件

`/etc/gshadow`文件是一个具有严格权限（0-0-0）的文件，用于存储组的密码和其他安全相关的信息。下面是`/etc/gshadow`文件的字段说明：

```bash
[root@localhost shell]# more /etc/gshadow
root:::
bin:::
daemon:::
sys:::
```

- 第1字段：组名；
- 第2字段：组密码；
- 第3字段：组管理员用户名；
- 第4字段：组中附加用户。



## 七、扩展知识

除了`/etc/passwd`和`/etc/shadow`文件，还有一些相关的文件和配置项需要了解：

- `/etc/login.defs`文件：包含与登录和密码策略相关的配置项，如密码有效期、密码修改间隔等。
- `/etc/default/useradd`文件：用户默认值文件，用于设置新用户的默认属性，如默认组、家目录路径等。



## 八、结论

`passwd`和`shadow`文件在Linux系统中起着至关重要的作用，用于管理用户账户和密码信息。了解这些文件的结构和字段可以帮助我们更好地理解和管理用户账户。在本文中，我们概述了这些文件的字段说明，并提供了实验示例和扩展知识。通过深入研究这些文件，我们可以更好地保护系统的安全性和稳定性。

希望本文对你有所帮助，如果有任何问题或建议，请随时提出。
