#!/bin/bash

# 定义需要检测的命令列表
commands=("nc" "curl" "wget" "telnet")

# 遍历每个命令进行检查
for cmd in "${commands[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        echo "INFO: $cmd 命令已安装，继续下一步..."
    else
        echo "WARN: $cmd 命令未安装，正在通过 yum 安装..."
        yum install -y "$cmd" >/dev/null 2>&1

        # 检查安装结果
        if [ $? -eq 0 ]; then
            echo "SUCCESS: $cmd 安装成功！"
        else
            echo "ERROR: $cmd 安装失败，请手动处理！"
            exit 1  # 可选：终止脚本执行
        fi
    fi
done