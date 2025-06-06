# PiCgo上传报错排查

> 下载地址：https://github.com/Molunerfinn/PicGo/releases/tag/v2.3.1

## 1、上传报错

使用curl测试是否可以上传：

```
linux:
curl -X POST https://pic.joshzhong.top/api/index.php \
> -F "image=@/root/Dock.png" \
> -F "token=22279fb1162c6b6e133c5910f6fb8"

windows：
curl -X POST https://pic.joshzhong.top/api/index.php -F "image=@C:\Users\joshz\Pictures\11.png" -F "token=22279fb1162c6b6e133c5910f6fb8"
```

返回结果：

```
<html>
<head><title>413 Request Entity Too Large</title></head>
<body>
<center><h1>413 Request Entity Too Large</h1></center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
```

结果显示`413 Request Entity Too Large` 是一个 HTTP 错误代码，表示上传的文件大小超过了服务器允许的限制。修改nginx设置即可：

```
client_max_body_size 10M;
```

## 2、系统权限报错

```
2024-11-22 10:17:27 [PicGo ERROR] :
The operation was rejected by your operating system. 
```

**解决办法：以管理员身份运行picgo程序**



## 3、其他报错

### 1.检查上传设置

### 2.检查是否开启API上传

### 3.检查服务器权限

```
[root@josh ~]# ll /data/easyimage/
total 12
drwxr-xr-x 2 lighthouse lighthouse 4096 Sep 23 14:14 config
-rwxr-xr-x 1 lighthouse lighthouse  525 Sep 23 13:58 docker-compose.yml
drwxr-xr-x 4 lighthouse lighthouse 4096 Sep 23 14:21 image
```

没有则进行赋权

```
[root@josh data]# chmod 755 -R easyimage/
[root@josh data]# chown -R lighthouse.lighthouse easyimage/
```

