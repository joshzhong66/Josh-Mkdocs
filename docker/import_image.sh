#!/bin/bash

# 检查是否提供了参数
if [ $# -eq 0 ]; then
    echo "用法: $0 <tar.gz 文件路径> ..."
    exit 1
fi

# 处理每个提供的 tar.gz 文件
for TAR_GZ_PATH in "$@"; do
    if [ ! -f "$TAR_GZ_PATH" ]; then
        echo "错误: 文件 $TAR_GZ_PATH 不存在！"
        continue
    fi

    # 获取解压后的 tar 文件路径
    TAR_PATH="${TAR_GZ_PATH%.gz}"

    echo "解压 $TAR_GZ_PATH ..."
    if ! gunzip -c "$TAR_GZ_PATH" > "$TAR_PATH"; then
        echo "解压失败，请检查文件是否有效！"
        continue
    fi

    echo "加载 Docker 镜像 ..."
    OUTPUT=$(docker load < "$TAR_PATH")
    
    # 提取 IMAGE ID
    IMAGE_ID=$(echo "$OUTPUT" | awk '/Loaded image:/ {print $NF}')
    
    if [ -z "$IMAGE_ID" ]; then
        echo "错误: 加载镜像失败！"
        rm -f "$TAR_PATH"
        continue
    fi

    echo "镜像加载成功，ID: $IMAGE_ID"

    # 从文件名生成镜像名称（自动转换 _ 为 / 和 :）
    FILENAME=$(basename "$TAR_GZ_PATH")
    BASENAME="${FILENAME%%.tar.gz}"  # 移除 .tar.gz 或 .gz
    BASENAME="${BASENAME%%.tgz}"
    
    # 分割最后一个 _ 作为 tag
    REPO_PART="${BASENAME%_*}"
    TAG="${BASENAME##*_}"
    REPO="${REPO_PART//_//}"         # 替换所有 _ 为 /
    IMAGE_NAME="$REPO:$TAG"

    echo "自动生成镜像名称: $IMAGE_NAME"
    docker tag "$IMAGE_ID" "$IMAGE_NAME"
    echo "镜像已重命名为: $IMAGE_NAME"

    # 清理 tar 文件
    rm -f "$TAR_PATH"
done

echo "所有镜像处理完成！"