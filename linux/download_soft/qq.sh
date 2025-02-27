#!/bin/bash
#
#########################################
# qq.sh 下载QQ
#########################################
LOG_FILE="/data/script/qq.log"
BASE_DIR="/data/mirrors/application/qq"
CMD="curl -Ls -o"

OS=("pc" "mac")
OS2=("ntDownloadX64Url" "downloadUrl")

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


# 创建子目录（win/mac）
for os in "${OS[@]}"; do
  sub_dir="${BASE_DIR}/${os}"
  if [ ! -d "$sub_dir" ]; then
    echo_log_info "子目录 $sub_dir 不存在，正在创建..."
    mkdir -p "$sub_dir" || echo_log_err "无法创建子目录 $sub_dir"
    echo_log_info "子目录 $sub_dir 创建成功"
  else
    echo_log_info "子目录 $sub_dir 已存在，跳过创建"
  fi
done

for i in "${!OS[@]}"; do
  # 获取实际下载地址
  URL="https://im.qq.com/${OS[i]}qq/index.shtml"
  DOWNLOAD_URL=$(curl -Ls $URL | grep -oP "var rainbowConfigUrl = \"\K[^\"]+" | xargs curl -Ls | grep -oP "${OS2[i]}\":\"\K[^\"]+")
  [ $? -ne 0 ] && echo_log_err "获取下载地址失败"
  
  # 获取URL文件名
  FILENAME=$(basename "$DOWNLOAD_URL")
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${OS[i]}" == "pc" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi
  [ ! -d "$DOWNLOAD_DIR" ] && mkdir -p $DOWNLOAD_DIR
  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "QQ*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "QQ*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
