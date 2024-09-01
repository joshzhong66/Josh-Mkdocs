# docker部署nginx



## 一、nginx概念

​		Nginx（engine x）是一个高性能的HTTP和反向代理web服务器，同时也提供了IMAP/POP3/SMTP服务。Nginx是由伊戈尔·赛索耶夫为俄罗斯访问量第二的Rambler.ru站点（俄文：Рамблер）开发的，公开版本1.19.6发布于2020年12月15日。

​		其将源代码以类BSD许可证的形式发布，因它的稳定性、丰富的功能集、简单的配置文件和低系统资源的消耗而闻名。2022年01月25日，nginx 1.21.6发布。 [12]

​		Nginx是一款轻量级的Web 服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器，在BSD-like 协议下发行。其特点是占有内存少，并发能力强，事实上nginx的并发能力在同类型的网页服务器中表现较好。



## 二、获取nginx镜像

### **1.查看nginx版本**

（1）选择版本，可以去[docker hub](http://hub.docker.com)，搜索`nginx`：

![image-20240507212041158](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/07/38fee01b15460e88e0ace24c53073daf-image-20240507212041158-5a6eaf.png)

点击```tags```,可以看到历史版本：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/07/9d8c91d0e10a5200bffc018fe62ece6f-image-20240507212132566-eadd90.png" alt="image-20240507212132566" style="zoom:50%;" />

（2）通过命令查看一些热门的Nginx镜像：

```bash
docker search nginx
```

输出：

```bash
NAME                           DESCRIPTION                                      STARS     OFFICIAL 
nginx                          Official build of Nginx.                         19768     [OK]       
unit                           Official build of NGINX Unit: Universal Web …    26        [OK]       
nginxinc/nginx-unprivileged    Unprivileged NGINX Dockerfiles                   144      
```



## 三、下载Nginx镜像

使用命令```docker pull nginx```默认为下载最新版（latest）：

```bash
docker pull nginx
```

也可以下载指定版本1.20.1：

```bash
docker pull nginx:1.20.1
```

查看下载到本地的镜像文件：

```bash
docker images
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/07/2f51ea0fe4f3a434de529462f8a16269-image-20240507213032019-03a440.png" alt="image-20240507213032019" style="zoom:50%;" />



## 四、启动nginx容器（简单版）

创建一个名为 "nginx" 的容器，并将容器内的端口 80 映射到主机的端口 8080。

格式：docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

```bash
docker run --name nginx -p 8071:80 -d nginx
```

这个命令的缺陷主要有以下几点：

- 缺乏挂载卷：该命令没有使用 `-v` 参数来挂载容器内的数据卷或文件。这意味着容器内的数据（例如网站文件、日志文件等）将无法持久化保存。当容器被删除或重新创建时，所有的数据都会丢失。
- 缺少自定义配置：该命令没有提供自定义的 Nginx 配置文件。默认情况下，Nginx 容器将使用其内部的默认配置。如果你需要自定义 Nginx 的配置，例如修改虚拟主机或代理设置等，你需要编辑容器内的配置文件，或者使用挂载卷将自定义的配置文件传递给容器。
- 缺少容器重启策略：该命令没有指定容器的重启策略。默认情况下，容器在退出时不会自动重启。如果你希望容器在发生故障或主机重启后自动重启，你可以使用 `--restart` 参数来设置适当的重启策略。
- 使用最新的 Nginx 镜像：该命令使用的是 `nginx` 镜像，但没有指定具体的版本号。默认情况下，Docker 将使用最新的可用版本。这意味着在将来重新创建容器时，可能会使用一个不同的版本，导致行为和配置的变化。



## 五、启动nginx容器（实际应用版）

### **1.创建挂载目录**

```bash
mkdir -p /data/nginx/conf
mkdir -p /data/nginx/log
mkdir -p /data/nginx/html
```

### **2.关于容器与主机之间互传文件**

（1）将上面创建简单版nginx容器文件，拷贝到主机，命令格式：```docker cp 【容器id】:容器目录  本地目录```

```bash
# 将容器nginx.conf文件复制到宿主机
docker cp nginx:/etc/nginx/nginx.conf /data/nginx/conf/nginx.conf

# 将容器conf.d文件夹下内容复制到宿主机
docker cp nginx:/etc/nginx/conf.d /data/nginx/conf/conf.d

# 将容器中的html文件夹复制到宿主机
docker cp nginx:/usr/share/nginx/html /data/nginx/
```

- `docker cp`：用于在容器和主机之间复制文件或目录的命令。
- `nginx:/etc/nginx/nginx.conf`：指定了容器内的文件路径，这里是容器名为 "nginx" 的容器中的 `/etc/nginx/nginx.conf` 文件。
- `/data/nginx/conf/nginx.conf`：指定了主机上的目标文件路径，这里是将文件复制到 `/data/nginx/conf/nginx.conf`。

**PS：以下这条命令不用执行，只是作为备注如何传输文件**

（2）将主机文件拷贝到容器目录，格式：```docker cp 本地目录  【容器id】:容器目录  ```

```bash
#把外面的内容复制到容器里面
docker cp  /data/nginx/conf/nginx.conf  【容器id】:/etc/nginx/nginx.conf
```

- `/data/nginx/conf/nginx.conf`：指定了主机上的源文件路径，这里是将主机上的 `/data/nginx/conf/nginx.conf` 文件复制到容器内。
- `【容器id】:/etc/nginx/nginx.conf`：指定了容器内的目标文件路径，这里是容器的 ID（或名称）为 `【容器id】` 的容器中的 `/etc/nginx/nginx.conf` 文件。

本命令跳过，执行以下命令。

### **3.启动容器命令**

```bash
docker run -d -p 8072:80 \
-v /data/nginx/html:/usr/share/nginx/html:ro \
-v /data/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /data/nginx/conf/conf.d:/etc/nginx/conf.d \
-v /data/nginx/log:/var/log/nginx \
--restart=always \
--name mynginx-02 \
nginx
```

启动容器命令的详细解释：

- `docker run`：运行一个新的容器。
- `-d`：以后台模式运行容器。
- `-p 8072:80`：将容器内的端口80映射到主机的端口8072。这样可以通过主机的端口访问Nginx服务。
- `-v /data/nginx/html:/usr/share/nginx/html:ro`：使用卷挂载功能，将本地目录 `/data/nginx/html` 挂载到容器内的 `/usr/share/nginx/html` 目录，并设置为只读（`ro`）。这样可以将自定义的 HTML 文件挂载到 Nginx 容器，用于网站内容的展示。
- `-v /data/nginx/conf/nginx.conf:/etc/nginx/nginx.conf`：使用卷挂载功能，将本地文件 `/data/nginx/conf/nginx.conf` 挂载到容器内的 `/etc/nginx/nginx.conf` 文件。这样可以使用自定义的Nginx配置文件。
- `-v /data/nginx/conf/conf.d:/etc/nginx/conf.d`：使用卷挂载功能，将本地目录 `/data/nginx/conf/conf.d` 挂载到容器内的 `/etc/nginx/conf.d` 目录。这样可以挂载自定义的Nginx配置文件片段。
- `-v /data/nginx/log:/var/log/nginx`：使用卷挂载功能，将本地目录 `/data/nginx/log` 挂载到容器内的 `/var/log/nginx` 目录。这样可以将Nginx的日志文件存储到本地目录。
- `--restart=always`：设置容器在退出时自动重启。
- `--name mynginx-02`：为容器指定一个名称，这里是 "mynginx-02"。
- `nginx`：基于 Nginx 镜像运行容器。

运行后观察本地目录`/data/nginx/log`下生成了两个log日志，是从容器内的nginx日志存储过来的：

```bash
[root@jerion ~]# cd /data/nginx/log
[root@jerion log]# ls
access.log  error.log
```



## **五、访问测试**

写入一个html文件，访问测试：

```bash
[root@localhost ~]# vim /data/nginx/html/index2.html
```
写入：
```bash
Hello world
```
输入IP+端口访问：```http://你的IP:端口/index2.html```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/08/edac8915d40485569d7b99698a272c88-image-20240508003024234-09561f.png" alt="image-20240508003024234" style="zoom:50%;" />
