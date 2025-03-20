#!/bin/bash

REPO_FILE="/etc/yum.repos.d/CentOS-SCLo-scl.repo"
TEMP_BACKUP_DIR=$(mktemp -d)
GCC_BACKUP_PATH="$TEMP_BACKUP_DIR/gcc-4.8.5"
GXX_BACKUP_PATH="$TEMP_BACKUP_DIR/g++-4.8.5"
DEVTOOLSET_VERSION="11"


echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2  # 移出颜色和日志级别参数

    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

    echo -e "${log_prefix} $*"
}
echo_log_info() {
    echo_log "32" "INFO" "$@"
}
echo_log_warn() {
    echo_log "33" "WARN" "$@"
}
echo_log_error() {
    echo_log "31" "ERROR" "$@"
    exit 1  # 可根据需要决定是否退出
}

# 清理函数
cleanup() {
    if [[ -d "$TEMP_BACKUP_DIR" ]]; then
        rm -rf "$TEMP_BACKUP_DIR"
    fi
}

# 错误处理函数
die() {
    echo_log_error "$@"
    cleanup
    exit 1
}

# 验证用户权限
check_root() {
    [[ $EUID -eq 0 ]] || die "必须使用 root 权限执行此脚本"
}

# 配置仓库
configure_repo() {
    echo_log_info "开始配置 SCLo 仓库"
    
    if [[ -f "$REPO_FILE" ]]; then
        echo_log_warn "仓库文件已存在，跳过创建"
        return 0
    fi

    cat > "$REPO_FILE" <<'EOF'
[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo
baseurl=http://mirrors.aliyun.com/centos/7/sclo/x86_64/rh/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
EOF

    [[ $? -eq 0 ]] || die "仓库文件创建失败"
    echo_log_info "SCLo 仓库配置完成"
}

# 验证仓库有效性
validate_repo() {
    echo_log_info "验证仓库状态"
    if ! yum repolist enabled | grep -q 'centos-sclo-sclo'; then
        die "SCLo 仓库未正确启用"
    fi
}

# 安装开发工具集
install_devtoolset() {
    echo_log_info "开始安装 devtoolset-${DEVTOOLSET_VERSION}"
    
    if rpm -q "devtoolset-${DEVTOOLSET_VERSION}-gcc" &>/dev/null; then
        echo_log_warn "devtoolset-${DEVTOOLSET_VERSION} 已安装，跳过操作"
        return 0
    fi

    yum clean all >/dev/null 2>&1 || die "清理缓存失败"
    yum makecache >/dev/null 2>&1 || die "生成缓存失败"
    
    yum install -y "devtoolset-${DEVTOOLSET_VERSION}-gcc*" || die "安装 devtoolset 失败"
    
    if ! rpm -qa | grep -q "devtoolset-${DEVTOOLSET_VERSION}-gcc"; then
        die "devtoolset 安装验证失败"
    fi
    echo_log_info "devtoolset-${DEVTOOLSET_VERSION} 安装完成"
}

# 安全替换编译器
replace_compiler() {
    local compiler_path="/opt/rh/devtoolset-${DEVTOOLSET_VERSION}/root/bin"
    
    echo_log_info "开始配置编译器"
    [[ -f "$compiler_path/gcc" ]] || die "gcc 二进制文件不存在"
    [[ -f "$compiler_path/g++" ]] || die "g++ 二进制文件不存在"

    # 备份原文件
    if [ ! -f /usr/bin/gcc ]; then
        echo_log_info "gcc 文件不存在，无需备份."
    else
        mv /usr/bin/gcc "$GCC_BACKUP_PATH"
        mv /usr/bin/g++ "$GXX_BACKUP_PATH"
    fi
    
    
    # 创建符号链接
    ln -sf "$compiler_path/gcc" /usr/bin/gcc || die "gcc 链接创建失败"
    ln -sf "$compiler_path/g++" /usr/bin/g++ || die "g++ 链接创建失败"
    
    echo_log_info "编译器配置完成"
}

# 验证版本
validate_version() {
    local version
    version=$(gcc --version | awk '/gcc/ {print $4}')
    
    if [[ "$version" != "${DEVTOOLSET_VERSION}.*" ]]; then
        echo_log_warn "当前 GCC 版本: $version"
        #die "GCC 版本未正确切换"
    fi
    echo_log_info "GCC 版本验证通过: $version"
}


# 主执行流程
main() {
    trap cleanup EXIT
    check_root
    configure_repo
    validate_repo
    install_devtoolset
    replace_compiler
    validate_version
    echo_log_info "所有操作已完成"
}

main