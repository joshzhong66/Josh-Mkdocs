#!/bin/bash

zbxa_name=$(hostname)
zbx_server_ip=10.22.51.65
psk_file="/usr/local/zabbix_agent/etc/zabbix_agentd.psk"
psk="f03a84aa7cc6ea8c13d9e01f2a704705bad15fd26a535dd8bf322c3b5c38d493"


if [ ! -d "/usr/local/zabbix_agent/etc/" ]; then
    echo "Error: /usr/local/zabbix_agent/etc/ 目录不存在！"
    exit 1
fi 

cd /usr/local/zabbix_agent/etc

# 创建psk
echo $psk > $psk_file

# 修改agentd.conf
sed -i 's@# PidFile=/tmp/zabbix_agentd.pid@PidFile=/tmp/zabbix_agentd.pid@g' zabbix_agentd.conf
sed -i 's@LogFile=/tmp/zabbix_agentd.log@LogFile=/usr/local/zabbix_agent/logs/zabbix_agentd.log@g' zabbix_agentd.conf
sed -i 's@# LogFileSize=1@LogFileSize=0@g' zabbix_agentd.conf
sed -i "s@^Server=.*@Server=${zbx_server_ip}@g" zabbix_agentd.conf              # IP地址修改为Zabbix Server服务器端IP
sed -i "s@^ServerActive=.*@ServerActive=${zbx_server_ip}@g" zabbix_agentd.conf  # IP地址修改为Zabbix Server服务器端IP
sed -i "s/^Hostname=.*/Hostname=${zbxa_name}/" zabbix_agentd.conf               # 主机名与Zabbix Web配置的主机名一致
sed -i 's@# AllowRoot=0@AllowRoot=1@g' zabbix_agentd.conf
sed -i 's@# Include=/usr/local/etc/zabbix_agentd.conf.d/\*.conf@Include=/usr/local/zabbix_agent/etc/zabbix_agentd.conf.d/\*.conf@g' zabbix_agentd.conf
sed -i 's@# UnsafeUserParameters=0@UnsafeUserParameters=1@g' zabbix_agentd.conf
sed -i 's@# TLSConnect=unencrypted@TLSConnect=psk@g' zabbix_agentd.conf
sed -i 's@# TLSAccept=unencrypted@TLSAccept=psk@g' zabbix_agentd.conf
sed -i 's@# TLSPSKIdentity=@TLSPSKIdentity=psk01@g' zabbix_agentd.conf
sed -i 's@# TLSPSKFile=@TLSPSKFile=/usr/local/zabbix_agent/etc/zabbix_agentd.psk@g' zabbix_agentd.conf

# 显示修改后的配置
egrep -v '#|^$' zabbix_agentd.conf

# 输出类似
# PidFile=/tmp/zabbix_agentd.pid
# LogFile=/usr/local/zabbix_agent/logs/zabbix_agentd.log
# LogFileSize=0
# Server=10.22.51.65
# ServerActive=10.22.51.65
# Hostname=test67
# AllowRoot=1
# Include=/usr/local/zabbix_agent/etc/zabbix_agentd.conf.d/*.conf
# UnsafeUserParameters=1
# TLSConnect=psk
# TLSAccept=psk
# TLSPSKIdentity=psk01
# TLSPSKFile=/usr/local/zabbix_agent/etc/zabbix_agentd.psk

# 重启Zabbix Agent服务
systemctl restart zabbix_agentd