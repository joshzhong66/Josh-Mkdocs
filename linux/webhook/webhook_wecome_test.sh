#!/bin/bash

# 日志记录函数
log() {
    echo "${log_prefix} [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 配置信息中替换为实际的企微机器人Webhook地址
webhook_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7"

send_notification() {
    local status=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # 构造内容（注意此处换行符处理）
    local content="备份系统通知
================
状态：${status}
时间：${timestamp}
脚本：${script_name}
主机：$(uname -n)
备份目录：${backup_src_dirs[*]}
详细信息：${message}"

    # 企业微信要求换行符为\n
    content=$(echo "${content}" | sed ':a;N;$!ba;s/\n/\\n/g')

    # 正确闭合的JSON结构
    local payload=$(cat <<EOF
{
    "msgtype": "text",
    "text": {
        "content": "${content}"
    }
}
EOF
)

    # 调试时可先注释静默输出
    log "发送payload: ${payload}"
    curl -X POST -H "Content-Type: application/json" \
         -d "${payload}" "${webhook_url}"
}

send_notification