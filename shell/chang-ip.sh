#vim chang-ip.sh   #编辑ip脚本
#sh chang-ip.sh    #执行ip脚本

#BOOTPROTO=static
#NAME=eth0
#DEVICE=eth0

chang-ip.sh的内容为：
#!/bin/bash
#
# Modify the network ip script
# Date : 2020-9-7
# FileName : change-ip.sh
#
#
# Network configuration file
ethfile="/etc/sysconfig/network-scripts/ifcfg-eth0"
# Verify that the input ip is legal
ipzz="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$"
# Modify IP
while :
do
read -p "Input IP address: " new_ip
        if [ -z $new_ip ]; then
                echo "IP address can't be empty, please re-enter!"
        elif [[  $new_ip =~ $ipzz ]]; then
                break
        else
                echo "IP address format is wrong, please re-enter!"
        fi
done
# Modify gateway
while :
do
read -p "Input Gateway address: " new_gw
        if [ -z $new_gw ]; then
                echo "Gateway address can't be empty,please re-enter!"
        elif [[ $new_gw =~ $ipzz ]]; then
                break
        else
                echo "Gateway address format is wrong, please re-enter!"
        fi
done
# Write network card configuration file
echo "
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
IPADDR=$new_ip
PREFIX=24
GATEWAY=$new_gw
DNS1=10.22.50.5
IPV6_PRIVACY=no
" > $ethfile
#
sleep 3
#service network restart
systemctl restart network.service