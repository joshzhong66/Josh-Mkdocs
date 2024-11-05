#!/bin/bash
#version: 1.0
#date: 2024-09-11
<< 'COMMENT'
comment：
1） 脚本说明：脚本的功能包含源码安装&&卸载"依赖"，
2)  依赖包包括：libnl3
COMMENT

function echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}

function echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}

function echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}

function echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}


function check_url() {
    curl --head --silent --fail --connect-timeout 3 --max-time 5 "$1" >/dev/null 2>&1
}


function tool_libnl3() {
    DATA_DIR="/usr/local/libnl3"
    Down_DIR="/usr/local/src"
    LIB_VER="3.9.0"
    LIBNL3_TAR="libnl-${LIB_VER}.tar.gz"
    INTERNAL_LIBNL3_URL="http://10.24.1.133/Linux/libnl/libnl-3.9.0.tar.gz"
    EXTERNAL_LIBNL3_URL="https://github.com/thom311/libnl/releases/download/libnl3_9_0/libnl-3.9.0.tar.gz"

    function main_libnl3() {
        clear
        echo -e "———————————————————————————
        \033[32m libnl${LIB_VER} 安装工具\033[0m
        ———————————————————————————
        1. 安装libnl${LIB_VER}
        2. 卸载libnl${LIB_VER}
        3. 返回\n"

        read -rp "请输入序号并回车：" num
        case "$num" in
        1) (install_libnl3) ;;
        2) (remove_libnl3) ;;
        3) (quit_libnl3) ;;
        *) (main_libnl3) ;;
        esac
    }

    function check_libnl3() {
        if rpm -qa | grep libnl >/dev/null 2>&1; then
            echo_log_warn "libnl3 通过 rpm 安装，如需安装源码包，请先卸载后再安装！"
            exit 1
        elif [ -d "${DATA_DIR}" ]; then
            echo_log_warn "libnl3 已通过源码包安装，如需重新安装，请先卸载后再安装！"
            exit 1
        else
            return 0
        fi
    }

    function install_libnl3() {
        check_libnl3
        # 安装依赖
        yum install -y bison flex gcc gcc-c++ make wget >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "依赖安装成功！" || echo_log_error "依赖安装失败！"

        if [ -f $Down_DIR/$LIBNL3_TAR ]; then
            echo_log_info "libnl3 源码包已存在！"
        else
            echo_log_info "开始下载 libnl3 源码包..."
            for url in "$INTERNAL_LIBNL3_URL" "$EXTERNAL_LIBNL3_URL"; do
                if check_url "$url"; then
                    wget -P "$Down_DIR" "$url" &>/dev/null
                    if [ $? -eq 0 ]; then
                        echo_log_info "$LIBNL3_TAR 下载成功"
                        return
                    fi
                fi
            done
            echo_log_error "两个下载链接都无效，下载失败。"
        fi

        
        tar -zxvf ${Down_DIR}/$LIBNL3_TAR >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "解压 $LIBNL3_TAR 成功" || echo_log_error "解压 $LIBNL3_TAR 失败"

        cd "${Down_DIR}/libnl-${LIB_VER}"

        ./configure --prefix=$DATA_DIR --sysconfdir=/etc --disable-static >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "编译 libnl3 成功" || echo_log_error "编译 libnl3 失败"

        make -j $(nproc) &>/dev/null && make install &>/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "安装 libnl3 成功" || echo_log_error "安装 libnl3 失败"

        echo ${DATA_DIR}/lib > /etc/ld.so.conf.d/libnl3.conf
        sudo ldconfig
        [ $? -eq 0 ] && echo_log_info "ldconfig 成功" || echo_log_error "ldconfig 失败"

        cat > /etc/profile.d/libnl3.sh << 'EOF'
# libnl3
export PATH="/usr/local/libnl3/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/libnl3/lib/pkgconfig:$PKG_CONFIG_PATH"
EOF
        source /etc/profile
        pkg-config --modversion libnl-genl-3.0 >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "libnl3 安装成功！" || echo_log_error "libnl3 安装失败！"
    }

    function remove_libnl3() {
        # 检查由 check_libnl3 完成
        rpm -qa | grep libnl >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            yum remove -y libnl3-cli libnl3 >/dev/null 2>&1
            [ $? -eq 0 ] && echo_log_info "rpm libnl3 已卸载成功！" || echo_log_error "rpm libnl3 卸载失败！"
        elif [ -d "${DATA_DIR}" ]; then
            rm -rf "${DATA_DIR}"
            rm -rf "${Down_DIR}/libnl-${LIB_VER}"
            [ $? -eq 0 ] && echo_log_info "libnl3 源码安装文件已卸载成功！" || echo_log_error "源码 libnl3 卸载失败！"
        fi
    }

    function quit_libnl3() {
        main
    }

    main_libnl3
}


function quit() {
    echo_log_info "退出安装脚本！"
    exit 0
}


# 完成操作后是否返回主菜单
function return_main() {
    echo -e -n "$(date +'%F %T') - [Info] $*"
    read input

    if [[ $input == 'y' ]]; then
        main
    elif [[ $input == 'n' ]]; then
        quit
    else
        return_main "\033[32m请重新输入(y/n)\033[0m "
    fi
}


function main() {
    clear
    echo -e "———————————————————————————
\033[32m Linux依赖包集成安装\033[0m
———————————————————————————
1. 安装/卸载 libnl3
2. 退出\n"
    read -rp "请输入序号并回车：" num
    case "$num" in
    1) (tool_libnl3) ;;
    2) (quit) ;;
    *) (main) ;;
    esac
}

main