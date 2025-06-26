#!/bin/bash

# yum install -y zip unzip expect jq

JSON_FILE="switch_list.json"
OUT_DIR="./sw_back_conf"
DATE=$(date +%Y%m%d)
ZIP_FILE="switch_backup_${DATE}.zip"

if [ ! -f "$JSON_FILE" ]; then
    echo "未找到 JSON 文件：$JSON_FILE"
    exit 1
fi

if [ ! -d "$OUT_DIR" ]; then
    mkdir -p "$OUT_DIR"
fi

> backup_error.log
> backup_success.log

echo_log() {
    local color="$1"; shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_error() {
    local msg="$*"
    echo_log "\033[31mERROR" "$msg"
    echo "$(date +'%F %T') - ERROR - $msg" >> backup_error.log
}
echo_log_success() {
    local msg="$*"
    echo_log "\033[32mSUCCESS" "$msg"
    echo "$(date +'%F %T') - SUCCESS - $msg" >> backup_success.log
}


# 单台设备 expect 备份函数
backup_one_switch() {
    local ip="$1"
    local username="$2"
    local password="$3"
    local outfile="$4"

    expect <<EOF
        set timeout 30
        spawn ssh -o StrictHostKeyChecking=no -l $username $ip

        expect {
            "*yes/no" { send "yes\r"; exp_continue }
            "*assword:" { send "$password\r" }
            timeout { exit 1 }
            eof { exit 1 }
        }

        expect "*>"
        send "display current-configuration\r"
        log_file -noappend $outfile

        expect {
            "*More ----" { send " "; exp_continue }
            "return" { log_file; send "\r"; exp_continue }
            "*>"
        }

        send "\r"
        sleep 1
        send "quit\r"
        expect eof
EOF
}

# 清洗输出：保留 display 部分
clean_output() {
    local rawfile="$1"
    if [ -f "$rawfile" ]; then
        awk '/^!Software Version/,/^return$/' "$rawfile" | tr -d '\r' > "${rawfile}.tmp" && mv "${rawfile}.tmp" "$rawfile"
    else
        echo_log_error "未生成配置文件：$rawfile"
    fi
}

# 单设备任务入口（用于 xargs 并发调用）
if [[ "$1" == "single" ]]; then
    region="$2"
    ip="$3"
    username="$4"
    password="$5"
    outfile="${OUT_DIR}/${region}_sw_${DATE}_${ip}.conf"
    backup_one_switch "$ip" "$username" "$password" "$outfile" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo_log_error "[$region][$ip] 登录或备份失败"
    else
        clean_output "$outfile"
        echo_log_success "[$region][$ip] 备份成功：$outfile"
    fi
    exit 0
fi

# 构建 task 列表
regions=$(jq -r 'keys[]' "$JSON_FILE")
> tasklist.txt

for region in $regions; do
    count=$(jq ".\"$region\" | length" "$JSON_FILE")
    for ((i=0; i<$count; i++)); do
        ip=$(jq -r ".\"$region\"[$i].ip" "$JSON_FILE")
        username=$(jq -r ".\"$region\"[$i].username" "$JSON_FILE")
        password=$(jq -r ".\"$region\"[$i].password" "$JSON_FILE")
        echo "bash $0 single \"$region\" \"$ip\" \"$username\" \"$password\"" >> tasklist.txt
    done
done

# 并发执行备份（默认最多5个线程）
cat tasklist.txt | xargs -P 5 -n 1 -I{} bash -c "{}"
rm -f tasklist.txt

# 打包压缩
zip -qr "$ZIP_FILE" "$OUT_DIR"
echo_log "\033[33mZIP" "已压缩为 $ZIP_FILE"

# webhook 发送结果通知
total=$(wc -l < backup_success.log)
failed=$(wc -l < backup_error.log)

curl -s -X POST -H "Content-Type: application/json" -d "{
    \"title\": \"交换机配置备份报告\",
    \"date\": \"$(date +'%F %T')\",
    \"success\": $total,
    \"failed\": $failed,
    \"file\": \"$ZIP_FILE\"
}" "$WEBHOOK_URL" >/dev/null

echo_log "\033[34mWEBHOOK" "结果已推送到 Webhook"
echo_log "\033[32mFINISH" "所有任务完成"