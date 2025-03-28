#!/bin/bash


KERNEL_VERSION="5.4.278"
DOWNLOAD_PATH="/usr/local/src"
linux="$DOWNLOAD_PATH/linux"


REPO_URLS=(
    "http://10.22.51.64/5_Linux/kernel/"
    "http://193.49.22.109/elrepo/kernel/el7/x86_64/RPMS/"
    "http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 检查root权限
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

# 安装依赖
install_dependencies() {
    if ! rpm -q curl wget perl perl-Data-Dumper  &>/dev/null; then
        echo -e "${YELLOW}安装必要依赖...${NC}"
        yum install -y curl wget perl perl-Data-Dumper || {
            echo -e "${RED}依赖安装失败${NC}";
            exit 1;
        }
    fi
}

# 选择可用镜像源
select_mirror() {
    for url in "${REPO_URLS[@]}"; do
        if check_url "$url"; then
            SELECTED_URL="$url"
            echo -e "${GREEN}使用镜像源：${SELECTED_URL}${NC}"
            return 0
        fi
    done
    echo -e "${RED}错误：所有镜像源不可用${NC}"
    exit 1
}

# 卸载3.x 内核
uninstall_kernel() {
    if rpm -q kernel-tools kernel-tools-libs kernel-headers  &>/dev/null; then
        # 卸载旧内核
        echo -e "${YELLOW}卸载内核...${NC}"
        rpm -e --nodeps kernel-tools kernel-tools-libs kernel-headers || {
            echo -e "${RED}旧内核卸载失败${NC}";
            exit 1;
        }
    else
        echo -e "${YELLOW}未找到旧内核，跳过卸载...${NC}"
        return 0
    fi
}


main() {
    check_root
    install_dependencies
    select_mirror
    uninstall_kernel

    # 进入下载目录
    cd "$DOWNLOAD_PATH" || exit 1

    # 定义RPM包列表
    declare -A RPMS=(
        ["kernel"]="kernel-lt-${KERNEL_VERSION}-1.el7.elrepo.x86_64.rpm"
        ["devel"]="kernel-lt-devel-${KERNEL_VERSION}-1.el7.elrepo.x86_64.rpm"
        ["headers"]="kernel-lt-headers-${KERNEL_VERSION}-1.el7.elrepo.x86_64.rpm"
        ["kernel-lt-tools-libs"]="kernel-lt-tools-libs-${KERNEL_VERSION}-1.el7.elrepo.x86_64.rpm"
        ["tools"]="kernel-lt-tools-${KERNEL_VERSION}-1.el7.elrepo.x86_64.rpm"
        ["tools-libs-devel"]="kernel-lt-tools-libs-devel-${KERNEL_VERSION}-1.el7.elrepo.x86_64.rpm"
        ["doc"]="kernel-lt-doc-${KERNEL_VERSION}-1.el7.elrepo.noarch.rpm"
    )

    # 查看当前目录下是否存在 kernel5.4.278.tar.gz
    if [ -f "$DOWNLOAD_PATH/kernel5.4.278.tar.gz" ]; then
        echo -e "${YELLOW}kernel5.4.278.tar.gz 已存在，跳过下载...${NC}"
    else
        echo -e "${YELLOW}下载 kernel5.4.278.tar.gz ...${NC}"
        if ! wget -t 3 --timeout=30 "$SELECTED_URL/kernel5.4.278.tar.gz"; then
    # 下载RPM包
    for type in "${!RPMS[@]}"; do
        file="${RPMS[$type]}"
        url="${SELECTED_URL}${file}"
        
        echo -e "${YELLOW}下载 $file ...${NC}"
        if ! wget -t 3 --timeout=30 "$url"; then
            echo -e "${RED}下载失败：$file${NC}"
            exit 1
        fi
    done

    # 安装内核
    echo -e "${YELLOW}安装内核包...${NC}"
    cd $DOWNLOAD_PATH
    for pkg in "${RPMS[@]}"; do
        if ! rpm -ivh "$pkg"; then
            echo -e "${RED}安装失败：$pkg${NC}"
            exit 1
        fi
    done

    # 内核验证
    echo -e "\n${GREEN}已安装内核列表：${NC}"
    ls -lh /boot/vmlinuz* 2>/dev/null || {
        echo -e "${RED}未找到内核文件${NC}";
        exit 1;
    }

    # GRUB配置
    echo -e "\n${YELLOW}更新GRUB配置...${NC}"
    if [ -d /sys/firmware/efi ]; then
        GRUB_CFG="/boot/efi/EFI/centos/grub.cfg"
    else
        GRUB_CFG="/boot/grub2/grub.cfg"
    fi

    grub2-mkconfig -o "$GRUB_CFG" || {
        echo -e "${RED}GRUB配置生成失败${NC}";
        exit 1;
    }

    # 设置默认启动项
    echo -e "\n${GREEN}当前启动项：${NC}"
    awk -F\' '$1=="menuentry " {print $2}' "$GRUB_CFG"
    
    # 安全设置默认内核
    DEFAULT_TITLE=$(grep -m1 "^menuentry" "$GRUB_CFG" | cut -d"'" -f2)
    if [[ "$DEFAULT_TITLE" == *"$KERNEL_VERSION"* ]]; then
        sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=\"$DEFAULT_TITLE\"/" /etc/default/grub
        echo -e "\n${GREEN}设置默认启动项为：$DEFAULT_TITLE${NC}"
    else
        echo -e "${RED}警告：新内核未出现在首位，请手动设置！${NC}"
        exit 1
    fi

    # 二次生成GRUB配置
    grub2-mkconfig -o "$GRUB_CFG"
    grub2-editenv list

    # 安全重启提示
    echo -e "\n${YELLOW}是否立即重启？${NC}"
    read -p "[y/N] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\n${GREEN}系统即将重启...${NC}"
        sleep 3
        reboot
    else
        echo -e "\n${YELLOW}请手动执行 reboot 重启系统${NC}"
    fi
}

main