#!/bin/bash

# Zabbix API 服务器地址
ZABBIX_URL="http://10.22.51.66/api_jsonrpc.php"
ZABBIX_USER="Admin"
ZABBIX_PASSWORD="zabbix"

# 获取 Zabbix API 认证令牌
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

# 确保获取到认证令牌
if [ "$AUTH_TOKEN" == "null" ] || [ -z "$AUTH_TOKEN" ]; then
    echo "❌ 认证失败，检查 Zabbix 用户名和密码"
    exit 1
fi
echo "✅ 认证成功，Token: $AUTH_TOKEN"

# 目标主机名（需要创建监控项的主机）
TARGET_HOST="68"

# 获取主机 ID
HOST_ID=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{
        \"jsonrpc\": \"2.0\",
        \"method\": \"host.get\",
        \"params\": {
            \"filter\": {\"host\": [\"$TARGET_HOST\"]}
        },
        \"auth\": \"$AUTH_TOKEN\",
        \"id\": 2
    }" \
    $ZABBIX_URL | jq -r '.result[0].hostid')

if [ -z "$HOST_ID" ] || [ "$HOST_ID" == "null" ]; then
    echo "❌ 主机 $TARGET_HOST 未找到"
    exit 1
fi
echo "✅ 获取主机 ID: $HOST_ID"

# 创建 CPU 监控项
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
    echo "❌ 创建监控项失败"
    exit 1
fi
echo "✅ 监控项创建成功，Item ID: $ITEM_CREATE"

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
echo "✅ 已注销 API 认证"

