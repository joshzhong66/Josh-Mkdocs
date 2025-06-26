#!/bin/bash

check_root() {
    if [[ $(id -u) != 0 ]]; then
        error_exit "必须使用root权限运行此脚本"
    fi
}

check_root