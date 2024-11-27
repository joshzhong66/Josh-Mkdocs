#!/bin/bash

system_facts=''
cpu_facts=''
mem_facts=''
disk_facts=''

system_info() {
    hostname=$(hostname 2>/dev/null)
    os_info=$(awk '/^PRETTY_NAME=/' /etc/*-release 2>/dev/null | awk -F'=' '{gsub("\"","");print $2}')
    kernel=$(uname -r 2>/dev/null)
    system_facts=$(cat << EOF
{
        "hostname": "${hostname:-}",
        "os_info": "${os_info:-}",
        "kernel": "${kernel:-}"
    }
EOF
    )
}

cpu_info() {
    cpu_core_count=`grep "^processor" /proc/cpuinfo |wc -l`
    upload=`uptime |awk -F':' '{print $NF}' |sed 's/,//g'`
    cpu_loadavg1=`echo ${upload} | awk '{print $1}'`
    cpu_loadavg5=`echo ${upload} | awk '{print $3}'`
    command=$(top -bn 1 | awk -F: '/Cpu/ {print $2}' | sed 's/%/ %/g; s/,/ /g')
    which iostat 2&>1 &>/dev/null
    if [ $? -eq 0 ];then
        idle=`iostat 1 2 |grep -A 1 avg-cpu |tail -1 |awk '{print $NF}'`
    else
        idle=`echo ${command} | awk '{print $7}'`
    fi
    cpuused=`echo ${idle} | awk '{sum=100-$idle}END{printf "%.2f\n",sum}'`
    cpu_facts=$(cat << EOF
{
        "cpuused": "${cpuused:-0}%",
        "cpu_load_1min": "${cpu_loadavg1:-0}",
        "cpu_load_5min": "${cpu_loadavg5:-0}"
    }
EOF
    )
}


mem_info() {
    get_pymem_info=$(export LANG=en_US; free -k | grep -i mem)
    MemTotalSize=$(echo ${get_pymem_info} | awk 'NR==1{printf "%.2f", $2 / 1024 / 1024}')  
    MemUsed=$(echo ${get_pymem_info} | awk 'NR==1{printf "%.2f", $3 / 1024 / 1024}')     
    MemFree=$(echo ${get_pymem_info} | awk 'NR==1{printf "%.2f", $4 / 1024 / 1024}')              
    BuffCacheSize=$(echo ${get_pymem_info} | awk 'NR==1{printf "%.2f", $6 / 1024 / 1024}')  
    Available=$(export LANG=en_US; free -k | grep -A 1 available | awk 'NR==2{printf "%.2f", $NF / 1024 / 1024}') 

    if [ -z ${Available} ]; then
        PhyMemUse=$(awk 'BEGIN{printf "%.2f", ('$MemTotalSize' - '$MemFree' - '$BuffCacheSize')}')
        usedperc=$(awk 'BEGIN{printf "%.2f", 100 * ('$PhyMemUse' / '$MemTotalSize')}')
    else
        PhyMemUse=$(awk 'BEGIN{printf "%.2f", ('$MemTotalSize' - '$Available')}')
        usedperc=$(awk 'BEGIN{printf "%.2f", 100 - ('$Available' / '$MemTotalSize' * 100)}')
    fi

    mem_facts=$(cat << EOF
{
        "MemTotalSize": "${MemTotalSize:-}GB",
        "MemUsed": "${MemUsed}"
        "MemFree": "${MemFree:-}GB",
        "Available": "${Available:-}GB",
        "usedperc": "${usedperc:-}%"
    }
EOF
    )
}

disk_info() {
    root_disk_info=`df -HT |grep -w '/'`
    data_disk_info=`df -HT |grep -w '/data'`

    if [ `echo ${root_disk_info}|grep -Ev "^$"|wc -l` -eq 1 ];then
        root_total_disk=`echo ${root_disk_info}|awk '{print $3}'`
        root_used_disk=`echo ${root_disk_info}|awk '{print $4}'`
        root_free_disk=`echo ${root_disk_info}|awk '{print $5}'`
        root_usage_disk=`echo ${root_disk_info}|awk '{print $(NF-1)}'`
    else
        root_total_disk=""
        root_free_disk=""
        root_usage_disk=""
    fi

    if mountpoint -q /data; then
        if [ "$(echo ${data_disk_info} | grep -Ev "^$" | wc -l)" -eq 1 ]; then
            data_total_disk=$(echo ${data_disk_info} | awk '{print $3}')
            data_used_disk=$(echo ${data_disk_info} | awk '{print $4}')
            data_free_disk=$(echo ${data_disk_info} | awk '{print $5}')
            data_usage_disk=$(echo ${data_disk_info} | awk '{print $(NF-1)}')
        else
            data_total_disk=""
            data_free_disk=""
            data_usage_disk=""
        fi
    else
        data_used_disk=$(du -sh /data 2>/dev/null | awk '{print $1}')
    fi
    disk_facts=$(cat << EOF
{
        "root_total_disk": "${root_total_disk:-}",
        "root_used_disk": "${root_used_disk:-}",
        "root_free_disk": "${root_free_disk:-}",
        "root_usage_disk": "${root_usage_disk:-}",
        "data_total_disk": "${data_total_disk:-}",
        "data_used_disk": "${data_used_disk:-}",
        "data_free_disk": "${data_free_disk:-}",
        "data_usage_disk": "${data_usage_disk:-}"
    }
EOF
    )
}

main() {
    system_info
    cpu_info
    mem_info
    disk_info
    check_facts=$(cat << EOF
{
        "system": ${system_facts:-},
        "cpu": ${cpu_facts:-},
        "memory": ${mem_facts:-},
        "disk": ${disk_facts:-}
}
EOF
)
    echo "${check_facts:-}"
}

main