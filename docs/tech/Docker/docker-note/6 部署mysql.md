# 部署MySQL



## **一、安装Mysql 5.7**

```bash
docker pull mysql:5.7        #安装容器
docker images mysql:5.7      #确认包
```

> 要查看 Docker Hub 上可用的 MySQL 版本，可以使用以下命令：
>
> ```bash
> #没有指定具体的标签时，会默认拉取mysql:latest标签，代表最新版本的MySQL镜像
> docker run -it --rm mysql mysql --version
> 
> #如果想查看其他特定版本的MySQL，需要明确指定该版本的标签，如mysql:5.7、mysql:8.0等
> docker run -it --rm mysql：5.7 mysql --version
> ```



## **二、简单版本**

### **1.启动Mysql容器**

```bash
需要使用 -e 配置环境变量 MYSQL_ROOT_PASSWORD（mysql root用户的密码），如果linux本身有mysql，则3306会被占用
docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7
```

![image-20240426234611759](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/26/6423cf5c59b795644962b966dba2801f-image-20240426234611759-868d36.png)

### **2.连接mysql**

```bash
docker exec -it 71bfb1ce8010 /bin/bash         #连接容器
mysql -uroot -p                                #连接数据库
```

> ```bash
> 如连接时，使用mysql -uroot -p 报错'/var/run/mysqld/mysqld.sock'，
> 使用mysql -u root -h 127.0.0.1 -p即可。
> mysql -u root -h 127.0.0.1 -p
> 
> （遇到一次报错，直接回车即可登录，没有密码）
> 
> 将 MYSQL_HOST 从 localhost 改为 127.0.0.1 即可
> 使用 localhost 时，mysql 客户端并不是访问 localhost:3306，而是直接访问 /var/run/mysqld/mysqld.sock。
> 如果是在本地部署 MySQL，这样当然没有问题；但是如果使用 Docker 部署 MySQL，
> /var/run/mysqld/mysqld.sock 根本不存在，必须通过 127.0.0.1:3306 进行访问。
> ```

### **3.数据库操作**

```bash
-- 创建db01数据库
create database db01;
-- 切换到db01;
use db01;
-- 创建表
create table t1(id int, name varchar(20));

-- 插入英文可以正常插入
insert into t1 values(1, 'abc');

-- 插入中文报错
insert into t1 values(3, '张三');

这是因为docker默认的字符集的问题，可以在mysql中使用以下命令查看数据库字符集：
show variables like 'character%';

返回的字符集中，character_set_database、character_set_server等都为latin1字符集，所以会报错。
而且因为启动容器时没有配置容器卷映射，当容器意外被删时，数据无法找回。
```

**navicat工具**

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/26/808e4b95d76b77ee1bad572a218be06f-image-20240426235910408-7d9918.png" alt="image-20240426235910408" style="zoom: 67%;" />



## **三、实战版**

### **1.启动 Mysql 容器，并配置容器卷映射**

```bash
docker run -d -p 3306:3306 \
           --privileged=true \
           -v /data/mysql/log:/var/log/mysql \
           -v /data/mysql/data:/var/lib/mysql \
           -v /data/mysql/conf:/etc/mysql/conf.d \
           -e MYSQL_ROOT_PASSWORD=jerion \
           --name mysql \
           mysql:5.7
```

### **2.在/data/mysql/conf下新建my.cnf，通过容器卷同步给mysql实例，解决中文乱码问题**

```bash
cd /data/mysql/conf/
vim my.cnf

[client]
default_character_set=utf8
[mysqld]
collation_server = utf8_general_ci
character_set_server = utf8
```

### **3.重启mysql容器，使得容器重新加载配置文件**

```bash
docker restart mysql
```

​		此时便解决了中文乱码（中文插入报错）问题。

> centos8进入mysql容器后输入中文可能会不显示，在启动mysql容器时，可添加`env LANG='C.UTF-8'`后有效，不过只限制进入的这一次，每次启动需要手动添加改参数。

​		而且因为启动时将容器做了容器卷映射，将mysql的配置（映射到**/app/mysql/conf**）、数据（映射到**/app/mysql/data**）、日志（映射到**/app/mysql/log**）都映射到了宿主机实际目录，所以即使删除了容器，也不会产生太大影响。只需要再执行一下启动Mysql容器命令，容器卷还按相同的位置进行映射，所有的数据便都可以正常恢复。





## **四、Mysql主从复制安装**

### **1.安装主服务器容器实例（端口号3307）**

#### **1.1 启动容器实例**

```bash
docker run -p 3307:3306 \
           --name mysql-master \
           --privileged=true \
           -v /mydata/mysql-master/log:/var/log/mysql \
           -v /mydata/mysql-master/data:/var/lib/mysql \
           -v /mydata/mysql-master/conf:/etc/mysql \
           -e MYSQL_ROOT_PASSWORD=123456 \
           -d mysql:5.7
```

