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


function get_cpu() {
    echo_log_info -e "No.\tPID\tCPU(%)\t线程数\t进程名"

    temp_output=""

    for pid in $(ps -eo pid --no-headers); do
        
        cpu_usage=$(ps -p ${pid} -o %cpu --no-headers)  # 获取进程的CPU使用率
        threads=$(cat /proc/${pid}/status 2>/dev/null | grep Threads | awk '{print $2}')    # 获取进程的线程数
        process_name=$(ps -p ${pid} -o comm --no-headers)   # 获取进程的名称


        # 处理进程状态文件可能不存在的情况（跳过）
        if [[ -z "$threads" ]]; then
            threads=0
        fi
        
        #  将数据添加到临时变量中
        temp_output+="${pid}\t${cpu_usage}\t${threads}\t${process_name}\n"
    done
        # 对结果按 CPU 使用率排序并加序号
    echo -e "$temp_output" | sort -k2 -rn | head -n 10 | awk -v count=1 '{printf "%d\t%s\n", count++, $0}' | while read line; do
        echo_log_info -e "$line"
    done
}

function get_memory() {
    echo_log_info -e "No.\tPID\tMem(%)\t线程数\t进程名"

    temp_output=""

    for pid in $(ps -eo pid --no-headers); do
        
        memory_usage=$(ps -p ${pid} -o %mem --no-headers)   # 获取进程的内存使用率
        threads=$(cat /proc/${pid}/status 2>/dev/null | grep Threads | awk '{print $2}')    # 获取进程的线程数
        process_name=$(ps -p ${pid} -o comm --no-headers)   # 获取进程的名称


        # 处理进程状态文件可能不存在的情况（跳过）
        if [[ -z "$threads" ]]; then
            threads=0
        fi
        
        #  将数据添加到临时变量中
        temp_output+="${pid}\t${memory_usage}\t${threads}\t${process_name}\n"
    done
        # 对结果按 CPU 使用率排序并加序号
    echo -e "$temp_output" | sort -k2 -rn | head -n 10 | awk -v count=1 '{printf "%d\t%s\n", count++, $0}' | while read line; do
        echo_log_info -e "$line"
    done

}



function main(){
    get_cpu
    get_memory
}


main