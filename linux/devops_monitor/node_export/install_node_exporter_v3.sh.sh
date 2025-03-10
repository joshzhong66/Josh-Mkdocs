#!/bin/bash
#
#
# 官方下载地址：https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
# SHA256值地址获取：https://github.com/prometheus/node_exporter/releases/download/v1.8.1/sha256sums.txt
#
# ubuntu使用                bash ./脚本名.sh
# centos使用sh或bash都行    ./脚本名.sh

# 定义全局变量
DEFAULT_VERSION="1.8.1"
PACKAGE_NAME="node_exporter"
INSTALL_PATH="/usr/local/node_exporter"
DOWNLOAD_PATH="/usr/local/src"
SYSTEMD_PATH="/etc/systemd/system/node_exporter.service"
ENV_FILE="/etc/profile.d/node_exporter.sh"


# 引入日志函数
#source ./logging.sh

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

check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then  # 使用curl检查URL，超时5秒
        return 0  # URL可用
    else
        return 1  # URL不可用
    fi
}

check_package() {
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "安装目录 '$INSTALL_PATH' 已存在. 请先卸载 $PACKAGE_NAME 然后再继续！"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME 已安装。请在安装新版本之前将其卸载！"
    fi
}

# 检测&安装依赖函数
check_dependencies_packages() {
    local pkg_manager=$1  # 接收包管理器命令
    shift                 # 移除第一个参数，剩余为包列表
    local packages=("$@") # 所有包存入数组
    local installed=()    # 已安装的包
    local to_install=()   # 待安装的包

    # 检测已安装的包 (RPM系)
    for pkg in "${packages[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
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
            check_dependencies_packages "DEBIAN_FRONTEND=noninteractive apt-get" "${base_packages[@]}"
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



# 获取CHECKSUM_MAP值
get_expected_checksum() {
    local version=$1
    local os_type="linux"  # 根据实际需要可扩展其他系统
    local arch

    # 自动检测系统架构
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)       echo_log_error "不支持的架构: $(uname -m)"; return 1 ;;
    esac

    # 构造文件名
    local filename="node_exporter-${version}.${os_type}-${arch}.tar.gz"

    # 动态获取校验文件
    local checksum_url="https://github.com/prometheus/node_exporter/releases/download/v${version}/sha256sums.txt"
    if ! tmpfile=$(mktemp); then
        echo_log_error "无法创建临时文件"
        return 2
    fi

    # 下载校验文件（带重试机制）
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

    # 提取校验码
    if ! checksum=$(grep -F "$filename" "$tmpfile" | awk '{print $1}'); then
        echo_log_error "未找到 ${filename} 的校验码"
        rm -f "$tmpfile"
        return 4
    fi

    # 清理并返回
    rm -f "$tmpfile"
    echo "$checksum"
}


check_version_exists() {
    local version=$1
    echo_log_info "正在验证版本 v${version} 是否存在..."
    
    # 检查GitHub Release标签
    if ! curl -sSLI -o /dev/null -w "%{http_code}" "https://github.com/prometheus/node_exporter/releases/tag/v${version}" | grep -q 200; then
        echo_log_error "版本 v${version} 不存在于官方仓库"
        return 2
    fi
    echo_log_info "版本 v${version} 存在于官方仓库"
}


download_package() {
    version=$1
    arch=$2
    tar_name="node_exporter-${version}.linux-${arch}.tar.gz"
    archive_dir="node_exporter-${version}.linux-${arch}"
    
    
    # 打印 version 以便调试
    echo_log_info "传递给 download_package 的版本号: ${version}"
    # 生成动态URL
    local internal_base="http://10.22.51.64/5_Linux/监控系统"
    local internal_url="${internal_base}/${tar_name}"
    local external_url="https://github.com/prometheus/node_exporter/releases/download/v${version}/${tar_name}"

    # 版本存在性检查，确保版本号正确传递到 check_version_exists
    if [[ -z "$version" ]]; then
        echo_log_error "版本号为空，无法进行验证"
        return 1
    fi

    check_version_exists "$version" || return $?


    # 动态获取校验码
    local expected_checksum
    if ! expected_checksum=$(get_expected_checksum "$version"); then
        return $?  # 传递错误代码
    fi

    # 下载逻辑
    echo_log_info "尝试下载安装包..."
    if check_url "$internal_url"; then
        echo_log_info "从内网下载: $internal_url"
        # 使用wget下载，失败后尝试curl
        if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
            echo_log_warn "wget下载失败，尝试使用curl..."
            if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$internal_url"; then
                echo_log_error "内网下载失败"
                return 3
            fi
        fi
    else
        echo_log_warn "内网不可达，尝试外网下载: $external_url"
        # 使用wget下载，失败后尝试curl
        if ! wget -q -O "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
            echo_log_warn "wget下载失败，尝试使用curl..."
            if ! curl -sSL -o "${DOWNLOAD_PATH}/${tar_name}" "$external_url"; then
                echo_log_error "外网下载失败"
                return 4
            fi
        fi
    fi
    
    # 验证文件完整性
    local actual_checksum
    actual_checksum=$(sha256sum "${DOWNLOAD_PATH}/${tar_name}" | awk '{print $1}')
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo_log_error "文件校验失败，预期: ${expected_checksum}，实际: ${actual_checksum}"
        return 5
    fi
}


