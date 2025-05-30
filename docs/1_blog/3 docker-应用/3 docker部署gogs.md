# docker部署gogs



## 一、Gogs概念

### 1、Gogs

#### 1.1 概念

​		Gogs 是一款极易搭建的自助 Git 服务，是一个开源代码托管平台。

#### 1.2 目的

​		Gogs 的目标是打造一个最简单、最快速和最轻松的方式搭建自助 Git 服务。使用 Go 语言开发使得 Gogs 能够通过独立的二进制分发，并且支持 Go 语言支持的 所有平台，包括 Linux、Mac OS X、Windows 以及 ARM 平台。



## 二、Docker搭建Gogs，并上传项目

### 1、安装Gogs

```bash
docker pull gogs/gogs    #拉取gogs

#启动gogs，配置SSH端口122，访问端口3001，gogs持久化存储目录为/var/gogs
docker run --name=gogs -p 122:22 -p 3001:3000 -v /var/gogs:/data gogs/gogs
```

测试访问gogs页面：http://10.22.51.63:3001

![image-20240510105103937](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/ae4aab0389717092b3df835b016ce02d-image-20240510105103937-5e8a96.png)

> 由于未添加`-d`参数后台运行，启动时显示监听3000端口后即可在浏览器访问：

![image-20240510105111335](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/21e9d7ae3fb188d50fd0136eab7ad9ff-image-20240510105111335-3ff55f.png)

> 如果想让它在后台运行，可以添加`-d`参数，启动后在浏览器访问即可。
>
> ```bash
> docker run -d --name=gogs -p 122:22 -p 3001:3000 -v /var/gogs:/data gogs/gogs
> ```

### 2、创建gogs数据库

首次运行gogs安装程序需填写数据库信息，所以要创建gogs数据库和gogs用户。

```bash
#进入MySQL容器内
docker exec -it mysql-master /bin/bash    #数据库主机端口为10.22.51.63:3307

#进入mysql
mysql -uroot -p
#创建gogs数据库
create database gogs;
grant all privileges on gogs.* to gogs@'%' identified by 'gogs';   #创建用户并授权
flush privileges;    #刷新权限
```

### 3、填写安装程序所需的信息

浏览器访问http://10.22.51.63:3001，填写安装程序所需的信息。

### 4、停止容器

```bash
docker rm -f gogs    #删除现有的容器gogs
docker stop gogs    #命令停止现有的容器
docker rename gogs old_gogs    #将现有的容器gogs，重命名为old_gogs
docker ps
```





