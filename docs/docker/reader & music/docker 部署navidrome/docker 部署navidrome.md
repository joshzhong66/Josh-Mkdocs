# docker部署navidrome



## 一、navidrome & miniserve简介

navidrome是一款开源音乐软件，miniserve 是上传文件的后台。



## 二、安装navidrome与miniserve

### 1.创建navidrome目录

```bash
mkdir -p /data/navidrome/data
mkdir -p /data/navidrome/music
```

### 2.编辑docker-compose.yml文件

`vim /data/navidrome/docker-compose.yml`

```bash
version: "3"
services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    networks:
      - music_network
    restart: unless-stopped
    ports:
      - "4533:4533"
    environment:
      ND_ENABLETRANSCODINGCONFIG: true
      ND_TRANSCODINGCACHESIZE: 0
      ND_SCANSCHEDULE: 1h
      ND_LOGLEVEL: info  
      ND_SESSIONTIMEOUT: 24h
      ND_BASEURL: ""
      LANG: C.UTF-8
      LC_ALL: C.UTF-8
    volumes:
      - "/data/navidrome/data:/data"
      - "/data/navidrome/music:/music:ro"

  miniserve:
    image: svenstaro/miniserve:latest
    container_name: miniserve
    networks:
      - music_network
    restart: unless-stopped
    depends_on:
      - navidrome
    ports:
      - "4534:8080"
    environment:
      LANG: C.UTF-8
      LC_ALL: C.UTF-8
    volumes:
      - "/data/navidrome/music:/downloads"    # 上传文件的目标目录
    command: "-r -z -u -q -p 8080 -a admin:dream13889 /downloads"

networks:
  music_network:
    name: music_network
    ipam:
      driver: default
      config:
        - subnet: 172.101.0.0/16
```

通过上述配置，`navidrome` 服务将运行音乐流媒体服务器，提供音乐文件的转码、扫描和播放功能，而 `miniserve` 服务将作为文件服务器，允许用户通过 Web 界面下载和上传音乐文件。`miniserve` 服务依赖于 `navidrome` 服务，并且它们都连接到各自的端口以便访问。

### 3.配置frp内网穿透（可选）

#### 3.1 配置frps服务端

frps.ini配置文件新增一个代理规则，需要穿透的domain服务：

```bash
[root@jerion ~]# cd /data/frp/frp_server
[root@jerion frp_server]# vim frps.ini

[music]
type = tcp
local_ip = 172.31.100.196
local_port = 4533
remote_port = 8208

[upload]
type = tcp
local_ip = 172.31.100.196
local_port = 4534
remote_port = 8209
```

#### 3.2 配置frpc客户端

frpc.ini配置文件新增一个代理规则，需要穿透的domain服务：

```bash
[root@jerion ~]# cd /data/frp/frp_client/
[root@jerion frp_client]# vim frpc.ini

[music]
type = tcp
local_ip = 172.31.100.196
local_port = 4533
remote_port = 8208

[upload]
type = tcp
local_ip = 172.31.100.196
local_port = 4534
remote_port = 8209
```

#### 3.3 重启

```bash
# 重启服务端
docker restart frps
# 重启客户端
docker restart frpc
```

### 4.启动navidrome容器

```bash
cd /data/navidrome
docker compose up -d
```



## 三、解决navidrome中文乱码

### 1.安装python-mutagen包

`python-mutagen` 是一个用于处理音频文件元数据的 Python 库。

```bash
yum -y install python-mutagen
```

### 2.转换当前目录下的所有mp3文件的编码

```bash
mid3iconv -e gbk *.mp3
```

- 使用 `mid3iconv` 命令将当前目录下所有 `*.mp3` 文件的 ID3 标签编码转换为 GBK（简体中文编码）。
- `-e gbk` 选项指定目标编码为 GBK。
- `*.mp3` 匹配当前目录下所有扩展名为 `.mp3` 的文件。

### 3.转换当前目录及子目录下的所有mp3文件的编码

```bash
#想转换当前目录及子目录则执行
find . -iname "*.mp3" -execdir mid3iconv -e gbk {} \;
```

- `find . -iname "\*.mp3"`：
  - 使用 `find` 命令在当前目录及其所有子目录中查找扩展名为 `.mp3` 的文件。
  - `.` 表示从当前目录开始查找。
  - `-iname "*.mp3"` 表示不区分大小写地匹配文件名为 `*.mp3` 的文件。
