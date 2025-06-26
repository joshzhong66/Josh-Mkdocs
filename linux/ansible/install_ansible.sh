#!/bin/bash
#
#
# 官网下载：http://mirrors.sunline.cn/source/ansible/ansible-2.14.4.tar.gz
# 公司资源：https://github.com/ansible/ansible/archive/refs/tags/v2.18.1.tar.gz
#
#
#
PACKAGE_NAME="ansible"
ANSIBLE_VERSION="2.14.4"
ANSIBLE_TAR="ansible-${ANSIBLE_VERSION}.tar.gz"
DOWN_DIR="/usr/local/src"
INSTALL_DIR="/usr/local/ansible"
WORK_DIR="/data/ansible"
INTERNAL_ANSIBLE_URL="http://mirrors.sunline.cn/source/ansible/${ANSIBLE_TAR}"
EXTERNAL_ANSIBLE_URL="https://github.com/ansible/ansible/archive/refs/tags/v${ANSIBLE_TAR}"

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

quit() {
    echo_log_info "退出脚本!"
}

check_url() {
    local url=$1
    if curl -f -s --connect-timeout 5 "$url" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_package() {
    if [ -d "$INSTALL_DIR" ]; then
        echo_log_error "安装目录 '$INSTALL_DIR' 已存在. 请先卸载 $PACKAGE_NAME 然后再继续！"
    elif which $PACKAGE_NAME &>/dev/null; then
        echo_log_error "$PACKAGE_NAME 已安装。请在安装新版本之前将其卸载！"
    fi

    if ! which python3 &>/dev/null; then
        echo_log_error "未安装 Python 3。请先安装 Python 3！"
    fi
    return 0
}



download_ansible() {
    for url in "$INTERNAL_ANSIBLE_URL" "$EXTERNAL_ANSIBLE_URL"; do
        if check_url "$url"; then
            echo_log_info "从 $url 下载 ansible 源包..."
            wget -P "$DOWN_DIR" "$url" &>/dev/null && {
                echo_log_info "$ANSIBLE_TAR 下载成功"
                return 0
            }
            echo_log_error "$url 下载失败..."
        else
            echo_log_warn "$url 无效"
        fi
    done
    echo_log_error "两个下载链接均无效，下载失败！！"
    return 1
}

install_ansible() {
    check_package

    if [ -f "$DOWN_DIR/$ANSIBLE_TAR" ]; then
        echo_log_info "Ansible 源包已经存在！"
    else
        echo_log_info "开始下载 Ansible 源包..."
        download_ansible
    fi

    yum install -y sshpass >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "依赖项安装成功..." || echo_log_error "依赖项安装失败..."

    tar -xzf "$DOWN_DIR/$ANSIBLE_TAR" -C $DOWN_DIR >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "成功解压 Ansible 源码包……" || echo_log_error "解压 Ansible 源码包失败……"
    
    mv "$DOWN_DIR/ansible-${ANSIBLE_VERSION}"  $INSTALL_DIR

    cd $INSTALL_DIR
    python3 -m venv venv && source venv/bin/activate
    [ $? -eq 0 ] && echo_log_info "成功创建Python虚拟环境" || echo_log_error "无法创建 Python 虚拟环境"

    [ ! -d "/root/.pip" ] && mkdir -p /root/.pip
    cat > /root/.pip/pip.conf <<'EOF'
[global]
timeout = 10
index-url =  http://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com

[install]
trusted-host=
    mirrors.aliyun.com
EOF

    unset http proxy && unset https proxy
    pip install -r requirements.txt &>/dev/null
    echo_log_info "开始构建 ansible"

    python setup.py build &>/dev/null && 
     &>/dev/null
    [ $? -eq 0 ] && echo_log_info "构建 ansible 成功" || echo_log_error "构建 ansible 失败"

    echo_log_info "创建ansible配置文件目录 $WORK_DIR/bin" && mkdir -p "$WORK_DIR/bin"
    echo_log_info "复制 bin 目录" && cp $INSTALL_DIR/venv/bin/ansible* $WORK_DIR/bin >/dev/null 2>&1

    cat > $WORK_DIR/ansible.cfg <<EOF
[defaults]
interpreter_python = auto_legacy_silent
inventory = $WORK_DIR/hosts
remote_tmp = \$HOME/.ansible/tmp
local_tmp = \$HOME/.ansible/tmp
remote_user = root
forks = 5
host_key_checking = False
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[inventory]
enable_plugins = host_list, script, yaml, ini
EOF
    [ $? -eq 0 ] && echo_log_info "复制 ansible.cfg 成功" || echo_log_error "复制 ansible.cfg 失败"

    if ! grep -q "ANSIBLE_HOME=" /etc/profile; then
        echo_log_info "配置ansible环境变量"
        cat >> /etc/profile <<EOF
# ansible
export ANSIBLE_HOME=${WORK_DIR}
export PATH=\$PATH:\$ANSIBLE_HOME/bin
export ANSIBLE_CONFIG=\$ANSIBLE_HOME/ansible.cfg
EOF
    fi
    source /etc/profile

    echo_log_info "显示 Ansible 版本 $(ansible --version 2>/dev/null | head -n1 | awk '{print $NF}' | awk -F] '{print $1}')"

    rm -rf $DOWN_DIR/ansible*
}

uninstall_ansible() {
    if [ -d "${INSTALL_DIR}" ]; then
        echo_log_info "Ansible 安装完毕，开始卸载……"
        rm -rf ${INSTALL_DIR} && rm -rf $WORK_DIR
        rm -f /root/.pip
        echo_log_info "成功卸载 Ansible"
        sed -i '/# ansible/,/ansible.cfg/d' /etc/profile
        source /etc/profile
    else
        echo_log_warn "Ansible 未安装..."
    fi
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m Ansible${ANSIBLE_VERSION} Install Tool\033[0m
———————————————————————————
1. 安装 Ansible${ANSIBLE_VERSION}
2. 卸载 Ansible${ANSIBLE_VERSION}
3. 退出脚本\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_ansible) ;;
    2) (uninstall_ansible) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main