#### **1.2 进入/mydata/mysql-master/conf，新建my.cnf配置文件**

vim /mydata/mysql-master/conf/my.cnf	

```bash
[mysqld]
## 设置server_id, 同一个局域网中需要唯一
server_id=101
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql
## 开启二进制日志功能
log-bin=mall-mysql-bin
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed
## 二进制日志过期清理时间。默认值为0，表示不自动清理
expire_logs_days=7
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
```

#### **1.3 重启容器实例**

```bash
docker restart mysql-master
```

#### **1.4 进入容器实例内**

```bash
docker exec -it mysql-master /bin/bash
```

#### **1.5 登录mysql，创建数据同步用户**

```sql
-- 首先使用 mysql -uroot -p 登录mysql
-- 创建数据同步用户
create user 'slave'@'%' identified by '123456';#host为%表示用户可以从任何主机连接到MySQL服务
-- 授权
grant replication slave, replication client on *.* to 'slave'@'%';
flush privileges;
```

### **2.安装从服务器容器实例（端口号3308）**

#### **2.1 启动容器服务**

```bash
docker run -p 3308:3306 \
           --name mysql-slave \
           --privileged=true \
           -v /mydata/mysql-slave/log:/var/log/mysql \
           -v /mydata/mysql-slave/data:/var/lib/mysql \
           -v /mydata/mysql-slave/conf:/etc/mysql \
           -e MYSQL_ROOT_PASSWORD=123456 \
           -d mysql:5.7
```

#### **2.2  进入/mydata/mysql-slave/conf目录，创建my.cnf配置文件**

`vim /mydata/mysql-slave/conf/my.cnf`

```bash
[mysqld]
## 设置server_id, 同一个局域网内需要唯一
server_id=102
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql
## 开启二进制日志功能，以备slave作为其它数据库实例的Master时使用
log-bin=mall-mysql-slave1-bin
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed
## 二进制日志过期清理时间。默认值为0，表示不自动清理
expire_logs_days=7
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断
## 如：1062错误是指一些主键重复，1032是因为主从数据库数据不一致
slave_skip_errors=1062
## relay_log配置中继日志
relay_log=mall-mysql-relay-bin
## log_slave_updates表示slave将复制事件写进自己的二进制日志
log_slave_updates=1
## slave设置只读（具有super权限的用户除外）
read_only=1
```

#### **2.3 修改完配置需要重启slave容器实例** 

```bash
docker restart mysql-slave
```

### **3.在主数据库中查看主从同步状态**

#### **3.1 进入主数据库容器**

```bash
docker exec -it mysql-master /bin/bash
```

#### **3.2  进入Mysql**

```bash
mysql -uroot -p
```

#### **3.3 查看主从同步状态**

```bash
show master status;
```

主要查看返回结果的文件名File、当前位置Position。

![image-20240510104505553](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/0ec257a4a9210e136a0204d681772f00-image-20240510104505553-d11a86.png)

### **4.进入从数据库容器，配置主从复制**

#### **4.1 进入从数据库容器**

```bash
docker exec -it mysql-slave /bin/bash
```

#### **4.2 进入数据库**

```bash
mysql -uroot -p
```

#### **4.3 配置从数据库所属的主数据库**

```bash
-- 格式：
-- change master to master_host='宿主机ip',
master_user='主数据库配置的主从复制用户名',
master_password='主数据库配置的主从复制用户密码',
master_port=宿主机主数据库端口,
master_log_file='主数据库主从同步状态的文件名File',
master_log_pos=主数据库主从同步状态的Position,
master_connect_retry=连接失败重试时间间隔（秒）;

change master to master_host='10.22.51.63',
master_user='slave',
master_password='123456',
master_port=3307,
master_log_file='mall-mysql-bin.000001',
master_log_pos=769,master_connect_retry=30;
```

#### **4.4 查看主从同步状态**

```bash
# \G 可以将横向的结果集表格转换成纵向展示。
# slave status的字段比较多，纵向展示比友好
show slave status \G;
```

​		除了展示刚刚配置的数据库信息外，主要关注 Slave_IO_Running、Slave_SQL_Running。目前两个值应该都为No，表示还没有开始。 

#### **4.5 开启主从同步**

```bash
start slave;
```

#### **4.6 再次查看主从同步状态，Slave_IO_Running、Slave_SQL_Running都变为Yes。** 

主从复制测试：在主数据库上新建库、使用库、新建表、插入数据 

```sql
create database db01;
use db01;
create table t1 (id int, name varchar(20));
insert into t1 values (1, 'abc');
```

#### **4.7 在从数据库上使用库、查看记录**

```sql
show databases;
use db01;
select * from t1;
```

![image-20240510104527613](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/cb5aac78489ada1d218a1d048eb7c93d-image-20240510104527613-9a6927.png)
