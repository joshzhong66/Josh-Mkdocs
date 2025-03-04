#!/usr/bin/env bash
set -o errexit      # 任一命令返回非零状态（即出现错误）时，脚本会立即退出
set -o nounset      # 使用了未定义的变量，立即报错并退出
set -o pipefail     # 启用 pipefail 后，只要管道中任一命令失败，整个管道就会返回失败状态

# ------------------------- 可配置参数 -------------------------
LOG_DIR="/var/log/monitor"
MAX_LOG_DAYS=7
NET_INTERFACE="eth0"
TOP_PROCESS_LIMIT=5
# -------------------------------------------------------------

# 初始化日志文件
LOG_FILE="${LOG_DIR}/system_monitor_$(date +%Y%m%d).log"
readonly TIMESTAMP=$(date -Iseconds)

# 颜色定义
readonly COLOR_RED="\033[31m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_YELLOW="\033[33m"
readonly COLOR_RESET="\033[0m"

# ------------------------- 工具函数 -------------------------
init_logging() {
    mkdir -p "${LOG_DIR}"
    find "${LOG_DIR}" -name "system_monitor_*.log" -mtime +${MAX_LOG_DAYS} -delete
}

log_failure() {
    local message="$1"
    echo -e "${COLOR_RED}[错误] ${TIMESTAMP} - ${message}${COLOR_RESET}" >&2
    echo "[错误] ${TIMESTAMP} - ${message}" >> "${LOG_FILE}"
    exit 1
}

validate_tools() {
    local required_tools=("netstat" "iostat" "ps" "bc")
    for tool in "${required_tools[@]}"; do
        if ! command -v "${tool}" >/dev/null 2>&1; then
            log_failure "缺少必要工具: '${tool}'!"
        fi
    done
}

# ------------------------- 监控指标采集函数 -------------------------
get_tcp_stats() {
    netstat -ant \
        | awk '/^tcp/ {
            state[$6]++
            if ($6 == "ESTABLISHED") established++
        } END {
            printf "total_connections=%d\n", NR
            for (s in state) printf "tcp_state_%s=%d\n", tolower(s), state[s]
        }'
}

get_disk_io() {
    iostat -dx 1 2 \
        | awk '/^Device/ {header=1; next} 
            header && NF>0 {
                printf "disk_read=%s\n", $4
                printf "disk_write=%s\n", $5
                exit
            }'
}

get_network_io() {
    # 修复点：精确计算网络流量
    local rx1 tx1 rx2 tx2
    rx1=$(awk -v iface="${NET_INTERFACE}" '$0 ~ iface ":" {print $2}' /proc/net/dev)
    tx1=$(awk -v iface="${NET_INTERFACE}" '$0 ~ iface ":" {print $10}' /proc/net/dev)
    sleep 1
    rx2=$(awk -v iface="${NET_INTERFACE}" '$0 ~ iface ":" {print $2}' /proc/net/dev)
    tx2=$(awk -v iface="${NET_INTERFACE}" '$0 ~ iface ":" {print $10}' /proc/net/dev)
    
    # 确保数值有效性
    rx1=${rx1:-0}; tx1=${tx1:-0}; rx2=${rx2:-0}; tx2=${tx2:-0}
    
    echo "rx_rate=$(echo "scale=2; ($rx2 - $rx1)/1024" | bc)"
    echo "tx_rate=$(echo "scale=2; ($tx2 - $tx1)/1024" | bc)"
}

get_system_stats() {
    # 修复点：兼容不同格式的top输出
    local cpu_line=$(top -bn1 | grep "Cpu(s)")
    local cpu_idle=$(echo "${cpu_line}" | awk -F '[ %]+' '
        {
            for(i=1;i<=NF;i++) {
                if ($i ~ /id/) {
                    sub(/%/, "", $(i-1))
                    print $(i-1)
                    exit
                }
            }
        }'
    )
    # 处理空值
    cpu_idle=${cpu_idle:-100}
    local cpu_usage=$(echo "100 - ${cpu_idle}" | bc)
    
    local mem_info=$(free -m | awk '/Mem/ {printf "mem_used=%d\nmem_total=%d\n", $3,$2}')
    
    cat <<EOF
cpu_usage="${cpu_usage}"
${mem_info}
load_avg="$(awk '{print $1,$2,$3}' /proc/loadavg)"
EOF
}

get_top_processes() {
    echo "类型 PID   PPID 用户     CPU% 内存% 命令行"
    ps -eo pid,ppid,user,%cpu,%mem,args --sort=-%cpu \
        | head -n $((TOP_PROCESS_LIMIT + 1)) \
        | awk -v limit=${TOP_PROCESS_LIMIT} '
            NR == 1 {next}
            NR <= limit+1 {
                printf "CPU %-5s %-5s %-8s %-5s %-5s %s\n", $1,$2,$3,$4,$5,$6
            }'

    ps -eo pid,ppid,user,%cpu,%mem,args --sort=-%mem \
        | head -n $((TOP_PROCESS_LIMIT + 1)) \
        | awk -v limit=${TOP_PROCESS_LIMIT} '
            NR == 1 {next}
            NR <= limit+1 {
                printf "MEM %-5s %-5s %-8s %-5s %-5s %s\n", $1,$2,$3,$4,$5,$6
            }'
}

# ------------------------- 主逻辑 -------------------------
main() {
    init_logging
    validate_tools

    {
        echo "===== 系统监控报告 @ ${TIMESTAMP} ====="
        
        # TCP 状态
        declare -A tcp_stats
        while IFS='=' read -r key value; do
            tcp_stats[$key]=$value
        done <<< "$(get_tcp_stats)"
        echo "[网络] 已建立连接: ${tcp_stats[tcp_state_established]}"
        echo "[网络] 监听端口: ${tcp_stats[tcp_state_listen]}"
        
        # 系统资源
        eval "$(get_system_stats)"
        echo "[CPU] 使用率: ${cpu_usage}%"
        echo "[内存] 已用: ${mem_used}MB / 总量: ${mem_total}MB"
        echo "[负载] 平均值: ${load_avg}"

        # 磁盘IO
        source <(get_disk_io)
        echo "[磁盘] 读取: ${disk_read}KB/s, 写入: ${disk_write}KB/s"

        # 网络IO
        source <(get_network_io)
        printf "[网络] 接收: %.2fKB/s, 发送: %.2fKB/s\n" "${rx_rate}" "${tx_rate}"

        # 进程信息
        echo "[进程] 资源消耗前 ${TOP_PROCESS_LIMIT} 名:"
        get_top_processes | column -t

        echo "================================================"
    } | tee -a "${LOG_FILE}" | awk '
        { 
            gsub(/$$.*$$/, "\033[34m&\033[0m"); 
            gsub(/[0-9]+\.[0-9]+%/, "\033[33m&\033[0m");
            print 
        }
    '
}

trap 'log_failure "脚本被信号中断"' SIGINT SIGTERM
main