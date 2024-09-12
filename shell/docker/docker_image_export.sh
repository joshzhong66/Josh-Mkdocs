#!/bin/bash
# 脚本说明： 将docker镜像列出，按镜像顺序做编号
#           输入编号，导出镜像为tar.gz文件
#           执行scp复制，提示输入ip地址 、用户名、密码
#           复制到ip地址，执行docker load导入镜像
#           执行docker tag，修改镜像名称
#           列出镜像，确定是否成功


docker_dir="/usr/local/src"

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


function check_packet() {
    if ! command -v sshpass &> /dev/null; then
        echo_log_warn "sshpass 未安装，准备安装sshpass..."
        yum -y install sshpass >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "sshpass 安装成功！" || echo_log_error "sshpass 安装失败！"
    fi
    if ! command -v rsync &> /dev/null; then
        echo_log_warn "rsync 未安装，准备安装rsync..."
        yum -y install rsync >/dev/null 2>&1
        [ $? -eq 0 ] && echo_log_info "rsync 安装成功！" || echo_log_error "rsync 安装失败！"
    fi
}

function list_images() {
    echo_log_info "可用的 Docker 镜像："
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | tail -n +2 | nl
}


# 导出镜像
function export_image() {
    read -p "请输入要导出的镜像编号: " image_number
    image_name=$(docker images --format "{{.Repository}}:{{.Tag}}" | sed -n "${image_number}p")

    [ -z "$image_name" ] && echo_log_error "无效的编号，请重新运行脚本。" && return

    sanitized_image_name=$(echo "$image_name" | tr '/' '_' | tr ':' '_')	#镜像名的/和:替换成下划线

    [ ! -w "$docker_dir" ] && echo_log_error "当前目录不可写，请检查权限或切换目录。"

    if [ -f "${docker_dir}/${sanitized_image_name}.tar.gz" ]; then
        while [[ "$answer" != "y" && "$answer" != "n" ]]; do
            echo_log_warn "文件已存在，是否重新导出？(y/n)"
            read -r answer
        done
        [[ $answer == "n" ]] && return || rm -f ${docker_dir}/${sanitized_image_name}.tar.gz
    fi
	
    echo_log_info "导出镜像: $image_name"
    docker save "$image_name" | gzip > "${docker_dir}/${sanitized_image_name}.tar.gz"
    [ $? -ne 0 ] && echo_log_error "镜像导出失败！"
    echo_log_info "镜像已导出为 ${sanitized_image_name}.tar.gz"
}


function validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        if [[ "$ip" == "0.0.0.0" || "$ip" == "255.255.255.255" || "$ip" =~ ^127\. || "$ip" =~ ^255\. ]]; then
            return 1
        fi
        return 0
    else
        return 1
    fi
}


# 传输镜像文件到远程服务器
function copy_image_to_remote() {
    while true; do
        read -p "请输入远程服务器的IP地址: " remote_ip
        if validate_ip "$remote_ip"; then
            break
        else
            echo_log_warn "无效的IP地址，请重新输入。"
        fi
    done
    read -p "请输入远程服务器的用户名: " remote_user
    read -s -p "请输入远程服务器的密码: " remote_password
    echo 
    sshpass -p "${remote_password}" rsync -avz --progress "${docker_dir}/${sanitized_image_name}.tar.gz" "${remote_user}@${remote_ip}:${docker_dir}"    #用rsync显示进度条
    #sshpass -p "${remote_password}" scp -v "${docker_dir}/${sanitized_image_name}.tar.gz" "${remote_user}@${remote_ip}:${docker_dir}"  #使用sshpass配合scp不会显示进度条
    [ $? -eq 0 ] && echo_log_info "镜像文件已传输到 ${remote_ip}:${docker_dir}" || { echo_log_error "文件传输失败！"; }
}

# 在远程服务器上加载镜像并修改名称
function remote_operations() {
    echo_log_info "正在复制镜像 ${sanitized_image_name}.tar.gz 到远程服务器 ${remote_ip}..."
    sshpass -p "${remote_password}" ssh "$remote_user@$remote_ip" >/dev/null 2>&1 << EOF
cd "${docker_dir}"
gunzip -c "${sanitized_image_name}.tar.gz" | docker load
EOF

    [ $? -eq 0 ] && echo_log_info "镜像${sanitized_image_name}加载成功！" || { echo_log_error "镜像${sanitized_image_name}加载失败！" ; }
}


function main() {
    check_packet
    list_images
    export_image
    copy_image_to_remote
    remote_operations
}


main