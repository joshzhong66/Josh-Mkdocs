#!/bin/bash



version() {
sed -rn 's#^.* ([0-9]+)\..*#\1#p' /etc/redhat-release
}

install_zabbix(){
PACK='zabbix-5.0.10.tar.gz'
COLOR='echo -e \E[01;31m'
END='\E[0m'

$COLOR "请先准备好nginx和mysql zabbix存放路径为/apps/nginx/html"$END

sleep 5

if [ -f /root/$PACK ];then
    ins_zabbix
else
    $COLOR "源码包不存在！开始下载！"$END
    yum -y install wget &> /dev/null
    wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/$PACK
    ins_zabbix
fi
}


ins_zabbix(){
USER='zabbix'
PACK='zabbix-5.0.10.tar.gz'
DIR='zabbix-5.0.10'
SRC_DIR='/apps'
YUM_PACK='libevent-devel wget tar gcc gcc-c++ make net-snmp-devel libxml2-devel libcurl-devel make'
COLOR='echo -e \E[01;31m'
END='\E[0m'
MYSQL_PACK='/usr/local/mysql/lib/libmysqlclient.so.20'

$COLOR "警告！！！确保主机有足够的内存最少4G内存！zabbix存放目录为/apps/nginx/html下！"$END
sleep 3


ss -ntlp|grep -wq 9000 
if [ $? -eq 0 ];then
   $COLOR "检测到已存在php！！继续执行"$END
else
   $COLOR "警告！！！未检测到php！！开始安装php！！"$END
   yum install -y epel-release yum-utils &> /dev/nul
   yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm &> /dev/null
   yum install -y php73-php-fpm php73-php-cli php73-php-bcmath php73-php-gd php73-php-json php73-php-mbstring php73-php-mcrypt php73-php-mysqlnd php73-php-opcache php73-php-pdo php73-php-pecl-crypto php73-php-pecl-mcrypt php73-php-pecl-geoip php73-php-pecl-swoole php73-php-recode php73-php-snmp php73-php-soap php73-php-xml &> /dev/null
   yum install -y php73-php-xml libxml2 openldap-devel libpng libpng-devel libjpeg libjpeg-devel freetype freetype-devel libXpm libXpm-devel libvpx libvpx-devel zlib zlib-devel t1lib t1lib-devel iconv iconv-devel libxml2 libxml2-devel bcmath  libmcrypt libmcrypt-devel gcc libcurl-devel gd gd-devel openssl openssl-devel &> /dev/null 
    yum install -y libevent-devel wget tar gcc gcc-c++ make net-snmp-devel libxml2-devel libcurl-devel &> /dev/null
   systemctl restart php73-php-fpm
fi 

ss -ntlp|grep -wq 80
if [ $? -eq 0 ];then
   $COLOR "检测到web应用存在！继续执行。。"$END
else
   $COLOR "警告！！！未检测到web应用！请检查！！"$END
   sleep 5
   exit 
fi



ss -ntlp | grep -wq 3306
if [ $? -eq 0 ];then



if [ -f /root/$PACK ];then
   $COLOR "源码包存在，开始解压"$END
   cd /root/ && tar xf $PACK
   $COLOR "开始下载$USER所需依赖"$END
   mkdir /apps &> /dev/null
  useradd -s /sbin/nologin $USER &> /dev/null
   $COLOR "开始编译安装$USER"$END
   cd /root/$DIR
   ./configure --prefix=$SRC_DIR/$USER --enable-server --enable-agent --with-mysql=/usr/local/mysql/bin/mysql_config --with-net-snmp --with-libcurl --with-libxml2 &> /dev/null 
   make -s &> /dev/null
   make install -s &> /dev/null
   $COLOR "开始准备$USER环境"$END
   ln -s $SRC_DIR/$USER/sbin/* /usr/sbin/ &> /dev/null
MYSQL_PACK='/usr/local/mysql/lib/libmysqlclient.so.20'
if [ -f $MYSQL_PACK ];then
   ln -s /usr/local/mysql/lib/libmysqlclient.so.20  /usr/lib64/ &> /dev/null
else
   $COLOR "警告！！！mysql连接文件不存在！！$USER可能无法启动！"$END
   sleep 10
fi
   $COLOR "开始准备$USER数据库"$END
read -p "$(echo -e '\033[1;32m请输入mysql密码:\033[0m')" PASS
   mysql -uroot -p$PASS -e "create database zabbix character set utf8 collate utf8_bin;" &> /dev/null
   mysql -uroot -p$PASS -e "grant all privileges on zabbix.* to zabbix@'127.0.0.1' identified by 'zabbixpwd';" &> /dev/null
   mysql -uroot -p$PASS -e "flush privileges;" &> /dev/null
   mysql -uroot -p$PASS -e "set names utf8;" &> /dev/null
   mysql -uroot -p$PASS zabbix -e "source /root/$DIR/database/mysql/schema.sql;" 
   mysql -uroot -p$PASS zabbix -e "source /root/$DIR/database/mysql/images.sql;"
   mysql -uroot -p$PASS zabbix -e "source /root/$DIR/database/mysql/data.sql;"
   $COLOR "开始准备$USER配置文件"$END
   mv $SRC_DIR/$USER/etc/zabbix_server.conf $SRC_DIR/$USER/etc/zabbix_server.conf.bak
   $COLOR "开始启动$USER"$END
   mkdir $SRC_DIR/nginx/html/$USER
   chown $USER:$USER -R $SRC_DIR/$USER
   cp -a /root/$DIR/ui/* $SRC_DIR/nginx/html/$USER/
   touch  /apps/zabbix/etc/zabbix_server.conf 
cat > /apps/zabbix/etc/zabbix_server.conf <<EOF
LogFile=/tmp/zabbix_server.log
DBHost=127.0.0.1
DBName=zabbix
DBUser=$USER
DBPassword=zabbixpwd
EOF

touch  /apps/nginx/html/zabbix/conf/zabbix.conf.php
cat > /apps/nginx/html/zabbix/conf/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = '127.0.0.1';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = 'zabbixpwd';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = '';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF
sed -i.bak '/post_max_size = 8M/c post_max_size = 32M' /etc/opt/remi/php73/php.ini 
sed -i.bak '/max_execution_time = 30/c max_execution_time = 300' /etc/opt/remi/php73/php.ini 
sed -i.bak '/max_input_time = 60/c max_input_time = 300' /etc/opt/remi/php73/php.ini 
sed -i.bak '/;date.timezone =/cdate.timezone = Asia/Shanghai' /etc/opt/remi/php73/php.ini 
systemctl restart php73-php-fpm
touch /usr/lib/systemd/system/zabbix_server.service
cat > /usr/lib/systemd/system/zabbix_server.service<<EOF
[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/apps/zabbix/etc/zabbix_server.conf"
EnvironmentFile="-/root/zabbix-5.0.10/misc/init.d/gentoo/zabbix-server"
TYPE=forking
Restart=on-failure
PIDFile=/tmp/zabbix_server.pid
KillMode=control-group
ExecStart=/apps/zabbix/sbin/zabbix_server -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
TimeoutSec=infinity
[Install]
wantedBy=multi-user.target
EOF
touch /usr/lib/systemd/system/zabbix_agentd.service
cat > /usr/lib/systemd/system/zabbix_agentd.service<<EOF
[Unit]
Description=Zabbix agent 
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/apps/zabbix/etc/zabbix_agentd.conf"
EnvironmentFile="-/root/zabbix-5.0.10/misc/init.d/debian/zabbix-agent"
TYPE=forking
Restart=on-failure
PIDFile=/tmp/zabbix_agentd.pid
KillMode=control-group
ExecStart=/apps/zabbix/sbin/zabbix_agentd -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
User=zabbix
Group=zabbix
[Install]
wantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart zabbix_server && systemctl enable --now zabbix_server
systemctl restart zabbix_agentd && systemctl enable --now zabbix_agentd


ss -ntlp|grep -wq 10051
if [ $? -eq 0 ];then
   $COLOR"$USER 服务启动成功,账号为Admin密码为zabbix"$END
    exit
else
   $COLOR"$USER 服务启动失败"$END
    exit      
fi





else
    $COLOR"未检测到mysql！请先安装mysql！"$END
    exit
fi


else
   $COLOR "源码包不存在！退出！"$END
    exit

fi
}