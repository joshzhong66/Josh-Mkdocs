#!/bin/bash

# Zabbix Server & Agent 配置
ZABBIX_SERVER="10.22.51.66"
AGENT_HOST="10.22.51.68"  # 需要监控的客户端 IP / 主机名
ZABBIX_URL="http://$ZABBIX_SERVER/api_jsonrpc.php"
ZABBIX_USER="Admin"
ZABBIX_PASSWORD="zabbix"
AGENT_DIR="/usr/local/zabbix_agent/"


# 通用日志函数
echo_log() {
    local color_code="$1"
    local log_level="$2"
    shift 2  # 移出颜色和日志级别参数

    # 组装带颜色的日志前缀
    local timestamp
    timestamp=$(date +'%F %T')
    local log_prefix="${timestamp} -[\033[${color_code}m${log_level}\033[0m]"

    # 输出带格式的日志
    echo -e "${log_prefix} $*"
}

# 信息日志（绿色）
echo_log_info() {
    echo_log "32" "INFO" "$@"
}

# 警告日志（黄色）
echo_log_warn() {
    echo_log "33" "WARN" "$@"
}

# 错误日志（红色）
echo_log_error() {
    echo_log "31" "ERROR" "$@"
    exit 1  # 可根据需要决定是否退出
}

# 成功日志（绿色加粗）
echo_log_success() {
    echo_log "1;32" "SUCCESS" "$@"
}

# 标题日志（蓝色加粗）
echo_log_header() {
    echo_log "1;34" "HEADER" "$@"
}

echo "检查 $AGENT_HOST 是否安装 Zabbix Agent..."
ssh root@$AGENT_HOST "[[ -d \"$AGENT_DIR\" ]]"
if [ $? -ne 0 ]; then
    echo_log_error "$AGENT_HOST 未安装 Zabbix Agent！请先安装。"
fi
echo_log_info "$AGENT_HOST 已安装 Zabbix Agent"


echo_log_info "检查 $AGENT_HOST 上 Zabbix Agent 是否监听端口 10050..."
ssh root@$AGENT_HOST "netstat -tulnp | grep -q ':10050'"
if [ $? -ne 0 ]; then
    echo "$AGENT_HOST 的 Zabbix Agent 未监听 10050 端口！尝试启动..."
    ssh root@$AGENT_HOST "systemctl start zabbix-agent && systemctl enable zabbix-agent"
    sleep 3
    ssh root@$AGENT_HOST "netstat -tulnp | grep -q ':10050'"
    if [ $? -ne 0 ]; then
        echo_log_success "启动 Zabbix Agent 失败，请手动检查！"
        exit 1
    fi
fi
echo_log_success "Zabbix Agent 运行正常，监听端口 10050"

# 配置psk文件
if [ ! -d "/usr/local/zabbix_agent/etc/" ]; then
    mkdir -p /usr/local/zabbix_agent/etc/
fi

# 创建或更新 PSK 文件
if [ ! -f /usr/local/zabbix_agent/etc/zabbix_agentd.psk ]; then
    cat > /usr/local/zabbix_agent/etc/zabbix_agentd.psk <<EOF
0ac9ae633e35740ea4624ac9a91f80fe98d6bc897e9a244716bae16899a402d4
EOF
    chmod 600 /usr/local/zabbix_agent/etc/zabbix_agentd.psk
    chown zabbix:zabbix /usr/local/zabbix_agent/etc/zabbix_agentd.psk
    echo "Zabbix Agent PSK file created successfully."
else
    echo "Zabbix Agent PSK file already exists, skipping creation."
fi


# 定义需要检测的依赖列表
commands=("nc" "curl" "wget" "jq")

# 遍历每个命令进行检查
for cmd in "${commands[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        echo "INFO: $cmd 命令已安装，继续下一步..."
    else
        echo "WARN: $cmd 命令未安装，正在通过 yum 安装..."
        yum install -y "$cmd" >/dev/null 2>&1

        # 检查安装结果
        if [ $? -eq 0 ]; then
            echo "SUCCESS: $cmd 安装成功！"
        else
            echo "ERROR: $cmd 安装失败，请手动处理！"
            exit 1  # 可选：终止脚本执行
        fi
    fi
