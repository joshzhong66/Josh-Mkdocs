#!/bin/bash


PACKAGE_NAME="zabbix"
VERSION="6.0.4"


get_expected_checksum() {
    local version=$1  # 使用传入的参数

    # 动态获取校验文件
    local checksum_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/${PACKAGE_NAME}-${version}.tar.gz.sha256"
    if ! tmpfile=$(mktemp); then
        echo "无法创建临时文件"
        return 2
    fi

    # 下载校验文件（带重试机制）
    for i in {1..3}; do
        if curl -fsSL -o "$tmpfile" "$checksum_url"; then
            break
        elif [ $i -eq 3 ]; then
            echo "校验文件下载失败: $checksum_url"
            rm -f "$tmpfile"
            return 3
        fi
        sleep 2
    done

    # 读取校验码
    local checksum
    checksum=$(head -n 1 "$tmpfile")

    if [[ -z "$checksum" ]]; then
        echo "无法读取校验码"
        rm -f "$tmpfile"
        return 4
    fi

    # 清理并返回
    rm -f "$tmpfile"
    echo "$checksum"
}

download_package() {
    version=$1
    arch=$2
    tar_name="$PACKAGE_NAME-${version}.tar.gz"
    archive_dir="$PACKAGE_NAME-${version}"

    # 变量检查
    if [[ -z "$DOWNLOAD_PATH" ]]; then
        DOWNLOAD_PATH="/tmp"
    fi

    # 生成动态URL
    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-${version}.tar.gz"

    # 动态获取校验码
    expected_checksum=$(get_expected_checksum "$version")
    if [[ $? -ne 0 || -z "$expected_checksum" ]]; then
        echo_log_error "校验码获取失败，返回错误码: $?"
        return 2
    fi

    # 下载逻辑
    echo_log_info "尝试下载安装包..."
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
    
    # 校验完整性
    actual_checksum=$(sha256sum "${DOWNLOAD_PATH}/${tar_name}" | awk '{print $1}')
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo_log_error "文件校验失败，预期: ${expected_checksum}，实际: ${actual_checksum}"
        return 5
    fi
}
