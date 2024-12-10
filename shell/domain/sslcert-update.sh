#!/bin/bash

####################################
# File Name: sslcert-update.sh
# Function: 华为云 DNS证书自动更新脚本
# Version: V1.0
# Update: 2024-07-26
####################################

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
    echo_log_info "jq Not installed"
    yum -y install jq > /dev/null 2>&1
fi

# 获取证书信息
request_cert_info() {
    #_log_info "openssl s_client -servername "${ACME_HOME}/${domain}_ecc/fullchain.cer" -connect "$domain:$port" -showcerts 2> /dev/null | openssl x509 -noout -dates"
    cert_info=$(echo | openssl s_client -servername "${ACME_HOME}/${domain}_ecc/fullchain.cer" -connect "$domain:$port" -showcerts 2> /dev/null | openssl x509 -noout -dates 2> /dev/null)
    echo_log_info "获取[$domain:$port]证书信息"
    [[ $? -ne 0 ]] && _log_err "获取[$domain:$port]证书信息失败"
    # 获取证书到期时间并转换为时间戳
    cert_end_date=$(echo "$cert_info" | grep 'notAfter' | sed 's/notAfter=//')
    update_end_date=$(date -d "$cert_end_date" +%Y-%m-%d)
    end_date_seconds=$(date -d "$cert_end_date" +%s)
    # 获取当前系统时间戳
    current_date_seconds=$(date +%s)
    # 计算证书剩余天数
    cert_expire_day=$(((end_date_seconds - current_date_seconds) / 86400))
}

acme_generate_cert() {
    if [ ! -d "${ACME_HOME}/${domain}_ecc" ]; then
        #echo_log_info "证书${ACME_HOME}/${domain}目录不存在，开始生成证书!"
        #echo_log_info "$ACME_CMD --issue --dns dns_huaweicloud -d $domain"
        $ACME_CMD --issue --dns dns_huaweicloud -d $domain  > /dev/null 2>&1
        [ $? -eq 0 ] && _log_info "生成证书成功" || { _log_err "生成证书失败"; }
    else
        #echo_log_info "证书目录 ${ACME_HOME}/${domain}_ecc 已存在，跳过证书生成"
        #echo_log_info "检查证书到期时间"
        request_cert_info "${ACME_HOME}/${domain}_ecc/fullchain.cer" "$port"
        if [[ $cert_expire_day -gt $EXPIRE_DAYS ]]; then
            echo_log_info "证书未过期，跳过更新"
        else
            _log_info "证书已过期，开始更新"
            acme_update_cert "$domain"
        fi
    fi
}


# 通过acme.sh更新证书
function acme_update_cert() {
    _log_info "$ACME_CMD --issue -d $domain --dns dns_huaweicloud -d $domain"
    $ACME_CMD --issue -d $domain --dns dns_huaweicloud -d $domain
    if [[ $? == 0 ]]; then
        echo "---------------------------------------------------"
    _log_info "acme.sh 更新域名[$domain]成功"
    else
        echo "---------------------------------------------------"
        _log_info "acme.sh 更新域名[$domain]失败"
    fi
}

# 检查证书文件
function check_cert_file() {
    # 判断证书文件是否存在
    #[[ ! -f "$cert_file" ]] && _log_err "$cert_file 文件不存在" && return 1

    # 检测acme.sh更新后的证书文件是否存在
    acme_cert_file=$ACME_HOME/${domain}_ecc/fullchain.cer
    acme_key_file=$ACME_HOME/${domain}_ecc/${domain}.key
    [[ ! -f "$acme_cert_file" ]] && _log_err "证书${acme_cert_file}文件不存在" && return 1

    # 通过比对md5sum值判断是否更新服务器证书
    srv_cert_file_md5=$(md5sum "$cert_file" | awk '{print $1}')
    acme_cert_file_md5=$(md5sum "$acme_cert_file" | awk '{print $1}')
    
    # 检查证书文件是否在过去24小时内被修改过
    if [[ $(find "$acme_cert_file" -mtime -1) ]] || [[ "$srv_cert_file_md5" != "$acme_cert_file_md5" ]] ; then
        _log_info "证书${acme_cert_file}的md5值不相等或证书文件在24小时内已更新"
        
        # 如果证书在24小时内修改过且md5值不相等，则更新证书
        cp "${acme_cert_file}" "${cert_file}" > /dev/null 2>&1
        cp "${acme_key_file}" "${key_file}" > /dev/null 2>&1
        
        if [[ $? -eq 0 ]]; then
            _log_info "更新目标服务器[$host]证书[$cert_file]成功"
            restart_app "$host" "$app_type"
        else
            _log_err "更新目标服务器[$host]证书[$cert_file]失败"
        fi
    else
        _log_info "证书${acme_cert_file}未在过去24小时内更新，跳过更新"
    fi
}