done


# 检查 Zabbix Server 是否能连接到 Agent
echo_log_info "🔍 检查 Zabbix Server 是否能连接到 Agent..."

nc -z -v $AGENT_HOST 10050
if [ $? -ne 0 ]; then
    echo_log_error "无法连接到 $AGENT_HOST:10050（Agent 端口），请检查防火墙！"
fi
echo_log_success "Zabbix Server 可以访问 $AGENT_HOST:10050"

# 获取 Zabbix API 认证令牌
echo "获取 Zabbix API Token..."
AUTH_TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"user.login\",
        \"params\": {
            \"username\": \"$ZABBIX_USER\",
            \"password\": \"$ZABBIX_PASSWORD\"
        },
        \"id\": 1
    }" \
    $ZABBIX_URL | jq -r '.result')

if [ "$AUTH_TOKEN" == "null" ] || [ -z "$AUTH_TOKEN" ]; then
    echo_log_error "Zabbix API 认证失败，请检查用户名和密码！"
fi
echo_log_success "Zabbix API 认证成功"


echo_log_info "查询 $AGENT_HOST 在 Zabbix 中的主机 ID..."
HOST_ID=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"host.get\",
        \"params\": {
            \"filter\": {\"host\": [\"$AGENT_HOST\"]}
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 2
    }" \
    $ZABBIX_URL | jq -r '.result[0].hostid')



# 如果主机ID不存在，则自动创建
if [ -z "$HOST_ID" ] || [ "$HOST_ID" == "null" ]; then
    echo_log_info "主机 $AGENT_HOST 不存在，正在创建..."

    HOST_ID=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"host.create\",
            \"params\": {
                \"host\": \"$AGENT_HOST\",
                \"interfaces\": [{
                    \"type\": 1,
                    \"main\": 1,
                    \"useip\": 1,
                    \"ip\": \"$AGENT_HOST\",
                    \"dns\": \"\",
                    \"port\": \"10050\"
                }],
                \"groups\": [{\"groupid\": \"$GROUP_ID\"}],
                \"templates\": [{\"templateid\": \"10001\"}]
            },
            \"auth\": \"$AUTH_TOKEN\",
            \"id\": 3
        }" \
        $ZABBIX_URL | jq -r '.result.hostids[0]')

    if [ -z "$HOST_ID" ] || [ "$HOST_ID" == "null" ]; then
        echo_log_error "创建主机失败，请检查 API 权限！"
        exit 1
    fi
    echo_log_success "主机 $AGENT_HOST 创建成功，ID: $HOST_ID"
else
    echo_log_info "主机已存在，ID: $HOST_ID"
fi

# 创建 CPU 监控项
echo_log_info "创建 CPU 使用率监控项..."
ITEM_CREATE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"item.create\",
        \"params\": {
            \"name\": \"CPU使用率\",
            \"key_\": \"system.cpu.util[,idle]\",
            \"hostid\": \"$HOST_ID\",
            \"type\": 0,
            \"value_type\": 0,
            \"delay\": \"10s\",
            \"units\": \"%\",
            \"preprocessing\": [
                {
                    \"type\": 13,
                    \"params\": \"return 100 - value;\"
                }
            ]
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 3
    }" \
    $ZABBIX_URL | jq -r '.result.itemids[0]')

if [ -z "$ITEM_CREATE" ] || [ "$ITEM_CREATE" == "null" ]; then
    echo_log_error "创建 CPU 监控项失败，请检查 API 调用！"
fi
echo_log_info "监控项创建成功，Item ID: $ITEM_CREATE"

# 退出 API
curl -s -X POST -H "Content-Type: application/json" \
    -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"user.logout\",
        \"params\": [],
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 4
    }" \
    $ZABBIX_URL > /dev/null
echo_log_info "API 认证已注销"

echo_log_info "已成功为 $AGENT_HOST 添加 CPU 监控项！"
