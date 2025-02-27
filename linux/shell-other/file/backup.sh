#!/bin/bash

<< 'COMMENT'
comment：
1）备份服务器的/data目录下的所有文件，并压缩为tar.gz文件，文件名格式为：yyyy-mm-dd.tar.gz
2) 删除30天前的备份文件
3) 磁盘空间换算
    1 GB = 1024 MB
    1 MB = 1024 KB
    1 GB = 1024 * 1024 = 1048576 KB 
COMMENT

set -e

LOG_FILE=/data/backup/backup.log
LOCK_FILE=/tmp/backup.lock
DATETIME=$(date +"%Y-%m-%d")
BACKUP_DIR=/data/backup
SCRIPTS_DIR=/data/scripts
RETENTION_DAYS=30
MIN_FREE_SPACE=1048576  # 1GB

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m" >> $LOG_FILE
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

backup() {
    [ -e $LOCK_FILE ] && echo_log_error "备份进程已存在，勿重复执行..."
    touch $LOCK_FILE
    trap "rm -f $LOCK_FILE" EXIT

    available_space=$(df $BACKUP_DIR | tail -1 | awk '{print $4}')
    if [ $available_space -lt $MIN_FREE_SPACE ]; then
        echo_log_error "磁盘空间不足: $available_space KB可用，至少需要 40 GB"
    fi

    [ -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR
    echo_log_info "开始备份 $SCRIPTS_DIR 数据..."
    cd $BACKUP_DIR
    tar -czf ${datetime}backup.tar.gz $SCRIPTS_DIR > /dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "备份成功" || echo_log_error "备份失败"

    echo_log_info "清理超过 $RETENTION_DAYS 天的备份"
    find $BACKUP_DIR/ -name "*.tar.gz" -mtime +$RETENTION_DAYS | xargs rm -f
    [ $? -eq 0 ] && echo_log_info "清理备份完成" || echo_log_error "清理备份失败"
}


main() {
    backup
}

main