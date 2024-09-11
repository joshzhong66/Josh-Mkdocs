#!/bin/bash
#date:2023-10-1
#author:josh
#version:v1.1

read -p "请输入新用户的用户名: " username

adduser $username

echo "请为新用户设置密码:"
passwd $username

usermod -aG wheel $username

read -p "是否允许用户无密码使用sudo切换到root? [y/n]: " grant_nopass
if [[ "$grant_nopass" == "y" || "$grant_nopass" == "Y" ]]; then
    echo "正在安全地修改sudoers文件..."
    
    TMPFILE=$(mktemp)
    trap "rm -f $TMPFILE" EXIT

    cp /etc/sudoers $TMPFILE
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> $TMPFILE
    
    #检查修改后的sudoers文件是否有语法错误
    visudo -c -f $TMPFILE
    if [ $? -eq 0 ]; then
        # 没错误，安全地覆盖sudoers文件
        cp $TMPFILE /etc/sudoers
        echo "已修改sudoers文件，用户无需密码即可使用sudo。"
    else
        echo "修改sudoers文件失败，文件语法有误。"
    fi
else
    echo "用户需要密码才能使用sudo切换到root。"
fi

echo "用户 $username 已成功创建并配置。"