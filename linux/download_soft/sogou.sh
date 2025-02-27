#!/bin/bash
#
#########################################
# sogou.sh 下载搜狗输入法
#########################################
LOG_FILE="/data/script/sogou.log"
BASE_DIR="/data/mirrors/application/sogou"
CMD="curl -Ls -o"

OS=("windows" "macOS" "WuBiWindows" "WuBiMacOS")
OS2=("normal" "normal" "link" "link")

FILENAMES=()

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
[ ! -d "$BASE_DIR" ] && echo_log_err "$BASE_DIR 目录不存在"

for i in "${!OS[@]}"; do
  # 获取实际下载地址
  URL="https://shurufa.sogou.com"
  DOWNLOAD_URL=$(curl -Ls $URL | grep -oP "downloadConfig\":\"\K.*(?=\",\"year)" | sed 's/\\//g' | jq -r ".${OS[i]}.${OS2[i]}")
  [ $? -ne 0 ] && echo_log_err "获取下载地址失败"
  
  # 获取URL文件名
  FILENAME=$(basename "$DOWNLOAD_URL")
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${OS[i]}" =~ "indows" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 ${DOWNLOAD_URL/-sec/}"
    $CMD "$LOCALFILE" "${DOWNLOAD_URL/-sec/}" || echo_log_err "下载失败：${DOWNLOAD_URL/-sec/}"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "sogou*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "sogou*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
