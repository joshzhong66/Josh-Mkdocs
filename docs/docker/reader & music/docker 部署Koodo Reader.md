# docker部署Koodo Reader



参考文档：[Koodo Reader官方网址](https://github.com/koodo-reader/koodo-reader)

## 一、简介

koodo reader是一款阅读器。

![image-20240630223937760](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/30/d9a06be694466b37ae68ad69d47fa6f1-image-20240630223937760-b5179b.png)



## 二、支持格式

格式支持：

 - EPUB（**.epub**）
 - PDF（**.pdf**）
 - 无 DRM 的 Mobipocket ( **.mobi** ) 和 Kindle ( **.azw3** , **.azw** )
 - 纯文本（**.txt**）
 - 小说书 ( **.fb2** )
 - 漫画书档案（**.cbr**、**.cbz**、**.cbt**、**.cb7**）
 - 富文本（**.md**、**.docx**）
 - 超文本（**.html**、**.xml**、**.xhtml**、**.mhtml**、**.htm**、**.htm**）
- 平台支持：**Windows**、**macOS**、**Linux**和**Web**
- 将您的数据保存到**OneDrive**、**Google Drive**、**Dropbox**、**FTP**、**SFTP**、**WebDAV**、**S3**、**S3 兼容**
- 自定义源文件夹并使用 OneDrive、iCloud、Dropbox 等在多个设备之间同步。
- 单列、双列或连续滚动布局
- 文本转语音、翻译、词典、触摸屏支持、批量导入
- 为您的书籍添加书签、注释和突出显示
- 调整字体大小、字体系列、行距、段落间距、背景颜色、文本颜色、边距和亮度
- 夜间模式和主题颜色
- 文本突出显示、下划线、粗体、斜体和阴影



## 三、docker部署

```bash
docker run -d \
  -p 8860:80 \
  --name koodo-reader \
  --restart always \
  -v /data/koodo_reader:/data/koodo_reader \
  liwangsheng/koodo-reader
```



## 四、docker compose部署

```bash
version: '3.5'
services:
  koodo:
    container_name: koodo
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8860:80/tcp"
    restart: unless-stopped
    volumes:
      - /data/koodo_reader:/data/koodo_reader
```

