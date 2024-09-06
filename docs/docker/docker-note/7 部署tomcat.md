# 部署Tomcat



## **一、安装tomcat**

```bash
docker pull tomcat
```



## **二、随机端口启动tomcat**

```bash
docker run -it -P --name t1 tomcat    #-P表示随机分配映射端口
```

![image-20240429143639144](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/70874c99ed0c93ec021ff9f43b75d2e5-70874c99ed0c93ec021ff9f43b75d2e5-image-20240429143639144-b44d31-892822.png)

![image-20240510104729020](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/c5b3d6b1c22cecffeba52d9a489f3b86-image-20240510104729020-482943.png)



## **三、指定端口启动tomcat**

指定linux主机端口8080，容器端口8080，命名t1：

```bash
docker run -d -p 8080:8080 --name t1 tomcat
```



## **四、访问返回404**

​		打开服务器地址：http://10.22.51.63:32769/，返回404，第5步给出答案。

![image-20240429145715628](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/178d228a7d4786ab338842c5c47e64eb-178d228a7d4786ab338842c5c47e64eb-image-20240429145715628-947b7d-c47911.png)



## **五、进入tomcat文件夹**

```python
docker exec -it 8a819cc62efa /bin/bash
rm -rf webapps    #强制删除目录及其所有子目录
mv webapps.dist webapps    #将目录名更改为webapps
```

![image-20240429152141070](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/68c385544ae6273b6d4f86ac872519f3-68c385544ae6273b6d4f86ac872519f3-image-20240429152141070-4e5518-e811ab.png)



## 六、安装tomcat 8

tomcat8下载安装命令（没有的包run后会自动安装）：

```
docker run -d -p 8080:8080 --name mytomcat8 billygoo/tomcat8-jdk8
```

![image-20240510105334789](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/ccc97d88664a0f7a6714a8bc45d2ad2d-image-20240510105334789-a9774f.png)

tomcat8无需删除webapps：

![image-20240510104755482](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/22237b45efa0ed817f92e7e0e212b8c5-image-20240510104755482-01e221.png)

