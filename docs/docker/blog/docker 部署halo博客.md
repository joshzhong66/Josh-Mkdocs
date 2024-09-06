# docker部署halo博客



## 一、Halo blog搭建

### 1.创建目录

```bash
mkdir -p /data/Halo/halo2
mkdir -p /data/Halo/db
```

### 2.编辑docker-compose.yml文件

`vim /data/Halo/docker-compose.yml`

```bash
version: "3"
services:
  halo:
    image: halohub/halo:2.14
    container_name: halo2
    networks:
      - halo_network
    restart: on-failure:3
    depends_on:
      halodb:
        condition: service_healthy
    volumes:
      - /data/Halo/halo2:/root/.halo2
    ports:
      - "8090:8090"
    healthcheck:
      # test: ["CMD", "curl", "-f", "http://localhost:8090/actuator/health/readiness"]
      test: ["CMD-SHELL", "curl -f http://localhost:8090/actuator/health/readiness || exit 1"]
      interval: 1m
      timeout: 10s
      retries: 3
      start_period: 1m
    command:
      - --spring.r2dbc.url=r2dbc:pool:postgresql://halodb/halo
      - --spring.r2dbc.username=halo
      # #设置你的数据库PostgreSQL的密码，请保证与下方POSTGRES_PASSWORD的变量值一致。
      - --spring.r2dbc.password=dream13889
      - --spring.sql.init.platform=postgresql
      # 外部访问地址，请根据实际需要修改
      - --halo.external-url=https://blog.jerion.cn/
      - --halo.security.initializer.superadminusername=admin
      - --halo.security.initializer.superadminpassword=dream13889
  halodb:
    image: postgres:15.4
    container_name: halodb2
    networks:
      - halo_network
    restart: on-failure:3
    volumes:
      - /data/Halo/db:/var/lib/postgresql/data
    healthcheck:
      # test: [ "CMD", "pg_isready" ]
      test: ["CMD-SHELL", "pg_isready -U halo -d halo -h localhost"]
      interval: 30s
      timeout: 5s
      retries: 5
    environment:
      - POSTGRES_PASSWORD=dream13889  #设置你的数据库密码
      - POSTGRES_USER=halo
      - POSTGRES_DB=halo
      - PGUSER=halo
networks:
  halo_network:
    name: halo_network
    ipam:
      driver: default
      config:
        - subnet: 172.197.0.0/16
```

### 3.配置frp内网穿透（可选）

#### 3.1 配置frps服务端

frps.ini配置文件新增一个代理规则，需要穿透的domain服务：

```bash
[root@jerion ~]# cd /data/frp/frp_server
[root@jerion frp_server]# vim frps.ini

[Halo]
type = tcp
local_ip = 172.31.100.196
local_port = 8090
remote_port = 8204
```

#### 3.2 配置frpc客户端

frpc.ini配置文件新增一个代理规则，需要穿透的domain服务：

```bash
[root@jerion ~]# cd /data/frp/frp_client/
[root@jerion frp_client]# vim frpc.ini

[Halo]
type = tcp
local_ip = 172.31.100.196
local_port = 8090
remote_port = 8204
```

#### 3.3 重启

```bash
# 重启服务端
docker restart frps
# 重启客户端
docker restart frpc
```

### 4.启动halo容器

```bash
cd /data/Halo
docker compose up -d
```



## 二、反向代理配置

如需要配置反向代理，需要确保nginx的网络与Halo容器的互通，或者使用同一个docker网络。

### 1.nginx配置反向代理

halo网络查询：

```bash
[root@hecs-349046 ~]# docker network ls 
NETWORK ID     NAME                DRIVER    SCOPE
c197f2593d0b   bridge           bridge    local
19719758a730   domain_default   bridge    local
60523a1ccfad   halo_network     bridge    local
7333414467bc   host             host      local
260007c398e2   none             null      local
```

容器的网络为：halo_network。

启动docker的nginx容器时，需要指定到halo同一个网络：

```bash
--network halo_network \
```

> 启动nginx容器：
>
> ```bash
> docker run -d -p 80:80 \
> -v /data/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
> -v /data/nginx/conf/conf.d:/etc/nginx/conf.d \
> -v /data/nginx/log:/var/log/nginx \
> -v /data/nginx/html:/usr/share/nginx/html \
> -v /data/nginx/cert:/etc/nginx/cert \
> --restart=always \
> --hostname=jerion \
> --name nginx \
> --network halo_network \
> nginx:latest
> ```

nginx配置反向代理，需要在http模块新增反向代理的配置，如下：

