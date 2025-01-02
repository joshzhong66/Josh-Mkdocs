#!/bin/bash
# \033[33m 表示黄色， \033[32m 表示绿色， \033[31m 表示红色， \033[0m 表示恢复样式

# 日志输出
function echo_log_info() {
    echo -e "$(date +'%F %T') - [Info] \033[32m$*\033[0m"
}
function echo_log_warn() {
    echo -e "$(date +'%F %T') - [Warn] \033[33m$*\033[0m"
}
function echo_log_error() {
    echo -e "$(date +'%F %T') - [Error] \033[31m$*\033[0m"
    exit 1
}

# 定义输出文件路径
output_file="/tmp/Scan_Online.out"

function check_packet() {
    if ! command -v nmap &> /dev/null; then
        echo_log_warn "nmap 未安装，准备安装 nmap..."
        yum install -y nmap &> /dev/null
        [ $? -eq 0 ] && echo_log_info "nmap 安装成功！" || echo_log_error "nmap 安装失败！"
    fi
    if ! command -v parallel &> /dev/null; then
        echo_log_warn "GNU Parallel 未安装，准备安装 GNU Parallel..."
        yum install -y parallel &> /dev/null
        [ $? -eq 0 ] && echo_log_info "parallel 安装成功！" || echo_log_error "parallel 安装失败！"
    fi
}

# 计算主机数量函数
function calc_hosts() {
    local cidr=$1
    echo $((2 ** (32 - cidr) - 2))  # 子网主机数量，减去网络号和广播地址
}

# 将 IP 转换为整数
function ip_to_int() {
    local ip=$1
    local a b c d
    IFS=. read -r a b c d <<< "$ip"
    echo "$((a << 24 | b << 16 | c << 8 | d))"
}

# 将整数转换为 IP
function int_to_ip() {
    local int_ip=$1
    echo "$((int_ip >> 24 & 255)).$((int_ip >> 16 & 255)).$((int_ip >> 8 & 255)).$((int_ip & 255))"
}

function scan_network() {
    local ipzz="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([02468]|[1-9][02468]|1[0-9][02468]|2[0-4][02468]|25[024])/([0-9]|[1-2][0-9]|3[0-2])$"
    while true; do
        read -p "请输入要扫描的网段 (例如 10.22.51.16/28): " input

        if [[ $input =~ $ipzz ]]; then
            ip_part=$(echo "$input" | cut -d'/' -f1)
            cidr_part=$(echo "$input" | cut -d'/' -f2)
            echo && echo_log_info "网段格式正确，开始计算 $input 网段的主机范围..."
            break
        else
            echo "输入的网段格式不正确，请重新输入。"
        fi
    done

    check_packet

    # 计算主机数量
    host_count=$(calc_hosts "$cidr_part")
    echo_log_info "网段中共有 $host_count 个可用主机。"

    # 计算网络地址的整数形式
    network_int=$(ip_to_int "$ip_part")

    # 计算起始IP地址（网络地址 + 1，避免网络地址本身）
    start_ip_int=$((network_int + 1))
    start_ip=$(int_to_ip "$start_ip_int")

    # 计算结束IP地址（起始IP + 主机数量）
    end_ip_int=$((network_int + host_count))
    end_ip=$(int_to_ip "$end_ip_int")

    echo_log_info "扫描的主机范围从 $start_ip 到 $end_ip。"

    echo "开始扫描 $input 网段，从 $start_ip 到 $end_ip..." > "$output_file"
    echo | tee -a $output_file


    temp_lock=$(mktemp)   # 创建临时锁文件

    export -f scan_ip     # 导出 scan_ip 函数供 parallel 使用
    export -f int_to_ip   # 导出 int_to_ip 函数供 parallel 使用
    
    # 使用 GNU Parallel 执行扫描
    seq "$start_ip_int" "$end_ip_int" | parallel --will-cite -j 10 scan_ip {} "$output_file" "$temp_lock"

    rm -f $temp_lock

    echo && echo_log_info "扫描完成。所有在线IP的端口扫描结果已保存到 $output_file，并在上方打印。"
}

# 扫描IP地址并检测开放端口的函数
scan_ip() {
    local current_ip_int=$1
    local current_ip=$(int_to_ip $current_ip_int)
    local output_file=$2
    local temp_lock=$3
    temp_file=$(mktemp)
    trap 'rm -f $temp_file' EXIT  # 保证退出时删除临时文件

    # 检查IP是否在线
    if ping -c 3 -W 5 "$current_ip" &> /dev/null; then
        echo "$current_ip 在线，正在检测所有端口..." | tee -a "$temp_file"
        # 扫描所有端口
        local scan_result=$(nmap -p- --open -T4 --host-timeout 10s "$current_ip" | awk 'BEGIN {printf "%-13s %-8s %-15s\n", "PORT", "STATE", "SERVICE"} /^[0-9]+\/tcp/ {printf "%-13s %-8s %-15s\n", $1, $2, $3}')
        if [[ "$scan_result" =~ "tcp" ]]; then
            echo "$scan_result" >> "$temp_file"
        else
            echo "检测不到任何端口，可能被拦截了." >> "$temp_file"
        fi
    else
        echo "$current_ip 不在线." | tee -a "$temp_file"
    fi
    echo >> "$temp_file"
    flock $temp_lock -c "cat '$temp_file' >> '$output_file'"    # 使用flock确保只有一个进程写入并插入空行
}

scan_network