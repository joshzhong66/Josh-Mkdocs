# Alist如何使用网易云



## 部署Alist

>下载地址：https://github.com/AlistGo/alist/releases
>安装参考：https://alist.nn.ci/guide/install/manual.html#running
>
>参考文档：https://anwen-anyi.github.io/index/01-home.html#_2-14-%E4%BF%AE%E6%94%B9alist%E4%BD%BF%E7%94%A8%E7%9A%84%E6%95%B0%E6%8D%AE%E5%BA%93%E4%B8%BAmysql



```
wget https://github.com/AlistGo/alist/releases/download/v3.40.0/alist-linux-musl-amd64.tar.gz
mkdir -p /data/alist
tar -zxvf alist-linux-musl-amd64.tar.gz -C /data/alist
cd /data/alist
chmod +x alist

./alist server						# 启动
./alist admin random				# 生成随机密码
./alist admin set NEW_PASSWORD		# 手动设置一个密码 `NEW_PASSWORD`是指你需要设置的密码
```

配置启动服务

```
vim /usr/lib/systemd/system/alist.service


[Unit]
Description=alist
After=network.target
 
[Service]
Type=simple
WorkingDirectory=/data/alist
ExecStart=/data/alist/alist server
Restart=on-failure

[Install]
WantedBy=multi-user.target




systemctl start alist
systemctl stop alist
systemctl status alist
systemctl restart alist
systemctl enable alist
systemctl disable alist
```







## Alist使用网易云

> 参考文档：https://alist.nn.ci/zh/guide/drivers/163music.html#cookie

### 1.获取网易云音乐的 Cookie 

1. **打开网易云音乐**：在浏览器中访问 [网易云音乐](https://music.163.com/)，并登录账户。
2. **打开开发者工具**：在浏览器中按 `F12` 或右键点击页面选择“检查”来打开开发者工具。
3. **获取 Cookie 信息**：
   - 在开发者工具中，点击 **“应用程序”**（Application）标签页。
   - 在左侧找到 **“Cookies”**，并展开 `https://music.163.com`。
   - 找到两个重要的 Cookie 参数：
     - `__csrf`
     - `MUSIC_U`

### 2.配置 Alist

1. **将 Cookie 配置到 Alist**：

   - 打开 Alist 的配置文件，通常位于 `data/config.json` 中。
   - 将获取的 `__csrf` 和 `MUSIC_U` 值添加到 Alist 配置中。

   ```json
   __csrf=43D953B1F;
   ```
   
2. **重启 Alist 服务**：

   - 在修改配置文件后，重启 Alist 服务以使配置生效：

   - 启动服务需要指定`--config /data/alist/config.json`，否则修改无法生效，重启会还原配置

     ```bash
     systemctl restart alist.service
     ```



