

# picgo

> 下载地址：https://github.com/Molunerfinn/PicGo/releases/tag/v2.3.1

## 1、上传报错

使用curl测试是否可以上传：

```
curl -X POST https://pic.joshzhong.top/api/index.php \
> -F "image=@/root/Dock.png" \
> -F "token=22279fb1162c6b6e133c5910f6fb8"
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



### 3、其他报错

检查上传设置

![image-20241123202223353](https://pic.joshzhong.top/i/2024/11/23/xfziag-0.png)

检查是否开启API上传

![image-20241123202246024](https://pic.joshzhong.top/i/2024/11/23/xg4f18-0.png)

