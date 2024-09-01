# docker部署django

## （1）django安装目录结构

```python
[root@zhongjl-test-02 /]# tree /data/compose 
/data/compose
├── deploy.sh
├── myproject					#django启动目录
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── media
│   ├── myproject				#django项目目录
│   │   ├── manage.py			#启动脚本
│   │   └── myproject
│   │       ├── asgi.py
│   │       ├── __init__.py
│   │       ├── settings.py
│   │       ├── urls.py
│   │       └── wsgi.py
│   ├── pip.conf
│   ├── requirements.txt		#安装依赖
│   ├── start.sh
│   ├── static
│   └── uwsgi.ini
├── mysql						#数据库
│   ├── conf
│   │   └── my.cnf
│   └── init
│       └── init.sql
├── nginx
│   ├── Dockerfile
│   ├── log
│   │   ├── access.log
│   │   └── error.log
│   ├── nginx.conf
│   └── ssl
├── recruitment
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── media
│   ├── pip.conf
│   ├── requirements.txt
│   ├── start.sh
│   ├── static
│   └── uwsgi.ini
├── redis
│   └── redis.conf
└── uwsgi
```



## （2）Dockerfile与各项配置

#### （1）编写docker-compose.yml

修改过的docker-compose.yml的内容:

```
mkdir -p /data/compose/myproject
vim /data/compose/myproject/docker-compose.yml
```

内容如下：

```python

version: "3"

volumes: # 自定义数据卷
  db_vol: #定义数据卷同步存放容器内mysql数据
  redis_vol: #定义数据卷同步存放redis数据
  media_vol: #定义数据卷同步存放web项目用户上传到media文件夹的数据
  static_vol: #定义数据卷同步存放web项目static文件夹的数据

networks: # 自定义网络(默认桥接), 不使用links通信
  nginx_network:
    driver: bridge
  db_network:
    driver: bridge
  redis_network: 
    driver: bridge

services:
  redis:
    image: redis:latest
    command: redis-server /etc/redis/redis.conf # 容器启动后启动redis服务器
    networks:
      - redis_network
    volumes:
      - redis_vol:/data # 通过挂载给redis数据备份
      - /data/compose/redis/redis.conf:/etc/redis/redis.conf # 挂载redis配置文件
    ports:
      - "6379:6379"
    restart: always # always表容器运行发生错误时一直重启

  db:
    image: mysql
    env_file:  
      - /data/compose/myproject/.env # 使用了环境变量文件
    networks:  
      - db_network
    volumes:
      - db_vol:/var/lib/mysql:rw # 挂载数据库数据, 可读可写
      - /data/compose/mysql/conf/my.cnf:/etc/mysql/my.cnf # 挂载配置文件
      - /data/compose/mysql/init:/docker-entrypoint-initdb.d/ # 挂载数据初始化sql脚本
    ports:
      - "3306:3306" # 与配置文件保持一致
    restart: always

  web:
    build: /data/compose/myproject
    ports:
      - "8000:8000"
    volumes:
      - /data/compose/myproject:/var/www/html/myproject # 挂载项目代码
      - static_vol:/var/www/html/myproject/static # 以数据卷挂载容器内static文件
      - media_vol:/var/www/html/myproject/media # 以数据卷挂载容器内用户上传媒体文件
      - /data/compose/uwsgi:/tmp # 挂载uwsgi日志
    networks:
      - nginx_network
      - db_network  
      - redis_network 
    depends_on:
      - db
      - redis
    restart: always
    tty: true
    stdin_open: true

  nginx:
    build: /data/compose/nginx
    ports:
      - "80:80"
      - "443:443"
    expose:
      - "80"
    volumes:
      - /data/compose/nginx/nginx.conf:/etc/nginx/conf.d/nginx.conf # 挂载nginx配置文件
      - /data/compose/nginx/ssl:/usr/share/nginx/ssl # 挂载ssl证书目录
      - /data/compose/nginx/log:/var/log/nginx # 挂载日志
      - static_vol:/usr/share/nginx/html/static # 挂载静态文件
      - media_vol:/usr/share/nginx/html/media # 挂载用户上传媒体文件
    networks:
      - nginx_network
    depends_on:
      - web
    restart: always

```

