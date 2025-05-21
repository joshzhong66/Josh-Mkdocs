# docker 部署Xiaoya Alist

>Github官方开源地址：https://github.com/xiaoyaDev/xiaoya-alist
>
>GitHub开源地址：https://github.com/monlor/docker-xiaoya/tree/main
>
>docker部署参考文档：https://www.cnblogs.com/gnz48/p/18651934

## 一、了解Xiaoya

### 1.Xiaoya简介

xiaoya是什么？“小雅”（**Xiaoya**）是一个基于 [**Alist**](https://github.com/alist-org/alist) 的资源聚合系统，常用于个人或家庭搭建的**家庭影音媒体服务器**。它主要用来整合多个网盘（如阿里云盘、百度网盘等）的内容，通过网页或播放器集中浏览和播放，常配合 **Emby**、**Jellyfin** 等媒体服务器使用。

### 2.**Xiaoya 的特点**

- ✅ 基于 Alist，支持多种网盘挂载（如阿里云盘、夸克、123盘等）
- ✅ 可通过浏览器访问，页面清晰简洁
- ✅ 结合 Emby/Jellyfin 可实现在线播放
- ✅ Docker 快速部署，适合个人或家庭使用

### 3.**搭配使用建议**

- **Alist**：资源挂载核心
- **Emby / Jellyfin**：流媒体播放
- **frp**：穿透远程访问（只要网盘下载和手机WiFi&5G速度跟上，看电影就很爽）
- **Aria2 / qBittorrent**：下载支持

## 二、了解Alist

> 具体请参考文档：**\LearningNotes\Docker笔记\docker应用\reader & music\CentOS7 部署Alist.md**

### 1.Alist简介

Alist 是一个用 Go 编写的高效、简洁的文件管理工具，一个支持多种存储，支持网页浏览和 WebDAV 的文件列表程序，由 gin 和 Solidjs 驱动。通常用于支持多种云存储协议的文件管理。它的主要特点是支持将云存储挂载为本地目录，允许用户像操作本地文件一样方便地操作远程存储资源。



### 2.主要特点

- **多种存储协议支持**：Alist 支持多种云存储协议，包括但不限于：

  - Google Drive

  - OneDrive

  - Dropbox

  - 阿里云OSS

  - 华为云OBS

  - 七牛云Kodo

  - FTP、SFTP 等传统协议

- **Web 界面**：Alist 提供了一个直观的 Web 界面，用户可以通过浏览器管理文件，进行上传、下载、删除等操作。
- **本地挂载**：通过 Alist，用户可以将云存储服务挂载到本地文件系统上，实现“透明”操作。
- **API 支持**：Alist 提供了 API，可以与其他系统或应用集成，实现自动化文件管理。
- **高效性**：Alist 在设计时就注重高效，能够处理大规模文件的上传、下载和管理。

### 3.使用场景

- **云存储文件管理**：适用于需要管理多种云存储账户、并希望统一操作界面的用户。
- **跨平台文件访问**：在多种存储介质之间进行数据迁移或同步。
- **自动化工作流**：使用 API 和脚本进行自动化文件上传下载等操作。

## 三、了解Wabdav协议



## 四、获取阿里云盘信息

>获取关键信息

### 1.云盘信息介绍

使用 Xiaoya-阿里云盘 构建家庭影音服务器时，需要以下三个关键信息来对接阿里云盘资源：

#### 1.`token` 

>token是Xiaoya 用户授权令牌
>
>**作用**：授权 Xiaoya 连接中转服务获取你的网盘资源，识别你的账户身份。

#### 2.`opentoken` 

>opentoken是阿里云盘访问令牌（access_token）
>
>**作用**：阿里云盘的访问凭证，允许 Xiaoya 获取你网盘中的具体文件内容。
>
>安全性：**千万不能给别人，别人获取了这个等于获取了你的阿里网盘账号和密码**

#### 3.`folder_id`

>  `folder_id`是阿里云盘中的文件夹 ID
>
> **作用**：指定从哪个文件夹开始挂载和展示资源。



### 2.获取token

打开网页**`https://aliyuntoken.vercel.app/`**，使用阿里云盘APP扫描

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517180342190.png" alt="image-20250517180342190" style="zoom:67%;" />

扫描后，二维码下方会出现Token：

```
refreshToken: 29faf032b49f4xxxxxxxxxxxxxxxxxx
```

> 保存下来，部署时需要使用，理论上可以一直不更换，后续token出现卡顿，重新获取即可。



### 3.获取Open token

>open token在alist官方也叫刷新令牌，并且官方提供两种方式进行获取，[参考文档](https://alistgo.com/zh/guide/drivers/aliyundrive_open.html)
>
>打开获取网址：https://alist.nn.ci/tool/aliyundrive/request.html

打开[获取网址](https://alist.nn.ci/tool/aliyundrive/request.html)后，点击【扫描二维码】，

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517180508386.png" alt="image-20250517180508386" style="zoom:67%;" />

点击后，出现二维码，使用阿里云盘手机APP进行扫描

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517180650277.png" alt="image-20250517180650277" style="zoom:67%;" />

扫描后，手机会弹出

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517181005007.png" alt="image-20250517181005007" style="zoom: 67%;" />

（这个貌似可以忽略）

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517181021898.png" alt="image-20250517181021898" style="zoom: 67%;" />



<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517181040478.png" alt="image-20250517181040478" style="zoom:50%;" />

再点击【已扫描】即会显示refresh_token，如下：

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517180850609.png" alt="image-20250517180850609" style="zoom:67%;" />

获取的刷新令牌如下：

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJiYzc2NjQ3YzI3ZmU0OTI5YjYzZTJmN2RiNDcxODBmMSIsImF1ZCI6Ijc2OTE3Y2NjY2Q0NDQxYzM5NDU3YTA0ZjYwODRmYjJmIiwiZXhwIjoxNzU1Mjxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```



### 4.获取folder id

打开网页`https://www.aliyundrive.com/s/rP9gP3h9asE`，点击【登录并保存】，保存到网盘根目录（首页）

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517181337032.png" alt="image-20250517181337032" style="zoom: 67%;" />

转存后，登录阿里云网盘首页，即可在阿里云盘【全部文件】中，看到【小雅转存文件夹】

![image-20250517181432615](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517181432615.png)

打开转存后的目录【小雅转存文件夹】，在浏览器的 url：

>https://www.alipan.com/drive/file/all/68286xxxxxxxxxxxxxxxxxxxxxxx

**最后一串就是转存目录的 folder id，记得这个目录不要删，里面的内容可以定期删除**

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/image-20250517181636486.png" alt="image-20250517181636486" style="zoom:67%;" />

```
682861d4d0ef70118exxxxXXXXX
```



## 五、docker部署Xiaoya

> 项目地址：https://github.com/xiaoyaDev/xiaoya-alist
>
> 官方一键安装脚本：bash -c "$(curl --insecure -fsSL https://ddsrem.com/xiaoya_install.sh)"
>
> ----------------------
>
> 如果是希望通过脚本安装，这个脚本无疑极其全面，为了了解运行原理，一步步手动进行部署、

**以下是手动创建执行，了解小雅部署的过程**

### 一、docker run部署

#### 1.创建目录

```
mkdir /data/xiaoya
```

#### 2.创建 mytoken.txt

创建 mytoken.txt，并写入阿里云的token

```
cat > /data/xiaoya/mytoken.txt <<EOF
29faf032b49f49xXXX
EOF
```

#### 3.创建 myopentoken.txt

创建 myopentoken.txt，并写入阿里云的opentoken

```
cat > /data/xiaoya/myopentoken.txt <<EOF
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJiYzc2NjQ3YzI3ZmU0OTI5YjYzZTJmN2RiNDcxODBmMSIsImF1ZCI6Ijc2OTE3Y2NjY2Q0NDQxYzM5NDU3YTA0ZjYwODRmYjJmxxxxxXXXXXXXXXXXXXXXXXXXX
EOF
```

#### 4.创建temp_transfer_folder_id.txt

创建temp_transfer_folder_id.txt，并写入folder_id

```
cat > /data/xiaoya/temp_transfer_folder_id.txt <<EOF
682861d4d0ef7011xXXXXXXXXXXXXXX
EOF
```

#### 5.启动docker容器

```
docker run -d \
	--restart=always \
	--name="xiaoya" \
	-p 5678:80 \
	-p 2345:2345 \
    -p 2346:2346 \
    -v /data/xiaoya:/data \
    xiaoyaliu/alist:latest

```

**执行日志：**

```
[root@node01 /root]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:2345            0.0.0.0:*               LISTEN      20512/docker-proxy  
tcp        0      0 0.0.0.0:2346            0.0.0.0:*               LISTEN      20519/docker-proxy  
tcp        0      0 0.0.0.0:5678            0.0.0.0:*               LISTEN      20506/docker-proxy  
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      774/rpcbind         
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1033/sshd           
tcp6       0      0 :::111                  :::*                    LISTEN      774/rpcbind         
tcp6       0      0 :::22                   :::*                    LISTEN      1033/sshd           

[root@node01 /root]# docker logs xiaoya
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1592    0  1592    0     0    595      0 --:--:--  0:00:02 --:--:--   595
有效地址为：https://raw.githubusercontent.com/xiaoyaDev/data/main
最新版本 0.14.27 开始更新下载.....

成功更新 tvbox.zip
成功更新 update.zip
成功更新 index.zip

/data/pikpak.txt: No such file or directory (os error 2)
157 records have been updated into your database
Mon May 19 13:06:02 CST 2025 User's own token 29faf032b49f491fb0fc4e1ca2e22c0e has been updated into database successfully
启动容器(Bridge模式)......
INFO[2025-05-19 13:06:12] reading config file: data/config.json        
INFO[2025-05-19 13:06:12] load config from env with prefix:            
INFO[2025-05-19 13:06:12] init logrus...                               
INFO[2025-05-19 13:06:12] start server @ 127.0.0.1:5244                
INFO[2025-05-19 13:06:12] success load storage: [/曲艺/戏曲（京，豫，吕，黄梅戏）剧], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/曲艺/戏曲（越，沪，昆，淮扬）剧], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电影/欧美/系列], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电视剧/港台/TVB], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电影/韩国/优质合集], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电影/日本], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电影/印度], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/曲艺/相声小品/春晚小品合集], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电子书/中国法律大全], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/教育/编程开发/Python特训就业班（14个分类）], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/整理中/epub合集], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/音乐/欧美流行], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/音乐/大合集], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/📺画质演示测试（4K，8K，HDR，Dolby）], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/有声书/有声小说/合集3], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/有声书/有声小说/合集1], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/有声书/有声小说/合集2], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/有声书/有声小说/合集2/明朝那些事儿], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/有声书/评书], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/游戏/PC], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/游戏/XBOX360], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/游戏/安卓], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/游戏/Emuelec], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/整理中/100T影视资源], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/每日更新/电视剧], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电影/奥斯卡获奖电影（1988-2022）], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/音乐/演唱会/未分类], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/音乐/演唱会], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电视剧/日本], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/电视剧/日本/合集], driver: [AliyundriveShare2Open] 
INFO[2025-05-19 13:06:12] success load storage: [/每日更新/电影], driver: [AliyundriveShare2Open] 

```

#### 6.通过浏览器访问

访问地址如：http://10.22.51.65:5678/ （10.22.51.65改成你的服务器IP即可）

>如访问不正常，可以等待5-10 分钟再刷新浏览器，验证是否挂载成功。（速度要取决于你的网络）
>
>如果刚开始页面会显示“获取设置失败”，这是正常情况“，这是因为小雅Alist加载需要一些时间。首次访问时，由于小雅需要进行索引，启动时间会比较慢，根据网络情况，需要1-5分钟不等。

![image-20250519131917371](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/2fd3ceeb80f4c1f0abb0ae5a76461725-2fd3ceeb80f4c1f0abb0ae5a76461725-image-20250519131917371-647f0a-345290.png)



**缺点：这个docker镜像，没有xiaoya的管理后台，只有首页**，**所以需要再单独部署一个alist**，用来挂载小雅



### 二、通过docker-compose部署

#### 1.创建compose文件夹

```
mkdir -p /data/xiaoya1/

mkdir -p /data/xiaoya1/{xiaoya,media,config,cache,meta}
```

#### 2.添加环境变量

>因为docker run使用的镜像是`xiaoyaliu/alist:latest**`，两者管理的环境变量名称还不太一样。
>
>但貌似`ghcr.io/monlor/xiaoya-alist:latest`**目前 是**较为活跃、主流、小雅项目官方推荐的版本，由小雅项目的主要维护者之一 [monlor](https://github.com/monlor) 发布并维护，镜像托管在 GitHub Container Registry（GHCR）上。

写入`ALIYUN_TOKEN`、`ALIYUN_OPEN_TOKEN`、`TEMP_TRANSFER_FOLDER_ID`三个变量

```
cat > /data/xiaoya1/env <<'EOF'
ALIYUN_TOKEN=29faf032b49f491fbxxxxxxxxxxx
ALIYUN_OPEN_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJiYzc2NjQ3YzI3ZmU0OTI5YjYzZTJmN2RiNDcxODBmMSIsImF1ZCI6Ijc2OTE3Y2NjY2Q0NDQxYzM5NDU3YTA0ZjYwxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ALIYUN_FOLDER_ID=682861d4d0ef701xxxxxxxxxxxxxxxxxxx
EOF
```

>## [环境变量参考](https://github.com/monlor/docker-xiaoya/tree/main/alist)
>
>`ALIYUN_TOKEN`: 阿里云token https://alist.nn.ci/zh/guide/drivers/aliyundrive.html
>
>`ALIYUN_OPEN_TOKEN`: 阿里云 open-token https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html
>
>`ALIYUN_FOLDER_ID`: 进入阿里云盘网页版，资源盘里面创建一个文件夹，点击文件夹，复制浏览器阿里云盘地址末尾的文件夹ID（最后一个斜杠/后面的一串字符串）
>
>`QUARK_COOKIE`: 夸克的cookie，登陆夸克网盘，F12找一个请求，查看请求中的Cookie信息
>
>`PAN115_COOKIE`: 115网盘的cookie，登陆115网盘，F12找一个请求，查看请求中的Cookie信息
>
>`ALIYUN_TO_115`: 是否将阿里云盘的文件自动迁移到115网盘，true/false，默认false
>
>`PAN115_FOLDER_ID`: 进入115网页版，创建一个文件夹，点击文件夹，复制浏览器115网盘地址中的cid，默认根目录为0
>
>```
>PIKPAK_USER`: pikpak 账号，用来观看小雅中pikpak分享给你的资源，格式：`qqq@qq.com:aaadds
>```
>
>`PIKPAK_LIST`: 挂载你自己 pikpak 账号，格式：`挂载名:qqq@qq.com:aaadds,aaa:+8613111111111:dasf`，密码中不支持符号,:
>
>```
>PIKPAK_SHARE_LIST`: 挂载自定义的pikpak分享内容，会覆盖小雅的分享，格式：`挂载名1:分享ID1:分享目录ID1,挂载名2:分享ID2:分享目录ID2
>ALI_SHARE_LIST`: 挂载额外的阿里云盘分享内容，格式：`挂载名1:分享ID1:文件夹ID1,挂载名2:分享ID2:文件夹ID2
>QUARK_SHARE_LIST`: 挂载额外的夸克网盘分享内容，格式：`挂载名1:分享ID1:文件夹ID1(不存在填root):提取码1(没有留空),挂载名2:分享ID2:文件夹ID2(不存在填root):提取码2
>PAN115_SHARE_LIST`: 挂载额外的115网盘分享内容，格式：`挂载名1:分享ID1:文件夹ID1(不存在填root):提取码1(没有留空),挂载名2:分享ID2:文件夹ID2(不存在填root):提取码2
>```
>
>`TVBOX_SECURITY`: 开启tvbox随机订阅地址，true/false，默认：false
>
>`PROXY`: 使用代理，支持http、https、socks5协议，格式：[http://ip:7890](http://ip:7890/) 或 socks5://ip:7890
>
>`WEBDAV_PASSWORD`: webdav用户名为dav，设置密码。默认用户密码：guest/guest_Api789
>
>`EMBY_ADDR`: emby部署地址，默认[http://emby:6908，容器内部使用地址，一般不用改](http://emby:6908，容器内部使用地址，一般不用改/)
>
>`EMBY_APIKEY`: 填入一个emby的api key，用于在infuse中播放emby
>
>`AUTO_CLEAR_ENABLED`: 自动清理阿里云云盘的文件，true/false，默认false
>
>`AUTO_CLEAR_INTERVAL`: 自动清理间隔，单位分钟，范围0-60分钟，默认10分钟
>
>`AUTO_CLEAR_THRESHOLD`: 阿里云盘自动清理文件存在时间阈值，单位分钟，范围0-60分钟，默认10分钟



#### 3.添加docker-compose.yml

```
cat > /data/xiaoya1/docker-compose.yml <<'EOF'
version: '3.8'

services:
  alist:
    image: ghcr.io/monlor/xiaoya-alist:latest
    volumes:
      - /data/xiaoya/xiaoya:/data
      - /data/xiaoya/media:/media/xiaoya
    ports:
      - "5678:5678"
      - "2345:2345"
      - "2346:2346"
    environment:
      - AUTO_UPDATE_MEDIA_ADDR=true
    env_file:
      - /data/xiaoya/env
    restart: unless-stopped
    networks:
      - xiaoya

networks:
  xiaoya:
    driver: bridge

EOF
```

#### 4.启动容器

```
cd /data/xiaoya1
docker compose up -d
```

**查看docker log日志**：

>```
>[root@node01 /data/xiaoya1]# docker logs -f fab311fd5898
>开始生成配置文件...
>添加阿里云盘 Token...
>添加阿里云盘 Open Token...
>添加阿里云盘 Folder ID...
>已关闭TVBOX安全模式...
>开始自动更新媒体服务地址...
>等待emby.js创建完成...
>有效地址为：https://raw.githubusercontent.com/xiaoyaliu00/data/main
>最新版本 0.14.27 开始更新下载.....
>
>等待jellyfin.js创建完成...
>成功更新 tvbox.zip
>成功更新 update.zip
>成功更新 index.zip
>成功更新 version.txt
>/data/pikpak.txt: No such file or directory (os error 2)
>157 records have been updated into your database
>sed: /www/tvbox/libs/alist.min.js: No such file or directory
>sed: /www/tvbox/cat/libs/cat.alist.min.js: No such file or directory
>sed: /www/tvbox/libs/alist.min.js: No such file or directory
>Mon May 19 13:47:27 CST 2025 update index succesfully, your new version.txt is 0.14.27
>Mon May 19 13:47:27 CST 2025 User's own token 29faf032b49f491fb0fc4e1ca2e22c0e has been updated into database successfully
>启动容器(Host模式)......
>INFO[2025-05-19 13:47:37] reading config file: data/config.json        
>INFO[2025-05-19 13:47:37] load config from env with prefix:            
>INFO[2025-05-19 13:47:37] init logrus...                               
>INFO[2025-05-19 13:47:37] start server @ 127.0.0.1:5234                
>INFO[2025-05-19 13:47:40] success load storage: [/曲艺/戏曲（京，豫，吕，黄梅戏）剧], driver: [AliyundriveShare2Open] 
>AliOpenAccessToken 已存在
>INFO[2025-05-19 13:47:42] success load storage: [/曲艺/戏曲（越，沪，昆，淮扬）剧], driver: [AliyundriveShare2Open] 
>AliOpenAccessToken 已存在
>INFO[2025-05-19 13:47:44] success load storage: [/], driver: [AliyundriveShare2Open] 
>.................
>
>```

#### 5.访问Xiaoya

打开浏览器输入服务器ip+5678端口，即可访问（如：http://10.22.51.65:5678/）



## 六、docker部署Alist

>挂载阿里云网盘参考：https://blog.csdn.net/2301_79855962/article/details/139559104
>
>​										https://www.cnblogs.com/littlecc/p/18300532

### 1.创建挂载目录

```
mkdir -p /data/alist/alist_data
```

### 2.添加docker-compose.yml

```
cat > /data/alist/docker-compose.yml << 'EOF'
version: '3.8'

services:
  alist:
    image: xhofe/alist:latest
    container_name: alist
    ports:
      - "5244:5244"
    volumes:
      - /data/alist/alist_data:/opt/alist/data
    restart: unless-stopped
EOF
```

### 3.启动容器

```
docker compose up -d
```

### 4.修改alist管理密码

>简洁命令：docker exec -it alist ./alist admin set NEW_PASSWORD

#### 1.连接容器

```
docker exec -it alist bash
```

#### 2.设置密码

```
./alist admin set password
```

- passwrod则是你想设置的密码

#### 3.登陆alist后台

![image-20250520105003636](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/c01c58133b22781572a515d647817392-c01c58133b22781572a515d647817392-image-20250520105003636-50f847-63129d.png)



#### 5.Alist添加阿里云盘

登陆Alist管理后台，点击【存储】——点击【添加】——驱动选择【阿里云盘open】

阿里云盘open挂载选项：

挂载路径：/阿里云盘（可自定义，用于在Alist首页展示）

缓存过期：300分钟

Web代理：启用

WebDav策略：302重定向

刷新令牌：**复制获取的open token**，或者打开网址重新获取：https://alist.nn.ci/tool/aliyundrive/request.html

点击【保存】

![image-20250520122121865](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/d5bd858d6619b11265c26bafb3a37697-image-20250520122121865-e39333.png)

完成后，如图所示：

![image-20250520120920817](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/4ca716d82db3bb1aef5fa683d6b3d0c9-image-20250520120920817-4bb194.png)



#### 6.挂载小雅Alist到Alist

##### 1.生成token令牌

**创建一个在AList中挂载小雅所需要的token**，执行命令：

```
docker exec -i xiaoya sqlite3 data/data.db <<EOF
select value from x_setting_items where key = "token";
EOF
```

>[root@node01 /root]# docker exec -i xiaoya sqlite3 data/data.db <<EOF
>
>> select value from x_setting_items where key = "token";
>> EOF
>> alist-09ceb38a-f143-47f7-b255-c3eec819cd7bqpNRXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

**保存好上述token，下一步骤需使用**



##### 2.挂载Xiaoya_Alist

Alist后台-找到【存储】——点击【添加】——驱动选择【Alist V3】,编辑Alist V3信息

【挂载路径】（可自定义，用于Alist首页展示）：**/xiaoya**   （这里推荐使用/根目录）

【WebDav策略】：**302重定向**

【根文件夹路径】：**/**

【链接】（填写小雅服务器IP和端口）：**http://10.22.51.65:5678** 

【令牌】（生成的token）：**alist-09ceb38a-f143-47f7-b255-c3eec819cd7bqpNRNmu47GiM9XVAh3NBQxxxxxxxx**

**其他未说明的选项，默认即可。**

![image-20250520122042033](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/dbd06916b0c5da36d3a75f2fc8073db7-image-20250520122042033-f2e1e0.png)



![image-20250520122054605](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/ed20c69dceca2246e9ad0b22195b534c-image-20250520122054605-9b7e90.png)



再次打开Alist主页即可看到

![image-20250520122239776](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/cca0dac541c5e615130174f3d4d11d05-image-20250520122239776-17ebcb.png)

这样，在打开http://10.22.51.65:5244/时，而未登陆的情况下，只能访问登陆页面，而非访问5678端口那样（**如果需要外网访问，是需要此步骤**）

![image-20250520122312294](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/ffd774a3f592f058adf14132f982c69d-image-20250520122312294-2fb7e8.png)





#### 7.添加wabdav权限

给需要观影的账号添加wabdav权限

![image-20250520125819203](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/8af85b3e8a12ae00155c1be0de076b01-image-20250520125819203-88d322.png)

8.建立索引

Alist后台——找到【索引】——搜索索引选择【数据库】——点击【保存】——再点击【构建索引】

![image-20250520131718167](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/59b33fddab34f89aaba5bcc267cf4326-image-20250520131718167-3e4ec1.png)

完成后如下：

![image-20250520131844010](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/3268b2ac15be17f8d8a388f068a978e1-image-20250520131844010-d5974b.png)

再回到Alist首页，右上角出现了搜索栏（其他客户端也可以搜索）

![image-20250520131955839](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/ca9da76fd8e871429697b1d7a7022dfb-image-20250520131955839-0c5cfa.png)



## 七、观影途径

### 1.网页观看

通过访问网页http://10.22.51.65:5244/，登陆后进行观看

![image-20250520130159605](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/a8ab37d892e89eb189b404497ecbb4cf-image-20250520130159605-6a9ea0.png)

### 2.PotPlayer客户端

打开`PotPlayer`客户端，点击新建专辑

![image-20250520130351465](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/bc60261899323b7060fc769e2af969fd-image-20250520130351465-999a4f.png)



添加专辑信息如下：

【专辑名称】：**`xiaoya`**

【勾选】：**`FTP/WebDAV/HTTP 搜索`**

【协议】：**`WebDav`**

【主机/路径】：**`10.22.51.65/dav/xiaoya`**   （这里需要注意，如果你在添加xiaoya使用的是根目录/，那么使用**10.22.51.65/dav**即可）

【端口】：**`5244`**

【用户名】：**`admin  `**（可以用非admin账号，添加WebDAV权限即可）

【密码】：**`xxx`**

![image-20250520130618542](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/b4b98573942bde0ce1c3690ade70b667-image-20250520130618542-0e71ef.png)

添加后即可看到观影列表，如下图所示：

![image-20250520130934771](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/c1883139baca150aa78ca9d015eb9e78-image-20250520130934771-1a9722.png)





### 3.添加点击网页PotPlayer

#### 1.修改注册表

打开PotPlayer安装目录，创建`potplayer.reg`文件，添加修改注册表的代码：

```
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\potplayer]
@="URL:PotPlayer Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\potplayer\shell]

[HKEY_CLASSES_ROOT\potplayer\shell\open]

[HKEY_CLASSES_ROOT\potplayer\shell\open\command]
@="\"C:\\Software\\PotPlayer64\\PotPlayer64\\PotPlayerMini64.exe\" \"%1\""

```

其中，路径需要改为你的PotPlayer安装路径

```
@="\"C:\\Software\\PotPlayer64\\PotPlayer64\\PotPlayerMini64.exe\" \"%1\""
```

创建完成，双击potplayer.reg，执行修改注册表：

![image-20250520132847790](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/8f92fa8f8deb31eea73e62374abcc325-image-20250520132847790-94f802.png)

#### 2.执行注册表脚本

然后，找一个视频进行测试，打开运行，输入视频链接，如下进行测试：

```
potplayer://http://10.22.51.65:5244/xiaoya/%E7%94%B5%E5%BD%B1/%E4%B8%AD%E5%9B%BD/%E4%B8%80%E4%BB%A3%E5%AE%97%E5%B8%88/The.Grandmaster.2013.mkv
```





#### 3.添加启动PotPlayer脚本

打开**PotPlayer安装目录**，在目录创建**`open-potplayer.bat`**，添加代码如下（**需要修改PotPlayer路径**）：

```
@echo off
set URL=%1
start "" ""C:\Software\PotPlayer64\PotPlayer64\PotPlayerMini64.exe"" "%URL%"
```



#### 4.打开Alist网页，播放视频

点击PotPlayer

![image-20250520134540434](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/d1e38dbed5be3e9c3da5c243df57d210-image-20250520134540434-41a2d4.png)

则会弹出打开提示：

![image-20250520134619792](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/66c387483aa3c644c9c9518453c440a9-image-20250520134619792-b89b24.png)

出现报错：

![image-20250520134631370](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/22d8f5bbb7224fb760ada45e07c76590-image-20250520134631370-0b6505.png)



### 4.网易云爆米花APP

下载【网易云爆米花APP】，安装后打开APP，先点击【资源库】，再点击右上角【+】

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/fe298671a1d11106a0929a49a5d15641-image-20250520142258268-7b6acb.png" alt="image-20250520142258268" style="zoom:67%;" />

选择网络存储的【WebDAV】协议

![image-20250520142209184](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/3a1c56d2dae2d8d6c6f03f39d8d61387-image-20250520142209184-dee723.png)

填写**`小雅`服务器信息**

协议：**`HTTP`**

地址：**`10.22.51.65`**

端口：**`5244`**

用户名：**`admin`**

密码：**`xxx`**

![image-20250520142127063](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/4ed96be801382ee83939b587e102e3ec-image-20250520142127063-ecd5ef.png)

再点击【保存】

等加载资源后，在首页即可看到

![image-20250520142608768](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/20/cda655a1b447244e105d1bdba74d16f8-image-20250520142608768-52554b.png)



### 5.docker部署emby

#### 1.创建docker-compose.yml

```
version: '3.8'

networks:
  emby:
    driver: bridge

services:   
  emby:
    image: ghcr.io/monlor/xiaoya-embyserver:latest
    container_name: xiaoya_emby
    env_file:
      - /data/xiaoya/env
    depends_on:
      - metadata
      - alist
    volumes:
      - /data/xiaoya/media:/media
    ports:
      - "6908:6908"
    restart: unless-stopped
    networks:
      - emby

```

#### 2.访问emby

用浏览器访问：http://192.168.1.10:8096，如果是首次使用，页面会引导你创建管理员账户和密码，按提示操作。

#### 3.添加Emby媒体库

进入管理后台后，点击左侧菜单的“媒体库”（Library）。

点击“添加媒体库”按钮。

选择媒体类型（电影、电视、音乐等）。

路径（Folder）选你的挂载路径：`/mnt/media` （容器内路径，对应宿主机 `/data/xiaoya/media`）。

确认保存。
