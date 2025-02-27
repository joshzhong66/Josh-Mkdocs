#!/bin/bash
#
#########################################
# sysdiag.sh 下载火绒杀毒
#########################################
LOG_FILE="/data/script/sysdiag.log"
BASE_DIR="/data/mirrors/application/antivirus"
CMD="curl -Ls -o"

OS=("x64" "x86" "arm64")

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

# 创建基础目录
if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "基础目录 $BASE_DIR 不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "无法创建基础目录 $BASE_DIR"
  echo_log_info "基础目录 $BASE_DIR 创建成功"
else
  echo_log_info "基础目录 $BASE_DIR 已存在，跳过创建"
fi



for i in "${OS[@]}"; do
  # 获取实际下载地址
  URL="https://www.huorong.cn/product/downloadHr60.php?pro=hr60&plat=${i}UrlAll"
  DOWNLOAD_URL=$(curl -Ls --max-time 5 --max-redirs 3 -o /dev/null -w '%{url_effective}\n' "$URL")
  result=$?; [[ $result -ne 28 && $result -ne 0 ]] && echo_log_err "获取下载地址失败"

  # 获取URL文件名
  FILENAME=$(basename "$DOWNLOAD_URL")
  FILENAMES+=("$FILENAME")

  LOCALFILE="$BASE_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -iname "sysdiag-all*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -iname "sysdiag-all*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
