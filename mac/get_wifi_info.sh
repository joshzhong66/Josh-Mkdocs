#!/bin/bash

# 获取 Wi-Fi 接口名称
WIFI_INTERFACE=$(networksetup -listallhardwareports | grep -A 2 "Wi-Fi" | awk '/Device:/ {print $2}')

# 检查是否获取到接口
if [ -z "$WIFI_INTERFACE" ]; then
    echo "错误：未找到 Wi-Fi 接口。"
    exit 1
fi

# 获取 IP 地址
IP_ADDRESS=$(ipconfig getifaddr "$WIFI_INTERFACE")

# 获取 MAC 地址（永久地址，即使随机化后也能显示真实地址）
MAC_ADDRESS=$(networksetup -getmacaddress "$WIFI_INTERFACE" | awk '{print $3}')

# 输出结果
echo "Wi-Fi 接口: $WIFI_INTERFACE"
echo "IP 地址:    ${IP_ADDRESS:-未连接}"
echo "MAC 地址:   ${MAC_ADDRESS:-未知}"