# VeraCrypt加密工具使用说明

>官方下载地址：https://www.veracrypt.fr/en/Downloads.html
>
>内网下载地址：http://10.22.51.64/2_Tool/%E6%96%87%E4%BB%B6%E5%A4%B9%E5%8A%A0%E8%A7%A3%E5%AF%86/VeraCrypt.zip



## 一、下载安装软件

> 如官网下载的exe安装包，正常双击进行安装，内网提供的是便携版

下载`VeraCrypt.zip`复制到软件安装目录，解压该包，并鼠标右击将`VeraCrypt-x64.exe`发送到桌面快捷，然后双击`VeraCrypt-x64.exe`打开软件

![image-20250515113258571](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/4e59e4693a4c537479d6f91a0c31f81e-image-20250515113258571-48c870.png)

## 二、VeraCrypt使用教程

### 1.设置中文语言

VeraCrypt默认为English，

- 打开 VeraCrypt→点击【"Settings（设置）"】 → 【"Language（语言"）】→找到【"简体中文"】→确定【保存】

  ![image-20250515114022019](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/29ba2f657c50fbb21fe2888e6f8820e5-image-20250515114022019-f65e6a.png)

### 2.创建加密卷

打开 VeraCrypt → 点击 "Create Volume（创建加密卷）" 

![image-20250515114222773](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/5f5dd046f7b05a0d3f06d37f27dd2352-image-20250515114222773-ffced5.png)

选择【创建文件型加密卷】

![image-20250515114125775](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/e27f918a611649f8b294eeb24f12e651-image-20250515114125775-6899d4.png)

选择【标准VeraCrypt加密卷】

![image-20250515114152712](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/a5ff3a4a3f0726a823f5cab6ab2b293b-image-20250515114152712-c46782.png)

选择文件，

![image-20250515114416434](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/9c6f37f6447d2a17a3509a78e0bfc3af-image-20250515114416434-ce4f95.png)

这边设置路径为`D:\我的文档`为例，文件名设置为`Joshzhong`（我的名字为例），点击【保存】，

>这一步，是需要你确认，你想将这个加密卷应用在哪个磁盘
>
>可以是电脑本地的磁盘（C/D/E等），也可以是U盘、移动硬盘
>
>然后创建文件名，输入你的名字或用途（用于区分人员或用途）

![image-20250515114631369](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/4b2d264bed03990fab39f568979575a2-image-20250515114631369-e6d162.png)

点击【下一步】

![image-20250515114942198](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/83dc0b25cb0c81a726717a2532d9bfa0-image-20250515114942198-279d37.png)

默认【下一步】

![image-20250515115003178](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/10d81e7f27f6dd7a2ed4eef546a74fda-image-20250515115003178-d6dfec.png)



加密卷大小

>加密卷大小文件代表一个人的空间 设置密码（每个人不同） 设置容量（如 500MB / 1GB，可按需分配）
>
>主要看你存放的用途和用量，不要超过磁盘的总量，设置的太大，后续存放的东西多，可能会影响加解密的速度。

输入你想设置的加密卷大小，这边设置【1GB】（因为这边我的D盘只有2.55G，以1GB为例，这边设置的大小不能超过磁盘大小，并且设置后，就会占用磁盘的空间）

![image-20250515115335947](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/5da93b7183b19d5327efa47158d48d4f-image-20250515115335947-86a454.png)



设置加密卷密码

这边设置一个简单的密码【josh】，然后点击【下一步】

![image-20250515115415069](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/0ebf8cbcf5870361e828bf980b5ef72e-image-20250515115415069-f07592.png)

因为密码设置过短，则会如弹出警告提示：**点是 ，即可使用短密码**



加密卷格式化

默认选项，点击【格式化】，完成后退出

![image-20250515115548095](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/718918ed8ffee748360ca7370feda03b-image-20250515115548095-ffd941.png)



3.加载加密卷

点击【选择文件】  选择前面创建好的加密卷【D:\我的文档\Joshzhong】，选择盘符【A】（这边选A）

![image-20250515120031076](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/4a9f1fe70cd31c2e448a9991019dcabf-image-20250515120031076-361b7a.png)

输入加密密码`josh`，点击【确定】

![image-20250515120102052](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/426fff64072b631ccb1082d36136dbaa-image-20250515120102052-3f1f5a.png)

解密后，即可在【此电脑】-看到磁盘【本地磁盘-A】，并且大小为1GB容量

![image-20250515120120634](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/d086e518d934a174e452350237cca150-image-20250515120120634-ec0798.png)

你可以在【本地磁盘-A】存放文件，

![image-20250515120435441](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/8a3405bda1ef6fd935ebde0b0c175faa-image-20250515120435441-f60b50.png)

如何退出加密卷【本地磁盘-A】，点击【卸载】即可

![image-20250515120513642](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2025/05/15/bc13ab175bc523cde78b84c0ddf6b960-image-20250515120513642-7ac809.png)