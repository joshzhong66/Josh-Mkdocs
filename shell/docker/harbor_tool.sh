#!/bin/bash

HARBOR_DOMAIN="harbor.its.sunline.cn"
HARBOR_PROJECT="devops"
HARBOR_USER="admin"
HARBOR_PASSWORD="Harbor12345"

# 手动验证api是否可用（-k 参数忽略证书验证）
# curl -k -s -u "$HARBOR_USER:$HARBOR_PASSWORD" "https://$HARBOR_DOMAIN/api/v2.0/projects/devops/repositories" | jq



# 调用 API 查询 tag
# curl -k -s -u "$HARBOR_USER:$HARBOR_PASSWORD" https://harbor.its.sunline.cn/api/v2.0/projects/devops/repositories/clash-and-dashboard/artifacts   # 查询
# curl -k -s -u "$HARBOR_USER:$HARBOR_PASSWORD" "https://harbor.its.sunline.cn/api/v2.0/projects/devops/repositories/clash-and-dashboard/artifacts" | jq -r '.[].tags[].name' # 提取
echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}] $* \033[0m"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
    exit 1
}

push_image_to_harbor() {
    # 登录 Harbor
    echo_log_info "正在登录 Harbor..."
    echo "$HARBOR_PASSWORD" | docker login $HARBOR_DOMAIN --username $HARBOR_USER --password-stdin >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "登录 Harbor 成功！" || echo_log_error "登录 Harbor 失败，请检查账号和密码。"

    # 获取本地镜像列表
    echo_log_info "正在获取本地镜像列表..."
    IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}")

    # 遍历镜像列表
    for IMAGE in $IMAGES; do
        # 提取镜像名称和标签
        IMAGE_NAME=$(echo $IMAGE | cut -d':' -f1)
        IMAGE_TAG=$(echo $IMAGE | cut -d':' -f2)

        # 排除已经推送到 Harbor 的镜像
        if [[ $IMAGE_NAME == $HARBOR_DOMAIN* ]]; then
            echo_log_info "跳过已推送的镜像: $IMAGE"
            continue
        fi

        # 重新标记镜像
        NEW_IMAGE_NAME="$HARBOR_DOMAIN/$HARBOR_PROJECT/$(basename $IMAGE_NAME):$IMAGE_TAG"
        echo_log_info "正在重新标记镜像: $IMAGE -> $NEW_IMAGE_NAME..."
        docker tag $IMAGE $NEW_IMAGE_NAME

        # 推送镜像到 Harbor
        echo_log_info "正在推送镜像到 Harbor: $NEW_IMAGE_NAME..."
        docker push $NEW_IMAGE_NAME

        if [ $? -eq 0 ]; then
            echo_log_info "成功推送镜像: $NEW_IMAGE_NAME"
        else
            echo_log_error "推送镜像失败: $NEW_IMAGE_NAME"
        fi
        done

        echo_log_info "所有镜像处理完成！"
}



