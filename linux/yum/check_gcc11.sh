#!/bin/bash

check_gcc11() {
    if command -v gcc &>/dev/null; then
        GCC_VERSION=$(gcc -dumpversion | cut -d. -f1)
        if [ "$GCC_VERSION" -eq 11 ]; then
            echo "GCC 11 已安装"
            return 0
        else
            echo "GCC 版本为 $GCC_VERSION，非 11"
            return 1
        fi
    else
        echo "GCC 未安装"
        return 2
    fi
}

check_gcc11