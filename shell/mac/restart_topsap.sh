#!/bin/bash

echo "准备 开始 重启 topsap service"
sudo pkill-9 LocalTopserv
[ $? -eq 0 ] && echo "kill success" || echo "kill fail"