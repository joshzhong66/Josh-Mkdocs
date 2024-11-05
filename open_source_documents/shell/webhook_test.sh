curl -X POST https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7 \
-H "Content-Type: application/json" \
-d '{
    "msgtype": "text",
    "text": {
        "content": "测试消息"
    }
}'