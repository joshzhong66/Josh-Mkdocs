#!/bin/bash

BASE_PATH="/root/.acme.sh"
NGINX_CERT_PATH="/data/nginxWebUI/cert"
NGINX_CONTAINER_NAME="nginxwebui-nginxWebUi-server-1"
WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7"
DOMAINS=$(ls $BASE_PATH)
NGINX_RELOAD=false
MESSAGE=""

send_wechat_message() {
    local content=$1
    if [ -n "$content" ]; then
        echo "发送的消息内容：$content"
        RESPONSE=$(curl -s -X POST -H 'Content-Type: application/json' -d '{
            "msgtype": "text",
            "text": {
                "content": "'"${content}"'"
            }
        }' $WEBHOOK_URL)
        echo "发送结果：$RESPONSE"
    else
        echo "没有需要发送的消息。"
    fi
}

print_certificate_info() {
    local domain=$1
    local mod_date=$2
    local expiry_date_formatted=$3
    local updated=$4

    echo "域名 $domain 的证书最后修改日期为:"
    echo " $mod_date，"
    echo " 下次到期时间为: $expiry_date_formatted。"

    MESSAGE+="域名 $domain 的证书最后修改日期为:\n $mod_date，\n 下次到期时间为: $expiry_date_formatted。\n"
    
    if [ "$updated" = true ]; then
        echo "域名 $domain 的证书最后更新时间为 $mod_date。证书到期日期为: $expiry_date_formatted。"
        MESSAGE+="域名 $domain 的证书最后更新时间为 $mod_date。证书到期日期为: $expiry_date_formatted。\n"
    else
        echo "域名 $domain 的证书未到更新时间，下次到期时间为: $expiry_date_formatted。"
        MESSAGE+="域名 $domain 的证书未到更新时间，下次到期时间为: $expiry_date_formatted。\n"
    fi
}

process_domain() {
    local domain=$1
    local cert_path=$BASE_PATH/$domain/fullchain.cer
    local key_path=$BASE_PATH/$domain/$domain.key
    local nginx_domain_path=$NGINX_CERT_PATH/$domain

    if [[ -f "$cert_path" ]]; then
        local mod_date=$(stat -c %y "$cert_path" | cut -d' ' -f1)
        local expiry_date=$(openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f2)
        local expiry_date_formatted=$(date -d "$expiry_date" +"%Y-%m-%d")

        # 打印所有证书信息
        print_certificate_info "$domain" "$mod_date" "$expiry_date_formatted" false

        if [[ $(find "$cert_path" -mtime -1 -print) ]]; then
            mkdir -p "$nginx_domain_path"
            cp "$cert_path" "$nginx_domain_path/full_chain.pem"
            cp "$key_path" "$nginx_domain_path/private.key"
            NGINX_RELOAD=true
            # 打印并记录成功更新的证书信息
            print_certificate_info "$domain" "$mod_date" "$expiry_date_formatted" true
        fi
    else
        MESSAGE+="域名 $domain 的证书未找到。\n"
    fi
}

main() {
    for domain in $DOMAINS; do
        if [[ "$domain" =~ \.(top|com|cn)$ ]]; then
            process_domain "$domain"
        fi
    done

    if $NGINX_RELOAD; then
        echo "重载 Nginx 配置..."
        docker exec -it $NGINX_CONTAINER_NAME sh -c "nginx -s reload"
    fi

    # 发送所有信息
    send_wechat_message "$MESSAGE"
}

main
