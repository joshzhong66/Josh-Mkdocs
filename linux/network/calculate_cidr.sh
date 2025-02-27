#!/bin/bash

# CIDR（子网掩码）：
# CIDR 表示 IP 地址和子网掩码的组合方式，通常表示为 IP地址/掩码位数，例如 192.168.1.0/24，其中 24 就是 CIDR 值，表示子网掩码的前 24 位是网络位。

# 主机数量计算：
# IP 地址是 32 位二进制数。子网掩码的 CIDR 值指示了有多少位是网络部分，剩余的位数是主机部分。
# 公式为： 可用主机数=2(32−CIDR)−2可用主机数 = 2^{(32 - CIDR)} - 2可用主机数=2(32−CIDR)−2 其中 2 是为了减去网络地址和广播地址。网络地址是所有主机部分都为 0 的地址，广播地址是所有主机部分都为 1 的地址，这两个地址是无法分配给主机的。


calc_hosts() {
    local cidr=$1

    # 参数验证：检查 CIDR 值是否在合法范围内
    if [[ ! "$cidr" =~ ^[0-9]+$ ]] || [ "$cidr" -lt 0 ] || [ "$cidr" -gt 32 ]; then
        echo "错误：无效的 CIDR 值，必须是 0 到 32 之间的整数"
        return 1
    fi

    # 处理特殊情况 /32（没有可用主机）
    if [ "$cidr" -eq 32 ]; then
        echo "可用主机数量为: 0 (仅限单一 IP 地址)"
        return 0
    fi

    # 计算可用主机数量
    local hosts=$((2 ** (32 - cidr) - 2))
    echo "可用主机数量为: $hosts"
}

read -rp "请输入要计算的 CIDR 值: " cidr

hosts=$(calc_hosts $cidr)
echo $hosts

