#!/bin/bash

# domain="joshzhong.top"
# port="443"
# ACME_HOME="/root/.acme.sh"
# echo | openssl s_client -servername "${ACME_HOME}/${domain}_ecc/fullchain.cer" -connect "$domain:$port" -showcerts | openssl x509 -noout -dates

EXPIRE_DAYS=11
DIR_PATH=$(dirname "$0")
JSON_FILE="$DIR_PATH/domain.json"
LOG_FILE="$DIR_PATH/sslcert-update.log"
ACME_HOME="/root/.acme.sh"
ACME_CMD="/root/.acme.sh/acme.sh"


if [[ -s $LOG_FILE ]]; then
    count=0
    while [ $count -lt 3 ]
    do
        echo "" >> $LOG_FILE
        count=$((count + 1))
    done
fi

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
}



if ! command -v jq &> /dev/null; then
    yum -y install jq > /dev/null 2>&1
fi

[ ! -f "$JSON_FILE" ] && echo_log_error "$JSON_FILE 文件不存在"

check_ssl_certificate_folder() {
    if [ -d "${ACME_HOME}/${domain}_ecc" ]; then
        echo_log_info "证书目录 ${ACME_HOME}/${domain}_ecc 已存在，跳过证书生成" >> /dev/null 2>&1
        return 0
    else
        echo_log_info "证书${ACME_HOME}/${domain}目录不存在，开始生成证书!"
        $ACME_CMD --issue --dns dns_huaweicloud -d $domain  > /dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "生成证书成功" || { echo_log_error "生成证书失败."; return; }
    fi
}

check_ssl_certificate_maturity() {
    
}

# 获取证书信息
request_cert_info() {
    cert_info=$(echo | openssl s_client -servername "${ACME_HOME}/${domain}_ecc/fullchain.cer" -connect "$domain:$port" -showcerts 2> /dev/null | openssl x509 -noout -dates 2> /dev/null)
    # 获取证书到期时间并转换为时间戳
    cert_end_date=$(echo "$cert_info" | grep 'notAfter' | sed 's/notAfter=//')
    update_end_date=$(date -d "$cert_end_date" +%Y-%m-%d)
    end_date_seconds=$(date -d "$cert_end_date" +%s)
    # 获取当前系统时间戳
    current_date_seconds=$(date +%s)
    # 计算证书剩余天数
    cert_expire_day=$(((end_date_seconds - current_date_seconds) / 86400))
}


check_json_file() {
    echo_log_info "读取${JSON_FILE}文件"
    jq -c 'to_entries[] | {domain: .key, host: .value.host, port: .value.port, cert_file: .value.cert_file, key_file: .value.key_file, app_type: .value.app_type}' "$JSON_FILE" | while IFS= read -r line; do
        domain=$(echo "$line" | jq -r '.domain')
        host=$(echo "$line" | jq -r '.host')
        port=$(echo "$line" | jq -r '.port')
        cert_file=$(echo "$line" | jq -r '.cert_file')
        key_file=$(echo "$line" | jq -r '.key_file')
        app_type=$(echo "$line" | jq -r '.app_type')

        check_ssl_certificate_folder
    done
}

main() {
    check_json_file
}


main