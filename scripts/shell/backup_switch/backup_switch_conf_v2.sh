#!/usr/bin/expect -f

# 脚本执行流程：
# yum -y install zip expect jq
# chmod +x backup_switch_conf_v2.sh
# ./backup_switch_conf_v2.sh 10.18.250.2 shenzhen Huawei@1234 sw20250620_10.18.250.2.conf

set ip [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set outfile [lindex $argv 3]

set timeout 30

# 开始连接交换机
spawn ssh -o StrictHostKeyChecking=no -l $username $ip

# 登录处理
expect {
    "*yes/no" {
        send "yes\r"
        exp_continue
    }
    "*assword:" {
        send "$password\r"
    }
}

# 登录成功后，进入命令行
expect "*>"

# 发送命令
send "display current-configuration\r"

#  开始日志记录（从命令执行开始记录）
log_file -noappend $outfile

# 自动翻页处理
expect {
    "*More ----" {
        send " "
        exp_continue
    }
    "return" {
        exp_continue
    }
    "*>"
}

# 停止记录（在 quit 前）
log_file

# 发送退出命令
send "quit\r"
expect eof
