# docker容器命令



## 一、容器命令

### **5.1 容器命令参数**

```bash
启动容器格式参数：
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
	OPTIONS: 是一系列的选项，用于配置容器的各种属性，如挂载卷、端口映射、环境变量等。
	IMAGE: 指定要使用的Docker镜像。
	COMMAND: 是容器启动时要执行的命令。如果省略，则默认使用镜像中定义的默认命令。
	ARG: 是传递给容器启动命令的参数。

常用的参数：
	--name：为容器指定一个名称
    --restart：用于指定容器的重启策略
	-d：后台运行容器并返回容器ID，也即启动守护式容器
	-i：以交互模式（interactive）运行容器，通常与-t同时使用
	-v: 容器中挂载卷
	-t：为容器重新分配一个伪输入终端（tty），通常与-i同时使用。
	-e：为容器添加环境变量
	-P：随机端口映射。将容器内暴露的所有端口映射到宿主机随机端口
	-p：指定端口映射
            
            
-p指定端口映射的几种不同形式：
	-p hostPort:containerPort    ：端口映射，例如-p 8080:80
	-p ip:hostPort:containerPort    ：配置监听地址，例如 -p 10.0.0.1:8080:80
	-p ip::containerPort        ：随机分配端口，例如 -p 10.0.0.1::80
	-p hostPort1:containerPort1 -p hostPort2:containerPort2        
	：指定多个端口映射，例如-p 8080:80 -p 8888:3306
```

> `--restart` 选项可用的参数：
>
> - `no`：默认值。表示容器退出时不会自动重启。
> - `always`：表示容器退出时总是自动重启。
> - `on-failure[:max-retries]`：表示容器在非零退出代码时自动重启。可选的 `max-retries` 参数指定 Docker 重试启动容器的最大次数。
> - `unless-stopped`：表示容器退出时总是自动重启，除非容器被手动停止。

### **5.2  启动交互式容器**

```bash
docker run -it ubuntu /bin/bash
命令参数：
    -i 交互模式
    -t 分配一个伪输入终端tty
    ubuntu 镜像名称
    /bin/bash（或者bash） shell交互的接口

# ubuntu交互模式，自定义容器名称myu01
docker run -it --name=myu01 ubuntu bash        

# 退出交互模式
方法1：在交互shell中exit即可退回宿主机，容器停止
方式2：使用快捷键ctrl + P + Q，容器仍然在运行
```

### **5.3 启动守护式容器**

​		大部分情况下，docker在后台运行时，可以通过-d指定容器的后台运行模式：

```bash
docker run -d 容器名
命令参数：
	-d：后台运行容器并返回容器ID，也即启动守护式容器
举例：
docker run -d redis    
```

​		注意事项：如果使用`docker run -d ubuntu`尝试启动守护式的ubuntu，会发现容器启动后就自动退出了。

​		因为Docker容器如果在后台运行，就必须要有一个前台进程。容器运行的命令如果不是那些一直挂起的命令（例如`top`、`tail`），就会自动退出。

### **5.4 列出正在运行的容器**

```bash
docker ps [OPTIONS]
    常用参数：
    -a：列出当前所有正在运行的容器+历史上运行过的容器
    -l：显示最近创建的容器
    -n：显示最近n个创建的容器
    -q：静默模式，只显示容器编号
举例：
docker ps -n 3     #查看最近3个创建的容器
```

### **5.5 日志-运行进程-内部细节**

```bash
docker logs 容器ID或容器名      #查看容器日志
docker top 容器ID或容器名       #查看容器内运行的进程
docker inspect 容器ID或容器名   #查看容器内部细节
```

### **5.6 启动停止重启容器**

```bash
docker start       容器ID或容器名          #启动已经停止的容器
docker restart     容器ID或容器名          #重启容器
docker stop        容器ID或容器名          #停止容器
docker kill        容器ID或容器名          #强制停止容器
```

### **5.7 删除容器**

```bash
docker rm 容器ID或容器名       #删除容器（删除容器是docker rm，删除镜像是docker rmi，注意区分）
docker rm -f 容器ID或容器名    #强制删除正在运行的容器

一次删除多个容器实例：
docker rm -f ${docker ps -a -q}
# 或者
docker ps -a -q | xargs docker rm
```

### **5.8 进入正在运行的容器**

```bash
docker exec -it 容器ID /bin/bash     #进入正在运行的容器(进入正在运行的容器，并以命令行交互：)
docker attach 容器ID                 #重新进入正在运行的容器(exit退出会导致容器停止)
```

> **docker exec** 和 **docker attach** 区别：
>
> attach直接进入容器启动命令的终端，不会启动新的进程，用exit退出会导致容器的停止
>
> exec是在容器中打开新的终端，并且可以启动新的进程，用exit退出不会导致容器的停止
>
> 如果有多个终端，都对同一个容器执行了 **docker attach**，就会出现类似投屏显示的效果。一个终端中输入输出的内容，在其他终端上也会同步的显示。
>
> 举例：
>
> docker exec -it e36c0f50ec13 bash

### **5.9 容器和宿主机文件拷贝**

