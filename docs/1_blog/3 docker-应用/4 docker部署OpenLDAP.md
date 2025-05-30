# docker部署OpenLDAP



部署openLDAP[参考](https://www.liuwg.com/archives/docker-openldap)

## 一、LDAP概念

​		LDAP是轻量级目录访问协议（Lightweight Directory Access Protocol）的缩写。它是一种用于在网络上访问和维护分布式目录信息服务的协议。LDAP通常用于集中式身份验证、授权和配置信息。

​		关于LDAP的一些关键点：

1. **目录服务**：LDAP通常与目录服务一起使用，用于以分层结构存储有关用户、组、设备和其他资源的信息。
2. **身份验证**：LDAP可用于身份验证目的，允许用户使用存储在LDAP目录中的一组凭据登录到各种系统和服务。
3. **授权**：LDAP还可以用于存储有关权限和访问控制的信息，允许管理员管理谁有权访问哪些资源。
4. **轻量级**：LDAP被认为是一种轻量级协议，适用于快速访问和管理目录信息。



## 二、安装docker

```bash
yum install -y yum-utils device-mapper-persistent-data lvm2   //安装docker依赖包
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo    //配置国内阿里云镜像仓库，解决镜像下载慢的问题。
yum install docker-ce docker-ce-cli containerd.io   //安装docker-ce服务

systemctl start docker          //启动docker命令
systemctl enable docker        //添加到开机启动项
```



## 三、拉取openldap与phpldapadmin镜像到本地

```bash
docker pull osixia/openldap

docker pull osixia/phpldapadmin
```



## 四、运行镜像

### 1.通过docker run命令运行openldap

```bash
docker run \
-p 389:389 \
-p 636:636 \
--name myldap_name \
--network bridge \
--hostname openldap-host \
--env LDAP_ORGANISATION="sunline" \
--env LDAP_DOMAIN="sunline.cn" \
--env LDAP_ADMIN_PASSWORD="123456" \
--detach osixia/openldap
```

> 注释如下:
>
> -p 389:389    TCP/IP访问端口
>
> -p 636:636    SSL连接端口
>
> –name myldap_name    容器名称为myldap_name
>
> –network bridge    连接默认的bridge网络
>
> –hostname openldap-host    设置容器主机名称为 openldap-host
>
> –env LDAP_ORGANISATION=“sunline”    配置LDAP组织名称
>
> –env LDAP_DOMAIN=“[sunline.cn](http://example.com/)”    配置LDAP域名
>
> –env LDAP_ADMIN_PASSWORD=“123456”    配置LDAP密码
>
> **默认登录用户名：admin**

执行结果：

![image-20240510105128295](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/cb113c6cfd4e21c4d36da837d56f3fda-image-20240510105128295-ec1b85.png)

### 2.通过docker run命令运行osixia/phpldapadmin

```bash
docker run \
-d \
--privileged \
-p 8082:80 \
--name myldapadmin \
--env PHPLDAPADMIN_HTTPS=false \
--env PHPLDAPADMIN_LDAP_HOSTS=10.22.51.63 \
--detach osixia/phpldapadmin
```

> 注释如下:
>
> -d    分离模式启动容器
>
> –privileged    特权模式启动（使用该参数，container内的root拥有真正的root权限。否则，container内的root只是外部的一个普通用户权限）
>
> –env PHPLDAPADMIN_HTTPS=false    禁用HTTPS
>
> –env PHPLDAPADMIN_LDAP_HOSTS =10.22.51.63    配置openLDAP的IP或者域名，我安装ldap机器IP就是10.22.51.63

执行结果：

![image-20240510105136108](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/49790a411aadd2bbf3b0917892609db8-image-20240510105136108-d21be9.png)



## 五、登录

通过访问phpldapadmin管理地址http://10.22.51.63:8082/进行登录与管理，登陆界面如下：

![image-20240510105149887](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/d42c90a5b66ac9b84c22e32e2120cd7a-image-20240510105149887-bb74d7.png)

点击login进行登录,如果登录失败，需要检查selinux和firewalld是否启用，

```bash
[root@localhost ~]# getenforce    #查看selinx状态
Enforcing

[root@localhost ~]# setenforce 0    #临时关闭

[root@localhost ~]# getenforce      #状态宽松即可
Permissive
```

```bash
Login DN：cn=admin,dc=sunline,dc=cn
Password：123456
```

![image-20240510105212864](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/70844cce6573f19b2e1ccda8e7fa9b0f-image-20240510105212864-89e9a4.png)
