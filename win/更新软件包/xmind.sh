#!/bin/bash
#
#########################################
# xmind.sh 下载xmind
# Win64 https://www.xmind.cn/zen/download/win64/
# Mac   https://www.xmind.cn/zen/download/mac/
# [root@zhongjl-51-64 /root]# curl -Ls --max-time 5 --max-redirs 3 -o /dev/null -w '%{url_effective}\n' "https://www.xmind.cn/zen/download/win64"
# https://dl3.xmind.cn/Xmind-for-Windows-x64bit-25.04.03523-202505300023.exe
#########################################
LOG_FILE="/data/script/application_update/xmind.log"
BASE_DIR="/data/mirrors/application/xmind"
CMD="curl -Ls -o"


OS=("win64" "mac")
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

# 判断日志文件是否存在
if [ ! -f "$LOG_FILE" ]; then
    echo_log_info "日志文件 $LOG_FILE 不存在，正在创建..."
    touch "$LOG_FILE" || echo_log_err "创建日志文件失败"
fi

# 判断目录是否存在
if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "目录 $BASE_DIR 不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "创建目录失败"
fi


for i in "${!OS[@]}"; do
  # 获取实际下载地址
  URL="https://www.xmind.cn/zen/download/${OS[i]}"
  DOWNLOAD_URL=$(curl -Ls --max-time 5 --max-redirs 3 -o /dev/null -w '%{url_effective}\n' "$URL")
  result=$?; [[ $result -ne 28 && $result -ne 0 ]] && echo_log_err "获取下载地址失败"
  
  # 获取URL文件名
  FILENAME=$(basename "$DOWNLOAD_URL")
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${OS[i]}" == "win64" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win64"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  [ ! -d "$DOWNLOAD_DIR" ] && mkdir -p $DOWNLOAD_DIR

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    eval $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

# 查找并清理非保留文件
if [ -n "$(find "$BASE_DIR" -type f -name "Xmind*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "[INFO] 清理旧版本 Xmind 文件"
  find "$BASE_DIR" -type f -name "Xmind*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -vf {} +
fi