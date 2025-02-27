#!/bin/bash
#
#########################################
# 7-zip.sh 下载7-zip
#########################################
LOG_FILE="/data/script/7-zip.log"
BASE_DIR="/data/mirrors/application/7-zip"
CMD="curl -Ls --max-time 10 --max-redirs 3 -o"

URL="https://www.7-zip.org"

# 日志输出
echo_log_info() {
  echo -e "$(date +'%F %T') - [info] $* " | tee -a $LOG_FILE
}
echo_log_err() {
  echo -e "$(date +'%F %T') - [error] $* " | tee -a $LOG_FILE
  echo >> $LOG_FILE
  exit 1
}

# 判断目录是否存在
if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "基础目录 $BASE_DIR 不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "无法创建基础目录 $BASE_DIR"
  echo_log_info "基础目录 $BASE_DIR 创建成功"
else
  echo_log_info "基础目录 $BASE_DIR 已存在，跳过创建"
fi

# 获取网页下载版本
FILENAME=$(curl -Ls $URL/download.html | grep -oP "<A href=\"a/\K[^-]+-x64\.exe" | head -n1)
[ $? -ne 0 ] && echo_log_err "获取网页下载版本失败"

LOCALFILE="$BASE_DIR/$FILENAME"
if [ ! -f "$LOCALFILE" ]; then
  echo_log_info "开始下载 $URL/a/$FILENAME"
  $CMD "$LOCALFILE" "$URL/a/$FILENAME" || echo_log_err "下载失败：$URL/a/$FILENAME"
  echo_log_info "清理旧版本文件"
  find "$BASE_DIR" -type f -name "7z*" ! -name "$FILENAME" -exec rm -rf {} \;
  echo >> $LOG_FILE
fi
