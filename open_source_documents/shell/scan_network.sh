#!/bin/bash

# 定义输出文件路径
output_file="/tmp/Scan_Online.out"

# 检查并安装 nmap
if ! command -v nmap &> /dev/null
then
    echo "nmap 未安装，正在安装 nmap..."
    yum install -y nmap
    if ! command -v nmap &> /dev/null
    then
        echo "nmap 安装失败，请手动安装 nmap。"
        exit 1
    fi
fi

# 检查并安装 parallel
if ! command -v parallel &> /dev/null
then
    echo "GNU Parallel 未安装，正在安装 GNU Parallel..."
    yum install -y parallel
    if ! command -v parallel &> /dev/null
    then
        echo "GNU Parallel 安装失败，请手动安装 GNU Parallel。"
        exit 1
    fi
fi

# 清空输出文件并写入标题
echo -e "IP地址\t\t开放端口" > "$output_file"

echo "开始扫描 192.168.31.0/24 网段..."

# 扫描IP地址并检测开放端口的函数
scan_ip() {
    local current_ip=$1
    local output_file=$2
    
    # 检查IP是否在线
    if ping -c 1 -W 1 "$current_ip" &> /dev/null; then
        echo "$current_ip 在线，正在检测所有端口..."
        # 扫描所有端口
        nmap -p- --open -T4 "$current_ip" | tee -a "$output_file"
    fi
}

export -f scan_ip

# 使用GNU Parallel执行扫描
seq 1 254 | parallel -j 10 scan_ip 10.22.51.{} "$output_file"

echo "扫描完成。所有在线IP的端口扫描结果已保存到 $output_file，并在上方打印。"