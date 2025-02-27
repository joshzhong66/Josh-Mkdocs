#!/bin/bash
#
#########################################
# vpn.sh 下载TopSec VPN
#########################################
LOG_FILE="/data/script/vpn.log"
BASE_DIR="/data/mirrors/application/vpn"
CMD="curl -Ls -o"

OS=("windows" "macos" "android")

# FILENAMES=()

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

for i in "${OS[@]}"; do
  # 获取实际下载地址
  URL="https://app.topsec.com.cn/"
  DOWNLOAD_URL=$URL$(curl -Ls $URL | grep -oP "<a href=\"/\K${i}[^ \"]+")
  [ $? -ne 0 ] && echo_log_err "获取下载地址失败"

  # 获取URL文件名
  FILENAME=$(basename "$DOWNLOAD_URL")
  # FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${i}" == "windows" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
    LFTP_DIR="Windows"
    EXPAND_NAME="exe"
  elif [[ "${i}" == "macos" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/mac"
    LFTP_DIR="Mac"
    EXPAND_NAME="pkg"
  else
    DOWNLOAD_DIR="$BASE_DIR/android"
    LFTP_DIR="手机客户端/安卓"
    EXPAND_NAME="apk"
  fi

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"

  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
    echo_log_info "执行远程上传 $FILENAME 到外网网盘_10.24.1.143"
    lftp -u administrator,Sunline%11 10.24.1.143 -e "set ftp:passive-mode off; cd ${LFTP_DIR}; mrm *.${EXPAND_NAME};put $LOCALFILE; bye" &>/dev/null
    [ $? -ne 0 ] && echo_log_err "远程上传失败：$FILENAME"
    [ $i -eq 2 ] && echo >> $LOG_FILE
  fi
done

#if [ -n "$(find "$BASE_DIR" -type f -name "TopSAP*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
#  echo_log_info "清理旧版本文件"
#  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "TopSAP*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
#  echo >> $LOG_FILE
#fi
