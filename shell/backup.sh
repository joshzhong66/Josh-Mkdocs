#!/bin/bash
#data:2024/09/06
#version:1.0

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

log_file=/data/backup/backup.log
lock_file=/tmp/backup.lock
datetime=$(date +"%Y-%m-%d")
backup_dir=/data/backup
data=/data/scripts
retention_days=30
min_free_space=41943040  # 40GB

function echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m" >> $log_file
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

function backup() {
    [ -e $lock_file ] && echo_log_error "检测到备份进程已存在，请勿重复执行"
    touch $lock_file
    trap "rm -f $lock_file" EXIT

    available_space=$(df $backup_dir | tail -1 | awk '{print $4}')
    if [ $available_space -lt $min_free_space ]; then
        echo_log_error "磁盘空间不足: $available_space KB 可用，至少需要 40 GB"
    fi

    [ ! -d $backup_dir ] && mkdir -p $backup_dir
    echo_log_info "开始备份 $data 数据..."
    cd $backup_dir
    tar -zcvf ${datetime}backup.tar.gz $data > /dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "备份成功" || echo_log_error "备份失败"

    echo_log_info "清理超过 $retention_days 天的备份"
    find $backup_dir/ -name "*.tar.gz" -mtime +$retention_days | xargs rm -f
    [ $? -eq 0 ] && echo_log_info "清理备份完成" || echo_log_error "清理备份失败"
}

function main() {
    backup
}

main