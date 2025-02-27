# 通用日志函数
echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2  # 移出颜色和日志级别参数

    # 组装带颜色的日志前缀
    local timestamp
    timestamp=$(date +'%F %T')
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

    # 输出带格式的日志
    echo -e "${log_prefix} $*"
}

# 信息日志（绿色）
echo_log_info() {
    echo_log "32" "INFO" "$@"
}

# 警告日志（黄色）
echo_log_warn() {
    echo_log "33" "WARN" "$@"
}

# 错误日志（红色）
echo_log_error() {
    echo_log "31" "ERROR" "$@"
    exit 1  # 可根据需要决定是否退出
}

# 成功日志（绿色加粗）
echo_log_success() {
    echo_log "1;32" "SUCCESS" "$@"
}

# 标题日志（蓝色加粗）
echo_log_header() {
    echo_log "1;34" "HEADER" "$@"
}