1、定义了4个数据卷，用于挂载各个容器内动态生成的数据，比如MySQL的存储数据，redis生成的快照、django+uwsgi容器中收集的静态文件以及用户上传的媒体资源。这样即使删除容器，容器内产生的数据也不会丢失。

2、定义了3个网络，分别为`nginx_network`(用于nginx和web容器间的通信)，`db_network`(用于db和web容器间的通信)和`redis_network`(用于redis和web容器间的通信)。



创建文件之后，确保你的`docker-compose.yml`文件路径与服务中定义的构建路径和卷挂载路径相匹配。如果你的`web`服务中有`build: /data/compose/myproject`，那么你的Django项目应该位于`/data/compose/myproject`路径下。



#### （2）编写Django+Uwsgi的Dockerfile：

- 在`/data/compose/myproject`目录下创建一个名为`Dockerfile`的文件。
- 复制你之前提供的Django+Uwsgi Dockerfile内容到这个文件中。

```
vim /data/compose/myproject/Dockerfile
```



构建Web镜像(Django+Uwsgi)的所使用的Dockerfile如下所示:

```
# 基于CentOS 7的Python 3.9环境
FROM centos:7

# 安装必要的软件和开发工具
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install python3 python3-pip nc mysql-devel gcc-c++ python3-devel libjpeg-devel zlib-devel libffi-devel openssl-devel && \
    yum -y groupinstall "Development Tools" && \
    yum clean all

# 设置 python 环境变量
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 可选：设置镜像源为国内
COPY pip.conf /root/.pip/pip.conf

# 容器内创建 myproject 文件夹
ENV APP_HOME=/var/www/html/myproject
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# 将当前目录加入到工作目录中
ADD . $APP_HOME

# 更新pip版本
RUN python3 -m pip install --upgrade pip

# 安装项目依赖
RUN pip install -r requirements.txt

# 复制 start.sh 到 /data/compose 并确保文件权限和格式
COPY start.sh /data/compose/start.sh
RUN chmod +x /data/compose/start.sh && sed -i 's/\r$//' /data/compose/start.sh

# 复制 uwsgi.ini 配置文件
COPY uwsgi.ini $APP_HOME/uwsgi.ini

# 设置工作目录并启动服务
WORKDIR /data/compose
ENTRYPOINT ["/bin/bash", "/data/compose/start.sh"]

```





#### （3）编写`start.sh`启动脚本文件

使用uwsgi.ini配置文件启动Django服务。

```
vim /data/compose/myproject/start.sh
```

内容如下所示：

```
#!/bin/bash
# 定义 MySQL 主机和端口
MYSQL_HOST=db
MYSQL_PORT=3306

# 等待 MySQL 服务启动
while ! nc -z $MYSQL_HOST $MYSQL_PORT; do
    echo "Waiting for the MySQL Server"
    sleep 3
done

# 如果需要初始化Django应用或执行数据迁移，这里可以执行相关命令
# 示例：python manage.py migrate --noinput
# 示例：python manage.py collectstatic --noinput
python manage.py migrate --noinput
python manage.py collectstatic --noinput


# 启动 UWSGI 服务
uwsgi --ini /var/www/html/myproject/uwsgi.ini

# 保持容器运行
tail -f /dev/null

exec "$@"

```

赋权

```
chmod +x /data/compose/myproject/start.sh
```



#### （4）配置 `uwsgi.ini` 配置文件

**创建 `uwsgi.ini`**：

- 在 `/data/compose/myproject` 目录中创建一个名为 `uwsgi.ini` 的文件。
- 编辑该文件，填入以下内容：```vim /data/compose/myproject/uwsgi.ini```

```python
[uwsgi]

project=myproject
uid=www-data
gid=www-data
base=/var/www/html

chdir=%(base)/%(project)
module=%(project).wsgi:application
master=True
processes=2

socket=0.0.0.0:8000
chown-socket=%(uid):www-data
chmod-socket=664

vacuum=True
max-requests=5000

pidfile=/tmp/%(project)-master.pid
daemonize=/tmp/%(project)-uwsgi.log

#设置一个请求的超时时间(秒)，如果一个请求超过了这个时间，则请求被丢弃
harakiri = 60
post buffering = 8192
buffer-size= 65535
#当一个请求被harakiri杀掉会，会输出一条日志
harakiri-verbose = true

#开启内存使用情况报告
memory-report = true

#设置平滑的重启（直到处理完接收到的请求）的长等待时间(秒)
reload-mercy = 10

#设置工作进程使用虚拟内存超过N MB就回收重启
reload-on-as= 1024
```



