#!/bin/bash

# 启用严格模式，增强脚本健壮性
set -euo pipefail

# 配置信息
backup_src_dirs=("/data/easyimage" "/data/wiki")  # 源目录数组
remote_user="root"                                # 远端服务器用户名
remote_host="10.22.51.64"                         # 远端服务器IP地址
remote_dir="/data/backup_勿删"                    # 远端备份目录
local_temp_dir="/tmp/backup_$(date +%Y%m%d%H%M)"  # 本地临时目录（带时间戳防冲突）
max_retries=3                                     # 失败操作最大重试次数
webhook_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=d575ce0e-6af6-4176-af18-56491df6b2e7"
log_prefix="[BACKUP]"                             # 日志前缀标识
script_name=$(basename "$0")                      # 获取脚本名称
retention_days=30                                 # 备份保留天数


# 日志记录函数
log() {
    echo "${log_prefix} [$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 清理临时目录函数
cleanup() {
    if [[ -d "${local_temp_dir}" ]]; then
        log "正在清理临时目录：${local_temp_dir}"
        rm -rf "${local_temp_dir}" || {
            log "错误：临时目录清理失败"
            exit 3
        }
    fi
}

# 带重试机制的命令执行函数
run_with_retry() {
    local retry=0
    until "$@"; do
        ((retry++))
        if ((retry >= max_retries)); then
            log "操作失败：命令 '$*' 达到最大重试次数 ${max_retries}"
            return 1
        fi
        log "命令 '$*' 失败，正在重试 (${retry}/${max_retries})..."
        sleep 2
    done
}

# 通知发送函数

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

# 注册退出清理钩子
trap 'exit_status=$?; \
      if [[ $exit_status -eq 0 ]]; then \
          send_notification "SUCCESS" "备份任务成功完成"; \
      else \
          send_notification "ERROR" "备份失败，退出代码：$exit_status"; \
      fi; \
      cleanup' EXIT

# 预检目录存在性
log "正在执行预检..."
for dir in "${backup_src_dirs[@]}"; do
    if [[ ! -d "${dir}" ]]; then
        log "错误：源目录 ${dir} 不存在或不可访问"
        exit 2
    fi
done

# 创建临时目录
log "正在创建临时目录：${local_temp_dir}"
mkdir -p "${local_temp_dir}" || {
    log "错误：无法创建临时目录"
    exit 1
}

# 打包处理函数
pack_directory() {
    local src_dir="$1"
    local output_path="$2"
    local dir_name=$(basename "${src_dir}")
    
    log "正在打包目录：${src_dir}"
    run_with_retry tar -czf "${output_path}" -C "$(dirname "${src_dir}")" "${dir_name}" || {
        log "错误：打包目录 ${src_dir} 失败"
        exit 4
    }
    log "完成打包：${output_path} (大小: $(du -sh "${output_path}" | cut -f1))"
}

# 执行打包操作
for src_dir in "${backup_src_dirs[@]}"; do
    timestamp=$(date +%Y%m%d_%H%M)
    output_file="${local_temp_dir}/${timestamp}_$(basename "${src_dir}").tar.gz"
    pack_directory "${src_dir}" "${output_file}"
done

# 执行远程同步
log "正在向远程服务器同步数据..."
run_with_retry rsync -avh --progress --stats "${local_temp_dir}/" "${remote_user}@${remote_host}:${remote_dir}" || {
    log "错误：远程同步失败"
    exit 5
}

log "所有备份任务已完成，数据已成功同步至 ${remote_host}:${remote_dir}"


# 远程清理旧备份函数
clean_remote_backups() {
    log "正在清理远程超过 ${retention_days} 天的备份文件..."
    
    # 安全删除操作（先列出将被删除的文件）
    local dry_run_output
    dry_run_output=$(run_with_retry ssh "${remote_user}@${remote_host}" \
        "find \"${remote_dir}\" -type f -name '*.tar.gz' -mtime +${retention_days} -print")
    
    if [[ -n "${dry_run_output}" ]]; then
        log "以下文件将被删除：\n${dry_run_output}"
        
        # 实际删除操作
        run_with_retry ssh "${remote_user}@${remote_host}" \
            "find \"${remote_dir}\" -type f -name '*.tar.gz' -mtime +${retention_days} -print -delete" || {
            log "错误：远程清理失败"
            exit 6
        }
    else
        log "没有需要清理的旧备份"
    fi
}

clean_remote_backups