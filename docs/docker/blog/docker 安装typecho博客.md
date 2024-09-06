# docker安装typecho博客



## 一、安装git

```bash
yum -y install git
```



## 二、安装compose（可选）

### 1.确保已经安装了 Docker

​		Docker Compose 是 Docker 的一个独立组件，因此在安装 Docker Compose 之前，需要先安装 Docker。你可以按照 Docker 官方文档的指引进行 Docker 的安装。

### 2.下载 Docker Compose 的可执行文件

可以使用以下命令从 Docker 官方 GitHub 存储库下载 Docker Compose 的最新版本：

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### 3.添加可执行权限

下载完成后，需要为 Docker Compose 文件添加可执行权限。可以使用以下命令完成：

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

### 4.验证安装

运行 `docker-compose --version` 命令来验证 Docker Compose 是否成功安装，应该能够看到 Docker Compose 的版本信息：

```bash
docker-compose --version
```

### 5.关闭防火墙

```bash
systemctl stop firewalld
```



## 三、拉取仓库

```bash
#拉取仓库
git clone https://github.com/fukoy/docker-typecho.git
cd docker-typecho

[root@jerion docker-typecho]# pwd
/data/typecho/docker-typecho
```



## 四、创建目录

```bash
mkdir -p /data/typecho/mysql/data
mkdir -p /data/typecho/mysql/logs
mkdir -p /data/typecho/mysql/conf

#剪切目录
mv /tmp/docker-typecho/nginx /data/typecho/nginx
mv /tmp/docker-typecho/www /data/typecho/www
```



## 五、配置文件修改

修改docker-compose文件：

```bash
vim docker-compose.yml
```

改成以下配置：

```bash
version: '3'

services:
  typecho:
    image: fukoy/nginx-php-fpm:php7.4
    container_name: typecho2
    networks:
      - typecho_network
    ports:
      - '8090:80'  #开放端口8090
    restart: always
    volumes:
      - /data/typecho/www:/usr/share/nginx/typecho/   #typecho网站文件
      - /data/typecho/nginx/conf.d:/etc/nginx/conf.d   #nginx配置文件夹
      - /data/typecho/nginx/nginx.conf:/etc/nginx/nginx.conf  #nginx配置文件
    depends_on:
      - mysql

  typechdb:
    image: mysql:5.7
    container_name: typechodb2
    networks:
      - typecho_network
    ports:
      - '3306:3306'
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=123456   # 替换为你的MySQL root密码
      - MYSQL_DATABASE=typecho       # 替换为你的数据库名称
      - MYSQL_USER=typecho           # 替换为你的数据库用户
      - MYSQL_PASSWORD=typecho       # 替换为你的数据库用户密码
    volumes:
      - /data/typecho/mysql/data:/var/lib/mysql
      - /data/typecho/mysql/logs:/var/log/mysql
      - /data/typecho/mysql/conf:/etc/mysql/conf.d

networks:
  typecho_network:
    name: typecho_network
    ipam:
      driver: default
      config:
        - subnet: 172.190.0.0/16
```

此处配置文件中与官方文档不一致，移除了 `env_file` 指令，并直接在 `mysql` 服务下添加了 `environment` 指令来设置环境变量。确保替换 `yourpassword`、`yourdatabase`、`youruser` 和 `yourpassword` 为你的实际 MySQL 配置。

在运行 `docker-compose up -d` 之前，请进行以下步骤：

1. 确认 `/data/nginx/nginx.conf` 存在且为文件。
2. 确认 `/data/www`、`/data/nginx/conf.d`、`/data/mysql/data`、`/data/mysql/logs` 和 `/data/mysql/conf` 路径在宿主机上存在并具有正确的权限。
3. 如果这些目录或文件不存在，请创建它们并确保 Docker 用户有权访问它们。



## 六、启动容器

### 1.启动服务

```bash
[root@jerion ~]# mkdir -p /usr/local/typecho1.2
[root@jerion ~]# mv /tmp/docker-typecho /usr/local/typecho1.2

#在/usr/local/typecho1.2/docker-typecho文件夹下
[root@jerion ~]# cd /usr/local/typecho1.2/docker-typecho
[root@jerion docker-typecho]# docker-compose up -d
[+] Running 3/3
 ✔ Network docker-typecho_web        Created                                                             1.2s 
 ✔ Container docker-typecho-mysql-1  Started                                                             2.6s 
 ✔ Container docker-typecho-web-1    Started                                                             2.5s 
```

### 2.停止服务

```bash
[root@chatgpt-test docker-typecho]# docker-compose down
[+] Running 3/3
 ✔ Container docker-typecho-web-1    Removed                                                            21.2s 
 ✔ Container docker-typecho-mysql-1  Removed                                                            15.4s 
 ✔ Network docker-typecho_web        Removed                                                             2.0s 
```

### 3.查看docker进程

```bash
[root@chatgpt-test docker-typecho]# docker ps
CONTAINER ID   IMAGE                        COMMAND                   CREATED          STATUS          PORTS                                                  NAMES
916e25d5d33b   fukoy/nginx-php-fpm:php7.4   "/start.sh"               34 seconds ago   Up 20 seconds   0.0.0.0:8090->80/tcp, :::8090->80/tcp                  docker-typecho-web-1
0a2d01d8ad6f   mysql:5.7                    "docker-entrypoint.s…"   36 seconds ago   Up 27 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp    docker-typecho-mysql-1
```

