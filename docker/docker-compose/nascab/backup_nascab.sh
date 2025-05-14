#!/bin/bash
# NasCab 备份管理脚本
# 版本: 1.0.0

BACKUP_DIR="/data/backup"
META_DIR="$BACKUP_DIR/meta"
MYDATA_DIR="$BACKUP_DIR/mydata"
DATA_SOURCE="/data/nascab/data"
MYDATA_SOURCE="/data/nascab/mydata"
KEEP_DAYS=7

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}


# 初始化目录
init_dirs() {
    [ ! -d "$META_DIR" ] && mkdir -p "$META_DIR"
    [ ! -d "$MYDATA_DIR" ] && mkdir -p "$MYDATA_DIR"
}

# 备份函数
backup_nascab() {
    echo_log_info "开始备份流程..."
    
    # 备份元数据
    local timestamp=$(date +%Y%m%d%H%M%S)
    local meta_file="$META_DIR/nascab_meta_$timestamp.tar.gz"
    
    tar -czf "$meta_file" -C "$DATA_SOURCE" . >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "元数据备份失败！"
    echo_log_info "元数据备份已创建: $(basename $meta_file)"
    
    # 增量备份用户数据
    rsync -av --delete "$MYDATA_SOURCE/" "$MYDATA_DIR/latest/" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "用户数据同步失败！"
    echo_log_info "用户数据同步完成"
    
    # 清理旧备份
    find "$META_DIR" -name "nascab_meta_*.tar.gz" -mtime +$KEEP_DAYS -delete
    echo_log_info "已清理超过${KEEP_DAYS}天的旧备份"
    
    echo_log_info "备份操作成功完成"
}

# 还原函数
restore_nascab() {
    echo_log_info "可用备份列表:"
    local backups=($(ls -1t "$META_DIR"/nascab_meta_*.tar.gz 2>/dev/null))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo_log_error "未找到任何备份文件！"
    fi
    
    PS3="请选择要恢复的备份: "
    select backup in "${backups[@]}"; do
        [ -n "$backup" ] && break
    done
    
    local timestamp=$(echo "$backup" | grep -oP '\d{14}')
    echo_log_info "已选择备份: $(basename $backup) [$timestamp]"
    
    # 停止容器
    echo_log_info "正在停止容器服务..."
    docker-compose -f /data/nascab/docker-compose.yml down >/dev/null 2>&1
    
    # 还原元数据
    echo_log_info "正在恢复元数据..."
    rm -rf "${DATA_SOURCE:?}/*"
    tar -xzf "$backup" -C "$DATA_SOURCE" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "元数据恢复失败！"
    
    # 还原用户数据
    echo_log_info "正在恢复用户数据..."
    rsync -av --delete "$MYDATA_DIR/latest/" "$MYDATA_SOURCE/" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "用户数据恢复失败！"
    
    # 修复权限
    chown -R 1000:1000 "$DATA_SOURCE" "$MYDATA_SOURCE"
    
    # 启动容器
    echo_log_info "正在启动容器服务..."
    docker-compose -f /data/nascab/docker-compose.yml up -d >/dev/null 2>&1
    echo_log_info "数据恢复操作成功完成"
}

# 新增打包函数（用于跨机器迁移）
package_backup() {
    echo_log_info "正在创建迁移包..."
    local package_path="/usr/local/src/nascab.tar.gz"
    
    # 校验备份完整性
    [ ! -d "$META_DIR" ] && echo_log_error "元数据目录不存在: $META_DIR"
    [ ! -d "$MYDATA_DIR/latest" ] && echo_log_error "用户数据目录不存在: $MYDATA_DIR/latest"

    # 打包核心数据
    tar -czvf "$package_path" -C "$BACKUP_DIR" meta mydata >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "打包失败！"
    
    echo_log_info "迁移包已生成: $package_path"
    echo_log_info "请将此文件复制到目标服务器的 /usr/local/src/ 目录"
}





