#!/bin/bash

# 获取当前时间
current_time=$(date)

# 获取系统负载
system_load=$(uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1}')

# 获取进程数量
processes=$(ps -ef | wc -l)

# 获取内存使用情况
memory_used=$(free | awk 'NR==2 {printf "%.2f\n", $3/$2 * 100}')

# 获取交换空间使用情况
swap_total=$(free | awk 'NR==3 {print $2}')
swap_used=$(free | awk 'NR==3 {print $3}')
if [ $swap_total -eq 0 ]; then
    swap_used_percentage="0"
else
    swap_used_percentage=$(echo "scale=2; $swap_used/$swap_total*100" | bc)
fi

# 获取磁盘使用情况
disk_usage=$(df -h / | awk 'NR==2 {print $5}')

# 获取本地IP和出口IP地址
local_address=$(hostname -I | awk '{print $1}')
export_address=$(curl -s ifconfig.me)

# 获取在线用户数量
users_online=$(who | wc -l)

# 打印欢迎信息
# echo "Connecting to $(whoami)@$(hostname)  0.2"
# echo "Last login: $(last -1 | awk '{print $3,$4,$5,$6,$7}')"
# echo "Welcome to $(uname -r)"
echo ""
# echo "System information as of time:  $current_time"
echo ""
echo "System load:      $system_load"
echo "Processes:        $processes"
echo "Memory used:      $memory_used%"
echo "Swap used:        $swap_used_percentage%"
echo "Usage On:         $disk_usage"
echo "Local address:    $local_address"
echo "Export address:   $export_address"
echo "Users online:     $users_online"
