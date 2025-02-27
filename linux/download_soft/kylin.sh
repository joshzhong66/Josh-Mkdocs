#!/bin/bash
#
#########################################
# kylin.sh 同步 Kylin 升级镜像
#########################################
LOG_FILE="/data/script/kylin.log"
URL="https://update.cs2c.com.cn/NS/V10/V10SP2/os/adv/lic/updates/"
LOCAL_DIR="/data/mirrors/kylin/Kylin-Server-10-SP2/update"

# 日志输出
echo_log_info() {
  echo -e "$(date +'%F %T') - [info] $* " | tee -a $LOG_FILE
}
echo_log_err() {
  echo -e "$(date +'%F %T') - [error] $* " | tee -a $LOG_FILE
  exit 1
}

# 检查 lftp 是否安装
if ! command -v lftp &> /dev/null; then
  echo_log_err "lftp 未安装，请先安装 lftp"
fi

# 检查本地目录是否存在
[ ! -d "$LOCAL_DIR" ] && echo_log_err "$LOCAL_DIR 目录不存在"

cd "$LOCAL_DIR" || echo_log_err "无法进入目录 $LOCAL_DIR"
echo_log_info "开始同步"
lftp $URL -e "set ftp:ssl-allow false; \
set http:user-agent 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36'; \
mirror --parallel=4 --verbose --skip-noaccess --only-newer --continue \
--exclude '/debug' --exclude '/x86_64/debug' --exclude '/aarch64/debug' \
--include '/x86_64' --include '/aarch64'; bye" || echo_log_err "lftp 同步失败"
echo_log_info "同步完成" && echo >> $LOG_FILE

