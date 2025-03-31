#!/bin/bash
# 免编译包安装
# https://mirrors.sunline.cn/source/gcc/gcc-11.4.0-bin.tar.xz
# https://file.joshzhong.top/4_Install/gcc-11.4.0-bin.tar.xz

PACKAGE_NAME="gcc"
VERSION="11.4.0"
PKG_ARCH="gcc-11.4.0-bin.tar.xz"
INSTALL_PATH="/usr/local"
SRC_DIR="/usr/local/src"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 镜像源优先级列表（尾部优先级最低）
MIRROR_URLS=(
    "https://mirrors.sunline.cn/source/gcc/"
    "https://file.joshzhong.top/4_Install/"
)

error_exit() {
    echo -e "\n${RED}${BOLD}错误：$1${NC}" >&2
    exit 1
}

check_gcc() {
    if command -v gcc &>/dev/null; then
        CHECK_GCC_VERSION=$(gcc -dumpversion | cut -d. -f1)
        if [ "$CHECK_GCC_VERSION" -eq 11 ]; then
            echo "GCC 11 已安装"
            exit 1
        else
            echo "GCC 版本为 $CHECK_GCC_VERSION，继续安装 $PACKAGE_NAME-$VERSION"
            return 0
        fi
    else
        echo "GCC 未安装，开始安装 $PACKAGE_NAME-$VERSION"
        return 0
    fi
}

check_root() {
    if [[ $(id -u) != 0 ]]; then
        echo -e "${RED}错误：必须使用root权限运行此脚本${NC}"
        exit 1
    fi
}

check_url() {
    local url=$1
    if curl -fsSL --connect-timeout 5 "$url" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_rpg_arch() {

}

# 选择可用镜像源
echo -e "${YELLOW}选择可用镜像源...${NC}"
select_mirror() {
    for url in "${MIRROR_URLS[@]}"; do
        if check_url "$url"; then
            SELECTED_URL="$url"
            echo -e "${GREEN}使用镜像源：${SELECTED_URL}${NC}"
            return 0
        fi
    done
    echo -e "${RED}错误：所有镜像源不可用${NC}"
    exit 1
}

install_gcc() {
    # 定义RPM包列表
    declare -A RPMS=(
        ["package"]="gcc-11.4.0-bin.tar.xz"
    )

    # 下载RPM包
    cd $SRC_DIR
    for type in "${!RPMS[@]}"; do
        file="${RPMS[$type]}"
        url="${SELECTED_URL}${file}"
        
        echo -e "${YELLOW}下载 $file ...${NC}"
        if ! wget -t 3 --timeout=30 "$url"; then
            echo -e "${RED}下载失败：$file${NC}"
            exit 1
        fi
    done

    echo -e "${YELLOW}解压 gcc-11.4.0-bin.tar.xz ...${NC}"
    cd $SRC_DIR
    if ! tar -Jxvf gcc-11.4.0-bin.tar.xz -C $INSTALL_PATH; then
        echo -e "${RED}解压失败：gcc-11.4.0-bin.tar.xz${NC}"
        exit 1
    fi


    echo -e "${YELLOW}安装 gcc-11.4.0-bin.tar.xz ...${NC}"
    if ! echo "/usr/local/gcc/lib64" > "/etc/ld.so.conf.d/gcc-$(uname -m).conf"; then
        echo -e "${RED}错误：写入配置文件失败！${NC}"
        exit 1  # 退出脚本并返回错误代码
    fi

    echo -e "\n${YELLOW}▶ 处理现有版本...${NC}"
    mv /usr/bin/gcc /usr/bin/gcc_bak
    mv /usr/bin/g++ /usr/bin/g++_bak

    # 创建软链接
    echo -e "\n${YELLOW}▶ 创建符号链接...${NC}"
    link_binary() {
        local src="$1"
        local dest="$2"
        ln -sf "$src" "$dest" || error_exit "创建链接失败：$dest"
        echo -e "已创建 ${CYAN}${dest}${NC} → ${CYAN}$(readlink -f "$dest")${NC}"
    }
    link_binary "$INSTALL_PATH/gcc/bin/gcc" "/usr/bin/gcc"
    link_binary "$INSTALL_PATH/gcc/bin/g++" "/usr/bin/g++"

    echo -e "\n${BOLD}=== 安装验证 ===${NC}"
    VALIDATION_PASS=true

    echo -e "${YELLOW}▶ 版本检查...${NC}"
    if ! /usr/bin/gcc --version | grep "$VERSION"; then
        error_exit "GCC 版本不匹配"
    fi

    echo -e "\n${BOLD}=== 安装验证 ===${NC}"
    gcc --version
    g++ --version


    echo -e "\n${YELLOW}▶ 清理临时文件...${NC}"
    rm -f "$SRC_DIR/$PACKAGE_NAME*" || error_exit "清理失败"
    echo -e "${GREEN}√ 安装文件已清理${NC}"

    echo -e "\n${GREEN}${BOLD}GCC ${VERSION} 安装成功！${NC}"
    echo -e "运行以下命令查看版本："
    echo -e "  ${CYAN}gcc --version${NC}"
    echo -e "  ${CYAN}g++ --version${NC}\n"
}


main() {
    check_gcc
    check_root
    select_mirror
    install_gcc
}

main