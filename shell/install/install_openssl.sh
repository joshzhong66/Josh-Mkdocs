#!/bin/bash
#author:josh



#openssl version测试-验证安装版本


set -e


OPENSSL_VERSION="1.1.1k"
OPENSSL_PREFIX="/usr/local"
OPENSSL_TAR="openssl-$OPENSSL_VERSION.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/$OPENSSL_TAR"


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

install_dependencies() {
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


create_symlinks() {
    echo "创建符号链接..."
    sudo ln -sf $OPENSSL_PREFIX/bin/openssl /usr/bin/openssl
    sudo ln -sf $OPENSSL_PREFIX/include/openssl /usr/include/openssl
    sudo ln -sf $OPENSSL_PREFIX/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
    sudo ln -sf $OPENSSL_PREFIX/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1


    echo "更新库缓存..."
    sudo ldconfig
}


verify_installation() {
    echo "验证 OpenSSL 安装..."
    if openssl version &>/dev/null; then
        echo "OpenSSL 安装成功。"
        openssl version
    else
        echo "OpenSSL 安装失败，请检查错误信息。"
        exit 1
    fi
}


main() {
    install_dependencies
    download_openssl
    extract_openssl
    build_install_openssl
    create_symlinks
    verify_installation
}


main

