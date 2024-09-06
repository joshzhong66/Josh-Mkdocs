# docker部署zabbix6

创建zabbix网络
```
docker network create -d bridge zbx_net
```

创建存放目录
```
mkdir -p /data/zabbix/db
```

下载docker镜像

```
docker pull zabbix/zabbix-web-nginx-mysql

docker pull zabbix/zabbix-server-mysql

docker pull zabbix/zabbix-agent

docker pull mysql:8.0.32

```





部署mysql
vm虚拟机mysql root的密码为123qwe
```
docker run -itd -p 3306:3306 \
--name zabbix-mysql \
--network zbx_net \
--restart always \
-v /etc/localtime:/etc/localtime \
-v /data/zabbix/db:/var/lib/mysql \
-e MYSQL_USER=zabbix \
-e MYSQL_PASSWORD="zabbix" \
-e MYSQL_ROOT_PASSWORD="sunline" \
mysql:8.0.32 \
--default-authentication-plugin=mysql_native_password \
--character-set-server=utf8 \
--collation-server=utf8_bin

```



### 

为zabbix-server创建一个持久卷

```bash
docker volume create zbx_vo1
```



创建zabbix server

```
docker run -itd -p 10051:10051 \
--mount source=zbx_vo1,target=/etc/zabbix \
-v /etc/localtime:/etc/localtime \
-v /usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
--name=zabbix-server-mysql --restart=always \
--network zbx_net \
-e DB_SERVER_HOST="zabbix-mysql" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="zabbix" \
-e MYSQL_ROOT_PASSWORD="sunline" \
-e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
-e ZBX_JAVAGATEWAY_ENABLE="true" \
-e ZBX_JAVAGATEWAYPORT=10052 \
zabbix/zabbix-server-mysql

```



创建语言存放目录

```
mkdir -p /data/zabbix/db/fonts
cd /data/zabbix/db/fonts/
wget https://dl.cactifans.com/zabbix_docker/msty.ttf
 
 
[root@monitor-vm fonts]# ls
msty.ttf
[root@monitor-vm fonts]# mv msty.ttf DejaVuSans.ttf
[root@monitor-vm fonts]# ls
DejaVuSans.ttf
```



启动zabbix-web容器

```
docker run -itd -p 8090:8080 \
-v /etc/localtime:/etc/localtime \
-v /data/zabbix/fonts/DejaVuSans.ttf:/usr/share/zabbix/assets/DejaVuSans.ttf \
--name zabbix-web-nginx-mysql --restart=always \
--network zbx_net \
-e DB_SERVER_HOST="zabbix-mysql" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="zabbix" \
-e MYSQL_ROOT_PASSWORD="sunline" \
-e ZBX_SERVER_HOST="zabbix-server-mysql" \
zabbix/zabbix-web-nginx-mysql
```





登录地址：http://192.168.42.128:8090/zabbix.php?action=dashboard.view

账户：admin

密码：zabbix