#### （5）编辑.env文件

创建.env文件：

```
vim /data/compose/myproject/.env
```

`.env`文件内容如下所示：

```
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=dbuser
MYSQL_DATABASE=myproject
MYSQL_PASSWORD=password
```

**确保在`docker-compose.yml`中使用env的这些环境变量**



通常在服务的定义中通过`env_file`或直接使用`environment`属性来实现。例如，对于MySQL服务，你可以这样配置：

```python
yamlCopy codedb:
  image: mysql
  env_file:
    - /data/compose/project/.env
  volumes:
    - db_vol:/var/lib/mysql
    - /data/compose/mysql/conf/my.cnf:/etc/mysql/my.cnf
    - /data/compose/mysql/init:/docker-entrypoint-initdb.d/
  ports:
    - "3306:3306"
```



#### （6）Django项目所依赖requirements.txt

Django项目所依赖的`requirements.txt` 文件位于你的项目目录中，并且与 Dockerfile 处在同一目录下。

执行命令```vim /data/compose/myproject/requirements.txt```

```python
# django
django==3.2
# uwsgi
uwsgi==2.0.18
# mysql
mysqlclient==1.4.6
# redis
django-redis==4.12.1
redis==3.5.3
# for images
Pillow==8.2.0 
```







#### （7）编写Nginx镜像和容器所需文件

需要为Nginx创建一个Dockerfile。这个文件定义了如何构建Nginx的Docker镜像。

```
mkdir -p /data/compose/nginx
```



#### 1.**创建或编辑Dockerfile**：

创建或编辑`/data/compose/nginx/Dockerfile`，

```
vim /data/compose/nginx/Dockerfile
```



复制并粘贴以下内容：

```
# nginx镜像compose/nginx/Dockerfile

FROM nginx:latest

# 删除原有配置文件，创建静态资源文件夹和ssl证书保存文件夹
RUN rm /etc/nginx/conf.d/default.conf \
&& mkdir -p /usr/share/nginx/html/static \
&& mkdir -p /usr/share/nginx/html/media \
&& mkdir -p /usr/share/nginx/ssl

# 设置Media文件夹用户和用户组为Linux默认www-data, 并给予可读和可执行权限,
# 否则用户上传的图片无法正确显示。
RUN chown -R www-data:www-data /usr/share/nginx/html/media \
&& chmod -R 775 /usr/share/nginx/html/media

# 添加配置文件
ADD ./nginx.conf /etc/nginx/conf.d/

# 关闭守护模式
CMD ["nginx", "-g", "daemon off;"]

```





#### 2. 创建Nginx配置文件（nginx.conf）

1. 创建或编辑nginx.conf配置文件，确保正确地代理到你的Django应用。

```
vim /data/compose/nginx/nginx.conf
```

- 在`/data/compose/nginx`目录下创建或编辑`nginx.conf`文件。
- 复制并粘贴以下内容：

```python
# nginx配置文件
# compose/nginx/nginx.conf

upstream django {
    ip_hash;
    server web:8000; # Docker-compose web服务端口
}

# 配置http请求，80端口
server {
    listen 80; # 监听80端口
    server_name 127.0.0.1; # 可以是nginx容器所在ip地址或127.0.0.1，不能写宿主机外网ip地址

    charset utf-8;
    client_max_body_size 10M; # 限制用户上传文件大小

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    location /static {
        alias /usr/share/nginx/html/static; # 静态资源路径
    }

    location /media {
        alias /usr/share/nginx/html/media; # 媒体资源，用户上传文件路径
    }

    location / {
        include /etc/nginx/uwsgi_params;
        uwsgi_pass django;
        uwsgi_read_timeout 600;
        uwsgi_connect_timeout 600;
        uwsgi_send_timeout 600;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
        proxy_set_header X-Real-IP  $remote_addr;
    }
}

```



#### （8）编写Db (MySQL)容器配置文件

1. **创建配置文件目录**：

   ```
   mkdir -p /data/compose/mysql/conf
   ```

