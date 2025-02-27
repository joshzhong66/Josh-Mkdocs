#!/bin/bash
#
#########################################
# sunlogin.sh 下载向日葵远程
#########################################
LOG_FILE="/data/script/sunlogin.log"
BASE_DIR="/data/mirrors/application/sunlogin"
CMD="curl -Ls -o"

# 65表示windows，89表示mac_x86_64，187表示mac_arm64
OS=("65" "89" "187")
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



# 定义基础参数
MAX_RETRY=3               # 最大重试次数
TIMEOUT=15                # 单次请求超时（秒）
REFERER="https://sunlogin.oray.com/"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

for i in "${OS[@]}"; do
  # 获取实际下载地址（添加请求头）
  URL="https://client-api.oray.com/softwares/${i}/download"
  DOWNLOAD_URL=$(curl -sL \
    --max-time $TIMEOUT \
    --max-redirs 3 \
    --header "Referer: $REFERER" \
    --user-agent "$USER_AGENT" \
    -w '%{url_effective}' \
    -o /dev/null \
    "$URL")

  # 验证下载地址有效性
  if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == *error* ]]; then
    echo_log_err "获取下载地址失败: $URL"
    continue
  fi

  # 清理URL中的查询参数（防止文件名含?导致问题）
  CLEAN_URL="${DOWNLOAD_URL%%\?*}"
  FILENAME=$(basename "$CLEAN_URL")
  FILENAMES+=("$FILENAME")

  # 设置下载目录
  if [[ "$i" == "65" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  # 创建目录（如果不存在）
  mkdir -p "$DOWNLOAD_DIR"

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"
  TEMP_FILE="${LOCALFILE}.tmp"  # 临时文件避免下载中途被读取

  # 仅当文件不存在时下载
  if [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载: $FILENAME"
    
    # 带重试机制的下载
    RETRY=0
    while [ $RETRY -lt $MAX_RETRY ]; do
      if $CMD \
        --header "Referer: $REFERER" \
        --user-agent "$USER_AGENT" \
        --connect-timeout $TIMEOUT \
        --output "$TEMP_FILE" \
        "$DOWNLOAD_URL"; then
        
        # 验证文件完整性（示例：检查文件大小）
        if [ -s "$TEMP_FILE" ]; then
          mv "$TEMP_FILE" "$LOCALFILE"
          echo_log_info "下载成功: $FILENAME"
          break
        else
          echo_log_err "文件为空: $FILENAME"
          rm -f "$TEMP_FILE"
        fi
      fi

      ((RETRY++))
      echo_log_info "第 $RETRY 次重试: $FILENAME"
      sleep 2
    done

    # 最终失败处理
    if [ $RETRY -eq $MAX_RETRY ]; then
      echo_log_err "下载失败: $FILENAME"
      rm -f "$TEMP_FILE"
    fi
  fi
done

# 清理旧版本（精确匹配）
if [ -n "$(find "$BASE_DIR" -type f -name "SunloginClient_*" $(printf "! -name %s " "${FILENAMES[@]}"))" ]; then
  echo_log_info "清理旧版本文件"
  find "$BASE_DIR" -type f -name "SunloginClient_*" $(printf "! -name %s " "${FILENAMES[@]}") -exec rm -f {} +
  echo >> $LOG_FILE
fi