restore_remote() {
    local package_path="/usr/local/src/nascab.tar.gz"
    echo_log_info "正在从迁移包恢复..."
    
    # 校验迁移包存在性
    [ ! -f "$package_path" ] && echo_log_error "未找到迁移包: $package_path"
    
    # 创建解压临时目录
    local temp_dir=$(mktemp -d)
    tar -xzvf "$package_path" -C "$temp_dir" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "解压迁移包失败！"

    # 检查迁移包目录结构
    [ ! -d "$temp_dir/meta" ] && echo_log_error "迁移包缺少 meta 目录"
    [ ! -d "$temp_dir/mydata" ] && echo_log_error "迁移包缺少 mydata 目录"
    
    # 强制创建本机备份目录结构
    mkdir -p "$META_DIR" "$MYDATA_DIR"
    chmod -R 755 "$BACKUP_DIR"
    echo_log_info "已初始化备份目录: $BACKUP_DIR"

    # 同步迁移包内容到本机备份目录
    rsync -av --delete "$temp_dir/meta/" "$META_DIR/" || echo_log_error "元数据同步失败"
    rsync -av --delete "$temp_dir/mydata/" "$MYDATA_DIR/" || echo_log_error "用户数据同步失败"
    rm -rf "$temp_dir"
    echo_log_info "迁移包内容已同步到本机备份目录"

    # 获取最新元数据备份文件
    local latest_meta=$(ls -t "$META_DIR"/nascab_meta_*.tar.gz | head -n1)
    [ -z "$latest_meta" ] && echo_log_error "未找到有效的元数据备份"

    # 停止并清理旧容器
    docker ps -a --format '{{.Names}}' | grep -q "^nascab$" && docker rm -f nascab >/dev/null 2>&1


    mkdir -p "$DATA_SOURCE" "$MYDATA_SOURCE"

    if [ ! -f /data/nascab/docker-compose.yml ]; then
        cat > /data/nascab/docker-compose.yml <<'EOF'
version: '3.9'
services:
    nascab:
        image: ypptec/nascab
        volumes:
            - '/data/nascab/data:/root/.local/share/nascab'
            - '/data/nascab/mydata:/mydata'
        ports:
            - '18021:21'
            - '18090:90'
            - '18443:443'
            - '18080:80'
        container_name: nascab
EOF
        echo_log_info "已生成 docker-compose.yml"
    else
        echo_log_info "文件已存在，跳过生成 docker-compose.yml"
    fi

    # 还原元数据
    tar -xzf "$latest_meta" -C "$DATA_SOURCE" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "元数据还原失败"
    echo_log_info "已从备份文件 $(basename $latest_meta) 还原元数据"

    # 同步用户数据
    rsync -av --delete "$MYDATA_DIR/latest/" "$MYDATA_SOURCE/" >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "用户数据还原失败"
    echo_log_info "用户数据同步完成"

    # 修复权限
    chown -R 1000:1000 "$DATA_SOURCE" "$MYDATA_SOURCE"
    echo_log_info "已修复目录权限"

    # 启动新容器
    docker-compose -f /data/nascab/docker-compose.yml up -d >/dev/null 2>&1
    [ $? -ne 0 ] && echo_log_error "容器启动失败！请检查日志：docker logs nascab"
    echo_log_info "容器服务已成功启动"

    # 最终状态检查
    sleep 3
    if docker ps | grep -q nascab; then
        echo_log_info "还原完成！访问地址：http://$(hostname -I | awk '{print $1}'):18080"
    else
        echo_log_error "容器未运行，请手动检查：docker logs nascab"
    fi
}

main() {
    clear
    echo -e "——————————————————————————————————
\033[32m NasCab 备份管理工具 v1.0\033[0m
——————————————————————————————————
1. 执行数据备份(增量)
2. 执行本地还原
3. 打包迁移包（跨机器迁移）
4. 从迁移包恢复（跨机器迁移）
5. 退出脚本
——————————————————————————————"

    read -rp "请输入您的选择 [1-3]: " choice
    case $choice in
        1) 
            init_dirs
            backup_nascab
            ;;
        2) 
            init_dirs
            restore_nascab
            ;;
        3)
            package_backup
            ;;
        4)
            restore_remote
            ;;
        5) 
            echo_log_info "正在退出脚本..."
            exit 0
            ;;
        *) 
            echo_log_error "无效的选择！"
            ;;
    esac
}

# 执行主程序
while true; do
    main
    read -rp "按 Enter 键继续..."
done