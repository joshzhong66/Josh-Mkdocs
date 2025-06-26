#!/bin/bash

PACKAGE_NAME="gcc"
GCC_VERSION="11.4.0"
PACKAGE_TAR="gcc-11.4.0-bin.tar.xz"
INSTALL_PATH="/usr/local"
DOWNLOAD_PATH="/usr/local/src"

check_pkg_arch() {
    local zip_path="$DOWNLOAD_PATH/linux.zip"
    local tar_xz_path="$DOWNLOAD_PATH/linux/$PACKAGE_TAR"

    if [[ -f "$zip_path" ]]; then
        echo -e "${YELLOW}发现linux.zip，尝试解压...${NC}"
        if ! unzip -o "$zip_path" -d "$DOWNLOAD_PATH"; then
            echo -e "${RED}解压linux.zip失败${NC}"
            return 1
        fi

        if [[ -f "$tar_xz_path" ]]; then
            echo -e "${GREEN}找到$PACKAGE_TAR，开始解压安装...${NC}"
            if ! tar -Jxvf "$tar_xz_path" -C "$INSTALL_PATH"; then
                error_exit "解压$PACKAGE_TAR失败"
            fi
            return 0
        else
            echo -e "${YELLOW}解压后未找到$PACKAGE_TAR${NC}"
            return 1
        fi
    fi
    return 1
}


check_pkg_arch