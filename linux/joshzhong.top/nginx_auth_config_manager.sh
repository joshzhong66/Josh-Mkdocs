#!/bin/bash

PACKAGE_NAME="Nginx Configuration"
CONFIG_FILE="/usr/local/nginx/conf/conf.d/file.joshzhong.top.conf"
TEMP_FILE="/tmp/nginx_config.tmp"

comment_auth() {
    # 使用sed命令来注释掉用户验证相关的行

    sed '/auth_basic\s/c\        # auth_basic "Restricted Area";' "$CONFIG_FILE" > "$TEMP_FILE" &&
    sed '/auth_basic_user_file\s/c\        # auth_basic_user_file /usr/local/nginx/conf/htpasswd;' "$TEMP_FILE" > "$CONFIG_FILE"

    if ! cmp -s "$CONFIG_FILE" "$TEMP_FILE"; then
        systemctl restart nginx
        echo "已注释用户验证配置并重启Nginx服务。"
    else
        echo "未发现需修改的内容或无任何更改，无需重启Nginx服务。"
    fi

    # 删除临时文件
    rm -f "$TEMP_FILE"
}


uncomment_auth() {
    # 使用sed命令来取消注释用户验证相关的行
    sed '/auth_basic\s/c\        auth_basic "Restricted Area";' "$CONFIG_FILE" > "$TEMP_FILE" &&
    sed '/auth_basic_user_file\s/c\        auth_basic_user_file /usr/local/nginx/conf/htpasswd;' "$TEMP_FILE" > "$CONFIG_FILE"

    # 比较文件是否已修改
    if ! cmp -s "$CONFIG_FILE" "$TEMP_FILE"; then
        systemctl restart nginx
        echo "已取消注释用户验证配置并重启Nginx服务。"
    else
        echo "未发现需修改的内容或无任何更改，无需重启Nginx服务。"
    fi

    # 删除临时文件
    rm -f "$TEMP_FILE"
}




quit() {
    echo "退出脚本。"
    exit 0
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m $PACKAGE_NAME Config Tool\033[0m
———————————————————————————
1. 注释用户验证配置
2. 取消注释用户验证配置
3. 退出脚本\n"

    read -rp "请输入序号并按Enter键：" num
    case "$num" in
    1) comment_auth ;;
    2) uncomment_auth ;;
    3) quit ;;

    *) main ;;
    esac
}

main
