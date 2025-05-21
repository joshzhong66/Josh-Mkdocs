

# Registry搭建docker私仓



​		Docker Registry是官方提供的工具，用于构建私有镜像仓库。

## **一、环境搭建**

​		Docker Registry也是Docker Hub提供的一个镜像，可以直接拉取运行。

### **1.拉取镜像**

```bash
docker pull registry
```

### **2.启动Docker Registry**

注：-d命令表示后台运行。

```bash
docker run -d -p 5000:5000 -v /app/myregistry/:/tmp/registry --privileged=true registry
```

![image-20240425230559694](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/c08782e2650f1ce58a09dbf171b4e4b4-image-20240425230559694-3d44c8.png)

### **3.验证（查看私服中的所有镜像），Registry会返回json格式的所有镜像目录** 

```bash
curl http://10.22.51.63:5000/v2/_catalog        #IP和端口为docker主机IP
```



## **二、向Registry私仓中上传镜像**

### **1.从Hub上下载ubuntu镜像到本地并成功运行**

```bash
docker pull ubuntu
docker run -d -it ubuntu
docker exec -it docker容器id /bin/bash    # 这里docker容器id为ff61b666e6a4
```

### **2.原始的ubuntu镜像是不带着ifconfig命令的,外网连通的情况下，安装ifconfig命令并测试通过**

```bash
apt-get update
apt-get install -y net-tools
```

### **3.安装完成后，commit我们自己的新镜像**

````bash
docker commit -m="ifconfig cmd add" -a="jerion" ff61b666e6a4 jerionubuntu:1.2
````

### **4.启动我们的新镜像并和原来的对比**

```bash
docker stop ff61b666e6a4    #停掉原来的ubuntu容器id
docker images
docker run -it docker镜像id /bin/bash    #启动个新的测试ifconfig(这里docker镜像id为92c1dbc89906)
```

### **5.将新镜像修改符合docker镜像规范**

> 按照公式：docker tag 镜像：Tag Host:Port/Repository:Tag
>
> 自己host主机IP地址，填写同学你们自己的，不要粘贴错误，
>
> 使用命令 docker tag 将jerionubuntu:1.2 这个镜像修改为10.22.51.63:5000/jerionubuntu:1.2

```bash
docker tag jerionubuntu:1.2 10.22.51.63:5000/jerionubuntu:1.2
docker images    #检验
```

### **6.配置docker允许接收http请求**

> 修改/etc/docker/daemon.json，添加insecure-registries允许http：
>

```bash
{ 
	"registry-mirros": ["https://xxxx.mirror.aliyuncs.com"], 
	"insecure-registries": ["10.22.xxx.xxx:5000"] 
}
```

​		然后重启docker：（新版本的docker会立即生效）

```bash
# centos6 的命令
chkconfig daemon-reload
service docker restart

# centos7/8 的命令
systemctl daemon-reload
systemctl restart docker

重启容器
docker run -d -p 5000:5000 -v /app/myregistry/:/tmp/registry --privileged=true registry
```

注：重启容器后，容器ID会变化，这里容器id变为4e9aea0a4ee3。



## **三、推送到私仓**

### **1.添加一个对应私仓地址的tag**

![image-20240425231730969](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/df5e9cf9fb0031a4fc8d0615efac7008-image-20240425231730969-b97803.png)

### **2.推送到私服库**

```bash
docker push 10.22.51.63:5000/jerionubuntu:1.2
```

![image-20240425232550471](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/46829027a4d5a1f3b1b79a18ba99304c-image-20240425232550471-92d49d.png)

### **3.再次验证私服库**

```bash
curl http://10.22.51.63:5000/v2/_catalog
```

![image-20240425232622868](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/249e688c09adba2c35b4e53b731c6487-image-20240425232622868-a203b9.png)



### **四、pull到本地并运行**

### **1.复制一份到主机**

​		将10.22.51.63:5000/jerionubuntu复制一份到主机（可忽略次步骤）

```bash
docker run -it 92c1dbc89906 /bin/bash	#运行一个10.22.51.63:5000/joshubuntu虚拟机（不加-d退出即停止运行）
docker export 202062990a66 >bak.tar	#将虚拟机打包到Linux
docker rmi -f 92c1dbc89906		#删掉原有的images镜像包
```

### **2.pull到本地**

```bash
curl -XGET http://10.22.51.63:5000/v2/_catalog
docker pull 10.22.51.63:5000/jerionubuntu:1.2
```

![image-20240425235836544](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/b4cb936666687ad6e9e9f728655b4e60-image-20240425235836544-60fe94.png)
