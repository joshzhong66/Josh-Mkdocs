#!/bin/bash

DEFAULT_VERSION="6.0.4"
PACKAGE_NAME="zabbix"
DOWNLOAD_PATH="/usr/local/src"

MYSQL_ROOT_USER="root"
MYSQL_ROOT_PWD="Sunline2024"

uninstall_zabbix_server() {
    systemctl daemon-reload
    systemctl stop zabbix_server
    systemctl stop zabbix_agent

    # 创建数据库和用户（幂等操作）
    mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" <<EOF
DROP DATABASE zabbix;
exit
EOF
    rm -rf /etc/init.d/zabbix_agentd 
    rm -rf /etc/init.d/zabbix_server 

    rm -rf /data/zabbix
    rm -rf $DOWNLOAD_PATH/$PACKAGE_NAME-$DEFAULT_VERSION

    
}

uninstall_zabbix_server