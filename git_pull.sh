#!/bin/bash

LOG_FILE="/data/Mkdocs/Josh-Mkdocs/pull_code.log"

echo_log_info() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] $message" | tee -a "$LOG_FILE"
}

echo_log_error() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] $message" | tee -a "$LOG_FILE"
}

git_pull() {
    cd /data/Mkdocs/Josh-Mkdocs
    if ! git pull origin master >/dev/null 2>&1; then
        curl -X POST -H 'Content-type: application/json' \
        '{"text":"Git pull failed on /data/Mkdocs/Josh-Mkdocs"}' \
        https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7
        
        echo_log_error "Code pull failed"
    else
        echo_log_info "Code pulled successfully"
    fi

    systemctl restart mkdocs
    [ $? -eq 0 ] && echo_log_info "Mkdocs Service restart successfully" || { echo_log_error "Mkdocs Service restart fail!"; return;}
}


delete_log() {
    THREE_DAYS_AGO=$(date -d "3 days ago" +%Y-%m-%d)
    TEMP_FILE=$(mktemp) # 存储保留日志

    awk -v date="$THREE_DAYS_AGO" '{
        log_date = substr($0, 1, 10); # 提取日志的日期部分 YYYY-MM-DD
        if (log_date >= date) print $0;
    }' "$LOG_FILE" > "$TEMP_FILE"

    mv "$TEMP_FILE" "$LOG_FILE"
    echo_log_info "已清除超过3天的日志。"

    git add . >/dev/null 2>&1
    git commit -m "提交所有更改，包括新增文件" >/dev/null 2>&1
    git push origin master >/dev/null 2>&1
}

main() {
    git_pull
    delete_log
}

main
