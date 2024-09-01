

## docker部署itops



### 1、部署itops

```
docker run -d -p 8089:8080 \
-v /data/itops:/usr/local/itops/data \
openitsystem/itops:1.0.1
```



### 2、部署mysql

```
mkdir -p /data/mysql/log
mkdir -p /data/mysql/data
mkdir -p /data/mysql/conf
```



```
docker run -d -p 3306:3306 \
           --privileged=true \
           -v /data/mysql5.7/log:/var/log/mysql \
           -v /data/mysql5.7/data:/var/lib/mysql \
           -v /data/mysql5.7/conf:/etc/mysql/conf.d \
           -e MYSQL_ROOT_PASSWORD=Sunline2024 \
           --name mysql5.7 \
           mysql:5.7



mysql -uroot -p

#创建数据库
create database itops;

#创建新的 ops 用户：
CREATE USER 'ops'@'localhost' IDENTIFIED BY 'sunline'; 

#确认数据库 ops 存在
CREATE DATABASE IF NOT EXISTS ops;

#确认用户已创建
SELECT user, host FROM mysql.user WHERE user = 'ops' AND host = 'localhost';

#刷新权限
FLUSH PRIVILEGES;

#检查 ops 用户的权限：
SHOW GRANTS FOR 'ops'@'localhost';
```





### 3、docker compose部署

```
version: '3.7'

services:
  itops:
    image: openitsystem/itops:1.0.1
    container_name: itops
    ports:
      - "8089:8080"
    environment:
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_USER=ops
      - DB_PASSWORD=sunline
      - DB_NAME=itops
    volumes:
      - /data/itops:/usr/local/itops/data
    depends_on:
      - mysql

  mysql:
    image: mysql:5.7
    container_name: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=sunline
      - MYSQL_DATABASE=itops
      - MYSQL_USER=ops
      - MYSQL_PASSWORD=sunline
    ports:
      - "3306:3306"
    volumes:
      - /data/mysql/conf:/etc/mysql/conf.d
      - /data/mysql/data:/var/lib/mysql
      - /data/mysql/log:/var/log/mysql

volumes:
  mysql_data:
```





### 4、登录信息

#### 1.默认的登录信息

```

平台登录路径 http://IP:8089
平台配置管理员账户：adminportal
平台配置管理员密码：tcQW*963@2019
```







#### 2.配置mysql数据库

填写mysql信息，点击更新配置



