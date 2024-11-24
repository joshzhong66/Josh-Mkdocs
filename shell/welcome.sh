#!/bin/bash
#author:josh

current_time=$(date)
system_load=$(uptime | awk -F'load average: ' '{print $2}' | awk -F',' '{print $1}')
processes=$(ps -ef | wc -l)
memory_used=$(free | awk 'NR==2 {print "%.2f\n" $3/$2 * 100}')
swap_total=$(free | awk 'NR==3 {print $2}')
swap_used=$(free | awk 'NR==3 {print $3}')
if [ $swap_total -eq 0 ]; then
    swap_used_percentage="0"
else
    swap_used_percentage=$(echo "scale=2; $swap_used/$swap_total*100" | bc)
fi

disk_usage=$(df -h / | awk 'NR==2 {print $5}')
local_address=$(hostname -I | awk '{print $1}')
export_address=$(curl -s ifconfig.me)
users_online=$(who | wc -l)

echo ""
echo "System load:          $system_load"
echo "Processes:            $processes"
echo "Memory used:          $memory_used"
echo "Swap used:            $swap_used_percenage"
echo "Usage On:             $disk_usage"
echo "Local address:        $local_address"
echo "Export address:       $export_address"
echo "Users Online:         $users_online"
