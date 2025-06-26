#!/usr/bin/expect -f

# 脚本执行流程：
# yum -y install zip expect jq
# chmod +x backup_switch_conf_v1.sh
# ./backup_switch_conf_v1.sh 10.18.250.1 shenzhen Huawei@1234

set ip [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]

set now [timestamp -format "%Y%m%d"]
log_file "sw${now}_${ip}.conf"

set timeout 30

spawn ssh -l $username $ip
expect "*assword:"
send "$password\r"

expect "*>"
send "display current-configuration\r"

expect {
    "*More ----" { send " "; exp_continue }
    "*>"
}

send "quit\r"
expect eof