2. **创建或编辑MySQL的配置文件 (`my.cnf`)**：

   在`/data/compose/mysql/conf`目录下创建或编辑名为`my.cnf`的文件。
   
   ```
   vim /data/compose/mysql/conf/my.cnf
   ```
   
   - 复制并粘贴以下配置内容：

```

#/data/compose/mysql/conf/my.cnf
[mysqld]
user=mysql
default-storage-engine=INNODB
character-set-server=utf8
secure-file-priv=NULL # mysql 8 新增这行配置
default-authentication-plugin=mysql_native_password  # mysql 8 新增这行配置

port            = 3306 # 端口与docker-compose里映射端口保持一致
#bind-address= localhost #一定要注释掉，mysql所在容器和django所在容器不同IP

basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
skip-name-resolve  # 这个参数是禁止域名解析的，远程访问推荐开启skip_name_resolve。

[client]
port = 3306
default-character-set=utf8

[mysql]
no-auto-rehash
default-character-set=utf8

```



2. 准备MySQL初始化脚本

初始化脚本在MySQL第一次启动时运行，用于设置数据库的初始状态，包括用户权限等。

1. **创建初始化脚本目录**：

   ```mkdir -p /data/compose/mysql/init```

   

1. **创建或编辑初始化脚本 (`init.sql`)**：

   - 在`/data/compose/mysql/init`目录下创建或编辑名为`init.sql`的文件。

     ```vim 
     vim /data/compose/mysql/init/init.sql
     ```
   
   - 我们还需设置MySQL服务启动时需要执行的脚本命令, 注意这里的用户名和password必需和myproject目录下`.env`文件中的环境变量保持一致。复制并粘贴以下内容，保存文件：

   ```
   # compose/mysql/init/init.sql
   ALTER USER 'dbuser'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
   GRANT ALL PRIVILEGES ON myproject.* TO 'dbuser'@'%';
   FLUSH PRIVILEGES;
   ```
   

确保已经正确创建和配置了MySQL的`my.cnf`和`init.sql`文件。这些设置将确保你的MySQL数据库按预期运行，并具有适当的安全配置。







#### （9）编写Redis 容器配置文件

为了确保Redis服务正常运行并满足Django项目的需要，我们将配置Redis的配置文件，并确保它能够与Django顺利集成。

#### 1. 创建Redis配置文件

Redis配置文件允许你自定义各种设置，例如持久化选项、密码保护等。

1. **创建配置文件目录**（如果尚未创建）：

   ```
   mkdir -p /data/compose/redis
   ```

2. **创建或编辑Redis的配置文件**：

   - 在`/data/compose/redis`目录下创建或编辑名为`redis.conf`的文件。
   
     ``````
     vim /data/compose/redis/redis.conf
     ``````
   
   - 复制并粘贴以下内容（包括设置密码，这很重要，因为它将与Django设置中的密码相匹配）：
   
   ```
   # Redis配置文件
   # compose/redis/redis.conf
   
   # 请注释掉下面一行，变成#bind 127.0.0.1,这样其它机器或容器也可访问
   bind 127.0.0.1
   
   # 取消下行注释，给redis设置登录密码。这个密码django settings.py会用到。
   requirepass yourpassword
   ```
   
   - 在`yourpassword`处替换为你实际想使用的密码，确保它与Django配置中的密码相匹配。
   - 保存文件。

#### 2. 确保Docker-compose使用Redis配置文件

在`docker-compose.yml`中配置Redis服务，确保它使用了刚才编辑的配置文件：

```
redis:
  image: redis:latest
  command: redis-server /usr/local/etc/redis/redis.conf
  volumes:
    - redis_vol:/data
    - /data/compose/redis/redis.conf:/usr/local/etc/redis/redis.conf
  ports:
    - "6379:6379"
```

这将确保Redis在启动时加载你指定的配置文件。



#### （10）配置Pip

1. **选择位置**：为了方便管理，应该将 `pip.conf` 放置在包含Dockerfile的同一目录下。
2. **创建文件**：在 `/data/compose/myproject` 目录（即你的Dockerfile所在的目录）中创建 `pip.conf` 文件。

创建```pip.conf```文件

```
vim /data/compose/myproject/pip.conf
```

**填充文件内容**：在编辑器中，输入以下内容，这里以阿里云的Python镜像源为例，当然你也可以选择其他如清华大学等镜像源：

```
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host = mirrors.aliyun.com

```