push_an_image_to_harbor() {
    # 登录 Harbor
    echo_log_info "正在登录 Harbor..."
    echo "$HARBOR_PASSWORD" | docker login $HARBOR_DOMAIN --username $HARBOR_USER --password-stdin >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "登录 Harbor 成功！" || echo_log_error "登录 Harbor 失败，请检查账号和密码。"

    # 获取本地镜像列表
    echo_log_info "正在获取本地镜像列表..."
    IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}")

    # 显示镜像列表并让用户选择
    echo_log_info "请选择要导入的镜像："
    INDEX=1
    for IMAGE in $IMAGES; do
        echo "$INDEX) $IMAGE"
        INDEX=$((INDEX + 1))
    done

    # 提示用户输入序号
    read -p "请输入要导入的镜像序号（例如 1 或 1-3）：" SELECTED_INDEX

    # 检查用户输入的是单个序号还是范围
    if [[ $SELECTED_INDEX =~ ^[0-9]+$ ]]; then
        # 单个序号
        SELECTED_INDICES=($SELECTED_INDEX)
    elif [[ $SELECTED_INDEX =~ ^[0-9]+-[0-9]+$ ]]; then
        # 范围
        START=$(echo $SELECTED_INDEX | cut -d'-' -f1)
        END=$(echo $SELECTED_INDEX | cut -d'-' -f2)
        SELECTED_INDICES=($(seq $START $END))
    else
        echo_log_error "输入的序号无效，请重新运行脚本并输入正确的序号。"
        return 1
    fi

    # 检查序号是否有效
    for SELECTED_INDEX in "${SELECTED_INDICES[@]}"; do
        if [[ $SELECTED_INDEX -lt 1 || $SELECTED_INDEX -ge $INDEX ]]; then
            echo_log_error "输入的序号 $SELECTED_INDEX 无效，请重新运行脚本并输入正确的序号。"
            return 1
        fi
    done

    # 遍历用户选择的镜像
    for SELECTED_INDEX in "${SELECTED_INDICES[@]}"; do
        # 获取用户选择的镜像
        SELECTED_IMAGE=$(echo "$IMAGES" | sed -n "${SELECTED_INDEX}p")

        # 提取镜像名称和标签
        IMAGE_NAME=$(echo $SELECTED_IMAGE | cut -d':' -f1)
        IMAGE_TAG=$(echo $SELECTED_IMAGE | cut -d':' -f2)

        # 排除已经推送到 Harbor 的镜像
        if [[ $IMAGE_NAME == $HARBOR_DOMAIN* ]]; then
            echo_log_info "跳过已推送的镜像: $SELECTED_IMAGE"
            continue
        fi

        # 重新标记镜像
        NEW_IMAGE_NAME="$HARBOR_DOMAIN/$HARBOR_PROJECT/$(basename $IMAGE_NAME):$IMAGE_TAG"
        echo_log_info "正在重新标记镜像: $SELECTED_IMAGE -> $NEW_IMAGE_NAME..."
        docker tag $SELECTED_IMAGE $NEW_IMAGE_NAME

        # 推送镜像到 Harbor
        echo_log_info "正在推送镜像到 Harbor: $NEW_IMAGE_NAME..."
        docker push $NEW_IMAGE_NAME

        if [ $? -eq 0 ]; then
            echo_log_info "成功推送镜像: $NEW_IMAGE_NAME"
        else
            echo_log_error "推送镜像失败: $NEW_IMAGE_NAME"
        fi
    done

    echo_log_info "镜像处理完成！"
}




