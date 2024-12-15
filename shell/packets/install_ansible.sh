#!/bin/bash
#
#
# 官网下载：http://mirrors.sunline.cn/source/ansible/ansible-2.14.4.tar.gz
# 公司资源：https://github.com/ansible/ansible/archive/refs/tags/v2.18.1.tar.gz
#
#
#
ANSIBLE_VERSION="2.14.4"
ANSIBLE_TAR="ansible-${ANSIBLE_VERSION}.tar.gz"
DOWNLOAD_PATH="/usr/local/src"
INSTALL_PATH="/usr/local/ansible"
WORK_PATH="/data/ansible"
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
    if [ -d "$INSTALL_PATH" ]; then
        echo_log_error "Installation directory '$INSTALL_PATH' already exists. Please uninstall Ansible before proceeding!"
    elif which ansible &>/dev/null; then
        echo_log_error "Ansible is already installed. Please uninstall it before installing the new version!"
    fi

    if ! which python3 &>/dev/null; then
        echo_log_error "Python 3 is not installed. Please install Python 3 first!"
    fi
    return 0
}

download_ansible() {
    for url in "$INTERNAL_ANSIBLE_URL" "$EXTERNAL_ANSIBLE_URL"; do
        if check_url "$url"; then
            echo_log_info "Download ansible source package from $url ..."
            wget -P "$DOWNLOAD_PATH" "$url" &>/dev/null && {
                echo_log_info "$ANSIBLE_TAR Download Success"
                return 0
            }
            echo_log_error "$url Download failed"
        else
            echo_log_warn "$url invalid"
        fi
    done
    echo_log_error "Both download links are invalid，Download failed！"
    return 1
}

install_ansible() {
    check_ansible

    if [ -f "$DOWNLOAD_PATH/$ANSIBLE_TAR" ]; then
        echo_log_info "Ansible The source package already exists！"
    else
        echo_log_info "Start downloading the Ansible source package..."
        download_ansible
    fi

    yum install -y sshpass >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Dependency installation successful..." || echo_log_error "Failed to install dependencies..."

    tar -xzf "$DOWNLOAD_PATH/$ANSIBLE_TAR" -C $DOWNLOAD_PATH >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "Unzip the Ansible source package successfully..." || echo_log_error "Failed to unzip the Ansible source package..."
    
    mv "$DOWNLOAD_PATH/ansible-${ANSIBLE_VERSION}"  $INSTALL_PATH

    cd $INSTALL_PATH
    python3 -m venv venv && source venv/bin/activate
    [ $? -eq 0 ] && echo_log_info "Create a Python virtual environment successfully" || echo_log_error "Failed to create a Python virtual environment"

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

    echo_log_info "Create ansible configuration file directory $WORK_PATH/bin" && mkdir -p "$WORK_PATH/bin"
    echo_log_info "Copy the bin directory" && cp $INSTALL_PATH/venv/bin/ansible* $WORK_PATH/bin >/dev/null 2>&1

    cat > $WORK_PATH/ansible.cfg <<EOF
[defaults]
interpreter_python = auto_legacy_silent
inventory = $WORK_PATH/hosts
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
    [ $? -eq 0 ] && echo_log_info "Copy ansible.cfg successfully" || echo_log_error "Failed to copy ansible.cfg"

    if ! grep -q "ANSIBLE_HOME=" /etc/profile; then
        echo_log_info "Configure ansible environment variables"
        cat >> /etc/profile <<EOF
# ansible
export ANSIBLE_HOME=${WORK_PATH}
export PATH=\$PATH:\$ANSIBLE_HOME/bin
export ANSIBLE_CONFIG=\$ANSIBLE_HOME/ansible.cfg
EOF
    fi
    source /etc/profile

    echo_log_info "Display Ansible Version $(ansible --version 2>/dev/null | head -n1 | awk '{print $NF}' | awk -F] '{print $1}')"

    rm -rf $DOWNLOAD_PATH/ansible*
}

uninstall_ansible() {
    if [ -d "${INSTALL_PATH}" ]; then
        echo_log_info "Ansible is installed, start uninstalling..."
        rm -rf ${INSTALL_PATH} && rm -rf $WORK_PATH
        rm -f /root/.pip
        echo_log_info "Uninstall Ansible Successfully"
        sed -i '/# ansible/,/ansible.cfg/d' /etc/profile
        source /etc/profile
    else
        echo_log_warn "Ansible is not installed"
    fi
}


main() {
    clear
    echo -e "———————————————————————————
\033[32m Ansible${ANSIBLE_VERSION} Install Tool\033[0m
———————————————————————————
1. Install Ansible${ANSIBLE_VERSION}
2. Uninstall Ansible${ANSIBLE_VERSION}
3. Quit Scripts\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) (install_ansible) ;;
    2) (uninstall_ansible) ;;
    3) (quit) ;;
    *) (main) ;;
    esac
}


main