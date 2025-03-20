#!/bin/bash

# 颜色定义
COLOR_BORDER="\033[1;34m"
COLOR_TITLE="\033[1;32m"
COLOR_OPTION="\033[1;37m"
COLOR_RESET="\033[0m"

# 变量定义
PACKAGE_NAME="node_exporter"
NODE_VERSION=" v1.3.1"

# 动态生成标题
print_menu_header() {
    echo -e "${COLOR_BORDER}╔════════════════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BORDER}║${COLOR_TITLE}           $PACKAGE_NAME${NODE_VERSION} 管理脚本                                ${COLOR_BORDER}║${COLOR_RESET}"
    echo -e "${COLOR_BORDER}╠════════════════════════════════════════════════════════════════════════╣${COLOR_RESET}"
}

# 生成菜单选项
print_menu_body() {
    echo -e "${COLOR_BORDER}║${COLOR_OPTION}  1. 安装 $PACKAGE_NAME${NODE_VERSION}                                          ${COLOR_BORDER}║${COLOR_RESET}"
    echo -e "${COLOR_BORDER}║${COLOR_OPTION}  2. 卸载 $PACKAGE_NAME${NODE_VERSION}                                          ${COLOR_BORDER}║${COLOR_RESET}"
    echo -e "${COLOR_BORDER}║${COLOR_OPTION}  3. 退出脚本                                                           ${COLOR_BORDER}║${COLOR_RESET}"
    echo -e "${COLOR_BORDER}╚════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}"
}


# 显示完整菜单
print_menu_header
print_menu_body