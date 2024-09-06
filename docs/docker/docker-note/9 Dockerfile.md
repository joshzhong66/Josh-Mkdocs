# Dockerfile



## **一、Dockerfile概念**

​		Dockerfile是用来构建Docker镜像的文本文件，是由一条条构建镜像所需的指令和参数构成的脚本。

### **1.构建步骤**

1. 编写Dockerfile文件
2. `docker build`命令构建镜像
3. `docker run`依据镜像运行容器实例

### **2.构建过程**

#### 2.1 Dockerfile编写

- 每条保留字指令都必须为**大写字母**，且后面要跟随**至少一个**参数

- 指令按照**从上到下**顺序执行

- **#**表示注释

- 每条指令都会创建一个新的镜像层并对镜像进行提交


#### 2.2 Docker引擎执行Docker的大致流程

1. docker从基础镜像运行一个容器

2. 执行一条指令并对容器做出修改

3. 执行类似docker commit的操作提交一个新的镜像层

4. docker再基于刚提交的镜像运行一个新容器

5. 执行Dockerfile中的下一条指令，直到所有指令都执行完成

   

## **二、Dockerfile保留字**

### **1.FROM**

基础镜像，当前新镜像是基于哪个镜像的，指定一个已经存在的镜像作为模板。Dockerfile第一条必须是FROM。

```bash
# FROM 镜像名
FROM hub.c.163.com/library/tomcat
```

### **2.MAINTAINER**

镜像维护者的姓名和邮箱地址：

```bash
# 非必须
MAINTAINER ZhangSan zs@163.com
```

> 自从 Docker 1.13 版本开始，`MAINTAINER` 指令已被标记为过时，推荐使用 `LABEL` 指令来代替。
>
> 下面是使用 `LABEL` 指令来指定镜像维护者姓名和邮箱地址的示例：
>
> ```bash
> LABEL maintainer="ZhangSan <zs@163.com>"
> ```

### **3.RUN**

容器构建时需要运行的命令。有两种格式：

（1）shell格式：

```bash
# 等同于在终端操作的shell命令
# 格式：RUN <命令行命令>
RUN yum -y install vim
```

（2）exec格式：

```bash
# 格式：RUN ["可执行文件" , "参数1", "参数2"]
RUN ["./test.php", "dev", "offline"]  # 等价于 RUN ./test.php dev offline
```

> `RUN`是在`docker build`时运行。

### **4.EXPOSE**

当前容器对外暴露出的端口。

```bash
# EXPOSE 要暴露的端口
# EXPOSE <port>[/<protocol] ....
EXPOSE 3306 33060
```

### **5.WORKDIR**

指定在创建容器后， 终端默认登录进来的工作目录。

```bash
ENV CATALINA_HOME /usr/local/tomcat
WORKDIR $CATALINA_HOME
```

### **6.USER**

指定该镜像以什么样的用户去执行，如果不指定，默认是root。（一般不修改该配置）

```bash
# USER <user>[:<group>]
USER patrick
```

### **7.ENV**

用来在构建镜像过程中设置环境变量。这个环境变量可以在后续的任何RUN指令或其他指令中使用

```bash
# 格式 ENV 环境变量名 环境变量值
# 或者 ENV 环境变量名=值
ENV MY_PATH /usr/mytest

# 使用环境变量
WORKDIR $MY_PATH
```

### **8.VOLUME**

容器数据卷，用于数据保存和持久化工作。类似于`docker run`的-v参数。

```bash
# VOLUME 挂载点
# 挂载点可以是一个路径，也可以是数组（数组中的每一项必须用双引号）
VOLUME /var/lib/mysql
```

### **9.ADD**

将宿主机目录下（或远程文件）的文件拷贝进镜像，且会自动处理URL和解压tar压缩包。

### **10.COPY**

类似`ADD`，拷贝文件和目录到镜像中。

将从构建上下文目录中**<源路径>**的文件目录复制到新的一层镜像内的**<目标路径>**位置。

```bash
COPY src dest
COPY ["src", "dest"]
# <src源路径>：源文件或者源目录
# <dest目标路径>：容器内的指定路径，该路径不用事先建好。如果不存在会自动创建
```

### **11.CMD**

指定容器启动后要干的事情。

有两种格式：

-  shell格式 

```bash
# CMD <命令>
CMD echo "hello world"
```

-  exec格式 

```bash
# CMD ["可执行文件", "参数1", "参数2" ...]
CMD ["catalina.sh", "run"]
```

