# Git通过ssh密钥克隆项目到本地



## 一、打开命令行终端

打开命令行终端，例如：`Git Bash`、`命令提示符` 或 `PowerShell`。



## 二、生成SSH密钥

运行以下命令，生成一个 SSH 密钥并将其添加到 github 账户：

```bash
ssh-keygen -t rsa -b 4096 -C "hongzelong@sunline.cn"
```

生成过程，需要执行三次回车（Enter）：

```
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\Jerion/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in C:\Users\Jerion/.ssh/id_rsa.
Your public key has been saved in C:\Users\Jerion/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:ctaFzDjvbQGVaOLV7VZancE2DVSB1O1qReTSYSytzsk hongzelong@sunline.cn
The key's randomart image is:
+---[RSA 4096]----+
|           oo=OOX|
|        .++oooo@O|
|       .o+= ..=*+|
|        .+ o .+.o|
|      . S o =..o |
|       + . . Eo  |
|          . o.   |
|           .     |
|                 |
+----[SHA256]-----+
```



## 三、添加密钥

打开 `C:\Users\Jerion/.ssh/id_rsa.pub` 公钥文件，复制里面的密钥内容：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/28bf2d54b26a339af195ae941ff6543b-image-20240830173840249-eed82b.png" alt="image-20240830173840249" style="zoom:50%;" />

在 github 或者 gitlab 等平台，添加公钥，这里添加到 github 平台上：

- 在 GitHub 任意页的右上角，单击个人资料照片，然后点击设置【Settings】；
- 在左边的【Access】栏中，点击SSH 和 GPG 密钥【SSH and GPG keys】；
- 点击新建 SSH 密钥【New SSH key】；
- 填写标题【Title】字段；
- 选择密钥类型【Key type】为 `Authentication Key`；
- 在密钥【Key】字段中，粘贴公钥；
- 点击添加SSH密钥【Add SSH key】按钮。

![image-20240830203522626](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/cbaffa952bcdefa47c33a8e8e196c03e-image-20240830203522626-fa68b6.png)



## 四、克隆项目到本地

再次打开命令行终端，执行以下命令进行克隆项目到本地指定路径下：

```bash
git clone git@github.com:zyx3721/Jerion-MkDoc.git D:\Jerion-MkDoc
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/5a691203cca3e2fb648226d77613253a-image-20240830175725209-3feffb.png" alt="image-20240830175725209" style="zoom: 33%;" />

增大Git的缓冲区大小： 

```bash
git config --global http.postBuffer 524288000
```

关闭部分Git特性以减少资源消耗：

```bash
git config --global core.compression 0
```