```bash
[root@jerion ~]# cd /data/nginx/conf/conf.d
[root@jerion conf.d]# vim halo.conf
server {
	listen 80;
	server_name blog.jerion.cn;	 #填写实际域名

	location / {
	    # 如果127.0.0.1:8090无法识别，可以使用容器名称+端口：halo2:8090
		# proxy_pass http://127.0.0.1:8090;
		# 这里配了frp内网穿透，因此端口为8204
		proxy_pass http://47.113.113.48:8204
    }
}
```

### 2.nginxWebUI配置反向代理

登录nginxwebui，在“反向代理”栏中，点击“添加反向代理”：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/24/a1dd24de2fc387a2f100bf4d8ecfb371-image-20240524003709693-ad604c.png" alt="image-20240524003709693" style="zoom:50%;" />

设置额外参数：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/24/8ac47be3800959bc2323373d81fd9467-image-20240524003701154-c661a6.png" alt="image-20240524003701154" style="zoom:50%;" />

配置完成后，在“启动配置”栏，分别执行`检验文件-替换文件-重新装载`，显示成功即可成功启用配置。



## 三、访问博客首页

浏览器访问`blog.jerion.cn`，首次登录需要填写注册管理员信息：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/24/c75b052b0bb2a062d071971043da92ca-image-20240524012949361-8b615b.png" alt="image-20240524012949361" style="zoom:50%;" />

登录管理后台需要再后面加上`/console`，如`blog.jerion.cn/console`。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/24/81bbb7e020d1250c6693e86085eb078a-image-20240524013001983-bdd760.png" alt="image-20240524013001983" style="zoom:50%;" />



## 四、博客的配置使用

### 1.添加主题

在服务器上下载主题包：

```bash
# 切换到主题目录下
cd /data/Halo/halo2
cd themes

# 获取主题压缩包
wget https://github.com/jiewenhuang/halo-theme-stack/releases/download/v1.1.0/halo-theme-stack-1.1.0.zip

# 解压
unzip halo-theme-stack-1.1.0.zip
# 删除压缩包
rm -rf halo-theme-stack-1.1.0.zip
# 重命名
mv halo-theme-stack-1.1.0 theme-stack
```

在web控制台中点击`主题管理`--`本地未安装`--`安装主题`，安装后启动新的主题：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/5338fb0b61ddc3dac26f7fe1cebc5126-image-20240528005235195-a45688.png" alt="image-20240528005235195" style="zoom:50%;" />

在“主题”栏中，修改一些信息，然后保存：

`主题`--`基本设置`：

![image-20240528005426042](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/9cf2047aae6e1222f3e286b28ba3cf26-image-20240528005426042-02a094.png)

![image-20240528113422265](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/98624c9de8aba6846edf14b7fb3c7dd0-image-20240528113422265-ef565f.png)

### 2.添加插件

在“插件”栏中，右上角点击“安装”，可安装需要的插件：

![image-20240528110051358](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/29897fd29435cfda567476a63a85de34-image-20240528110051358-283243.png)

### 3.添加附件

在“附件”栏中，可以新建分组：

![image-20240528111917220](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/aad7ef99550b2d4b1767aa49003461e9-image-20240528111917220-98e26c.png)

上传附件：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/7b8e8dd0a1dd3944ba594e0e95949a32-image-20240528112605022-35f088.png" alt="image-20240528112605022" style="zoom:50%;" />

![image-20240528112626544](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/a50d1e66ad3a2c81264087583bd0371b-image-20240528112626544-c497e6.png)

### 4.添加设置

在“设置”栏中，可以配置一些设置信息：

![image-20240528112823533](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/0f5d7d157aa15208529fcb05f490a6cb-image-20240528112823533-96d47c.png)

### 5.添加文章分类

在”文章“栏中，右上角点击”文章分类“，可以新建文章分类：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/d231f88e04626f1a9a158688aa56d63c-image-20240528130856965-041a0d.png" alt="image-20240528130856965" style="zoom: 33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/46a245c1e246ae358a0fccb031dbbbdc-image-20240528132146969-d5ac95.png" alt="image-20240528132146969" style="zoom:33%;" />

### 6.添加菜单

在“菜单”栏，可以新建菜单选择分类：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/a81d5f34524e8a56bd758af8f0956e79-image-20240528131625091-005a6e.png" alt="image-20240528131625091" style="zoom:33%;" />

![image-20240528132306039](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/28/97bcf6b9406e05e1149a809a4ea063c1-image-20240528132306039-35ac15.png)
