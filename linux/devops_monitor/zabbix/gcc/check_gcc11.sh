#!/bin/bash

echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2  # 移出颜色和日志级别参数

    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

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


check_gcc11() {
    if command -v gcc &>/dev/null; then
        GCC_VERSION=$(gcc -dumpversion | cut -d. -f1)
        if [ "$GCC_VERSION" -eq 11 ]; then
            echo_log_info "GCC 11 已安装"
            return 0
        else
            echo_log_warn "GCC 版本为 $GCC_VERSION，非 11"
            return 1
        fi
    else
        echo_log_warn "GCC 未安装"
        return 2
    fi
}


check_gcc11