**完成这些步骤后，所有的配置就配置好了。**

## （3）构建镜像

#进入到包含 docker-compose.yml的目录

```
cd /data/compose/myproject		 
```

#构建镜像

```
docker-compose build
```

如果构建没有出错，可以查看已生成的镜像



#查看已生成的镜像

```
docker images
```

```
REPOSITORY                     TAG       IMAGE ID       CREATED         SIZE
myproject_nginx                latest    4754c26b94db   2 hours ago     188MB
myproject_web                  latest    2d7f60435555   2 hours ago     757MB
redis                          latest    7fc37b47acde   2 weeks ago     116MB
mysql                          latest    6f343283ab56   4 weeks ago     632MB
```



## （4）启动django容器



进入docker-compose.yml所在文件夹，输入以下命令：

```
#启动容器组服务
docker-compose up

docker-compose down         # 停止并移除当前容器
docker-compose up -d        # 以分离模式重新启动容器
docker-compose logs  		# 查看所有服务的日志
docker-compose logs web  	# 只查看 web 服务的日志
```



启动进程如下：

```
[root@zhongjl-test-02 /data/compose/myproject]# docker ps
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS                PORTS                                                                      NAMES
2c8dffdea778   myproject_nginx     "/docker-entrypoint.…"   37 minutes ago   Up 37 minutes         0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp   myproject_nginx_1
f8fa4584492a   myproject_web       "/bin/bash /data/com…"   37 minutes ago   Up 37 minutes         0.0.0.0:8000->8000/tcp, :::8000->8000/tcp                                  myproject_web_1
9ed8a88e19cf   redis:latest        "docker-entrypoint.s…"   37 minutes ago   Up 37 minutes         0.0.0.0:6379->6379/tcp, :::6379->6379/tcp                                  myproject_redis_1
1c1c7224efee   mysql               "docker-entrypoint.s…"   37 minutes ago   Up 37 minutes         0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp                       myproject_db_1
```







## （5）创建Django项目

django项目（myproject）的目录结构

```
[root@zhongjl-test-02 /data/compose/myproject]# tree myproject/
myproject/
├── manage.py
└── myproject
    ├── asgi.py
    ├── __init__.py
    ├── settings.py
    ├── urls.py
    └── wsgi.py

1 directory, 6 files
```



#### 1.连接容器web

```python
docker exec -it f8fa4584492a bash
```



#### 2.查看django版本

```
python3 -m django --version
```



#### 3.创建django项目，项目名称

```
django-admin startproject myproject
```

创建后，项目文件夹内，会有django的文件

```
[root@zhongjl-test-02 /data/compose/myproject/myproject/myproject]# ll
total 16
-rw-r--r-- 1 root root  395 Apr 25 15:54 asgi.py
-rw-r--r-- 1 root root    0 Apr 25 15:54 __init__.py
-rw-r--r-- 1 root root 3407 Apr 25 16:15 settings.py
-rw-r--r-- 1 root root  751 Apr 25 15:54 urls.py
-rw-r--r-- 1 root root  395 Apr 25 15:54 wsgi.py
```



而mange.py文件则在：``/data/compose/myproject/myproject``



#### 4.运行django项目

**注意：在运行django项目前，请先django项目目录下的settings的mysql配置信息**(redis暂不需修改)



```vim /data/compose/myproject/myproject/myproject/settings.py```

```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'myproject',
        'USER': 'dbuser',
        'PASSWORD': 'password',
        'HOST': 'db',  # Use the Docker service name as the hostname
        'PORT': '3306',
    }
}
```



启动django

```
前台启动
python3 /var/www/html/myproject/manage.py runserver 0.0.0.0:8000


后台启动
nohup python3 /var/www/html/myproject/manage.py runserver 0.0.0.0:8000 &
```



- `nohup`: 表示忽略挂起信号，允许进程在后台运行。
- `&`: 在命令末尾加上 `&` 表示将进程放到后台运行。



使用 `ps` 命令查找进程 ID（PID）

```bash
ps aux | grep python3
```

使用 `kill` 命令终止进程：

```bash
kill -9 <PID>
```



**如果启动遇到报错，可以根据错误文件python项目调整配置，也可以对照以下django的项目文件修改，修改的文件可以在容器内，也可以在宿主机，有映射存储，是共通的。**



## （6）django项目文件参考

