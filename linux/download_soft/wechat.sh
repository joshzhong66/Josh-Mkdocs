#!/bin/bash
#
#########################################
# wecom.sh 下载微信
#########################################
LOG_FILE="/data/script/wechat.log"
BASE_DIR="/data/mirrors/application/wechat"
CMD="curl -Ls -o"

OS=("pc" "mac")
OS2=("Windows" "mac")
XML=("<span class=\"download-version\">" "<p>")
NAME=("WeChatSetup.exe" "WeChatMac.dmg")

FILENAMES=()

ARCHS=("win" "mac")  

# 日志输出
echo_log_info() {
  echo -e "$(date +'%F %T') - [info] $* " | tee -a $LOG_FILE
}
echo_log_err() {
  echo -e "$(date +'%F %T') - [error] $* " | tee -a $LOG_FILE
  echo >> $LOG_FILE
  exit 1
}

# 创建基础目录
if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "基础目录 $BASE_DIR 不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "无法创建基础目录 $BASE_DIR"
  echo_log_info "基础目录 $BASE_DIR 创建成功"
else
  echo_log_info "基础目录 $BASE_DIR 已存在，跳过创建"
fi

# 创建架构子目录（x64/x86/arm64）
for arch in "${ARCHS[@]}"; do
  sub_dir="${BASE_DIR}/${arch}"
  if [ ! -d "$sub_dir" ]; then
    echo_log_info "架构目录 $sub_dir 不存在，正在创建..."
    mkdir -p "$sub_dir" || echo_log_err "无法创建架构目录 $sub_dir"
    echo_log_info "架构目录 $sub_dir 创建成功"
  else
    echo_log_info "架构目录 $sub_dir 已存在，跳过创建"
  fi
done

for i in "${!OS[@]}"; do
  # 获取网页下载版本
  URL="https://${OS[i]}.weixin.qq.com/"
  DOWNLOAD_URL="https://dldir1.qq.com/weixin/${OS2[i]}/${NAME[i]}"
  VERSION=$(curl -Ls $URL | grep -oP "${XML[i]}\K[0-9]+\.[0-9]+\.[0-9]+" | head -n1)
  [ $? -ne 0 ] && echo_log_err "获取网页下载版本失败"

  # 获取文件名
  FILENAME="${NAME[i]%.*}-$VERSION.${NAME[i]#*.}"
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${OS[i]}" == "pc" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "WeChat*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "WeChat*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
