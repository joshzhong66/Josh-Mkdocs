#!/bin/bash
#author: hellojing
#time: 2023-01-07

######################################################################################################
# Environmental
######################################################################################################
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
######################################################################################################
# System Tools
# yum install sysstat
######################################################################################################
# Define globle variable
######################################################################################################
system_facts=''
cpu_facts=''
mem_facts=''
disk_facts=''
function get_system() {
    # 获取系统信息
    hostname=$(hostname 2>/dev/null) # 主机名
    os_pretty_name=$(awk '/^PRETTY_NAME=/' /etc/*-release 2>/dev/null | awk -F'=' '{gsub("\"","");print $2 }') # 系统版本
    kernel=$(uname -r 2>/dev/null) # 内核信息

    system_facts=$(cat << EOF
        {
        "hostname": "${hostname:-}",
        "os_pretty_name": "${os_pretty_name:-}",
        "kernel": "${kernel:-}"
    }
EOF
    )
}

function get_cpu() {
    cpu_phy_num=`grep "^processor" /proc/cpuinfo |wc -l` # cpu核数
    upload=`uptime |awk -F':' '{print $NF}' |sed 's/,//g'`
    cpu_loadavg1=`echo ${upload} | awk '{print $1}'` # 一分钟负载
    cpu_loadavg5=`echo ${upload} | awk '{print $2}'` # 五分钟负载
    command=`top -bn 1 |grep Cpu|awk -F: '{print $2}' |sed 's/%/ %/g' |sed 's/,/ /g' |tail -1`
    which iostat 2&>1 &>/dev/null
    if [ $? -eq 0 ];then
        idle=`iostat 1 2 |grep -A 1 avg-cpu |tail -1 |awk '{print $NF}'` # Cpu使用率
    else
        idle=`echo ${command} | awk '{print $7}'` # Cpu使用率
    fi

   #cpu使用率
   cpuused=`echo ${idle} | awk '{sum=100-$idle}END{printf "%.2f\n",sum}'`
    cpu_facts=$(cat << EOF
    {
        "cpuused": "${cpuused:-0}%",
        "cpu_loadavg1": "${cpu_loadavg1:-0}",
        "cpu_loadavg5": "${cpu_loadavg5:-0}"
    }
EOF
    )
}

function get_mem {
    get_pymem_info=`export LANG=en_US;free -k |grep -i mem`
    #物理内存总大小[kb]
    MemTotalSize=`echo ${get_pymem_info} |awk 'NR==1{print $2}'`
    # 物理内存空闲大小[kb]
    MemFree=`echo ${get_pymem_info} |awk 'NR==1{print $4}'`
    # Buffers+Cached使用大小[kb]
    BuffCacheSize=`echo ${get_pymem_info} |awk 'NR==1{print $6}'`
    # 可用内存[kb]
    Available=`export LANG=en_US;free -k |grep -A 1 available |awk 'NR==2{print $NF}'`

    if [ -z ${Available} ];then
        # 物理内存使用大小[kb]
        PhyMemUse=`expr ${MemTotalSize} - ${MemFree} - ${BuffCacheSize}`
        #物理内存使用率
        usedperc=`awk 'BEGIN{printf "%.2f\n",100*'$PhyMemUse'/'$MemTotalSize'}'`
    else
        # 物理内存使用大小[kb]
        PhyMemUse=`expr ${MemTotalSize} - ${Available}`
        # 物理内存使用率
        usedperc=`echo | awk 'BEGIN{printf "%.2f\n",100 - ('$Available'/'$MemTotalSize'*100)}'`
    fi

    mem_facts=$(cat << EOF
    {
        "MemTotalSize": "${MemTotalSize:-}KB",
        "MemFree": "${MemFree:-}KB",
        "Available": "${Available:-}KB",
        "usedperc": "${usedperc:-}%"
    }
EOF
    )
}

function get_disk() {
    root_disk_info=`df -HT |grep -w '/'`
    data_disk_info=`df -HT |grep -w '/data'`

    if [ `echo ${root_disk_info}|grep -Ev "^$"|wc -l` -eq 1 ];then
        # 根目录总大小
        root_total_disk=`echo ${root_disk_info}|awk '{print $3}'`
        # 根目录剩余大小
        root_free_disk=`echo ${root_disk_info}|awk '{print $5}'`
        # 根目录使用率
        root_usage_disk=`echo ${root_disk_info}|awk '{print $(NF-1)}'`
    else
        root_total_disk=""
        root_free_disk=""
        root_usage_disk=""
    fi
    if [ `echo ${data_disk_info}|grep -Ev "^$"|wc -l` -eq 1 ];then
        # /data目录总大小
        data_total_disk=`echo ${data_disk_info}|awk '{print $3}'`
        # /data目录剩余大小
        data_free_disk=`echo ${data_disk_info}|awk '{print $4}'`
        # /data目录使用率
        data_usage_disk=`echo ${data_disk_info}|awk '{print $(NF-1)}'`
    else
        data_total_disk=""
        data_free_disk=""
        data_usage_disk=""
    fi
    disk_facts=$(cat << EOF
    {
        "root_total_disk": "${root_total_disk:-}",
        "root_free_disk": "${root_free_disk:-}",
        "root_usage_disk": "${root_usage_disk:-}",
        "data_total_disk": "${data_total_disk:-}",
        "data_free_disk": "${data_free_disk:-}",
        "data_usage_disk": "${data_usage_disk:-}"
    }
EOF
    )
}

function main(){
get_system
get_cpu
get_mem
get_disk

check_facts=$(cat << EOF
    {
        "system": ${system_facts:-[]},
        "cpu": ${cpu_facts:-[]},
        "mem": ${mem_facts:-[]},
        "disk": ${disk_facts:-[]}
    }
EOF
    )
echo ${check_facts:-[]}

}

######################################################################################################
# main
######################################################################################################

main