#### 1.**`__init__.py`**：

项目的早期阶段，一般就是空文件





#### 2.vim wsgi.py

```
"""
WSGI config for myproject project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.0/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

# Set the settings module for the 'myproject' project:
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')

application = get_wsgi_application()

```





#### 3.settings.py

修改mysql和redis服务的配置信息。最重要的几项配置如下所示：

```
"""
Django settings for myproject project.

For more information on this file, see
https://docs.djangoproject.com/en/4.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/4.0/ref/settings/
"""

import os

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'your-secret-key'  # Replace 'your-secret-key' with your actual Django secret key

# SECURITY WARNING: don't run with debug turned on in production!

#根据需要自行修改
DEBUG = False

#填写服务器本机iP,域名可不填写
ALLOWED_HOSTS = ['10.22.51.65', 'josh.com']  

# Application definition
#APP引入，暂时没有可不改
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'myproject.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'myproject.wsgi.application'

# 数据库Database，设置为mysql，默认是使用sqlite
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'myproject',
        'USER': 'dbuser',
        'PASSWORD': 'password',
        'HOST': 'db',  # Use the Docker service name as the hostname
        'PORT': '3306',
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization

#设置语言，默认是英文，中文为'zh-hans'
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Redis Configuration
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://192.168.42.131:6379/1",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PASSWORD": "yourpassword",  # Use the actual password
        },
    }
}

```





#### 4.manage.py

```
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys

def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()

```





## （7）脚本部署

脚本执行前提：

> 1、确保服务器时间校准后
>
> 2、安装docker和docker-compose
>
> 3、执行后，自动创建目录，安装镜像，构建镜像、启动容器

脚本较为粗糙，但是能用，内容如下：

