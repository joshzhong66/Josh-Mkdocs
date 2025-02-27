#!/bin/bash
#
#########################################
# todesk.sh 下载todesk
#########################################
LOG_FILE="/data/script/todesk.log"
BASE_DIR="/data/mirrors/application/todesk"
CMD="curl -Ls -o"

OS=("windows" "windows" "macos")
NAME=("ToDesk_Setup.exe" "ToDesk_Lite.exe" "ToDesk.pkg")

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
#[ ! -d "$BASE_DIR" ] && echo_log_err "$BASE_DIR 目录不存在"

if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "$BASE_DIR 目录不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "无法创建目录 $BASE_DIR"
  echo_log_info "$BASE_DIR 目录创建成功"
fi

for i in "${!OS[@]}"; do
  # 获取网页下载版本
  URL="https://update.todesk.com/${OS[i]}/uplog.html"
  DOWNLOAD_VER=$(curl -Ls $URL | grep -oP "<div class=\"text\">\K.*(?=</div>)" | head -n1)
  [ $? -ne 0 ] && echo_log_err "获取网页下载版本失败"

  if [[ $i -ne 2 ]]; then
    DOWNLOAD_URL="https://dl.todesk.com/${OS[i]}/${NAME[i]}"
  else
    DOWNLOAD_URL="https://dl.todesk.com/${OS[i]}/${NAME[i]%.*}_$DOWNLOAD_VER.${NAME[i]#*.}"
  fi

  # 获取文件名
  FILENAME="${NAME[i]%.*}_$DOWNLOAD_VER.${NAME[i]#*.}"
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${OS[i]}" == "windows" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"

  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "ToDesk*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "ToDesk*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
