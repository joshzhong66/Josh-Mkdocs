#!/bin/bash
#
#########################################
# sunlogin.sh 下载向日葵远程
#########################################
LOG_FILE="/data/script/sunlogin.log"
BASE_DIR="/data/mirrors/application/sunlogin"
CMD="curl -Ls -o"

MAX_RETRY=3               # 最大重试次数
TIMEOUT=15                # 单次请求超时（秒）
REFERER="https://sunlogin.oray.com/"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# 65表示windows，89表示mac_x86_64，187表示mac_arm64
OS=("65" "89" "187")

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
if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "目录 $BASE_DIR 不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "创建目录失败"
fi

for i in "${OS[@]}"; do
  # 获取实际下载地址
  URL="https://client-api.oray.com/softwares/${i}/download"
  #DOWNLOAD_URL=$(curl -Ls --max-time 5 --max-redirs 3 -o /dev/null -w '%{url_effective}\n' "$URL")
  DOWNLOAD_URL=$(curl -sL \
    --max-time $TIMEOUT \
    --max-redirs 3 \
    --header "Referer: $REFERER" \
    --user-agent "$USER_AGENT" \
    -w '%{url_effective}' \
    -o /dev/null \
    "$URL")

  result=$?; [[ $result -ne 28 && $result -ne 0 ]] && echo_log_err "获取下载地址失败"
  
  # 获取URL文件名
  FILENAME=$(basename "$DOWNLOAD_URL")
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "$i" == "65" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    #$CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
      $CMD \
      --header "Referer: $REFERER" \
      --user-agent "$USER_AGENT" \
      --connect-timeout $TIMEOUT \
      --output "$TEMP_FILE" \
      "$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "Sunlogin*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "Sunlogin*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