```
#!/bin/bash

# 创建项目结构
mkdir -p /data/compose/{myproject,mysql/{conf,init},nginx,redis}
mkdir -p /data/compose/nginx/{log,ssl}
mkdir -p /data/compose/myproject/{static,media}

# 创建和写入 Docker-compose 配置
cat > /data/compose/myproject/docker-compose.yml <<EOF
version: "3"

volumes: 
  db_vol:
  redis_vol:
  media_vol:
  static_vol:

networks:
  nginx_network:
    driver: bridge
  db_network:
    driver: bridge
  redis_network: 
    driver: bridge

services:
  redis:
    image: redis:latest
    command: redis-server /etc/redis/redis.conf
    networks:
      - redis_network
    volumes:
      - redis_vol:/data
      - /data/compose/redis/redis.conf:/etc/redis/redis.conf
    ports:
      - "6379:6379"
    restart: always

  db:
    image: mysql
    env_file:  
      - /data/compose/myproject/.env
    networks:  
      - db_network
    volumes:
      - db_vol:/var/lib/mysql:rw
      - /data/compose/mysql/conf/my.cnf:/etc/mysql/my.cnf
      - /data/compose/mysql/init:/docker-entrypoint-initdb.d/
    ports:
      - "3306:3306"
    restart: always

  web:
    build: /data/compose/myproject
    expose:
      - "8000"
    volumes:
      - /data/compose/myproject:/var/www/html/myproject
      - static_vol:/var/www/html/myproject/static
      - media_vol:/var/www/html/myproject/media
      - /data/compose/uwsgi:/tmp
    networks:
      - nginx_network
      - db_network  
      - redis_network 
    depends_on:
      - db
      - redis
    restart: always
    tty: true
    stdin_open: true

  nginx:
    build: /data/compose/nginx
    ports:
      - "80:80"
      - "443:443"
    expose:
      - "80"
    volumes:
      - /data/compose/nginx/nginx.conf:/etc/nginx/conf.d/nginx.conf
      - /data/compose/nginx/ssl:/usr/share/nginx/ssl
      - /data/compose/nginx/log:/var/log/nginx
      - static_vol:/usr/share/nginx/html/static
      - media_vol:/usr/share/nginx/html/media
    networks:
      - nginx_network
    depends_on:
      - web
    restart: always
EOF

# 创建 Django+Uwsgi Dockerfile
# 创建 Django+Uwsgi Dockerfile
cat > /data/compose/myproject/Dockerfile <<EOF
FROM centos:7

# 更新系统并安装必要的包
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install python3 python3-pip nc mysql-devel gcc-c++ python3-devel libjpeg-devel zlib-devel libffi-devel openssl-devel && \
    yum -y groupinstall "Development Tools" && \
    yum clean all

# 设置Python环境变量
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 配置pip国内源
COPY pip.conf /root/.pip/pip.conf

# 设置应用的工作目录
ENV APP_HOME=/var/www/html/myproject
RUN mkdir -p \$APP_HOME
WORKDIR \$APP_HOME

# 将当前目录的内容添加到工作目录中
ADD . \$APP_HOME

# 更新pip并安装项目依赖
RUN python3 -m pip install --upgrade pip
RUN pip install -r requirements.txt

# 复制并调整start.sh脚本的权限
COPY start.sh /data/compose/start.sh
RUN chmod +x /data/compose/start.sh && sed -i 's/\r$//' /data/compose/start.sh

# 复制uwsgi配置文件
COPY uwsgi.ini \$APP_HOME/uwsgi.ini

# 设置最终的工作目录和入口点
WORKDIR /data/compose
ENTRYPOINT ["/bin/bash", "/data/compose/start.sh"]
EOF



# 创建启动脚本
cat > /data/compose/myproject/start.sh <<EOF
#!/bin/bash
MYSQL_HOST=db
MYSQL_PORT=3306

while ! nc -z $MYSQL_HOST $MYSQL_PORT; do
    echo "Waiting for the MySQL Server"
    sleep 3
done

python manage.py migrate --noinput
python manage.py collectstatic --noinput

uwsgi --ini /var/www/html/myproject/uwsgi.ini

tail -f /dev/null

exec "\$@"
EOF
chmod +x /data/compose/myproject/start.sh

# 创建 uwsgi 配置文件
cat > /data/compose/myproject/uwsgi.ini <<EOF
[uwsgi]
project=myproject
uid=www-data
gid=www-data
base=/var/www/html

chdir=%(base)/%(project)
module=%(project).wsgi:application
master=True
processes=2

socket=0.0.0.0:8000
chown-socket=%(uid):www-data
chmod-socket=664

vacuum=True
max-requests=5000

pidfile=/tmp/%(project)-master.pid
daemonize=/tmp/%(project)-uwsgi.log

harakiri = 60
post buffering = 8192
buffer-size= 65535
harakiri-verbose = true

memory-report = true

reload-mercy = 10

reload-on-as= 1024
EOF

# 创建环境变量文件
cat > /data/compose/myproject/.env <<EOF
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=dbuser
MYSQL_DATABASE=myproject
MYSQL_PASSWORD=password
EOF

# 创建 Requirements 文件
cat > /data/compose/myproject/requirements.txt <<EOF
django==3.2
uwsgi==2.0.18
mysqlclient==1.4.6
django-redis==4.12.1
redis==3.5.3
Pillow==8.2.0
EOF

# 创建 Nginx 镜像 Dockerfile
cat > /data/compose/nginx/Dockerfile <<EOF
FROM nginx:latest

RUN rm /etc/nginx/conf.d/default.conf \
&& mkdir -p /usr/share/nginx/html/static \
&& mkdir -p /usr/share/nginx/html/media \
&& mkdir -p /usr/share/nginx/ssl

RUN chown -R www-data:www-data /usr/share/nginx/html/media \
&& chmod -R 775 /usr/share/nginx/html/media

ADD ./nginx.conf /etc/nginx/conf.d/

CMD ["nginx", "-g", "daemon off;"]
EOF

# 创建 Nginx 配置文件
cat > /data/compose/nginx/nginx.conf <<EOF
# nginx配置文件
# compose/nginx/nginx.conf

upstream django {
    ip_hash;
    server web:8000; # Docker-compose web服务端口
}

# 配置http请求，80端口
server {
    listen 80; # 监听80端口
    server_name 192.168.4; # 可以是nginx容器所在ip地址或127.0.0.1，不能写宿主机外网ip地址

    charset utf-8;
    client_max_body_size 10M; # 限制用户上传文件大小

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    location /static {
        alias /usr/share/nginx/html/static; # 静态资源路径
    }

    location /media {
        alias /usr/share/nginx/html/media; # 媒体资源，用户上传文件路径
    }

    location / {
        include /etc/nginx/uwsgi_params;
        uwsgi_pass django;
        uwsgi_read_timeout 600;
        uwsgi_connect_timeout 600;
        uwsgi_send_timeout 600;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
        proxy_set_header X-Real-IP  $remote_addr;
    }
}
EOF

# 创建 MySQL 配置文件
cat > /data/compose/mysql/conf/my.cnf <<EOF
[mysqld]
user=mysql
default-storage-engine=INNODB
character-set-server=utf8
secure-file-priv=NULL
default-authentication-plugin=mysql_native_password

port            = 3306
basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
skip-name-resolve

[client]
port = 3306
default-character-set=utf8

[mysql]
no-auto-rehash
default-character-set=utf8
EOF

# 创建 MySQL 初始化脚本
cat > /data/compose/mysql/init/init.sql <<EOF
ALTER USER 'dbuser'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON myproject.* TO 'dbuser'@'%';
FLUSH PRIVILEGES;
EOF

# 创建 Redis 配置文件
cat > /data/compose/redis/redis.conf <<EOF
bind 127.0.0.1
requirepass yourpassword
EOF

# 生成 pip 配置文件
cat > /data/compose/myproject/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host = mirrors.aliyun.com
EOF

# 构建镜像并启动容器
cd /data/compose/myproject
docker-compose build
docker-compose up -d


```



