# Alist文档



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
   __csrf=4c275809be2063ff4ec916fe91f5feb6;MUSIC_U=000FE5EB6356EEEFE3AE6B1D5E38C17EBD48676C2A9D0DE8CDBB667409B36D6FA020191754C511FCFC4D820315F2CAAEFE3D67E89DC180DDB67C33A45D173D953423AA7B3259341EDFE105ABAFE977927E1C3C31C900E8815C8B26221E30449C938B5267FD69AF90DCF19DEAD9408BD7D1B6A9734A6A4C1BC830E46A4A2EB4A228048AEC9A78D535CA4F370B848366BD213B25FB7C608A162F35EE82C189942D1A6D733C0B69E758E04615AC9F71E9377A0A6D2694EA48E5C0CC41A13C1E0E57DE45465D7B493D9A2C345E676D1295168323746BA8A545FA1BA2A27E6AD4E4B794C1E51A55209EAE5838DB5E8CB79C5A6E499CF0E79CC3B4980FCC9A2804B0B8009AF64823D68207A3C0A814AB62A2596E9E2E2FC0E2DB989F6F51D1ED5F8F5F606B89E931C2F771045BF1B87253CA3B9A36F16917BC73CF24C64B8AFA8AF3FD0CB85251B32BAD8F30F2997941CFA8CB5EDB42D36661ED32E89118D7E565AAAB1F;
   ```
   
2. **重启 Alist 服务**：

   - 在修改配置文件后，重启 Alist 服务以使配置生效：

   - 启动服务需要指定`--config /data/alist/config.json`，否则修改无法生效，重启会还原配置

     ```bash
     systemctl restart alist.service
     ```



```

```

