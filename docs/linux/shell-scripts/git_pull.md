# 3.git_pull.sh

```
#!/bin/bash


function echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}

function echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}

function echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}

function echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

function git_pull(){
    cd /data/Mkdocs/Josh-Mkdocs
    if ! git pull origin master >/dev/null 2>&1; then
        # 如果拉取失败，发送 webhook 通知
        curl -X POST -H 'Content-type: application/json' \
        '{"text":"Git pull failed on /data/Mkdocs/Josh-Mkdocs"}' \
        https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7

        echo_log_error "Code pull failed" >> /data/Mkdocs/Josh-Mkdocs/pull_code.log
    else
        echo_log_info "Code pulled successfully" >> /data/Mkdocs/Josh-Mkdocs/pull_code.log
    fi
}



main() {
    git_pull
}


main

```

