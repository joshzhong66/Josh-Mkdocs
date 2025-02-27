#!/bin/bash
#
#########################################
# 360brower.sh 下载360安全浏览器
#########################################
LOG_FILE="/data/script/360brower.log"
BASE_DIR="/data/mirrors/application/360"
CMD="curl -Ls -o"

URL="https://browser.360.cn"

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
#[ ! -d "$BASE_DIR" ] && echo_log_err "$BASE_DIR 目录不存在"
if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "基础目录 $BASE_DIR 不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "无法创建基础目录 $BASE_DIR"
  echo_log_info "基础目录 $BASE_DIR 创建成功"
else
  echo_log_info "基础目录 $BASE_DIR 已存在，跳过创建"
fi


# 获取实际下载地址
DOWNLOAD_URL=$(curl -Ls $URL | grep -oP "href=\"\Khttps[^\"]+" | head -n1)
[[ $? -ne 0 ]] && echo_log_err "获取下载地址失败"

# 获取文件名
FILENAME=$(basename "$DOWNLOAD_URL")

LOCALFILE="$BASE_DIR/$FILENAME"
if [ ! -f "$LOCALFILE" ]; then
  echo_log_info "开始下载 $DOWNLOAD_URL"
  $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  echo_log_info "清理旧版本文件"
  find "$BASE_DIR" -type f -name "360se*" ! -name "$FILENAME" -exec rm -rf {} \;
  echo >> $LOG_FILE
fi
