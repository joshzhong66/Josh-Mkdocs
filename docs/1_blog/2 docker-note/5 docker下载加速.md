# docker下载加速



> 查看docker镜像源：
>
> ```bash
> cat /etc/docker/daemon.json
> ```

## **一、登录阿里云，搜索：容器镜像服务**

![image-20240425204956987](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/4e91a932edc53cd13169db990754337a-image-20240425204956987-0e87b7.png)



## **二、安装／升级Docker客户端**

​		推荐安装1.10.0以上版本的Docker客户端，参考文档[docker-ce](https://yq.aliyun.com/articles/110806)。



## **三、配置镜像加速器**

​		针对Docker客户端版本大于 1.10.0 的用户

​		您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器

```bash
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{    
"registry-mirrors": ["https://ip6hzdyo.mirror.aliyuncs.com"]
}

EOF

重载docker
systemctl daemon-reload
systemctl restart docker
```

![image-20240425205125415](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/3d428187eb69aae8445b13df0c9bf298-image-20240425205125415-c508bd.png)

除了使用阿里云的镜像仓库，还可以使用以下这些仓库：

```bash
"registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "http://f1361db2.m.daocloud.io",
    "https://hub.uuuadc.top",
    "https://docker.anyhub.us.kg",
    "https://dockerhub.jobcher.com",
    "https://dockerhub.icu",
    "https://docker.ckyl.me",
    "https://docker.awsl9527.cn"
]
```

