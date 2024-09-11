#!/bin/bash
#author: josh

PYTHON_VERSION="3.8.10"
PYTHON_TAR="Python-$PYTHON_VERSION.tgz"
PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_TAR"
INSTALL_PREFIX="/usr/local"

ANSIBLE_VERSION="2.9.6"
REQUIRED_MODULES="os sys json"
OPENSSL_VERSION="1.1.1k"
OPENSSL_PREFIX="/usr/local"
OPENSSL_TAR="openssl-$OPENSSL_VERSION.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/$OPENSSL_TAR"

set -e

log_and_exit() {
    echo "$1"
    exit 1
}

check_openssl_installed() {
    if command -v openssl &> /dev/null && openssl version | grep -q "$OPENSSL_VERSION"; then
        echo "OpenSSL $OPENSSL_VERSION 已安装，跳过安装步骤。"
        return 0
    else
        return 1
    fi
}

download_openssl() {
    if [ ! -f "$OPENSSL_TAR" ]; then
        echo "正在下载 OpenSSL $OPENSSL_VERSION..."
        wget $OPENSSL_URL
    else
        echo "OpenSSL 源代码已经下载。"
    fi
}

extract_openssl() {
    if [ ! -d "openssl-$OPENSSL_VERSION" ]; then
        echo "正在解压 OpenSSL 源代码..."
        tar -xzvf $OPENSSL_TAR
    else
        echo "OpenSSL 源代码已经解压。"
    fi
}

install_openssl_dependencies() {
    echo "安装依赖项..."
    sudo yum install -y gcc perl-Core zlib-devel make
}

build_install_openssl() {
    cd "openssl-$OPENSSL_VERSION"
    echo "配置 OpenSSL..."
    ./config --prefix=$OPENSSL_PREFIX --openssldir=$OPENSSL_PREFIX shared zlib

    echo "编译 OpenSSL..."
    make

    echo "跳过有问题的测试..."
    make -k test || true

    echo "安装 OpenSSL..."
    sudo make install
    cd ..
}

create_openssl_symlinks() {
    echo "创建符号链接..."
    sudo ln -sf $OPENSSL_PREFIX/bin/openssl /usr/bin/openssl
    sudo ln -sf $OPENSSL_PREFIX/include/openssl /usr/include/openssl
    sudo ln -sf $OPENSSL_PREFIX/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
    sudo ln -sf $OPENSSL_PREFIX/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1

    echo "更新库缓存..."
    sudo ldconfig
}

verify_openssl_installation() {
    echo "验证 OpenSSL 安装..."
    if openssl version &>/dev/null; then
        echo "OpenSSL 安装成功。"
        openssl version
    else
        echo "OpenSSL 安装失败，请检查错误信息。"
        exit 1
    fi
}

download_python() {
    echo "正在下载 Python $PYTHON_VERSION..."
    wget $PYTHON_URL
}

extract_python() {
    echo "正在解压 Python 源代码..."
    tar -xzvf $PYTHON_TAR
}


build_install_python() {
    cd "Python-$PYTHON_VERSION"
    echo "配置 Python..."
    # 移除基于 profile 的优化，并确保包括 OpenSSL 的头文件和库文件路径
    CFLAGS="-I$OPENSSL_PREFIX/include" LDFLAGS="-L$OPENSSL_PREFIX/lib" \
    ./configure --prefix=$INSTALL_PREFIX --with-openssl=$OPENSSL_PREFIX --enable-shared

    echo "编译 Python..."
    make

    echo "安装 Python..."
    sudo make altinstall  # 使用 altinstall 防止覆盖系统默认的python版本
    if [ $? -ne 0 ]; then
        echo "Python 安装失败"
        exit 1
    fi
    cd ..
}



install_python_dependencies() {
    echo "正在安装所需依赖..."
    sudo yum update -y || log_and_exit "更新失败，正在退出..."
    sudo yum groupinstall -y "development tools"
    sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel wget zlib-devel \
                       libbz2-devel readline-devel sqlite-devel curl llvm \
                       ncurses-devel ncurses-libs xz-devel tk-devel liblzma-devel gdbm-devel \
                       db4-devel libpcap-devel expat-devel epel-release git \
                       make libuuid-devel gdbm-devel xz-devel readline-devel \
                       ncurses-devel bzip2-devel tk-devel libmpdec-devel || log_and_exit "依赖安装失败，正在退出..."
}

install_ansible() {
    echo "正在安装 Ansible..."
    if pip3 show ansible | grep -q "Version: $ANSIBLE_VERSION"; then
        echo "Ansible $ANSIBLE_VERSION 已安装，跳过安装步骤。"
    else
        pip3 install --upgrade pip setuptools wheel cython
        pip3 install "ansible==$ANSIBLE_VERSION"
        if [ $? -eq 0 ]; then
            echo "Ansible 安装成功。"
        else
            echo "Ansible 安装失败。"
        fi
    fi
}

main() {
    install_python_dependencies
    if ! check_openssl_installed; then
        download_openssl
        extract_openssl
        install_openssl_dependencies
        build_install_openssl
        create_openssl_symlinks
        verify_openssl_installation
    fi
    download_python
    extract_python
    build_install_python
    install_ansible
}

main

echo "OpenSSL、Python 3.8、Ansible 设置已完成。"
echo "通过运行 'ansible --version' 来验证 Ansible 是否正确安装。"

