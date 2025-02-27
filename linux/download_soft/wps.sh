#!/bin/bash
#
#########################################
# wps.sh 下载WPS
#########################################
LOG_FILE="/data/script/wps.log"
BASE_DIR="/data/mirrors/application/wps"
CMD="curl -Ls -o"

OS=("win" "mac" "PDF")
ARCHS=("win" "mac")  

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

if [ ! -d "$BASE_DIR" ]; then
  echo_log_info "$BASE_DIR 目录不存在，正在创建..."
  mkdir -p "$BASE_DIR" || echo_log_err "无法创建目录 $BASE_DIR"
  echo_log_info "$BASE_DIR 目录创建成功"
fi

for i in "${!OS[@]}"; do
  # 获取实际下载地址
  if [ $i -ne 2 ]; then
    URL="https://www.wps.cn/platformUrls"
    DOWNLOAD_URL=$(curl -Ls $URL | jq -r ".productList[$i].productButtonUrl") && DOWNLOAD_VER=$(curl -Ls $URL | jq -r ".productList[$i].productVcode")
  else
    URL="https://www.wpspdf.cn/"
    DOWNLOAD_URL=$(curl -Ls $URL | grep "banner_btn red_btn" | grep -oP "href=\"\K[^\"]+")
  fi
  [ $? -ne 0 ] && echo_log_err "获取下载地址失败"
  
  # 获取文件名
  NAME=$(basename "$DOWNLOAD_URL")
  if [ $i -ne 2 ]; then
    FILENAME="${NAME%.*}-$DOWNLOAD_VER.${NAME#*.}"
  else
    FILENAME="WPS-${OS[i]}${NAME#W.P.S}"
  fi
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${OS[i]}" != "mac" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  [ ! -d "$DOWNLOAD_DIR" ] && mkdir -p $DOWNLOAD_DIR

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "WPS*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "WPS*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