```bash
docker cp 容器ID:容器内路径 目的主机路径	   #容器内文件拷贝到宿主机
docker cp 主机路径 容器ID:容器内路径		#宿主机文件拷贝到容器中

举例：
docker cp 79443d0c6126:/tmp/josh.txt /tmp
docker cp /tmp/askage.sh 79443d0c6126:/tmp
```

### **5.10 导入和导出容器**

**export**：导出容器的内容流作为一个tar归档文件（对应**import**命令）；

**import**：从tar包中的内容创建一个新的文件系统再导入为镜像（对应**export**命令）

```bash
# 导出
# docker export 容器ID > tar文件名
docker export 202062990a66 >bak.tar        #会导出到linux服务器你所在的目录下

# 导入
# cat tar文件 | docker import - 自定义镜像用户/自定义镜像名:自定义镜像版本号
举例：
cat bak.tar | docker import - test/ubuntu_my:1.1        #导入后用docker images确认 
```

![image-20240510103858901](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/f1be33cb28dddd81ffe714f6cd0ee157-image-20240510103858901-64bd8c.png)

> docker run -it 9133655d6ea8 bash		#重启导入的test/ybuntu_my系统

### 5.11 提交容器副本使之成为一个新的镜像

```bash
docker commit -m="提交的描述信息” -a="作者” 容器ID 要创建的目标镜像名:[标签名]
举例：
docker commit -m="ifconfig cmd add" -a="jerion" ff61b666e6a4 jerionubuntu:1.2
```

> 案例演示ubuntu安装vim
>
> 从Hub上下载ubuntu镜像到本地并成功
>
> 运行原始的默认ubuntu镜像是不带着vim命令的 
>
> 外网连通的情况下，安装vim
>
> 安装完成后，commit我们自己的新镜像
>
> 启动新镜像和原来的镜像对比



## **二、容器数据卷**

### **1.容器数据卷的概念**

卷就是目录或文件，存在于一个或多个容器中，由docker挂载到容器，但不属于联合文件系统，因此能够绕过UnionFS，提供一些用于持续存储或共享数据。

特性：卷设计的目的就是数据的持久化，完全独立于容器的生存周期，因此Docker不会在容器删除时删除其挂载的数据卷。

特点：

- 数据卷可以在容器之间共享或重用数据

- 卷中的更改可以直接实施生效

- 数据卷中的更改不会包含在镜像的更新中

- 数据卷的生命周期一直持续到没有容器使用它为止

> docker run -v <宿主机路径>:<容器路径> <其他选项> <镜像>

> 在 Docker Compose文件中，`volumes` 部分用于定义容器中的数据卷。在你提供的两个例子中，它们的作用是相同的，都是用来定义数据卷的挂载方式。
>
> - 原始的定义方式：
>
>   ```bash
>   volumes:
>     - type: bind
>       source: "/data/NginxWebUI"
>       target: "/home/nginxWebUI"
>   ```
>
> - 简化后的定义方式：
>
>   ```bash
>   volumes:
>     - /data/NginxWebUI:/home/nginxWebUI
>   ```
>
> 这两种方式的作用是一样的，都是将主机上的`/data/NginxWebUI`目录挂载到容器中的`/home/nginxWebUI`目录。第二种方式是一种更为简洁的写法，它省略了`type: bind`、`source` 和 `target` 这些属性，因为在这种情况下，Docker 会默认将这个挂载视为绑定类型的挂载。
>
> 因此，这两种方式在功能上是等效的。

### **2.运行一个带有容器卷存储功能的容器实例**

```bash
docker run -it --privileged=true -v 宿主机绝对路径目录:容器内目录[rw | ro] 镜像名
```

### **3.查看容器绑定的数据卷可以使用docker inspect**

> 权限：
>
> rw：读写  
>
> ro：只读。如果宿主机写入内容，可以同步给容器内，容器内可以读取。 

### **4.容器卷的继承**

```bash
# 启动一个容器
docker run -it --privileged=true /tmp/test:/tmp/docker --name u1 ubuntu /bin/bash

# 使用--volumes-from继承u1的容器卷映射配置
docker run -it --privileged=true --volumes-from u1 --name u2 ubuntu
```

### **5.例1：主机与容器双向互写文件**

```bash
docker run -it --privileged=true -v /tmp/host_data:/tmp/docker_data --name=u1 ubuntu
touch /tmp/docker_data/aaa.txt
```

![image-20240510104249803](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/b477b2e6c714bae105fcce7562ae75bc-image-20240510104249803-779b0e.png)

```bash
ll /tmp/host_data/        #宿主机查看同步情况
```

![image-20240510104310806](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/dd7180acaed7c510231cc4b5f00fe4bd-image-20240510104310806-2943a9.png)

### 6.例2：容器只读，主机写入

```bash
docker run -it --privileged=true -v /tmp/mydocker/u:/tmp/u:ro --name u2 ubuntu
```

![image-20240510104322716](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/4b23185dfae5dce0d2e9031cb2f6fb2c-image-20240510104322716-790ff1.png)

![image-20240510104332611](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/1167ab3008566693de2eac91075063a3-image-20240510104332611-b37e63.png)



## **三、所有命令示意图**

![image-20240510104348157](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/b06918334d00fa832aaa7bbe719fa7e6-image-20240510104348157-c32973.png)