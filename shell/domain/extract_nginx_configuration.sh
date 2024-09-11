#!/bin/bash

server_list="/usr/local/scripts/domain/server"
#read -p "输入服务器列表文件路径: " server_list
#/usr/local/scripts/server 定义一个服务器列表

output_dir="/tmp/ansible_nginx_info"
mkdir -p $output_dir

search_dirs=(
    "/etc/nginx/ssl"
    "/etc/ssl"
    "/usr/local/nginx/conf"
    "/etc/pki/tls/certs"
        "/data/nginx/conf/cert"
)

while IFS= read -r server_ip
do
    output_file="${output_dir}/ansible_${server_ip}_nginx.txt"
    {
        echo "处理服务器: $server_ip"
        echo "###### <1> 检查 nginx 路径"
        nginx_path=$(ansible $server_ip -m shell -a 'which nginx' | grep -v "CHANGED" | grep -v "rc=0" | tr -s ' ' | cut -d ' ' -f 3)
        echo "Nginx 路径: $nginx_path"
        
        echo -e "\n###### <2> 查看 nginx 配置文件所在"
        nginx_config_output=$(ansible $server_ip -m shell -a "$nginx_path -V" 2>&1 | grep 'prefix=' | sed -e 's/.*--prefix=\([^ ]*\).*/\1/')
        nginx_config_output="${nginx_config_output%/}"/conf  # 添加 /conf 以修正路径
        echo "Nginx 配置路径: $nginx_config_output"

        echo -e "\n###### <3> 查看 nginx 配置文件内容"
        nginx_conf_file="${nginx_config_output}/nginx.conf"
        ansible $server_ip -m shell -a "cat $nginx_conf_file"
        echo -e "\n包含的配置文件:"
        included_files=$(ansible $server_ip -m shell -a "grep 'include' $nginx_conf_file | grep -v '#' | awk '{print \$2}' | sed 's/;//'")
        echo "$included_files"

        echo -e "\n###### <4> 提取的证书路径"
        cert_paths=$(ansible $server_ip -m shell -a "grep -E 'ssl_certificate' $nginx_conf_file" | grep -oP 'ssl_certificate\s+\K[^;]*')
        echo "从nginx.conf提取的证书路径: $cert_paths"

        if [[ -z "$cert_paths" ]]; then
            echo "未从nginx.conf中找到证书路径，尝试搜索系统中的.pem文件"
            for dir in "${search_dirs[@]}"; do
                cert_paths+=$(ansible $server_ip -m shell -a "find $dir -type f -name '*.pem' 2>/dev/null")
                cert_paths+=" "  # 添加空格作为分隔符
            done
        fi
        echo "最终确定的证书路径: $cert_paths"

        echo -e "\n###### <5> 搜索证书的确切路径"
        for cert in $cert_paths; do
            find_output=$(ansible $server_ip -m shell -a "find / -name \"$(basename $cert)\" 2>/dev/null")
            echo "$find_output"
        done

        echo -e "\n###### <6> 查看证书所在目录"
        for cert in $cert_paths; do
            dir=$(dirname $cert)
            ls_output=$(ansible $server_ip -m shell -a "ls -l $dir 2>/dev/null")
            echo "$ls_output"
        done
    } > $output_file

    echo "服务器 $server_ip 的结果已保存到 ${output_file}"
done < "$server_list"

echo "所有服务器执行完毕."