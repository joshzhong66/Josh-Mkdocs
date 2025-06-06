# docker镜像命令



## **一、帮助与启动命令**

### **1.启动docker命令**

```bash
启动docker: systemctl start docker
停止docker: systemctl stop docker
重启docker: systemctl restart docker
查看docker状态：systemctl status docker
开机启动: systemctl enable dqsker
```

### **2.docker帮助命令**

```bash
查看docker概要信息: docker info
查看docker总体帮助文档: docker --help
查看docker命令帮助文档: docker 具体命令 --help
```



## **二、镜像命令**

### **1.列出本地主机上的镜像**

```bash
docker images

参数：
	-a：列出所有镜像（含历史镜像）
    -q：只显示镜像ID
    -f：过滤

各个选项说明:
	REPOSITORY: 表示镜像的仓库源
	TAG: 镜像的标签版本号
    IMAGE ID: 镜像ID
    CREATED: 镜像创建时间
    SIZE: 镜像大小

同一仓库源可以有多个TAG版本，代表这个仓库源的不同个版本，我们使用 REPOSITORY:TAG 来定义不同的镜像。
如果你不指定一个镜像的版本标签，例如你只使用 ubuntu，docker 将默认使用ubuntu:latest 镜像

举例：docker images
```

### **2.在远程仓库中搜索镜像**

```bash
docker search 镜像名称（（默认取docker hub中搜索））

参数：
	-f：过滤
    --limit 数量：只展示前几项

举例：docker search redis --limit 5
```

### **3.镜像名称[:tag]**

```bash
参数：
    tag为标签版本号（默认下载最新版）

举例：docker pull ubuntu
```

### **4.查看占据的空间**

```bash
docker system df    #查看镜像（Images）/容器（Containers）/数据卷（Local Volumes）所占的空间
```

### **5.删除镜像**

```bash
docker rmi 镜像名称/ID
docker rmi -f hello-world                 #强制删除镜像包
docker rmi 镜像1 镜像2 镜像3               #可以使用空格分隔，删除多个镜像
docker rmi -f $(docker images -qa)        #删除全部
```

### **6.虚悬镜像（仓库名、标签都是空的镜像，俗称虚悬镜像）**

​		虚悬镜像(dangling image)是指在 Dockera 中存在的一种镜像，它已经被创建，但是没有被任何容器所引用。这通常发生在当你在构建镜像的过程中，因为一些原因（例如构建取消或构建失败)你创建了一个镜像，但是没有将其命名或标记。这些镜像被称为虚悬镜像，因为它们“悬浮"在 Docker中，没有被任何容器所使用，而且也不会被 Docker 清理工具删除。

#### 6.1 构建一个虚悬镜像

1.编写Dockerfile文件：

```bash
[root@jerion tmp]# cd /tmp
[root@jerion tmp]# vim Dockerfile
from ubuntu
CMD echo 'action is success'
```

2.构建镜像：

```bash
[root@jerion tmp]# docker build .    #在当前目录查找名为Dockerfile的文件，并基于该Dockerfile构建镜像
```

![image-20240510105242701](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/71d1aecd88d80e6132ff0e909444e5a9-image-20240510105242701-86955e.png)

#### 6.2 查看docker容器中存在的虚悬镜像

```bash
查看所有镜像包：
docker images

查看指定的虚悬镜像包：
docker image ls -l dangling=true
```

![image-20240510105250353](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/1bb4c125e4f44f321a9eb99c527f4945-image-20240510105250353-54f3b3.png)

#### 6.3删除虚玄镜像

```bash
手动确认删除：
docker image prune

手动强制删除：
docker image prune -f
```

### **7.下载镜像**

```bash
docker pull 镜像名称
举例：
docker pull tomcat
docker pull redis
docker pull unbuntu
docker pull mysql:5.7
```

#### 7.1 查看docker镜像源

```bash
# 查看docker镜像源
cat /etc/docker/daemon.json
```

### 8.镜像传输

要将一个Docker镜像从一台服务器传输到另一台服务器，你可以按照以下步骤操作：

#### 方法一：通过 Docker Hub

1. **推送镜像到 Docker Hub**：
   - 在源服务器上登录到 Docker Hub：`docker login`
   - 标记要传输的镜像：`docker tag IMAGE_ID YOUR_DOCKERHUB_USERNAME/REPOSITORY_NAME:TAG`
   - 推送镜像到 Docker Hub：`docker push YOUR_DOCKERHUB_USERNAME/REPOSITORY_NAME:TAG`
2. **从 Docker Hub 拉取镜像**：
   - 在目标服务器上登录到 Docker Hub：`docker login`
   - 拉取镜像：`docker pull YOUR_DOCKERHUB_USERNAME/REPOSITORY_NAME:TAG`

#### 方法二：通过保存和加载镜像文件

1. **在源服务器上保存镜像为文件**：
   - 保存镜像为 tar 文件：`docker save -o IMAGE_NAME.tar IMAGE_ID`
2. **将保存的镜像文件传输到目标服务器**：
   - 使用 scp、rsync 或其他文件传输工具将 tar 文件传输到目标服务器上。
3. **在目标服务器上加载镜像文件**：
   - 加载镜像文件：`docker load -i IMAGE_NAME.tar`
   - 使用 `docker tag` 命令为加载的镜像指定新的名称和标签。例如：

```bash
#加载镜像
[root@josh-clound ~]# docker load -i deluan_navidrome.tar 
aedc3bda2944: Loading layer [==================================================>]   7.63MB/7.63MB
b96cafd12891: Loading layer [==================================================>]  142.4MB/142.4MB
5f70bf18a086: Loading layer [==================================================>]  1.024kB/1.024kB
add7684a85dc: Loading layer [==================================================>]  44.42MB/44.42MB
Loaded image ID: sha256:59f3c0949a3150359677d6a61785a39b4b713fa8a6a761f3f4ddc530ffe13c1f

#查看镜像文件名称为：none
[root@josh-clound ~]# docker images
REPOSITORY                 TAG       IMAGE ID       CREATED        SIZE
<none>                     <none>    59f3c0949a31   4 weeks ago    193MB


#指定新的镜像名称和标签deluan/navidrome:latest
[root@josh-clound ~]# docker tag 59f3c0949a31 deluan/navidrome:latest

#再次查看
[root@josh-clound ~]# docker images
REPOSITORY                 TAG       IMAGE ID       CREATED        SIZE
deluan/navidrome           latest    59f3c0949a31   4 weeks ago    193MB
```

#### 方法三：使用 Docker 导出和导入

1. **在源服务器上导出镜像**：
   - 导出镜像为 tar 文件：`docker export CONTAINER_ID > IMAGE_NAME.tar`
2. **将导出的镜像文件传输到目标服务器**。
3. **在目标服务器上导入镜像**：
   - 导入镜像：`cat IMAGE_NAME.tar | docker import - IMAGE_NAME:TAG`

**注意事项：**

- 确保目标服务器上有足够的空间来存储传输的镜像。
- 在目标服务器上运行 `docker images` 确认镜像已成功加载。

选择适合你情况的方法，并根据具体需求执行相应的步骤，这样你就可以将 Docker 镜像从一台服务器传输到另一台服务器。