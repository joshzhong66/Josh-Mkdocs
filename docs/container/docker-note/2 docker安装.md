# **docker安装**



## **一、安装前准备**

```bash
uname -r    #查看下内核版本，建议3.10以上

升级内核及升级系统包：
yum -y update：升级所有包同时也升级软件和系统内核；
yum -y upgrade：只升级所有包，不升级软件和系统内核
```



## **二、卸载docker旧版本**

```bash
docker version  # 查看当前Docker版本
yum erase docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine \
    docker-ce
```

​		yum可能会报告您没有安装这些软件包。/var/lib/docker/卸载 Docker 时，不会自动删除存储的映像、容器、卷和网络。

​		删除相关配置文件：

```bash
find /etc/systemd -name '*docker*' -exec rm -f {} \;
find /lib/systemd -name '*docker*' -exec rm -f {} \;
```



## **三、安装docker**

### **1.安装依赖gcc gcc-c++**

```bash
yum -y install gcc gcc-c++
```

### **2.设置存储库**

​		在新主机上首次安装 Docker Engine 之前，需要设置 Docker 存储库。之后，您可以从存储库安装和更新 Docker。

​		安装yum-utils软件包（提供yum-config-manager 实用程序）并设置存储库。

```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

​		yum-util 提供yum-config-manager功能，另两个是devicemapper驱动依赖。

​		设置docker镜像源为阿里云的yum源作为docker仓库，在/etc/yum.repos.d/中可以发现生成了docker-ce.repo镜像源。

![image-20240512140244804](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/12/2d3271205a7a4335ac085a2ca86d10ba-image-20240512140244804-b05917.png)

### **3.更新yum软件包索引**

```bash
yum makecache fast        #创建缓存（非必选项）
```

注：CentOS8以上没有fast这个命令，去掉就可以了。

### **4.查看docker可用版本**

```bash
yum list docker-ce --showduplicates | sort -r
```

### **5.安装docker**

​		选择一个版本安装：**yum install docker-ce-版本号**

```bash
yum -y install docker-ce-18.03.1.ce
```

​		安装docker最新版：**yum install -y docker-ce docker-ce-cli containerd.io**

### **6.启动docker，并设置开机自启动**

```bash
systemctl start docker
systemctl enable docker

systemctl stop docker  #停止
```

### **7.测试docker**

```bash
 docker run hello-world
```

