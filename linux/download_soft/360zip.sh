#!/bin/bash
#
#########################################
# 360zip.sh 下载360压缩
#########################################
LOG_FILE="/data/script/360zip.log"
BASE_DIR="/data/mirrors/application/360zip"
CMD="curl -Ls -o"

OS=("win" "mac")

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

for i in "${OS[@]}"; do
  # 获取实际下载地址
  URL="https://yasuo.360.cn/update/versioninfo.json"
  DOWNLOAD_URL=$([[ "${i}" == "win" ]] && echo "http:" || echo "")$(curl -Ls $URL | jq -r ".data.${i}DownloadUrl")
  [[ $DOWNLOAD_URL == "null" ]] && echo_log_err "获取下载地址失败"

  # 获取下载版本
  DOWNLOAD_VER=$(curl -Ls $URL | jq -r ".data.${i}Code")
  [[ $DOWNLOAD_VER == "null" ]] && echo_log_err "获取网页下载版本失败"

  # 获取文件名
  NAME=$(basename "$DOWNLOAD_URL")
  [[ "${i}" == "win" ]] && FILENAME="${NAME[i]%.*}_$DOWNLOAD_VER.${NAME[i]#*.}" || FILENAME=$NAME
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "${i}" == "win" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"

  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
  fi
done

if [ -n "$(find "$BASE_DIR" -type f -name "360zip*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  [ ${#FILENAMES[@]} -ne 0 ] && find "$BASE_DIR" -type f -name "360zip*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -rf {} +
  echo >> $LOG_FILE
fi