# 重启应用服务
function restart_app() {
  if [[ $app_type == "docker" ]]; then
    docker exec nginxwebui nginx -s reload > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            _log_info "重启目标服务器[$host]: nginx成功"
    else
            _log_err "重启目标服务器[$host]: nginx失败"
        fi
    fi
}

function check_cert_expire() {
    # 判断json文件是否存在
    [[ ! -f "$JSON_FILE" ]] && _log_err "$JSON_FILE 文件不存在"
    _log_info "读取${JSON_FILE}文件"
    jq -c 'to_entries[] | {domain: .key, host: .value.host, port: .value.port, cert_file: .value.cert_file, key_file: .value.key_file, app_type: .value.app_type}' "$JSON_FILE" | while IFS= read -r line; do
        domain=$(echo "$line" | jq -r '.domain')
        host=$(echo "$line" | jq -r '.host')
        port=$(echo "$line" | jq -r '.port')
        cert_file=$(echo "$line" | jq -r '.cert_file')
        key_file=$(echo "$line" | jq -r '.key_file')
        app_type=$(echo "$line" | jq -r '.app_type')

        acme_generate_cert
        check_cert_file
        
        if [[ $cert_expire_day -le $EXPIRE_DAYS ]]; then
            # 通过acme.sh更新证书
            _log_info "域名[$domain],[$cert_expire_day]天后过期,开始更新证书"
            echo "---------------------------------------------------"
            acme_update_cert "$domain" 

            # 检测acme.sh更新后的证书文件是否存在
            acme_cert_file=$ACME_HOME/${domain}_ecc/fullchain.cer
            acme_key_file=$ACME_HOME/${domain}_ecc/${domain}.key
            [[ ! -f "$acme_cert_file" ]] && _log_err "证书${acme_cert_file}文件不存在"

            # 通过比对md5sum值判断是否更新服务器证书
            srv_cert_file_md5=$(md5sum $cert_file| awk '{print $1}')
            acme_cert_file_md5=$(md5sum "$acme_cert_file" | awk '{print $1}')

            # 通过ansible更新目标服务器证书
            if [[ "$srv_cert_file_md5" != "$acme_cert_file_md5" ]]; then
                cp ${acme_cert_file} ${cert_file} > /dev/null 2>&1
                cp ${acme_key_file} ${key_file} > /dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                _log_info "更新目标服务器[$host]证书[$cert_file]成功"
                restart_app "$host" "$app_type"
                else
                _log_err "更新目标服务器[$host]证书[$cert_file]失败"
                fi
            fi

            # 更新后获取使用中证书信息
            sleep 10
            request_cert_info "$domain" "$port"

            if [[ $cert_expire_day -gt $EXPIRE_DAYS ]]; then
            curl -s -X POST -H 'Content-Type: application/json' -d "{
                \"msgtype\": \"text\",
                \"text\": {
                    \"content\": \"更新域名 $domain 成功, $update_end_date 后过期。\"
                }
            }" "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=05154f52-3b88-4a35-a143-ef7d8f7494f1"
            _log_info "更新域名[$domain]成功,[$update_end_date]后过期"
            else
            curl -s -X POST -H 'Content-Type: application/json' -d "{
                \"msgtype\": \"text\",
                \"text\": {
                    \"content\": \"更新域名 $domain 异常,请检查日志。\"
                }
            }" "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=05154f52-3b88-4a35-a143-ef7d8f7494f1"
            _log_err "更新域名[$domain]异常,请检查"
            fi
        fi
    done
}

function main() {
    check_cert_expire
}

main
