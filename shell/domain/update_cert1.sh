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



restart_app() {
  if [[ $app_type == "docker" ]]; then
    docker exec nginxwebui nginx -s reload > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo_log_info "重启目标服务器[$host]: nginx成功"
    else
            echo_log_error "重启目标服务器[$host]: nginx失败"
        fi
    fi
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

        acme_cert_file=$ACME_HOME/${domain}_ecc/fullchain.cer
        acme_key_file=$ACME_HOME/${domain}_ecc/${domain}.key

        if [ ! -f "$acme_cert_file" ]; then
            echo_log_info "证书${acme_cert_file}文件不存在，开始生成证书!"
            $ACME_CMD --issue -d $domain --dns dns_huaweicloud > /dev/null 2>&1
            [ $? -eq 0 ] && echo_log_info "生成证书成功" || { echo_log_error "生成证书失败."; return; }
            cp "${acme_cert_file}" "${cert_file}" > /dev/null 2>&1
            cp "${acme_key_file}" "${key_file}" > /dev/null 2>&1
            restart_app
        fi

        cert_info=$(echo | openssl s_client -servername "$domain" -connect "$domain:$port" -showcerts 2> /dev/null | openssl x509 -noout -dates 2> /dev/null)
        [[ $? -ne 0 ]] && echo_log_error "获取[$domain:$port]证书信息失败"
    
        # 获取证书到期时间并转换为时间戳
        cert_end_date=$(echo "$cert_info" | grep 'notAfter' | sed 's/notAfter=//')
        update_end_date=$(date -d "$cert_end_date" +%Y-%m-%d)
        end_date_seconds=$(date -d "$cert_end_date" +%s)
        # 获取当前系统时间戳
        current_date_seconds=$(date +%s)
        # 计算证书剩余天数
        cert_expire_day=$(((end_date_seconds - current_date_seconds) / 86400))

        if [[ $cert_expire_day -le $EXPIRE_DAYS ]]; then
            echo_log_info "域名[$domain],[$cert_expire_day]天后过期,开始更新证书"
            $ACME_CMD --issue -d $domain --dns dns_huaweicloud > /dev/null 2>&1
            [ $? -eq 0 ] && echo_log_info "更新证书成功" || { echo_log_error "更新证书失败."; return; }
            cp "${acme_cert_file}" "${cert_file}" > /dev/null 2>&1
            cp "${acme_key_file}" "${key_file}" > /dev/null 2>&1
            restart_app
        fi
    done
}

main() {
    check_json_file
}


main