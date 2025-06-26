#!/bin/bash

check_gcc11() {
    if command -v gcc &>/dev/null; then
        GCC_VERSION=$(gcc -dumpversion | cut -d. -f1)
        if [ "$GCC_VERSION" -eq 11 ]; then
            echo_log_info "GCC 11 已安装"
            return 0
        else
            echo_log_error "GCC 版本为 $GCC_VERSION，非 11"
            return 1
        fi
    else
        echo_log_warn "GCC 未安装"
        return 2
    fi
}

check_gcc11