-  参数列表格式 

```bash
# CMD ["参数1", "参数2" ....]，与ENTRYPOINT指令配合使用
```

Dockerfile中如果出现多个`CMD`指令，只有最后一个生效。`CMD`会被`docker run`之后的参数替换。

例如，对于tomcat镜像，执行以下命令会有不同的效果：

```bash
# 因为tomcat的Dockerfile中指定了 CMD ["catalina.sh", "run"]
# 所以直接docker run 时，容器启动后会自动执行 catalina.sh run
docker run -it -p 8080:8080 tomcat

# 指定容器启动后执行 /bin/bash
# 此时指定的/bin/bash会覆盖掉Dockerfile中指定的 CMD ["catalina.sh", "run"]
docker run -it -p 8080:8080 tomcat /bin/bash
```

> `CMD`是在`docker run`时运行，而` RUN`是在`docker build`时运行。

### **12.ENTRYPOINT**

用来指定一个容器启动时要运行的命令。

类似于`CMD`命令，但是`ENTRYPOINT`不会被`docker run`后面的命令覆盖，这些命令参数会被当做参数送给`ENTRYPOINT`指令指定的程序。

`ENTRYPOINT`可以和`CMD`一起用，一般是可变参数才会使用`CMD`，这里的`CMD`等于是在给`ENTRYPOINT`传参。

当指定了`ENTRYPOINT`后，`CMD`的含义就发生了变化，不再是直接运行其命令，而是将`CMD`的内容作为参数传递给`ENTRYPOINT`指令，它们两个组合会变成`<ENTRYPOINT> "<CMD>"`。

例如：

```bash
FROM nginx

ENTRYPOINT ["nginx", "-c"]  # 定参
CMD ["/etc/nginx/nginx.conf"] # 变参
```

对于此Dockerfile，构建成镜像 **nginx:test**后，如果执行；

- docker run nginx:test，则容器启动后，会执行 nginx -c /etc/nginx/nginx.conf

- docker run nginx:test /app/nginx/new.conf，则容器启动后，会执行 nginx -c /app/nginx/new.conf



## **三、构建镜像**

创建名称为**Dockerfile**的文件，示例：

```bash
FROM ubuntu
LABEL maintainer="jerion <hzl@163.com>"

ENV MYPATH /usr/local
WORKDIR $MYPATH

RUN apt-get update
RUN apt-get install net-tools

EXPOSE 80

CMD echo $MYPATH
CMD echo "install ifconfig cmd into ubuntu success ....."
CMD /bin/bash
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/29/91a6b19e6fdb4f2cb68f3420f312af8a-image-20240429225252947-43dedc.png" alt="image-20240429225252947" style="zoom:50%;" />

编写完成之后，将其构建成docker镜像。

命令：

```bash
# 注意：定义的TAG后面有个空格，空格后面有个点
# docker build -t 新镜像名字:TAG .
docker build -t ubuntu:1.0.1 .
```

![image-20240429230911283](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/29/437037fc207b3b8f6ca4d22c140a3b53-image-20240429230911283-344f8b.png)

![image-20240429230939613](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/29/dca97ec406d6e4e30e8e27cb5799f2d3-image-20240429230939613-5a1403.png)

> 在构建Docker镜像时使用的`docker build`命令不需要`-it`参数。`-it`参数通常用于在运行容器时创建一个交互式会话，而不是在构建镜像时。
>
> 在构建Docker镜像时，只需使用`docker build`命令，类似于以下方式：
>
> ```bash
> docker build -t my_image .
> ```
>
> 在这个例子中，`-t`参数用于给镜像指定一个名称my_image，`.` 表示 Dockerfile 所在的当前目录。

> 镜像维护者的姓名和邮箱地址可通过运行`docker inspect`命令来查看镜像的元数据，里面包括了`LABEL`中定义的信息。



## **四、虚悬镜像**

虚悬镜像：仓库名、标签名都是空的镜像，称为dangling images（虚悬镜像）。

在构建或者删除镜像时可能由于一些错误导致出现虚悬镜像。

例如：

```bash
# 构建时候没有镜像名、tag
docker build .
```

列出docker中的虚悬镜像：

```bash
docker image ls -f dangling=true
```

虚悬镜像一般是因为一些错误而出现的，没有存在价值，可以删除：

```bash
# 删除所有的虚悬镜像
docker image prune
```

