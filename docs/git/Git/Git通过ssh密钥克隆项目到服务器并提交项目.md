# Git通过ssh密钥克隆项目到服务器并提交项目



> 参考GitHub[官方文档](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## 一、GitHub添加SSH Key

### 1.安装git

```bash
yum -y install git
```

### 2.客户端生成SSH Key

生成一个 SSH 密钥并将其添加到 GitHub 账户：

```bash
ssh-keygen -t rsa -b 4096 -C "you_github_mail"
```

生成过程，需要执行三次回车（Enter）：

```bash
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:QyPWLQ9/kpUOYUBMP8g1aVtzKbHQIPhj3uoeq1fNPqU whizhzl@gmail.com
The key's randomart image is:
+---[RSA 4096]----+
|       ==.B+.. . |
|      .o.Bo+=oo  |
|      o.O.=o++   |
|     . o+*.*     |
|       oSo=oo    |
|        ..ooo .  |
|        .o . o   |
|        oo  E    |
|      .=+    .   |
+----[SHA256]-----+
```

### 3.查看密钥

查看输出的公钥内容，并在 GitHub 的账户设置中添加这个 SSH 密钥：

```shell
cat ~/.ssh/id_rsa.pub
```

### 4.添加密钥

访问GitHub，登陆GitHub账户，按照以下步骤操作：

- 在 GitHub 任意页的右上角，单击个人资料照片，然后点击设置【Settings】；
- 在左边的【Access】栏中，点击SSH 和 GPG 密钥【SSH and GPG keys】；
- 点击新建 SSH 密钥【New SSH key】；
- 填写标题【Title】字段；
- 选择密钥类型【Key type】为 `Authentication Key`；
- 在密钥【Key】字段中，粘贴公钥；
- 点击添加SSH密钥【Add SSH key】按钮。

![](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/996148c783050541d3194024a064546e-image-20240830131759522-8397f8.png)



## 二、GitHub添加用户

### 1.查看Git配置

查看 Git 是否已经配置了用户名称和邮箱，可以使用以下命令：

```bash
git config --global user.name
git config --global user.email
```

### 2.配置用户与邮箱

如果你希望在 GitHub 上提交时，提交记录与你的 GitHub 账号一致，那么你在本地 Git 配置的用户名和邮箱与 GitHub 账号也需要保持一致。

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

>[root@jerion2 ~]# git config --global user.name "zyx3721"
>[root@jerion2 ~]# git config --global user.email "whizhzl@gmail.com"
>[root@jerion2 ~]# git config --global user.email                    
>whizhzl@gmail.com
>[root@jerion2 ~]# git config --global user.name                     
>zyx3721



## 三、GItHub仓库操作

### 1.克隆项目

克隆一个非自己的项目到服务器本地目录上，这里以 Mkdocs-material 站点项目为例：

```bash
mkdir -p /data/Mkdocs-material
cd /data/Mkdocs-material
git clone https://github.com/shenweiyan/Knowledge-Garden.git

# 显示信息
Cloning into 'Knowledge-Garden'...
remote: Enumerating objects: 14860, done.
remote: Counting objects: 100% (14629/14629), done.
remote: Compressing objects: 100% (1484/1484), done.
remote: Total 14860 (delta 6743), reused 14330 (delta 6721), pack-reused 231 (from 1)
Receiving objects: 100% (14860/14860), 80.26 MiB | 1.11 MiB/s, done.
Resolving deltas: 100% (6774/6774), done.
```

### 2.查看当前远程仓库

查看当前Git 仓库中配置的远程仓库（remote）信息地址：

```bash
/data/Mkdocs-material/Knowledge-Garden
git remote -v

# 显示信息
origin  https://github.com/shenweiyan/Knowledge-Garden.git (fetch)
origin  https://github.com/shenweiyan/Knowledge-Garden.git (push)
```

> **解释说明：**
>
> - `origin`：这是远程仓库的名称，默认情况下，Git 将克隆的远程仓库命名为 `origin`。可以为每个远程仓库设置不同的名字。
> - `(fetch)`：表示用于拉取数据的 URL。当运行 `git fetch` 或 `git pull` 时，Git 会从这个 URL 获取数据。
> - `(push)`：表示用于推送数据的 URL。当运行 `git push` 时，Git 会将数据推送到这个 URL。

### 3.移除远程仓库地址

使用 `git remote remove` 命令移除远程仓库地址：

```bash
git remote remove origin
git remote -v	 # 再次查看当前配置的远程仓库地址，会发现已经没有了
```

### 4.添加我的GitHub仓库作为远程仓库

在当前服务器的本地仓库目录下，使用 `git remote add` 命令添加我的github远程仓库（这里我在github上创了一个空的仓库）：

```bash
git remote add origin https://github.com/zyx3721/Jerion-MkDoc.git	# https方式
git remote add origin git@github.com:zyx3721/Jerion-MkDoc.git		# ssh方式
```

之前已经配置了 SSH 密钥并添加到 GitHub，可以选择使用 SSH URL，这样无需每次推送时输入用户名和密码

再次查看当前配置的远程仓库地址，确认地址是否变更：

```bash
git remote -v

# 显示信息
origin  git@github.com:zyx3721/Jerion-MkDoc.git (fetch)
origin  git@github.com:zyx3721/Jerion-MkDoc.git (push)
```

### 5.提交代码

```bash
git commit -m "Mkdocs-material"	   # 提交代码
git push origin main	           # main 或者 master指分支名称
git push --force origin main       # 强制推送
```

### 6.拉取更新代码

使用 `git pull` 命令从远程仓库名 `origin` 上拉取 main 分支最新代码：

```bash
git pull origin main
```

> **解释说明：**
>
> - `origin` 是远程仓库的默认名称。
> - `main` 是要拉取的远程分支名称。



## 四、报错解决办法

### 1.git add报错参考

为什么会使用 `git add .`，是因为远程代码和您的本地代码之间有冲突，Git 会提示您解决冲突。

#### 1.1 git add报错

```bash
(venv) [root@josh JoshZhong-MkDoc]#	git add .
```

>如果在执行 `git add .` 时遇到了删除文件未被追踪的问题。这是因为当前版本的 Git 默认不会追踪已删除的文件，您需要明确告诉 Git 记录这些删除操作。

#### 1.2 git add报错解决办法

使用 `git status` 检查工作区状态：

```bash
# 使用 git status 检查哪些文件被删除或修改
git status
# 使用 git add --all 记录所有更改
git add --all
```

>(venv) [root@josh JoshZhong-MkDoc]# git add --all
>(venv) [root@josh JoshZhong-MkDoc]# git commit -m "修改mkdocs.yml"
>[main 85fbf1e] 修改mkdocs.yml
> 327 files changed, 40126 insertions(+), 40303 deletions(-)
> create mode 100644 __pycache__/hooks.cpython-39.pyc
> create mode 100644 __pycache__/meta_slugs.cpython-39.pyc
> delete mode 100644 script/discussions2Mkdocs.py

使用 `git add --all` 或 `git add -A`，这样 Git 将会追踪新增、修改和删除的所有文件，执行 `git add --all` 后，可以继续提交更改。

#### 1.3 再次提交代码

```bash
git commit -m "Your commit message"
```

#### 1.4 推送更改到远程仓库

```bash
git push origin main
```

### 2.git push报错参考

#### 2.1 推送代码报错

```bash
git push origin main
```

>(venv) [root@josh JoshZhong-MkDoc]# git push origin main
>The authenticity of host 'github.com (20.205.243.166)' can't be established.
>ECDSA key fingerprint is SHA256:p2QAMXNIC1TJYWeIOttrVc98/R1BUFWu3/LiyKgUfQM.
>ECDSA key fingerprint is MD5:7b:99:81:1e:4c:91:a5:0d:5a:2e:2e:80:13:3f:24:ca.
>Are you sure you want to continue connecting (yes/no)? yes
>Warning: Permanently added 'github.com,20.205.243.166' (ECDSA) to the list of known hosts.
>To git@github.com:joshzhong66/JoshZhong-MkDoc.git
> ! [rejected]        main -> main (fetch first)
>error: failed to push some refs to 'git@github.com:joshzhong66/JoshZhong-MkDoc.git'
>hint: Updates were rejected because the remote contains work that you do
>hint: not have locally. This is usually caused by another repository pushing
>hint: to the same ref. You may want to first merge the remote changes (e.g.,
>hint: 'git pull') before pushing again.
>hint: See the 'Note about fast-forwards' in 'git push --help' for details.

错误是因为远程仓库中的 `main` 分支包含了一些您本地仓库没有的更改。Git 防止您在不合并这些远程更改的情况下直接推送新的更改，以避免丢失数据。

#### 2.2 推送报错解决办法

##### 解决办法一：合并冲突，再次提交

- 拉取远程仓库的更改并合并：


```bash
git pull origin main
```

将拉取远程仓库的 `main` 分支并与您的本地 `main` 分支合并。如果有冲突，您需要手动解决冲突，然后提交合并后的结果。

- 推送合并后的更改（如果合并成功且没有冲突，可以推送）：

```
git push origin main
```

##### 解决办法二：覆盖远程仓库

如果不保留远程更改，可以使用强制推送：

```bash
git push --force origin main
```

>Counting objects: 1094, done.
>Delta compression using up to 2 threads.
>Compressing objects: 100% (938/938), done.
>Writing objects: 100% (1094/1094), 2.81 MiB | 833.00 KiB/s, done.
>Total 1094 (delta 429), reused 389 (delta 119)
>remote: Resolving deltas: 100% (429/429), done.
>remote: To git@github.com:joshzhong66/JoshZhong-MkDoc.git
>
> + f47159d...85fbf1e main -> main (forced update)

关键点：

- **Counting objects** 和 **Compressing objects**：表示 Git 正在准备推送的对象。
- **Writing objects**：表示这些对象已经成功写入远程仓库。
- **Resolving deltas**：远程仓库已经成功处理并应用了这些更改。
- **forced update**：表示您使用了强制推送，覆盖了远程仓库中的 `main` 分支。
