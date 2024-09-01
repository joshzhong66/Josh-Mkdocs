# Esxi6.7 安装MacOS 10.15.6

> 支持Esxi6.7和Esxi7.0

## 1、下载安装文件

> Unlocker 3.0.0Github地址：https://github.com/Tonnp/esxi-unlocker/releases/tag/3.0
>
> 安装参考：https://www.youtube.com/watch?app=desktop&v=ZUbrIDkKWjU
>
> 更多mac下载：https://macoshome.com/macos/7947.html
>
> mac_iso下载地址：
>
> ```
> 通过百度网盘分享的文件：macOS.Catalina.iso
> 链接：https://pan.baidu.com/s/1DWcNCgG_jIZzyDSm6-WyrA 
> 提取码：enoj 
> ```







## 2、上传文件

### 1.上载文件Unlocker到esxi

![image-20240816215538223](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/1ab872641a10348bf0cd7ed6078848e7-image-20240816215538223-dc412c.png)

### 2.上传mac镜像文件到esxi

![image-20240816230109664](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/6556b033997721d99329b674b7096c36-image-20240816230109664-96dc8a.png)

## 3、安装Unlocker 3.0.0

```
[root@localhost:~] find / -name esxi-unlocker-3.0*
/vmfs/volumes/66af22a6-ea55e212-86a7-d45d6406a2f3/unlocker_300/esxi-unlocker-3.0.zip
[root@localhost:~] cd /vmfs/volumes/66af22a6-ea55e212-86a7-d45d6406a2f3/unlocker_300/
[root@localhost:/vmfs/volumes/66af22a6-ea55e212-86a7-d45d6406a2f3/unlocker_300] ls
esxi-unlocker-3.0.zip


unzip esxi-unlocker-3.0.zip && cd unzip esxi-unlocker-3.0
cd esxi-unlocker-3.0
chmod +x esxi-install.sh
```

>VMware Unlocker 3.0.0
>===============================
>Copyright: Dave Parsons 2011-18
>Installing unlocker.tgz
>Acquiring lock /tmp/bootbank.lck
>Copying unlocker.tgz to /bootbank/unlocker.tgz
>Editing /bootbank/boot.cfg to add module unlocker.tgz
>Success - please now restart the server!

重启esxi

```
reboot
```



## 4、安装mac

名称：可自定义

兼容性：默认

客户机操作系统系列：Mac OS

客户机操作系统版本：按mac版本进行选择（如10.15.6）

![image-20240816230347960](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/6a1ee512127e21bcda9ada851df2e4cb-image-20240816230347960-d0037c.png)

选择安装位置，尽量安装在固态硬盘，速度相对快一些

![image-20240816230420633](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/2452fbd6fd3a2345325929240bdae295-image-20240816230420633-c60cfc.png)

1.选择硬盘配置，根据个人需求，不建议太低

2.CD/DVD选择刚刚上传的镜像文件

![image-20240816231015346](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/41b05622cb5a2d894448ec6eb693a7fc-image-20240816231015346-425ee0.png)

选择镜像文件夹路径和文件名称

![image-20240816230931634](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/00f09d203cb416ebacd7fb584c6ccb2a-image-20240816230931634-987aa9.png)

创建完成页面

![image-20240816231047878](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/1f379cd6afe905f89e46a6f47cb3d1fe-image-20240816231047878-992afc.png)

![image-20240816231126274](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/1cdb51b364dc7ebb2060d0acd4ef6266-image-20240816231126274-7a6981.png)



开启虚拟机电源，在新窗口打开虚拟机

![image-20240816231236599](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/48e7f70ad8c4214de23cd0f63876750b-image-20240816231236599-656833.png)



打开虚拟机画面出现mac标识，可以进行安装。



![image-20240816231217042](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/cd4873d373f210db31a35a4a11e25676-image-20240816231217042-e2d132.png)

选择语言`中文`

![image-20240816231426458](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/d6763536ae55097dc9e71bfc769c43a8-image-20240816231426458-3d4dda.png)



选择`磁盘工具`，点击`继续`

![image-20240816231532080](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/02dc0bf419e4f3651888485ed5b6d3c0-image-20240816231532080-b8907c.png)

点击左上角`显示`

![image-20240816231614654](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/3f9ef09d8b49f2546ef4b4b413a13090-image-20240816231614654-084d6c.png)

点击`显示所有设备`，会显示出安装硬盘

![image-20240816231943651](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/c7ce8c11a57db1926b87ed1da2b9f036-image-20240816231943651-5536cd.png)

选择该硬盘，点击`抹掉`

![image-20240816232032546](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/473eaf7f12f7fcddddc7a8d7425e1661-image-20240816232032546-a2f2f3.png)

1- mac（据说名称要直通进去才能改）

2- 格式为APFS

3- GUID分区图

点击抹掉

![image-20240816232140119](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/971b8c6d960b58e449412de2a0f433cf-image-20240816232140119-fdfc01.png)

完成画面

![image-20240816232232193](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/9042102a69112628bd183e5a5f145c4c-image-20240816232232193-35261d.png)

关掉磁盘工具

![image-20240816232407116](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/30e7b8c3b7795048cb25a065f7b37623-image-20240816232407116-23ab84.png)



安装macos ，点击继续

![image-20240816232459515](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/532257638645ec5ecd48d122976c437e-image-20240816232459515-3249ca.png)

下一步，同意协议->选择磁盘->安装

![image-20240816232559432](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/178fbb645747c4114defe4526ca24a95-image-20240816232559432-c5af57.png)

等待ing....

![image-20240816234112812](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/1bb1b7b5b9509bdd7c772484aeecb3b8-image-20240816234112812-6cd64b.png)



![image-20240816234432327](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/10dd35b836d4d676f4f4d410defb2d52-image-20240816234432327-59b65f.png)





![image-20240816234459626](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/e2092156db0dc9d604ccd4a29ed766dc-image-20240816234459626-9e2eb0.png)

![image-20240816234514533](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/adf04eee136aa9a4932b823c252c29ee-image-20240816234514533-a7c034.png)





![image-20240816234619376](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/68fb1f73505f8f0b58b6e564ae35c88b-image-20240816234619376-08f03b.png)



![image-20240816234724963](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/f7f8ecd1ade588280b47ff723f7149a7-image-20240816234724963-e2a10b.png)



系统版本

![image-20240816234919355](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/16/810044b635aa620e455b64db42991360-image-20240816234919355-573c89.png)



如果需要直通显卡可以使用

>gtx660
>
>AMD rx590
>
>AMD rx5700xt