### 4.重启

```bash
#docker-compose重启
docker-compose restart
```



## 七、修改MYSQL数据库

在yml文件中我提供了mysql密码，但是在安装后，使用密码始终无法登录，后面尝试密码为空进入了。

### 1.登录mysql

```bash
#进入容器：docker exec -it 容器id /bin/bash

[root@chatgpt-test docker-typecho]# docker exec -it 0a2d01d8ad6f /bin/bash
root@0a2d01d8ad6f:/# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 20
Server version: 5.7.36 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

### **2.设置 `root` 用户的密码**

在 MySQL 提示符下，使用`ALTER USER`语句为`root`用户设置新密码。请确保你使用了强密码。以下是设置密码为`123456`的命令：

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
FLUSH PRIVILEGES;
```

### 3.授予远程访问权限

为了允许其他设备远程连接到 MySQL 服务器，你需要为`root`用户添加一个允许从任何主机连接的权限。

先查看`root`用户是否有允许从任何主机连接的权限：

```sql
mysql> select User, Host FROM mysql.user;
+---------------+-----------+
| User          | Host      |
+---------------+-----------+
| root          | %         |
| typecho       | %         |
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
```

显示结果中host为`%`说明已有权限。

如果没有，使用以下命令：

```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'mjMJ@2023' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

这里 `'root'@'%'` 表示 `root` 用户可以从任何 IP 地址连接。出于安全考虑，通常建议仅允许特定的 IP 地址或地址范围。如果你想限制远程访问的 IP 地址，可以将 `%` 替换为特定的 IP 地址或地址范围。

### 4.创建新用户

在 MySQL 提示符下，创建一个名为 `typecho` 的新用户，并设置密码（在这里我们使用 `mjMJ@2023` 作为示例密码）：

```sql
CREATE USER 'typecho'@'%' IDENTIFIED BY 'typecho';
```

`'typecho'@'%'` 表示用户 `typecho` 可以从任何 IP 地址连接。如果你想限制用户只能从特定的 IP 地址连接，将 `%` 替换为该 IP 地址。

### 5.授予权限

赋予 `typecho` 用户创建数据库和表的权限：

```sql
GRANT CREATE ON *.* TO 'typecho'@'%';
GRANT DROP ON *.* TO 'typecho'@'%';
GRANT ALTER ON *.* TO 'typecho'@'%';
```

这些命令允许用户 `typecho` 在所有数据库上创建、删除和修改表。如果你想限制这些权限仅适用于特定的数据库，可以将 `*.*` 替换为 `<数据库名>.*`。

### **6.刷新权限**

为了使权限更改立即生效，需要刷新权限：

```sql
FLUSH PRIVILEGES;
```

### 7.退出 MySQL

输入 `exit` 命令退出 MySQL 客户端。

```sql
exit
```



## 八、安装typecho博客

打开浏览器，访问http://10.22.51.63:8090/install.php：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/a75cb4b465b48bb2ecefc3f6cc8aeb4c-image-20240510160534209-e53e1d.png" alt="image-20240510160534209" style="zoom:50%;" />

**选择Pdo驱动SQLite适配器**

默认配置，直接安装：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/b3fcf5d17b58132d228cf2da1c409703-image-20240510160642188-add786.png" alt="image-20240510160642188" style="zoom: 33%;" />

设置管理员账号信息：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/f445f344d940e0dd13519eeddc4b62f5-image-20240510160720766-edbd98.png" alt="image-20240510160720766" style="zoom:33%;" />

安装成功：

![image-20240510160743375](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/9c33bf05f81fd5456245342949050c12-image-20240510160743375-0b8dcf.png)

博客界面：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/184a53e8dd41eb8bcd93c42fd1a0a7e8-image-20240510160817526-8f55d6.png" alt="image-20240510160817526" style="zoom: 33%;" />



## 九、相关报错问题

### 1. 初始化配置报错

选择mysql原生函数适配器和Pdo驱动Mysql适配器：

![image-20240510164257603](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/acd04bfb9c4aac7e9a883e1461ad43bc-image-20240510164257603-2963c4.png)

![image-20240510164306756](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/dde3246572242cae6da42c2f357be2ce-image-20240510164306756-e261df.png)

均报错，提示：对不起, 无法连接数据库, 请先检查数据库配置再继续进行安装

![image-20240510164331748](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/d0d1b1eb5ff22b81e09cfeb437967b88-image-20240510164331748-5b2b15.png)

可能是哪里的权限有问题，不管是使用mysql的root还是typeche账户都是报错，尝试过将localhost换成127.0.0.1均不行。

### 2.nginx报错

```bash
Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error mounting "/data/nginx/nginx.conf" to rootfs at "/etc/nginx/nginx.conf": mount /data/nginx/nginx.conf:/etc/nginx/nginx.conf (via /proc/self/fd/6), flags: 0x5000: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type
```

原因：

1、创建容器时，默认将nginx.conf配置创建成了目录；

2、没有将克隆的配置复制到对应的容器目录。

解决办法：

移动配置文件，到对应的目录下即可：

```bash
mv /tmp/docker-typecho/nginx /data/typecho/nginx
mv /tmp/docker-typecho/www /data/typecho/www
```