install_node_exporter() {
    local package_name="Node Exporter"
    local service_name="node_exporter.service"
    local systemd_service_path="/etc/systemd/system/${service_name}"
    # 获取版本号
    read -rp "请输入Node Exporter版本（回车使用默认值 ${DEFAULT_VERSION}）: " version
    version=${version:-$DEFAULT_VERSION}
    version=${version#v}  # 兼容v前缀
    
    # 验证版本格式
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo_log_error "无效的版本格式，请使用数字格式如：1.8.1"
        return 1
    fi

    # 检测系统架构
    local arch
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)
            echo_log_error "不支持的架构: $(uname -m)"
            return 5
            ;;
    esac

    
    echo_log_info "开始安装 ${PACKAGE_NAME} v${version}"

    # 安装依赖
    install_dependencies

    # 预检验证
    _precheck() {
        # 检查现有安装
        if [ -d "${INSTALL_PATH}" ]; then
            echo_log_warn "检测到已存在的安装目录: ${INSTALL_PATH}"
            read -rp "是否强制覆盖？(y/n) " force_install
            if [[ "${force_install}" != "y" ]]; then
                return 12
            fi

            # 停止旧服务
            if systemctl is-active --quiet "$service_name"; then
                echo_log_info "停止运行中的服务..."
                systemctl stop "$service_name" || {
                    echo_log_error "无法停止服务，请手动检查"
                    return 13
                }
            fi

            # 删除旧目录
            echo_log_info "清理旧安装目录..."
            rm -rf "${INSTALL_PATH}" || {
                echo_log_error "目录删除失败: ${INSTALL_PATH}"
                return 14
            }

            # 清理旧配置文件
            if [ -f "$systemd_service_path" ]; then
                rm -f "$systemd_service_path" || {
                    echo_log_error "服务文件删除失败: $systemd_service_path"
                    return 15
                }
            fi
        fi

        # 检查依赖命令
        local cmds=(tar curl systemctl)
        for cmd in "${cmds[@]}"; do
            if ! command -v "$cmd" >/dev/null; then
                echo_log_error "依赖命令缺失: $cmd"
                return 16
            fi
        done
    }

    # 解压文件
    _setup_files() {
        # 解压文件
        if ! tar -zxf "${DOWNLOAD_PATH}/${tar_name}" -C "${DOWNLOAD_PATH}"; then
            echo_log_error "文件解压失败"
            return 15
        fi

        # 创建安装目录
        mkdir -p "${INSTALL_PATH}" || {
            echo_log_error "创建目录失败: ${INSTALL_PATH}"
            return 16
        }

        # 移动文件（保留原始权限）
        if ! cp -rp "${DOWNLOAD_PATH}/${archive_dir}/"* "${INSTALL_PATH}"; then
            echo_log_error "文件移动失败"
            return 17
        fi
    }

    # 用户和权限管理
    _setup_permissions() {
        # 创建系统用户
        if ! id prometheus &>/dev/null; then
            if ! useradd -r -s /sbin/nologin prometheus; then
                echo_log_error "创建用户失败"
                return 18
            fi
            echo_log_info "已创建系统用户: prometheus"
        fi

        # 设置目录权限
        if ! chown -R prometheus:prometheus "${INSTALL_PATH}"; then
            echo_log_error "设置目录权限失败"
            return 19
        fi

        if ! chmod 755 "${INSTALL_PATH}/node_exporter"; then
            echo_log_error "设置可执行权限失败"
            return 20
        fi
    }

    # 环境配置
    _setup_environment() {
        # 写入环境变量
        local env_file="/etc/profile.d/node_exporter.sh"
        local timestamp=$(date +%Y%m%d%H%M%S)

        # 删除旧文件
        if [ -f "$env_file" ]; then
            echo_log_warn "删除旧环境变量文件: ${env_file}"
            rm -f "$env_file" || {
                echo_log_error "删除失败"
                return 21
            }
        fi

        cat <<EOF > "$env_file" || return 22
# Node Exporter ${version}
export NODE_EXPORTER_HOME="${INSTALL_PATH}"
export PATH="\${NODE_EXPORTER_HOME}:\${PATH}"
EOF

        # 立即生效环境变量
        if ! source "$env_file"; then
            echo_log_warn "环境变量立即生效失败，需要重新登录"
        fi
    }

    # 服务管理
    _setup_service() {
        # 生成服务文件
        cat <<EOF > "$systemd_service_path" || return 23
[Unit]
Description=Node Exporter ${version}
Documentation=https://prometheus.io/docs/guides/node-exporter/
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecStart=${INSTALL_PATH}/node_exporter
Restart=on-failure
RestartSec=5s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

        # 设置文件权限
        chmod 644 "$systemd_service_path" || return 24

        # 重载系统守护进程
        if ! systemctl daemon-reload; then
            echo_log_error "systemd 配置重载失败"
            return 25
        fi

        # 启动服务
        if ! systemctl start "$service_name"; then
            echo_log_error "服务启动失败"
            return 26
        fi

        # 验证服务状态
        if ! systemctl is-active --quiet "$service_name"; then
            echo_log_error "服务未正常运行"
            return 27
        fi

        # 设置开机启动
        if ! systemctl enable "$service_name" >/dev/null 2>&1; then
            echo_log_error "设置开机启动失败"
            return 28
        fi
    }

    # 安装后验证
    _postcheck() {
        # 验证可执行文件
        if ! command -v node_exporter >/dev/null 2>&1; then
            echo_log_error "可执行文件未找到"
            return 29
        fi

        # 验证版本信息
        local installed_version

        # 修改版本提取逻辑
        installed_version=$(node_exporter --version 2>&1 | awk -F'[ ,]+' '/^node_exporter, version/{gsub("v", "", $3); print $3}')
        expected_version="${version}"

        # 比较时使用标准化版本
        if [[ "$installed_version" != "$expected_version" ]]; then
            echo_log_error "版本不匹配，预期: ${expected_version}，实际: ${installed_version}"
            return 30
        fi

        # 验证端口监听
        if ! ss -tulnp | grep -q ':9100'; then
            echo_log_error "未检测到端口 9100 监听"
            return 31
        fi
    }

    # 获取本机有效IP地址
    _get_access_ip() {
        local ip
        # 优先级1: 通过默认路由获取网卡IP
        local interface=$(ip route get 1 2>/dev/null | awk '{print $5; exit}')
        if [ -n "$interface" ]; then
            ip=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        fi

        # 优先级2: 获取 eth0 的IP（兼容传统环境）
        if [ -z "$ip" ]; then
            ip=$(ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        fi

        # 优先级3: 获取第一个非回环地址
        if [ -z "$ip" ]; then
            ip=$(hostname -I | awk '{print $1}')
        fi

        # 最终回退到 localhost
        echo "${ip:-localhost}"
    }

    ##############################
    ### 主流程开始 ###
    ##############################
    echo_log_header "开始安装 ${package_name} ${version}"

    # 步骤执行链
    local rc=0
    _precheck || rc=$?
    [ $rc -eq 0 ] && download_package "$version" "$arch" || rc=$?
    [ $rc -eq 0 ] && _setup_files || rc=$?
    [ $rc -eq 0 ] && _setup_permissions || rc=$?
    [ $rc -eq 0 ] && _setup_environment || rc=$?
    [ $rc -eq 0 ] && _setup_service || rc=$?
    [ $rc -eq 0 ] && _postcheck || rc=$?


    # 在安装成功提示中调用
    if [ $rc -eq 0 ]; then
        local access_ip=$(_get_access_ip)
        echo_log_success "安装成功完成"
        echo_log_info "访问地址: http://${access_ip}:9100/metrics"
        return 0
    else
        echo_log_error "安装过程在步骤 $rc 失败"
        return $rc
    fi
}



uninstall_node_exporter() {
    # 定义局部变量避免污染全局空间
    local package_name="Node Exporter"
    local service_name="node_exporter.service"
    local systemd_service_path="/etc/systemd/system/${service_name}"
    
    # 状态标志变量
    local is_installed=0
    
    # 检查是否通过二进制文件安装
    if command -v node_exporter >/dev/null 2>&1; then
        is_installed=1
        echo_log_info "检测到 ${package_name} 可执行文件"
    fi
    
    # 检查安装目录是否存在
    if [ -d "${INSTALL_PATH}" ]; then
        is_installed=1
        echo_log_info "检测到安装目录：${INSTALL_PATH}"
    fi
    
    # 检查下载文件是否存在
    if [ -f "${DOWNLOAD_PATH}/${TAR_NAME}" ]; then
        is_installed=1
        echo_log_info "检测到安装包：${DOWNLOAD_PATH}/${TAR_NAME}"
    fi
    
    # 如果没有安装迹象则直接返回
    [ "${is_installed}" -eq 0 ] && [ ! -f "${systemd_service_path}" ] && {
        echo_log_error "未找到 ${package_name} 安装痕迹"
        return 1
    }
    
    # 停止服务逻辑
    _stop_service() {
        if systemctl is-active --quiet "${service_name}"; then
            if ! systemctl stop "${service_name}"; then
                echo_log_error "停止服务失败"
                return 2
            fi
            echo_log_info "服务已停止"
        fi
        
        if systemctl is-enabled --quiet "${service_name}"; then
            if ! systemctl disable "${service_name}" >/dev/null 2>&1; then
                echo_log_error "禁用服务失败"
                return 3
            fi
            echo_log_info "服务已禁用"
        fi
        return 0
    }
    
    # 删除文件逻辑
    _clean_files() {
        # 删除systemd服务文件
        if [ -f "${systemd_service_path}" ]; then
            rm -f "${systemd_service_path}" || {
                echo_log_error "删除服务文件失败: ${systemd_service_path}"
                return 4
            }
            echo_log_info "已删除服务文件: ${systemd_service_path}"
        fi
        
        # 删除安装目录
        if [ -d "${INSTALL_PATH}" ]; then
            rm -rf "${INSTALL_PATH}" || {
                echo_log_error "删除安装目录失败: ${INSTALL_PATH}"
                return 5
            }
            echo_log_info "已删除安装目录: ${INSTALL_PATH}"
        fi
        
        # 删除下载包
        if [ -f "${DOWNLOAD_PATH}/${TAR_NAME}" ]; then
            rm -f "${DOWNLOAD_PATH}/${TAR_NAME}" || {
                echo_log_error "删除安装包失败: ${DOWNLOAD_PATH}/${TAR_NAME}"
                return 6
            }
            echo_log_info "已删除安装包: ${DOWNLOAD_PATH}/${TAR_NAME}"
        fi
        return 0
    }
    
    # 执行卸载流程
    echo_log_info "开始卸载 ${package_name}"
    
    if ! _stop_service; then
        echo_log_error "卸载过程中止：服务操作失败"
        return $?
    fi
    
    if ! _clean_files; then
        echo_log_error "卸载过程中止：文件清理失败"
        return $?
    fi
    
    # 最终验证
    if command -v node_exporter >/dev/null 2>&1 || [ -d "${INSTALL_PATH}" ]; then
        echo_log_error "卸载未完全完成，请手动检查"
        return 7
    fi
    
    echo_log_info "${package_name} 已成功卸载"
    return 0
}


main() {
    clear
    # 定义颜色常量
    local COLOR_BORDER="\033[1;34m"     # 亮蓝色边框
    local COLOR_TITLE="\033[1;37m"      # 亮白色标题
    local COLOR_OPTION="\033[1;33m"     # 黄色选项
    local COLOR_INPUT="\033[1;35m"      # 紫色输入提示
    local COLOR_RESET="\033[0m"         # 重置颜色

    # 动态生成标题
    print_menu_header() {
        echo -e "${COLOR_BORDER}╔════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}"
        echo -e "${COLOR_BORDER}║${COLOR_TITLE}           $PACKAGE_NAME${NODE_VERSION} 管理脚本                                       ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}"
    }

    # 生成菜单选项
    print_menu_body() {
        echo -e "${COLOR_BORDER}║${COLOR_OPTION}  1. 安装 $PACKAGE_NAME${NODE_VERSION}                                                 ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}║${COLOR_OPTION}  2. 卸载 $PACKAGE_NAME${NODE_VERSION}                                                 ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}║${COLOR_OPTION}  3. 退出脚本                                                           ${COLOR_BORDER}║${COLOR_RESET}"
        echo -e "${COLOR_BORDER}╚════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    }


    # 显示完整菜单
    print_menu_header
    print_menu_body

    # 输入提示（带颜色重置）
    echo -en "${COLOR_INPUT}▷▷▷ 请输入操作序号 (1-3): ${COLOR_RESET}"
    read -r num

    # 处理选择
    case "$num" in
        1) install_node_exporter ;;
        2) uninstall_node_exporter ;;
        3) quit ;;
        *) 
            echo -e "${COLOR_INPUT}无效输入，请重新选择！${COLOR_RESET}"
            sleep 1
            main 
            ;;
    esac
}

# 启动主菜单
main