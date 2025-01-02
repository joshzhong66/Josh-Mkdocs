function ip_to_int() {
    local ip=$1
    local a b c d

    # 检查 IP 格式是否有效
    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "Invalid IP address format"
        return 1
    fi

    # 使用 cut 命令分割 IP 地址
    a=$(echo $ip | cut -d'.' -f1)
    b=$(echo $ip | cut -d'.' -f2)
    c=$(echo $ip | cut -d'.' -f3)
    d=$(echo $ip | cut -d'.' -f4)

    # 确保每一部分在 0 到 255 之间
    if ((a < 0 || a > 255 || b < 0 || b > 255 || c < 0 || c > 255 || d < 0 || d > 255)); then
        echo "Each octet must be between 0 and 255"
        return 2
    fi

    # 返回转换后的整数
    echo "$(((a * 256 + b) * 256 + c) * 256 + d)"
}