pull_images_from_harbor() {
    echo_log_info "正在登录 Harbor..."
    echo "$HARBOR_PASSWORD" | docker login $HARBOR_DOMAIN --username $HARBOR_USER --password-stdin >/dev/null 2>&1
    [ $? -eq 0 ] && echo_log_info "登录 Harbor 成功！" || echo_log_error "登录 Harbor 失败，请检查账号和密码。"

    # 获取 Harbor 中的镜像列表
    echo_log_info "正在获取 Harbor 镜像列表..."
    IMAGE_LIST=$(curl -k -s -u "$HARBOR_USER:$HARBOR_PASSWORD" "https://$HARBOR_DOMAIN/api/v2.0/projects/devops/repositories" | jq -r '.[].name')

    # 检查是否获取到镜像列表
    [ -z "$IMAGE_LIST" ] && echo_log_error "未找到任何镜像，请检查 Harbor 配置或项目名称。"

    # 显示镜像列表并让用户选择
    echo_log_info "可用的镜像列表："
    INDEX=1
    declare -A IMAGE_MAP
    for IMAGE in $IMAGE_LIST; do
        echo "$INDEX. $IMAGE"
        IMAGE_MAP[$INDEX]=$IMAGE
        INDEX=$((INDEX + 1))
    done

    # 提示用户输入选择
    echo "请输入需要拉取的镜像编号（如 1 或 1-3）："
    read USER_INPUT

    # 解析用户输入
    IFS=',' read -r -a SELECTIONS <<< "$USER_INPUT"
    SELECTED_IMAGES=()


    for SELECTION in "${SELECTIONS[@]}"; do
        if [[ $SELECTION =~ ^[0-9]+$ ]]; then
            # 单个编号
            if [ -n "${IMAGE_MAP[$SELECTION]}" ]; then
                SELECTED_IMAGES+=("${IMAGE_MAP[$SELECTION]}")
            else
                echo_log_error "无效的编号: $SELECTION"
            fi
        elif [[ $SELECTION =~ ^[0-9]+-[0-9]+$ ]]; then
            # 范围编号（如 1-3）
            START=$(echo "$SELECTION" | cut -d'-' -f1)
            END=$(echo "$SELECTION" | cut -d'-' -f2)
            for ((i=START; i<=END; i++)); do
                if [ -n "${IMAGE_MAP[$i]}" ]; then
                    SELECTED_IMAGES+=("${IMAGE_MAP[$i]}")
                else
                    echo_log_error "无效的编号: $i"
                fi
            done
        else
            echo_log_error "无效的输入: $SELECTION"
        fi
    done

    # 拉取用户选择的镜像
    if [ ${#SELECTED_IMAGES[@]} -eq 0 ]; then
        echo_log_warn "未选择任何镜像，退出。"
        exit 0
    fi

    if ! command -v jq &>/dev/null; then
        echo_log_info "jq 未安装，准备安装 jq。"
        yum -y install jq
    else
        echo_log_info "jq 已安装，跳过安装步骤。"
    fi

    echo_log_info "开始拉取镜像..."
    for IMAGE in "${SELECTED_IMAGES[@]}"; do
        echo_log_info "正在获取镜像 $IMAGE 的标签列表..."

        # 获取 标签列表
        # curl -k -s -u "$HARBOR_USER:$HARBOR_PASSWORD" https://harbor.its.sunline.cn/api/v2.0/projects/devops/repositories/clash-and-dashboard/artifacts
        HARBOR_REPO=$(echo $IMAGE | awk -F'/' '{print $2}')
        echo_log_info "镜像独立名称为: $HARBOR_REPO"
        TAGS=$(curl -k -s -u "$HARBOR_USER:$HARBOR_PASSWORD" "https://$HARBOR_DOMAIN/api/v2.0/projects/$HARBOR_PROJECT/repositories/$HARBOR_REPO/artifacts" | jq -r '.[] | select(.tags != null) | .tags[].name')
        
        [ $? -eq 0 ] && echo_log_info "获取镜像 $IMAGE 的标签列表成功！" || echo_log_error "获取镜像 $IMAGE 的标签列表失败，请检查账号和密码。"
        echo_log_info "$HARBOR_REPO 的标签列表为：$TAGS"

        FULL_IMAGE_NAME="$HARBOR_DOMAIN/$IMAGE:$TAGS"
        echo_log_info "正在拉取镜像: $FULL_IMAGE_NAME..."
        # 拉取格式： docker pull harbor.its.sunline.cn/devops/redis-photon:v2.12.1
        docker pull $FULL_IMAGE_NAME

        if [ $? -eq 0 ]; then
            echo_log_info "成功拉取镜像: $FULL_IMAGE_NAME"
        else
            echo_log_error "拉取镜像失败: $FULL_IMAGE_NAME"
        fi
    done

    echo_log_info "镜像拉取完成！"
}


main() {
    push_imager_to_harbor
    push_an_image_to_harbor
    pull_images_from_harbor
}

main() {
    clear
    echo -e "———————————————————————————
\033[32m Harbo Tool\033[0m
———————————————————————————
1. 导入全部镜像到Harbor
2. 导入单个镜像到Harbor
3. 从Harbor导出单个镜像
4. 退出脚本\n"

    read -rp "Please enter the serial number and press Enter：" num
    case "$num" in
    1) push_image_to_harbor ;;
    2) push_an_image_to_harbor ;;
    3) pull_images_from_harbor ;;
    4) quit ;;

    *) main ;;
    esac
}

main
