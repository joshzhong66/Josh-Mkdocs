#!/bin/bash
###
# @author: Songyao
# @Date: 2024-05-27 17:57:55
# @description:
###
# author: hellojing
# time: 20230107

# Define globle variable
######################################################################################################
BasePath=$(
    cd $(dirname $0)
    pwd
)
ScriptsPath="$BasePath/scripts"
TasksPath="$BasePath/tasks"
TmpPath="$BasePath/tmp"
AnsibleHosts=$1
######################################################################################################

function usage() {
cat <<EOF
Usage: sh $0 <hostsfile>
备注: hostsfile为ansible hosts文件台账信息
EOF
}

function main() {
    if [ -f "$AnsibleHosts" ]; then
        ANSIBLE_RETRY_FILES_ENABLED=FALSE ANSIBLE_STDOUT_CALLBACK=json ansible-playbook -i $AnsibleHosts $TasksPath/main.yml >$TmpPath/OriginAnsibleFile.txt
        # ANSIBLE_RETRY_FILES_ENABLED 不输出异常返回的文件main.retry
        # ANSIBLE_STDOUT_CALLBACK 定义数据返回格式
        /usr/bin/python3 $ScriptsPath/reshandle.py
    else
        echo "ansible hosts文件不存在."
    fi
}

case $1 in
help | -h | --help)
    usage
    ;;
*)
    main
    ;;
esac

