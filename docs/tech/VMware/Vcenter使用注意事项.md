## 1、vcenter安装centos7注意事项

创建虚拟机时，选择好对应的镜像文件，需要勾选`已连接`，这样系统镜像才能被识别到

![image-20240820160817083](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/1341dbec816926a49f83956e0ce9d5bb-image-20240820160817083-602cc3.png)





![image-20240820160910081](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/3771dd7baf82e1cebdd490b6cc771005-image-20240820160910081-ac946c.png)



## 2、制作虚拟机模板

### 1、关闭虚拟机电源

### 2、制作虚拟机模板

![image-20240820161524982](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/744c1921d3f856df33e89082f804b4e7-image-20240820161524982-a0474a.png)

![image-20240820161543785](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/08d42aa72b752efd07697614666992ea-image-20240820161543785-d3e373.png)

![image-20240820161614234](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/b131225bac8b6d39c8e08f7fd326a716-image-20240820161614234-84ac46.png)

![image-20240820161650049](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/3054a26e0d003ac8d2ec36256c902b38-image-20240820161650049-3f157b.png)



![image-20240820161728231](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/7ba83fd2c017570c0bc5dd60a384c093-image-20240820161728231-d78f97.png)



![image-20240820161745543](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/9829f5af328321db114f771287f94205-image-20240820161745543-1eaa76.png)



![image-20240820161754739](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/268eb9c330df0cac27fd4b94be56840f-image-20240820161754739-b349c7.png)





## 3、Vmware vCenter 上传文件至存储卷：提示不信任证书，导致无法上传



报错：

>由于不确定的原因，操作失败。通常，此问题是由于浏览器不信任证书引起的。如果您使用的是自签名证书或自定义证书，请在一个新的浏览器选项卡中打开以下 URL 并接受证书，然后重试此操作。

以上报错需要我们自己导入证书并信任即可。证书下载地址：你的域名后面加`/certs/download.zip`，下载完成后会有一个三个文件。

如：`https://10.22.51.45/certs/download.zip`

win双击安装证书即可，

![image-20240820141808709](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/20/6236b93907c6be8b2b9559f9d15d3d2a-image-20240820141808709-c09abd.png)

完成后，刷新浏览器再重新上传





> 参考：https://www.cnblogs.com/98record/p/14346342.html