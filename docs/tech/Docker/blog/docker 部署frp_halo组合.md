

#### 1. frp+nginx+halo+postgres

> 启动选项：halo:2.14、postgres:15.4、nginx、frps

```
version: "3"

services:
  halo:
    image: halohub/halo:2.14
    container_name: halo2
    restart: on-failure:3
    depends_on:
      - halodb
    volumes:
      - /data/Halo/halo2:/root/.halo2
    ports:
      - "8090:8090"
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8090/actuator/health/readiness || exit 1"]
      interval: 1m
      timeout: 10s
      retries: 3
      start_period: 1m
    command:
      - --spring.r2dbc.url=r2dbc:pool:postgresql://halodb/halo
      - --spring.r2dbc.username=halo
      - --spring.r2dbc.password=mjMJ@2024
      - --spring.sql.init.platform=postgresql
      - --halo.external-url=http://120.78.156.217:8090/

  halodb:
    image: postgres:15.4
    container_name: halodb2
    restart: on-failure:3
    volumes:
      - /data/Halo/db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U halo -d halo"]
      interval: 30s
      timeout: 10s
      retries: 5
    environment:
      - POSTGRES_PASSWORD=mjMJ@2024
      - POSTGRES_USER=halo
      - POSTGRES_DB=halo
      - PGUSER=halo

  frps:
    image: ryaning/frps
    container_name: frps2
    restart: always
    volumes:
      - /data/frp/frps.ini:/etc/frp/frps.ini
    ports:
      - "7000:7000"
      - "7001:7001"
      - "10080:10080"
      - "10443:10443"
      - "5000:5000"
      - "3000:3000"
      - "8222:8222"
      - "8223:8223"
      - "8224:8224"
      - "8225:8225"
      - "8226:8226"
      - "8227:8227"
      - "8228:8228"
      - "8229:8229"
      - "8230:8230"
      - "8231:8231"
      - "8232:8232"
      - "8233:8233"
      - "8234:8234"
      - "8235:8235"
      - "8236:8236"
      - "8237:8237"
      - "8238:8238"
      - "8239:8239"
      - "8240:8240"
      - "8241:8241"
      - "8242:8242"
      - "8243:8243"
      - "8244:8244"
      - "8096:8096"

  nginx:
    image: nginx
    container_name: nginx2
    ports:
      - "80:80"
    volumes:
      - /data/nginx/html:/usr/share/nginx/html:ro
      - /data/nginx/conf/nginx.conf:/etc/nginx/nginx.conf
      - /data/nginx/conf/conf.d:/etc/nginx/conf.d
      - /data/nginx/log:/var/log/nginx
    restart: always
```





#### 2.frp+nginx+halo+mysql





文件夹

```
mkdir -p /data/Halo
mkdir -p /data/Halo/mysql
mkdir -p /data/Halo/mysqlBackup
```



```
version: "3"

services:
  halo:
    image: halohub/halo:2.14
    container_name: halo2
    restart: on-failure:3
    depends_on:
      - halodb
    volumes:
      - /data/Halo:/root/.halo2
    ports:
      - "8090:8090"
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8090/actuator/health/readiness || exit 1"]
      interval: 1m
      timeout: 10s
      retries: 3
      start_period: 1m
    command:
      - --spring.r2dbc.url=r2dbc:pool:mysql://halodb:3306/halo
      - --spring.r2dbc.username=root
		# MySQL 的密码，请保证与下方 MYSQL_ROOT_PASSWORD 的变量值一致。
      - --spring.r2dbc.password=123456789
      - --spring.sql.init.platform=mysql
		# 外部访问地址，请根据实际需要修改
      - --halo.external-url=http://10.22.51.65:8090/
		# 初始化的超级管理员用户名
      - --halo.security.initializer.superadminusername=admin
		# 初始化的超级管理员密码
      - --halo.security.initializer.superadminpassword=123456789
  
  halodb:
    image: mysql:8.0.31
    container_name: halodb2
    restart: on-failure:3
    volumes:
      - /data/Halo/mysql:/var/lib/mysql
      - /data/Halo/mysqlBackup:/data/mysqlBackup
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "127.0.0.1", "--silent"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 30s
    environment:
      - MYSQL_ROOT_PASSWORD=123456789
      - MYSQL_DATABASE=halo


  frps:
    image: ryaning/frps
    container_name: frps2
    restart: always
    network_mode: host
    volumes:
      - /data/frp/frps.ini:/etc/frp/frps.ini

  nginx:
    image: nginx
    container_name: nginx2
    ports:
      - "80:80"
    volumes:
      - /data/nginx/html:/usr/share/nginx/html:ro
      - /data/nginx/conf/nginx.conf:/etc/nginx/nginx.conf
      - /data/nginx/conf/conf.d:/etc/nginx/conf.d
      - /data/nginx/log:/var/log/nginx
    restart: always

```

