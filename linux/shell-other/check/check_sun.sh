#!/bin/bash

PACKAGE_NAME="zabbix"
DEFAULT_VERSION="6.0.4"
DOWNLOAD_PATH="/usr/local/src"
VER_URL=https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.4.tar.gz

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

# 成功日志（绿色加粗）
echo_log_success() {
    echo_log "1;32" "SUCCESS" "$@"
}

# 标题日志（蓝色加粗）
echo_log_header() {
    echo_log "1;34" "HEADER" "$@"
}

check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then  # 使用curl检查URL，超时5秒
        return 0  # URL可用
    else
        return 1  # URL不可用
    fi
}

check_version_exists() {
    local version=$1
    echo_log_info "正在验证版本 v${version} 是否存在..."
    
    # 检查GitHub Release标签
    if ! curl -sSLI -o /dev/null -w "%{http_code}" $VER_URL | grep -q 200; then
        echo_log_error "版本 v${version} 不存在于官方仓库"
        return 2
    fi
    echo_log_info "版本 v${version} 存在于官方仓库"
}


# 获取CHECKSUM_MAP值
get_expected_checksum() {
    local version=$1
    local checksum_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz.sha256"

    if ! tmpfile=$(mktemp); then
        echo_log_error "无法创建临时文件"
        return 2
    fi

    for i in {1..3}; do
        if curl -fsSL -o "$tmpfile" "$checksum_url"; then
            break
        elif [ $i -eq 3 ]; then
            echo_log_error "校验文件下载失败: $checksum_url"
            rm -f "$tmpfile"
            return 3
        fi
        sleep 2
    done

    local checksum
    checksum=$(awk '{print $1}' "$tmpfile")  # 直接获取校验值
    rm -f "$tmpfile"

    if [[ -z "$checksum" ]]; then
        echo_log_error "未找到 ${PACKAGE_NAME}-${version}.tar.gz 的校验码"
        return 4
    fi

    echo "$checksum"  # 只返回校验值
    return 0
}


download_package() {
    version=$1
    tar_name="$PACKAGE_NAME-${version}.tar.gz"
    
    echo_log_info "传递给 download_package 的版本号: ${version}"

    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz"

    if [[ -z "$version" ]]; then
       echo_log_error "版本号为空，无法进行验证"
       return 1
    fi

    check_version_exists "$DEFAULT_VERSION" || return $?

    # 获取 SHA256 校验值
    expected_checksum=$(get_expected_checksum "$DEFAULT_VERSION")
    if [[ $? -ne 0 || -z "$expected_checksum" ]]; then
        echo_log_error "无法获取 SHA256 校验值"
        return 6
    fi

    echo "SHA256 预期校验值: $expected_checksum"

    # 下载逻辑
    echo_log_info "尝试下载安装包..."
    if [ ! -f "$DOWNLOAD_PATH/$tar_name" ]; then 
        if check_url "$internal_url"; then
            echo_log_info "从内网下载: $internal_url"
            if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                echo_log_warn "wget下载失败，尝试使用curl..."
                if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                    echo_log_error "内网下载失败"
                    return 3
                fi
            fi
        else
            echo_log_warn "内网不可达，尝试外网下载: $external_url"
            if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                echo_log_warn "wget下载失败，尝试使用curl..."
                if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                    echo_log_error "外网下载失败"
                    return 4
                fi
            fi
        fi
    else
        echo_log_info "$tar_name 已存在，跳过下载"
    fi

    # 验证文件完整性
    local actual_checksum
    actual_checksum=$(sha256sum "${DOWNLOAD_PATH}/${tar_name}" | awk '{print $1}')
    echo_log_info "正在验证文件 ${tar_name} 完整性..."
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo_log_error "文件校验失败，预期: ${expected_checksum}，实际: ${actual_checksum}"
        return 5
    else
        echo_log_success "文件校验通过，校验值: ${actual_checksum}"
    fi
}




download_package $DEFAULT_VERSION

