docker部署dockerNas

```
docker search dockernas

docker pull xiongzhanzhang/dockernas

mkdir /data/new_dockernas
```



启动容器

```
docker run -d --name new_dockernas \
--restart always \
-p 8091:8080 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /data/new_dockernas:/home/dockernas/data \
xiongzhanzhang/dockernas
```

修改```/var/run/docker.sock```挂载的目录，登录nas系统后会报错，这边使用默认的了。



查看登录账户与密码：

```cat /data/new_dockernas/config.json```

```
{
    "basePath": "/home/dockernas/data",
    "bindAddr": "0.0.0.0:8080",
    "passwd": "df5d4ae10df04233ba9dde69a83c2017",
    "user": "admin"

```



访问地址：http://10.22.51.65:8091/login

账号：admin

密码：df5d4ae10df04233ba9dde69a83c2017