## （8）django其它操作

#### 1.启动django

连接docker容器

```
docker exec -it id bash
```



查看版本

```
python3 -m django --version
```



创建项目

```
django-admin startproject mysite
```





运行方式，端口可以自定义

```
python3 /var/www/html/myproject/manage.py runserver 0.0.0.0:8000
```



使用 `nohup` 命令来后台运行 Django 项目：

```bash
nohup python3 /var/www/html/myproject/manage.py runserver 0.0.0.0:8000 &
```

- `nohup`: 表示忽略挂起信号，允许进程在后台运行。
- `&`: 在命令末尾加上 `&` 表示将进程放到后台运行。

使用 `ps` 命令查找进程 ID（PID）

```bash
ps aux | grep python3
```

使用 `kill` 命令终止进程：

```bash
kill -9 <PID>
```







成功则返回

> Performing system checks...
>
> System check identified no issues (0 silenced).
>
> You have 18 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
> Run 'python manage.py migrate' to apply them.
> April 16, 2024 - 04:02:48
> Django version 3.2, using settings 'myproject.settings'
> Starting development server at http://0.0.0.0:8000/



通过服务器IP+端口8000进行访问，如返回，在django中，urls.py定义如何请求映射到视图函数。

![image-20240425171453013](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/25/8f2d97a3175c6b112fe91f65a5f5155e-image-20240425171453013-e89ecc.png)

> # Not Found
>
> The requested resource was not found on this server.

通常是未将settings.py的设置为```DEBUG = True```，如需登录django后台，使用：http://10.22.51.65:8000/admin进行访问，并且需要创建管理员

![image-20240425171637023](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/25/02d49a14a9c05264d92689f851d5e1c8-image-20240425171637023-a95374.png)





#### 2.创建superuser管理员

1、确保settings.py的DATABASES与Mysql数据用户密码一致。

在项目目录下，执行命令```python3.6 manage.py createsuperuser```

```
[root@11eaf6e23195 myproject]# python3.6 /var/www/html/myproject/manage.py createsuperuser

Username (leave blank to use 'root'): josh
Email address: 980521387@qq.com
Password: 123456
Password (again): 123456
This password is too short. It must contain at least 8 characters.
This password is too common.
This password is entirely numeric.
Bypass password validation and create user anyway? [y/N]: y
Superuser created successfully.
```



遇到个报错，提示：您有 18 个未应用的迁移。

> You have 18 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
> Run 'python manage.py migrate' to apply them.

解决办法：**应用数据库迁移**，再重新执行创建。

```
python3.6 manage.py makemigrations
python3.6 manage.py migrate
```



#### 3.web修改中文

编辑vi settings.py，```修改参数为：LANGUAGE_CODE = 'zh-hans'```，改完刷新页面生效。

#### **4.创建应用app**

创建jobs的app

```
#创建应用名为jobs
python3.6 manage.py startapp jobs

#修改settings.py,
vi /var/www/html/myproject/myproject/settings.py
```

在INSTALLED_APPS后，增加jobs

```
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "jobs"    #此处
]
```

