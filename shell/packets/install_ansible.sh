#!/bin/bash

ANSIBLE_VERSION="2.14.4"
ANSIBLE_TAR="ansible-${ANSIBLE_VERSION}.tar.gz"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/ansible"
INTERNAL_ANSIBLE_URL="http://mirrors.sunline.cn/source/ansible/${ANSIBLE_SOURCE}"
EXTERNAL_ANSIBLE_URL="https://github.com/ansible/ansible/archive/refs/tags/v${ANSIBLE_SOURCE#ansible-}"

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
    exit 1
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
}

quit() {
    echo_log_info "Exit Script!"
}

check_url() {
    local url=$1
    if curl --head --silent --fail "$url" > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_ansible() {
    if [ -d "$INSTALL_DIR" ] || (source /etc/profile && which ansible &>/dev/null) || rpm -qa | grep -q ansible; then
        echo_log_warn "Please uninstall Ansible before installing it!"
    elif source /etc/profile && which python3 &>/dev/null; then
        echo_log_warn "Please install Python3 first!"
    fi
}

download_ansible() {
    for url in "$INTERNAL_ANSIBLE_URL" "$EXTERNAL_ANSIBLE_URL"; do
        if check_url "$url"; then
            echo_log_info "Download ansible source package from $url ..."
            wget -P "$DOWNLOAD_DIR" "$url" &>/dev/null && {
                echo_log_info "$ANSIBLE_TAR Download Success"
                return 0
            }
            echo_log_warn "$url Download failed"
        else
            echo_log_warn "$url invalid"
        fi
    done
    echo_log_error "Both download links are invalid，Download failed！"
    return 1
}

install_ansible() {
    check_ansible

    if [ -f "$DOWNLOAD_DIR/$ANSIBLE_TAR" ]; then
        echo_log_info "Ansible The source package already exists！"
    else
        echo_log_info "Start downloading the Ansible source package..."
        download_ansible
    fi

    yum install -y sshpass >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Dependency installation successful..." || echo_log_error "Failed to install dependencies..."

    tar -xzf "DOWNLOAD_PATH/$ANSIBLE_TAR" -C $DOWNLOAD_PATH && mv $DOWNLOAD_PATH/>/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Unzip the Ansible source package successfully..." || echo_log_error "Failed to unzip the Ansible source package..."
    
    echo_log_info "Create a Python virtual environment"
    cd $INSTALL_PATH
    python3 -m venv venv && source venv/bin/activate

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
    [ $? -eq 0 ] && echo_log_info "Install dependencies successfully" || echo_log_error "Install dependencies failed"

    python setup.py build &>/dev/null && python setup.py install &>/dev/null
    [ $? -eq 0 ] && echo_log_info "Build ansible successfully" || echo_log_error "Building ansible failed"

    echo_log_info "Create ansible configuration file directory $INSTALL_PATH/bin" && mkdir -p "$INSTALL_PATH/bin"
    echo_log_info "Copy the bin directory" && cp $INSTALL_PATH/venv/bin/ansible* $INSTALL_PATH/bin >/dev/null 2>&1

    cat > $INSTALL_DIR/ansible.cfg <<EOF
[defaults]
interpreter_python = auto_legacy_silent
inventory = $INSTALL_DIR/hosts
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

    if ! grep -q "ANSIBLE_HOME=" /etc/profile; then
        echo_log_info "配置 ansible 环境变量"
        cat >> /etc/profile <<EOF
# ansible
export ANSIBLE_HOME=${INSTALL_DIR}
export PATH=\$PATH:\$ANSIBLE_HOME/bin
export ANSIBLE_CONFIG=\$ANSIBLE_HOME/ansible.cfg
EOF
    fi
    source /etc/profile

    echo_log_info "Display Ansible Version $(ansible --version 2>/dev/null | head -n1 | awk '{print $NF}' | awk -F] '{print $1}')"

}

uninstall_ansible() {
    if [ -d "${INSTALL_DIR}" ]; then
        echo_log_info "Uninstall Ansible"
        rm -rf ${INSTALL_DIR}
        echo_log_info "Uninstall Ansible Successfully"
    else
        echo_log_warn "Ansible is not installed"
    fi
    sed -i '/# ansible/,/ansible.cfg/d' /etc/profile
    source /etc/profile
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m Ansible${ANSIBLE_VERSION} 安装工具\033[0m
———————————————————————————
1. Install Ansible${ANSIBLE_VERSION}
2. Uninstall Ansible${ANSIBLE_VERSION}
3. quit\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_ansible) ;;
    2) (uninstall_ansible) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}