#!/bin/bash

# 定义备份目录和远程服务器信息
BACKUP_DIR="/data"
REMOTE_USER="root"  # 替换为远程服务器的用户名
REMOTE_HOST="10.22.51.64"
REMOTE_DIR="/path/to/backup"  # 替换为远程服务器上的备份目录

# 获取当前日期
DATE=$(date +%Y%m%d)

# 创建本地临时备份目录
LOCAL_BACKUP_DIR="/tmp/backup_${DATE}"
mkdir -p ${LOCAL_BACKUP_DIR}

# 打包wiki文件夹
tar -czf ${LOCAL_BACKUP_DIR}/${DATE}_wiki.tar.gz -C ${BACKUP_DIR} wiki

# 打包easyimage文件夹
tar -czf ${LOCAL_BACKUP_DIR}/${DATE}_easyimage.tar.gz -C ${BACKUP_DIR} easyimage

# 使用rsync将备份文件传输到远程服务器
rsync -avz ${LOCAL_BACKUP_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}

# 删除本地临时备份目录
rm -rf ${LOCAL_BACKUP_DIR}

echo "Backup completed and transferred to remote server using rsync."