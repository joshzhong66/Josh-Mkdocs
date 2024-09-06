# docker部署reader



参考文档：[reader官方网址](https://github.com/hectorqin/reader)、[参考博客](https://blog.laoda.de/archives/docker-compose-install-reader?cid=2776)

## 一、简介

reader是在线阅读服务器版本。



## 二、reader搭建

### 1.创建reader目录

```bash
mkdir -p /data/reader/logs
mkdir -p /data/reader/storage
```

### 2.下载docker-compose.yml文件

```bash
wget https://mirror.ghproxy.com/https://raw.githubusercontent.com/hectorqin/reader/master/docker-compose.yaml
```

### 3.编辑docker-compose.yml文件

`vim /data/reader/docker-compose.yml`

```bash
version: '3.1'

services:
# 多用户版
  read_all:
    image: hectorqin/reader
    container_name: reader   #容器名,可自行修改
    networks:
      - reader_network
    restart: always
    ports:
      - 4396:8080   #4396端口映射可自行修改
    volumes:
      - /data/reader/logs:/logs   #log映射目录 /root/data/docker_data/reader/logs 映射目录可自行修改
      - /data/reader/storage:/storage   #数据映射目录 /root/data/docker_data/reader/storage 映射目录可自行修改
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - READER_APP_SECURE=true   #开启登录鉴权，开启后将支持多用户模式
      - READER_APP_CACHECHAPTERCONTENT=true   #是否开启缓存章节内容 V2.0
      - READER_APP_SECUREKEY=dream13889       #管理员密码  可自行修改
# 自动更新docker
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    networks:
      - reader_network
    restart: always
    # 环境变量,设置为上海时区
    environment:
        - TZ=Asia/Shanghai
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: reader watchtower --cleanup --schedule "0 0 4 * * *"

networks:
  reader_network:
    name: reader_network
    ipam:
      driver: default
      config:
        - subnet: 172.100.0.0/16
```

### 4.配置frp内网穿透（可选）

#### 4.1 配置frps服务端

frps.ini配置文件新增一个代理规则，需要穿透的domain服务：

```bash
[root@jerion ~]# cd /data/frp/frp_server
[root@jerion frp_server]# vim frps.ini

[reader]
type = tcp
local_ip = 172.31.100.196
local_port = 4396
remote_port = 8207
```

#### 4.2 配置frpc客户端

frpc.ini配置文件新增一个代理规则，需要穿透的domain服务：

```bash
[root@jerion ~]# cd /data/frp/frp_client/
[root@jerion frp_client]# vim frpc.ini

[reader]
type = tcp
local_ip = 172.31.100.196
local_port = 4396
remote_port = 8207
```

#### 4.3 重启

```bash
# 重启服务端
docker restart frps
# 重启客户端
docker restart frpc
```

### 5.启动reader容器

```bash
cd /data/reader
docker compose up -d
```



## 三、访问reader

第一次登录需要注册账户，注册账户：admin   密码：dream13889。

![image-20240630222410792](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/30/829c47237619a99413ffe97071403a9e-image-20240630222410792-93a54b.png)
