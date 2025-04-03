#!/bin/bash

#\033[1;32m → 绿色 + 加粗（用于强调“安装完成！”）
#\033[1;34m → 蓝色（用于分割线）
#\033[1;33m → 黄色（用于“注意事项”）
#\033[1;31m → 红色（用于警告和关键提示）
#\033[1;36m → 青色（用于路径和设置选项）
#\033[0m → 终止格式，使后续文本恢复默认颜色

set -euo pipefail

# 配置参数
URL="http://boss.sunline.cn:8080/download/pc/versionUpdate/boss_forMAC.zip"
DOWN_DIR="${HOME}/Downloads"
ZIP_FILE="${DOWN_DIR}/boss_forMAC.zip"
DOCUMENTS_DIR="${HOME}/Documents"
INSTALL_DIR="${DOCUMENTS_DIR}/boss_forMAC"

# 清理旧文件
echo "正在清理旧文件..."
rm -rf "$INSTALL_DIR" "$ZIP_FILE"

# 下载安装包
echo "正在下载安装包..."
if ! curl -# -o "$ZIP_FILE" "$URL"; then
    echo "下载失败，请检查："
    echo "1. 网络连接状态"
    echo "2. 访问权限：sudo ifconfig | grep 'inet '"
    echo "3. 文件URL有效性：$URL"
    exit 1
fi

# 验证下载文件
if [[ ! -f "$ZIP_FILE" ]]; then
    echo "下载文件不存在: $ZIP_FILE"
    exit 1
fi

# 解压到文稿目录
echo "正在解压文件..."
cd "$DOCUMENTS_DIR" || { echo "无法进入文稿目录"; exit 1; }

# 强制解压并处理中文目录
ditto -x -k --sequesterRsrc --rsrc "$ZIP_FILE" ./

# 精确匹配目录模式
if [ -d "boss_forMAC_正式" ]; then
    mv -f "boss_forMAC_正式" "$INSTALL_DIR"
    echo "已找到并移动到目标目录：$INSTALL_DIR"
else
    # 通配符匹配备用方案
    actual_dir=$(find . -maxdepth 1 -type d -name "boss_forMAC*" ! -name "__MACOSX" | head -n 1)
    [ -n "$actual_dir" ] && mv -f "$actual_dir" "$INSTALL_DIR"
fi

# 验证安装目录
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "解压失败，目录不存在: $INSTALL_DIR"
    echo "尝试手动解压：open $ZIP_FILE"
    exit 1
fi

# 设置文件权限
echo "设置应用程序权限..."
cd "$INSTALL_DIR" || { echo "无法进入安装目录"; exit 1; }
if ! chmod +x boss.command;then
    echo "chmod +x boss.command 失败"
    exit 1
fi

if ! chmod -R 777 jre1.8.0_144.jre; then
    echo "chmod -R 777 jre1.8.0_144.jre 失败"
    exit 1
fi

if [ -d JavaAppletPlugin ]; then
    if ! chmod -R 777 JavaAppletPlugin; then
        echo "chmod -R 777 JavaAppletPlugin 失败"
        exit 1
    fi
else
    echo "JavaAppletPlugin 目录不存在"
    return 0
fi

# 创建桌面快捷方式
echo "创建桌面快捷方式..."
ln -sf "$INSTALL_DIR/boss.command" "${HOME}/Desktop/BOSS客户端"

# 禁用系统保护（需要管理员权限）
echo "正在禁用系统保护..."
echo "请输入mac电脑的开机密码，输入过程中不会显示，请确保密码输入正确,输入完成按回车确认"
sudo spctl --master-disable 2>/dev/null || true

# 启动应用程序
echo "启动 BOSS 客户端..."
sleep 1
open -a Terminal.app "$INSTALL_DIR/boss.command"

# 完成提示
echo -e "\n\033[1;32m安装完成！\033[0m 请通过桌面快捷方式启动程序"
echo -e "\033[1;34m──────────────────────────────────────────\033[0m"
echo -e "\033[1;33m注意事项：\033[0m"
echo -e "1. 首次启动可能会提示 \033[1;31m未知开发者\033[0m，请前往："
echo -e "   \033[1;36m系统设置 → 隐私与安全性 → 安全性\033[0m"
echo -e "   在 \033[1;36m「允许从以下位置下载的应用程序」\033[0m 下方"
echo -e "   可能会看到如下提示："
echo -e "   \033[1;31m已阻止使用 \"boss.command\"，因为来自身份不明的开发者\033[0m"
echo -e "   请点击 \033[1;32m「仍要打开」\033[0m 按钮"
echo -e "2. \033[1;32m建议将快捷方式拖到程序坞\033[0m，方便后续使用"
