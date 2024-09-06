# docker部署woodwhales-music



参考文档：[woodwhales-music官方网址](https://github.com/woodwhales/woodwhales-music?tab=readme-ov-file)、[woodwhales-music参考界面](https://music.icoders.cn/)

## 一、简介

woodwhales-music是一个自建音乐服务器。



## 二、部署mysql

### 1.启动Mysql容器，并配置容器卷映射

```bash
docker run -d -p 3306:3306 \
--privileged=true \
--restart=always \
-v /data/mysql/log:/var/log/mysql \
-v /data/mysql/data:/var/lib/mysql \
-v /data/mysql/conf:/etc/mysql/conf.d \
-e MYSQL_ROOT_PASSWORD=root1234 \
-e MYSQL_DATABASE=open-music \
--name mysql \
mysql:latest
```

### 2.解决Mysql中文乱码问题

```bash
cd /data/mysql/conf/
vim my.cnf

[client]
default_character_set=utf8
[mysqld]
collation_server = utf8_general_ci
character_set_server = utf8
```

### 3.重启mysql容器

重启mysql容器，使得容器重新加载配置文件：

```bash
docker restart mysql
```

此时便解决了中文乱码（中文插入报错）问题。

> centos8进入mysql容器后输入中文可能会不显示，在启动mysql容器时，可添加`env LANG='C.UTF-8'`后有效，不过只限制进入的这一次，每次启动需要手动添加改参数。

而且因为启动时将容器做了容器卷映射，将mysql的配置（映射到**/app/mysql/conf**）、数据（映射到**/app/mysql/data**）、日志（映射到**/app/mysql/log**）都映射到了宿主机实际目录，所以即使删除了容器，也不会产生太大影响。只需要再执行一下启动Mysql容器命令，容器卷还按相同的位置进行映射，所有的数据便都可以正常恢复。



## 三、部署woodwhales-music

```bash
docker run -d -p 8084:8084 \
--restart=always \
-v /data/open-music:/app/data \
-e "MYSQL_HOST=10.22.51.63" \
-e "MYSQL_DATABASE=open-music" \
-e "MYSQL_PORT=3306" \
-e "MYSQL_USER=root" \
-e "MYSQL_PASSWORD=root1234" \
-e "SPRING_DATASOURCE_URL=jdbc:mysql://10.22.51.63:3306/open-music?allowPublicKeyRetrieval=true&useSSL=false" \
-e "SYSTEM_INIT_PASSWORD=admin" \
--name woodwhales-music \
woodwhales/woodwhales-music:3.7.0
```

解释说明：

- `-e SPRING_DATASOURCE_URL`：设置环境变量 `SPRING_DATASOURCE_URL`，指定 Spring 数据源的 JDBC URL。

  在指定该参数时，解决了1个报错问题，原因是：添加了 `allowPublicKeyRetrieval=true` 选项。

  这个选项允许客户端在使用缓存的 SHA-2 密码插件进行身份验证时检索公钥。当数据库连接字符串中没有这个选项时，客户端无法检索公钥，从而导致连接失败。通过在连接字符串中添加该选项，客户端能够成功进行身份验证并建立连接，从而解决了 `Public Key Retrieval is not allowed` 的错误。
  
- `-e "SYSTEM_INIT_PASSWORD=admin"`：设置环境变量 `SYSTEM_INIT_PASSWORD`，指定系统初始化密码。



## 四、登录woodwhales-music

打开浏览器访问http://10.22.51.63:8084，进入woodwhales-music播放界面，这里没有音乐所以是空的：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/b8286addbfccfaf92960dd9a84d1fcbc-image-20240701164723063-2c0a8b.png" alt="image-20240701164723063" style="zoom: 33%;" />

访问http://10.22.51.63:8084/admin/login，进入woodwhales-music管理后台，默认用户和密码为admin：

![image-20240701164852169](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/7bb1e35badf827ee6e595333d4f67d94-image-20240701164852169-2ce38f.png)



## 五、添加音乐

### 1.网易云音乐平台

#### 1.1 选择歌曲

这是2024年6月份~热榜第一的歌曲：

![image-20240701164000355](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/e28f2e33b16b473fab0db35bc0887274-image-20240701164000355-881a56.png)

#### 1.2 copy-Html源码

使用开发者工具抓取，`class`为`g-bd4 f-cb`的`html`源码：

![image-20240701164215755](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/0be82f8ca2f53817e06f25207fdd0b82-image-20240701164215755-29573c.png)

源码内容如下：

```html
    <div class="g-bd4 f-cb">
    <div class="g-mn4">
    <div class="g-mn4c">
    <div class="g-wrap6">
    <div class="m-lycifo">
    <div class="f-cb">
    <div class="cvrwrap f-cb f-pr">
    <div class="u-cover u-cover-6 f-fl">
    <img src="http://p1.music.126.net/4iTkYFSI2ILuXnv9yBgSnw==/109951169617468185.jpg?param=130y130" class="j-img" data-src="http://p1.music.126.net/4iTkYFSI2ILuXnv9yBgSnw==/109951169617468185.jpg">
    <span class="msk f-alpha"></span>
    </div>
    <div class="out s-fc3">
    <i class="u-icn u-icn-95 f-fl"></i>
    <a data-action="outchain" data-rt="" data-href="/outchain/2/2158973221/" class="des s-fc7">生成外链播放器</a>
    </div>
    <div class="out s-fc3 to-app-listen">
    <div class="btn" data-action="orpheus" data-id="2158973221">点击打开客户端</div>
    </div>
    </div>
    <div class="cnt">
    <div class="hd">
    <i class="lab u-icn u-icn-37"></i>
    <div class="tit">
    <em class="f-ff2">若月亮没来 (Live版)</em>
    </div>
    </div>
    <p class="des s-fc4">歌手：<span title="杨宗纬 / 宝石Gem / 王宇宙Leto"><a class="s-fc7" href="/artist?id=6066">杨宗纬</a> / <a class="s-fc7" href="/artist?id=12084497">宝石Gem</a> / <a class="s-fc7" href="/artist?id=49144727">王宇宙Leto</a></span></p>
    <p class="des s-fc4">所属专辑：<a href="/album?id=197079448" class="s-fc7">天赐的声音第五季 第5期</a></p>
    <div class="m-info">
    <div id="content-operation" class="btns f-cb" data-rid="2158973221" data-type="18">
    <a data-res-action="play" data-res-id="2158973221" data-res-type="18" href="javascript:;" class="u-btn2 u-btn2-2 u-btni-addply f-fl" hidefocus="true" title="播放"><i><em class="ply"></em>播放</i></a>
    <a data-res-action="addto" data-res-id="2158973221" data-res-type="18" href="javascript:;" class="u-btni u-btni-add" hidefocus="true" title="添加到播放列表"></a>
    <a data-res-id="2158973221" data-res-type="18" data-count="-1" data-fee="8" data-payed="0" data-pl="128000" data-dl="0" data-cp="1" data-toast="false" data-st="0" data-flag="4" data-res-action="fav" class="u-btni u-btni-fav " href="javascript:;">
    <i>收藏</i>
    </a>
    <a data-res-id="2158973221" data-res-type="18" data-count="-1" data-res-action="share" data-res-name=
```

#### 1.3 后台添加该歌曲信息

添加音乐信息内容（借鉴了作者的图）：

![image-20240701164539438](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/83a8a540661cf9084c4f2cc13e4d8e9c-image-20240701164539438-c0d289.png)

改完点击`提交`即可。

#### 1.4 添加音乐封面

音乐链接和封面，都是需要手动获取，不是很方便。

![image-20240701181510629](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/c1318a77858ef99550cb5369ecd6e390-image-20240701181510629-6576ac.png)

在歌曲的页面，通过开发者工具检查可以找到jpg文件，提取出来即可：

```html
<img src="http://p1.music.126.net/4iTkYFSI2ILuXnv9yBgSnw==/109951169617468185.jpg?param=130y130" class="j-img" data-src="http://p1.music.126.net/4iTkYFSI2ILuXnv9yBgSnw==/109951169617468185.jpg">
```

提取内容：

```bash
http://p1.music.126.net/4iTkYFSI2ILuXnv9yBgSnw==/109951169617468185.jpg
```

#### 1.5 添加音乐mp3

获取网易云mp3音乐文件，复制`https://music.163.com/#/song?id=2158973221`链接：

![image-20240701181534851](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/4bc43f126c3668ffee2eb096a8b68fd8-image-20240701181534851-b68119.png)

替换链接地址：

```bash
# 将链接
https://music.163.com/#/song?id=2158973221
# 替换成
https://music.163.com/song/media/outer/url?id=2158973221.mp3
```

有些歌曲，这样替换是无法播放，你需要打开链接验证该文件是否存在。

添加完成，点击`提交`即可：

![image-20240701181655965](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/87be4a411ecaeb9c10dd0db02fef4127-image-20240701181655965-a38041.png)

提交后首页可看到新增的歌曲：

![image-20240701183540321](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/7c971ad36b02f88e19bea911f7dff82f-image-20240701183540321-a0a58b.png)

#### 1.6 播放歌曲

回到woodwhales-music播放界面http://10.22.51.63:8084，即可播放歌曲：

![image-20240701181811121](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/6e430ed4aba803df9c5d7cd276a97748-image-20240701181811121-794871.png)



## 六、下载歌曲地址

网易云下载地址：https://3g.gljlw.com/music/wy/

![image-20240701182440986](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/a2bd8dfc73eaf479e6168fc236a6c9b1-image-20240701182440986-a91fd7.png)

依然通过网易云获取音乐信息和封面。

再使用[网易云下载地址](https://3g.gljlw.com/music/wy/)的mp3链接，代替官方链接作为音乐源。

搜索对应的歌曲名字后，点击`下载地址`，可以获取到链接：

![image-20240701182614326](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/07/01/e2284661ed2b98fe32e0158381f527d8-image-20240701182614326-132736.png)

例如（获取链接如下，复制粘贴到后台即可）

```bash
https://m801.music.126.net/20240701185039/d1f2711fecd090cd40cce7568be95f6a/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/36188872386/e6b8/e521/d81c/7b8cbe252e8be7d0b1e7d6310d7cac5b.mp3
```

​	
