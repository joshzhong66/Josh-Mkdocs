#!/bin/bash
#
#########################################
# chrome.sh 下载谷歌浏览器
#########################################
LOG_FILE="/data/script/chrome.log"
BASE_DIR="/data/mirrors/application/chrome"
CMD="curl -Ls -o"

OS=("win" "mac")

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
    echo_log_info "$BASE_DIR 目录不存在，正在创建..."
    mkdir -p "$BASE_DIR" || echo_log_err "无法创建目录 $BASE_DIR"
    echo_log_info "$BASE_DIR 目录创建成功"
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
  # 获取下载包大小
  [[ "${i}" == "win" ]] && DOWNLOAD_URL="https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B3352BF67-38A0-3B25-A3DD-B671FE1781A2%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup64.exe" || DOWNLOAD_URL="https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
  [[ ! $(curl -LsI $DOWNLOAD_URL | grep "200 OK") ]] && echo_log_err "获取下载包大小失败"
  DOWNLOAD_SIZE=$(curl -LsI $DOWNLOAD_URL | grep Content-Length | awk '{print $2}')

  # 获取文件名
  FILENAME=$(basename "$DOWNLOAD_URL")

  # 设置下载目录
  if [[ "${i}" == "win" ]]; then
    DOWNLOAD_DIR="$BASE_DIR/win"
  else
    DOWNLOAD_DIR="$BASE_DIR/mac"
  fi

  [ ! -d "$DOWNLOAD_DIR" ] && mkdir -p $DOWNLOAD_DIR 

  LOCALFILE="$DOWNLOAD_DIR/$FILENAME"

  if [[ ! "$DOWNLOAD_SIZE" =~ "$(stat --format=%s $LOCALFILE 2>/dev/null)" ]] || [ ! -f "$LOCALFILE" ]; then
    echo_log_info "开始下载 $DOWNLOAD_URL"
    rm -f $LOCALFILE
    $CMD "$LOCALFILE" "$DOWNLOAD_URL" || echo_log_err "下载失败：$DOWNLOAD_URL"
    [[ "${i}" == "mac" ]] && echo >> $LOG_FILE
  fi
done
