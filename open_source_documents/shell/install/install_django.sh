#!/bin/bash

# 定义常用的路径和变量
BASE_DIR="/data/compose"
MYSQL_CONF_DIR="$BASE_DIR/mysql/conf"
MYSQL_INIT_DIR="$BASE_DIR/mysql/init"
NGINX_DIR="$BASE_DIR/nginx"
REDIS_DIR="$BASE_DIR/redis"
PROJECT_DIR="$BASE_DIR/myproject"

# 创建项目结构
mkdir -p $PROJECT_DIR/{static,media} \
         $MYSQL_CONF_DIR $MYSQL_INIT_DIR \
         $NGINX_DIR/{log,ssl} \
         $REDIS_DIR || { echo "Failed to create directories"; exit 1; }

# Docker-compose 配置
DOCKER_COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
cat > $DOCKER_COMPOSE_FILE <<EOF
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
      - $REDIS_DIR/redis.conf:/etc/redis/redis.conf
    ports:
      - "6379:6379"
    restart: always

  db:
    image: mysql
    env_file:  
      - $PROJECT_DIR/.env
    networks:  
      - db_network
    volumes:
      - db_vol:/var/lib/mysql:rw
      - $MYSQL_CONF_DIR/my.cnf:/etc/mysql/my.cnf
      - $MYSQL_INIT_DIR:/docker-entrypoint-initdb.d/
    ports:
      - "3306:3306"
    restart: always

  web:
    build: $PROJECT_DIR
    expose:
      - "8000"
    volumes:
      - $PROJECT_DIR:/var/www/html/myproject
      - static_vol:/var/www/html/myproject/static
      - media_vol:/var/www/html/myproject/media
      - $BASE_DIR/uwsgi:/tmp
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
    build: $NGINX_DIR
    ports:
      - "80:80"
      - "443:443"
    expose:
      - "80"
    volumes:
      - $NGINX_DIR/nginx.conf:/etc/nginx/conf.d/nginx.conf
      - $NGINX_DIR/ssl:/usr/share/nginx/ssl
      - $NGINX_DIR/log:/var/log/nginx
      - static_vol:/usr/share/nginx/html/static
      - media_vol:/usr/share/nginx/html/media
    networks:
      - nginx_network
    depends_on:
      - web
    restart: always
EOF

# 检查文件创建是否成功
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Failed to create Docker compose file"
    exit 1
fi

# 创建和优化 Dockerfile
DOCKERFILE_PATH="$PROJECT_DIR/Dockerfile"
cat > $DOCKERFILE_PATH <<EOF
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

if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "Failed to create Dockerfile"
    exit 1
fi

# 启动脚本优化
START_SH_PATH="$PROJECT_DIR/start.sh"
cat > $START_SH_PATH <<'EOF'
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

chmod +x $START_SH_PATH || { echo "Failed to set execute permission on start.sh"; exit 1; }

# 创建 uwsgi 配置文件
UWSGI_INI_PATH="$PROJECT_DIR/uwsgi.ini"
cat > $UWSGI_INI_PATH <<EOF
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

# 环境变量文件
ENV_FILE="$PROJECT_DIR/.env"
cat > $ENV_FILE <<EOF
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=dbuser
MYSQL_DATABASE=myproject
MYSQL_PASSWORD=password
EOF

# Requirements 文件
REQ_FILE="$PROJECT_DIR/requirements.txt"
cat > $REQ_FILE <<EOF
django==3.2
uwsgi==2.0.18
mysqlclient==1.4.6
django-redis==4.12.1
redis==3.5.3
Pillow==8.2.0
EOF

# 构建镜像并启动容器
cd $PROJECT_DIR
docker-compose build && docker-compose up -d || { echo "Docker compose failed"; exit 1; }
