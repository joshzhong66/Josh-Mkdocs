#!/bin/bash

# 初始化Zabbix数据库的自动化脚本（适配7.2.4版本）
# 功能：创建数据库/用户/权限/导入数据/服务配置
# 执行方式：需root权限运行

set -eo pipefail

# -------------------------- 配置区 ---------------------------
declare -r MYSQL_ROOT_USER="root"
declare -r MYSQL_ROOT_PWD="Sunline2025"
declare -r ZABBIX_DB_USER="zabbix"
declare -r ZABBIX_DB_PWD="Zabbix2025"
declare -r ZABBIX_VERSION="7.2.4"
declare -r SQL_BASE_DIR="/usr/local/src/zabbix-${ZABBIX_VERSION}/database/mysql"
declare -r REQUIRED_SQL_FILES=("schema.sql" "images.sql" "data.sql")
declare -r SERVICE_FILES_DIR="/usr/local/src/zabbix-${ZABBIX_VERSION}/misc/init.d/fedora/core5"

# ------------------------ 日志函数 ---------------------------
_log() {
    local level=$1
    shift
    printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${level^^}" "$@"
}

log_info() { _log "info" "$@"; }
log_warn() { _log "warn" "$@"; }
log_error() { _log "error" "$@"; }

# ----------------------- 通用验证函数 ------------------------
validate_mysql_connection() {
    if ! mysql -u"$1" -p"$2" -e "SELECT 1" &>/dev/null; then
        log_error "MySQL连接验证失败 用户: $1"
        return 1
    fi
}

validate_sql_files() {
    log_info "验证SQL文件完整性"
    for sql in "${REQUIRED_SQL_FILES[@]}"; do
        local sql_path="${SQL_BASE_DIR}/${sql}"
        if [[ ! -f "$sql_path" ]]; then
            log_error "缺失必要SQL文件: $sql_path"
            return 2
        fi
        if [[ ! -s "$sql_path" ]]; then
            log_error "空SQL文件: $sql_path"
            return 3
        fi
    done
}

# ---------------------- 数据库操作函数 -----------------------
setup_database() {
    log_info "开始初始化Zabbix数据库"
    
    # 创建数据库和用户（幂等操作）
    mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" <<EOF
CREATE DATABASE IF NOT EXISTS zabbix 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_bin;

CREATE USER IF NOT EXISTS '${ZABBIX_DB_USER}'@'%' 
  IDENTIFIED BY '${ZABBIX_DB_PWD}';

GRANT ALL PRIVILEGES ON zabbix.* 
  TO '${ZABBIX_DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    [[ $? -eq 0 ]] || {
        log_error "数据库初始化失败"
        return 4
    }
    log_info "数据库架构创建完成"
}

import_sql_data() {
    log_info "开始导入SQL数据"
    
    cd "${SQL_BASE_DIR}" || return 5
    
    for sql_file in "${REQUIRED_SQL_FILES[@]}"; do
        log_info "正在导入: ${sql_file}"
        
        if ! mysql -u"${ZABBIX_DB_USER}" -p"${ZABBIX_DB_PWD}" zabbix < "${sql_file}"; then
            log_error "SQL导入失败: ${sql_file}"
            return 6
        fi
        
        # 验证导入效果
        local table_count
        table_count=$(mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" zabbix -Nse \
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'zabbix';")
            
        log_info "当前数据库表数量: ${table_count}"
    done
    
    log_info "SQL数据导入完成"
}

# ---------------------- 服务配置函数 -----------------------
configure_services() {
    log_info "配置Zabbix服务文件"
    
    [[ -d "${SERVICE_FILES_DIR}" ]] || {
        log_error "服务文件目录不存在: ${SERVICE_FILES_DIR}"
        return 7
    }
    
    for service in zabbix_server zabbix_agentd; do
        local src_file="${SERVICE_FILES_DIR}/${service}"
        local dest_file="/etc/init.d/${service}"
        
        # 验证源文件存在
        [[ -f "$src_file" ]] || {
            log_error "服务文件不存在: $src_file"
            return 8
        }
        
        # 修改二进制路径
        sed -i "s@/usr/local/sbin/${service}@/data/zabbix/sbin/${service}@" "$src_file"
        
        # 复制服务文件
        cp -v "$src_file" "$dest_file"
        
        # 设置执行权限
        chmod +x "$dest_file"
        chkconfig "$service" on
    done
    
    log_info "服务配置完成"
}

# ---------------------- 主执行流程 -----------------------
main() {
    # 预验证
    validate_mysql_connection "${MYSQL_ROOT_USER}" "${MYSQL_ROOT_PWD}"
    validate_mysql_connection "${ZABBIX_DB_USER}" "${ZABBIX_DB_PWD}"
    validate_sql_files
    
    # 数据库操作
    setup_database
    import_sql_data
    
    # 服务配置
    configure_services
    
    # 最终验证
    log_info "最终数据库状态验证"
    mysql -u"${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PWD}" zabbix -e "
        SHOW TABLES LIKE 'users%';
        SELECT COUNT(*) AS total_tables FROM information_schema.tables 
        WHERE table_schema = 'zabbix';"
    
    log_info "Zabbix数据库初始化成功完成"
}

# ---------------------- 执行入口 -----------------------
if [[ $EUID -ne 0 ]]; then
    log_error "必须使用root权限执行此脚本"
    exit 1
fi

main "$@"