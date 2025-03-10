#!/bin/bash

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

# 检测&安装依赖函数
check_dependencies_packages() {
    local pkg_manager=$1  # 接收包管理器命令
    shift                 # 移除第一个参数，剩余为包列表
    local packages=("$@") # 所有包存入数组
    local installed=()    # 已安装的包
    local to_install=()   # 待安装的包
    
    
    local check_cmd       # 检查包命令（根据发行版选择检测方式）

    case "$ID" in
        debian|ubuntu)
            check_cmd="dpkg -s"  # 使用dpkg检测.deb包
            ;;
        *)
            check_cmd="rpm -q"   # 使用rpm检测.rpm包
            ;;
    esac

    # 检测已安装的包
    for pkg in "${packages[@]}"; do
        if $check_cmd "$pkg" &>/dev/null; then
            installed+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done

    # 显示已安装信息
    if [ ${#installed[@]} -gt 0 ]; then
        echo_log_info "已安装的包: ${installed[*]}"
    fi

    # 安装缺失的包
    if [ ${#to_install[@]} -gt 0 ]; then
        echo_log_info "正在安装: ${to_install[*]}"
        if ! $pkg_manager install -y "${to_install[@]}" >/dev/null; then
            echo_log_error "安装失败: ${to_install[*]}"
            return 1
        fi
        echo_log_info "安装完成: ${to_install[*]}"
    else
        echo_log_info "所有依赖已安装"
    fi
}

# 安装系统依赖
install_dependencies() {
    echo_log_info "检测系统环境，安装依赖..."
    
    # 加载系统信息
    if ! . /etc/os-release; then
        echo_log_error "无法获取系统信息"
        return 1
    fi

    echo_log_info "检测到系统ID：$ID"

    # 定义基础工具包
    local base_packages=(wget tar gzip curl)

    case "$ID" in
        debian|ubuntu)
            echo_log_info "更新软件源..."
            if ! apt-get update >/dev/null; then
                echo_log_error "软件源更新失败"
                return 1
            fi
            export DEBIAN_FRONTEND=noninteractive
            check_dependencies_packages "apt-get" "${base_packages[@]}"
            ;;
        centos|rhel|fedora|amzn)
            if command -v dnf >/dev/null; then
                check_dependencies_packages "dnf" "${base_packages[@]}"
            else
                check_dependencies_packages "yum" "${base_packages[@]}"
            fi
            ;;
        *)
            echo_log_error "不支持的发行版: $ID"
            return 1
            ;;
    esac
}


# # 主执行流程
# if install_dependencies; then
#     echo_log_info "依赖安装完成"
# else
#     echo_log_error "依赖安装失败"
#     exit 1
# fi

install_dependencies