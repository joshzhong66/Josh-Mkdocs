# Josh'Blog

> ## 博客地址：https://joshzhong.top
>



## 记录工作  && 生活 && 日常

- 自律生活

- 早睡早起
- 健身锻炼
- 阅读书籍



## 部署mkdocs

### 1.克隆项目

```
mkdir -p /data/Mkdocs/Josh-Mkdocs
cd /data/Mkdocs/Josh-Mkdocs
git clone git@github.com:joshzhong66/Josh-Mkdocs.git
```

### 2.创建python虚拟环境&安装依赖

```
cd /data/Mkdocs/Josh-Mkdocs
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install mkdocs-material mkdocs-awesome-pages-plugin mkdocs-rss-plugin mkdocs-glightbox mkdocs-git-revision-date-localized-plugin
```

### 3.创建mkdocs启动服务文件

```
cat > /etc/systemd/system/mkdocs.service <<'EOF'
[Unit]
Description=MkDocs Server
After=network.target

[Service]
User=root
Type=simple
WorkingDirectory=/data/Mkdocs/Josh-Mkdocs
ExecStartPre=/bin/bash -c 'source /data/Mkdocs/venv/bin/activate'
ExecStart=/data/Mkdocs/venv/bin/mkdocs serve --dev-addr 0.0.0.0:10090
Restart=always
Environment="PATH=/data/Mkdocs/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
EOF
```

### 4.配置反向代理

```
cat > /usr/local/nginx/conf/conf.d/joshzhong.top.conf <<'EOF'
server {
  server_name joshzhong.top;
  listen 443 ssl;
  ssl_certificate /usr/local/nginx/cert/joshzhong.top/joshzhong.top.pem;
  ssl_certificate_key /usr/local/nginx/cert/joshzhong.top/joshzhong.top.key;
  ssl_protocols TLSv1.2 TLSv1.3;
  location / {
    proxy_pass http://127.0.0.1:10090;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host $http_host;
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
EOF
```

### 5.重载nginx

```
nginx -s reload
```

### 6.启动nginx

```
systemctl daemon-reload
systemctl start mkdocs && systemctl enable mkdocs
```