- `-execdir mid3iconv -e gbk {} \;`：
  - 对找到的每个文件，使用 `mid3iconv` 命令将其 ID3 标签编码转换为 GBK。
  - `-execdir` 在文件所在的目录中执行命令，以避免路径问题。
  - `{} `是 `find` 命令的占位符，表示当前匹配的文件。
  - `\;` 结束 `-execdir` 命令的选项。



## 四、登陆navidrome

首次登陆，需手动创建用户名：admin，密码：dream13889：

![image-20240630235854054](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/30/e57028e44329c425dd4ec5cd7d2b3b08-image-20240630235854054-3c2f8b.png)



## 五、登陆miniserve

访问miniserve后台上传歌曲，用户名：admin，密码：dream13889：

![image-20240701002003938](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/f76be20a9741da998efaa00a6e2037f6-image-20240701002003938-9c2d9b.png)



## 六、在navidrome播放音乐

上传歌曲后，访问navidrome，右上角点击“快速扫描”后，即可查看上传后的歌曲：

![image-20240701001942124](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/d55c1b06a0135d1acaca6335802a7847-image-20240701001942124-f4f990.png)



## 七、转换格式

`.flac.crdownload` 文件是两种文件类型的组合：

- **.flac 文件：**这是一种无损音频压缩格式，称为 Free Lossless Audio Codec（FLAC）。它可以压缩音频文件而不损失任何数据，因此音质非常高。
- **.crdownload 文件：**这是 Google Chrome 浏览器在下载文件时生成的临时文件扩展名，表示文件正在下载中。

![image-20240615235836917](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/06/15/6ceca86cb8469fa7f89d6b2c9d5c9a4f-image-20240615235836917-a0487d.png)

上传文件后，在Linux可以手动转换：

```bash
mv filename.flac.crdownload filename.flac
```

通过脚本进行转换：

```bash
vim rename_convert.sh
```

脚本内容：

```bash
#!/bin/bash

# 设置音乐文件目录
MUSIC_DIR="/data/navidrome/music"

# 切换到音乐文件目录
cd "$MUSIC_DIR" || exit

# 扫描 .crdownload 文件并重命名
for file in *.crdownload; do
    # 检查是否有匹配的文件
    if [[ -e "$file" ]]; then
        # 获取新文件名，去掉 .crdownload 扩展名
        newfile="${file%.crdownload}"
        
        # 输出重命名信息
        echo "Renaming '$file' to '$newfile'"

        # 重命名文件
        mv "$file" "$newfile"
        
        echo "Renamed '$file' to '$newfile'"
    fi
done

# 列出目录中的所有文件，确认操作结果
echo "Current files in directory:"
ls -l "$MUSIC_DIR"
```

脚本文件赋权并执行：

```bash
chmod +x rename_convert.sh
./rename_convert.sh
```



## 八、参考文档

- [Github地址](https://github.com/navidrome/navidrome/)
- [官网地址](https://www.navidrome.org/docs/installation/docker/)
- [官方示例网站1](https://www.navidrome.org/demo/
  )
- [官方示例网站2](https://demo.navidrome.org/app/)
- [参考博客1](https://blog.laoda.de/archives/navidrome)
- [参考博客2](https://blog.vlinyu.com/archives/docker-compose-navidrome-guide)
- [音乐客户端](https://github.com/jeffvli/sonixd/releases)



## 九、其它

音乐软件推荐：[音流](https://music.aqzscn.cn/docs/versions/latest/)

从目标文件夹提取所有mp3文件并复制：

```bash
find /volume2/music/吴军.硅谷来信/吴军.硅谷来信/2017年 -type f -name '*.mp3' -exec cp --parents {} /volume2/music/tmp \;
```

- 这条命令的作用是在 `/volume2/music/吴军.硅谷来信/吴军.硅谷来信/2017年` 目录及其子目录中找到所有扩展名为 `.mp3` 的文件，并将它们复制到 `/volume2/music/tmp` 目录下，同时保持原文件的目录结构。
  - `find /volume2/music/吴军.硅谷来信/吴军.硅谷来信/2017年`：使用 `find` 命令从指定路径 `/volume2/music/吴军.硅谷来信/吴军.硅谷来信/2017年` 开始查找文件。
  - `-type f`：指定查找类型为文件。
  - `-name '\*.mp3'`：指定文件名模式为以 `.mp3` 结尾的文件。
  - `-exec cp --parents {} /volume2/music/tmp \;`：
    - 对每个找到的文件执行 `cp` 命令，将文件复制到 `/volume2/music/tmp` 目录。
    - `--parents` 选项使得 `cp` 命令保留原始文件的父级目录结构。
    - `{}` 是 `find` 命令的占位符，表示每个找到的文件。
    - `\;` 表示 `-exec` 命令的结束。
