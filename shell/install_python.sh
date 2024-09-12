#!/bin/bash

URL="http://10.22.51.64:8071/05_%E6%BA%90%E7%A0%81%E5%8C%85/02_python/Python-3.9.7.tgz"
PYTHON_VER="3.9.7"
SOFTWARE_DIR="/usr/local/src"
PYTHON_INSTER_DIR="/usr/local/python"

set -e # 退出脚本，遇到错误则停止
#install_python
function install_python(){
    if command -v python3 &>/dev/null; then
        echo "python3已安装,是否卸载后重新安装?(y/n)"
        read -rp "请输入y 或者 n :" response
        if [[ $response == "y" ]]; then
            uninstall_python
        else
            echo "取消安装！"
            exit
        fi
    fi

    echo "安装python依赖"
    yum -y install openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel wget >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "安装依赖成功"
    else
        echo "安装依赖失败"
        exit
    fi

    echo "开始安装Python ${PYTHON_VER}..."
    cd $SOFTWARE_DIR
    if [ ! -f Python-3.9.7.tgz ]; then
        echo "Python-3.9.7.tgz不存在，开始下载..."
        wget -P $SOFTWARE_DIR $URL && cd $SOFTWARE_DIR
        if [ -d $SOFTWARE_DIR/Python-3.9.7 ]; then
            echo "Python-3.9.7目录已存在，删除目录"
            rm -rf Python-3.9.7
        else
            echo "Python-3.9.7目录不存在"
        fi
    else
        echo "Python-3.9.7.tgz已存在，开始解压..."
        tar -zxvf Python-3.9.7.tgz && cd Python-3.9.7
        exit
    fi
    
    ./configure --prefix=${PYTHON_INSTER_DIR} --enable-optimizations >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "编译成功"
    else
        echo "编译失败"
        exit
    fi
    make altinstall
    if [ $? -eq 0 ]; then
        echo "安装成功"
    else
        echo "安装失败"
        exit
    fi


    echo "Python ${PYTHON_VER} 安装成功，验证python版本..."

    $PYTHON_INSTER_DIR/bin/python3.9 --version
    if [ $? -eq 0 ]; then
        echo "版本验证成功"
    else
        echo "验证失败"
        exit
    fi
    #创建软链接
    if [ -e /usr/bin/python3 ]; then
        echo "软链接已存在"
        mv /usr/bin/python3 /usr/bin/python3.bak
    else
        echo "创建软链接"
    fi

    if [ -e /usr/bin/pip3 ]; then
        ehco "软链接/usr/bin/pip3 已存在"
        mb /usr/bin/pip3 /usr/bin/pip3.bak
    else
        echo "创建软链接"
    fi
    ln -s /usr/local/python/bin/python3.9 /usr/bin/python3
    ln -s /usr/local/python/bin/pip3.9 /usr/bin/pip3
}
#uninstall_python
function uninstall_python(){
    echo "开始卸载python3..."
    rm -rf ${PYTHON_INSTER_DIR}
    rm /usr/bin/python3
    rm /usr/bin/pip3
    if [ -e /usr/bin/python3.bak ]; then
        echo "软链接已存在"
        mv /usr/bin/python3.bak /usr/bin/python3
    else
        echo "软链接不存在"
    fi
    if [ -e /usr/bin/pip3.bak ]; then
        echo "软链接已存在"
        mv /usr/bin/pip3.bak /usr/bin/pip3
    else
        echo "软链接不存在"
    fi
    echo "卸载成功"
}


    echo -e -e "———————————————————————————
\033[32m PYTHON${PYTHON_VER} 安装工具\033[0m
———————————————————————————
1. 安装python3.9.7
2. 卸载python3
3. 退出
———————————————————————————
\033[32m 请选择：\033[]]
———————————————————————————"

    read -rp "请输入序号并回车：" num
    case $num in
    1) install_python ;;
    2) uninstall_python ;;
    3) exit ;;
    *) echo "输入错误，请重新输入！" && sleep 1 && exec "$0" ;;
    esac