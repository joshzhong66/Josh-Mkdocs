# GitHub操作文档参考

## 1、GitHub添加SSH Key

> 克隆项目遇到报错：
>
> RPC failed; result=35



### 1.安装git

```
yum -y install git
```



### 2.客户端生成SSH Key

生成一个 SSH 密钥并将其添加到 GitHub 账户

```
ssh-keygen -t rsa -b 4096 -C "you_github_mail"
```

生成过程，需要执行三次回车（Enter）：

>Generating public/private rsa key pair.
>Enter file in which to save the key (/root/.ssh/id_rsa): 
>Enter passphrase (empty for no passphrase): 
>Enter same passphrase again: 
>Your identification has been saved in /root/.ssh/id_rsa.
>Your public key has been saved in /root/.ssh/id_rsa.pub.
>The key fingerprint is:
>SHA256:eK6Ft7m/EUja3Ux+7IrhaOmOaV5ydH5vUQdI0EFusIQ josh.zhong66@gmail.com
>The key's randomart image is:
>+---[RSA 4096]----+
>|         .+=+o   |
>|        E. +o .  |
>|        . . +  . |
>|       = o * .  o|
>|      o S + + o..|
>|       = o . o.  |
>|      o *.+ . .. |
>|      .Xo= = o.  |
>|     o=+Bo=....  |
>+----[SHA256]-----+

### 3.查看密钥

查看输出的公钥内容，并在 GitHub 的账户设置中添加这个 SSH 密钥。

```shell
cat ~/.ssh/id_rsa.pub
```

### 4.添加密钥

访问GitHub，登陆GitHub账户，按照以下步骤操作：

1. 在 GitHub 任意页的右上角，单击个人资料照片，然后单击“**设置**”。
2. 在边栏的“Access”部分中，单击 “SSH 和 GPG 密钥”。
3. 单击“新建 SSH 密钥”或“添加 SSH 密钥” 。
4. 在 "Title"（标题）字段中，为新密钥添加描述性标签。 例如，如果使用的是个人笔记本电脑，则可以将此密钥称为“个人笔记本电脑”。
5. 选择密钥类型（身份验证或签名）。 有关提交签名的详细信息，请参阅“[关于提交签名验证](https://docs.github.com/zh/authentication/managing-commit-signature-verification/about-commit-signature-verification)”。
6. 在“密钥”字段中，粘贴公钥。
7. 单击“添加 SSH 密钥”。
8. 如果出现提示，请确认你的帐户是否拥有 GitHub 访问权限。 有关详细信息，请参阅“[Sudo 模式](https://docs.github.com/zh/authentication/keeping-your-account-and-data-secure/sudo-mode)”。



![image-20240829231938292](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/08/29/e5b2b20289b8f5a2b9608b75faa1a633-image-20240829231938292-54f5df.png)





## 2、GitHub添加用户

### 1.查看Git配置

查看 Git 是否已经配置了用户名称和邮箱，可以使用以下命令：

```
git config --global user.name
git config --global user.email
```



### 2.配置用户与邮箱

如果你希望在 GitHub 上提交时，提交记录与你的 GitHub 账号一致，那么你在本地 Git 配置的用户名和邮箱与 GitHub 账号也需要保持一致。

```
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

>(venv) [root@josh]# git config --global user.name joshzhong66
>(venv) [root@josh]# git config --global user.email josh.zhong66@gmail.com
>(venv) [root@josh]# git config --global user.email
>josh.zhong66@gmail.com
>(venv) [root@josh]# git config --global user.name         
>joshzhong66



## 3、GItHub仓库操作

### 1.克隆项目

```
git clone https://github.com/joshzhong66/JoshZhong-MkDoc.git
```

>Cloning into 'JoshZhong-MkDoc'...
>remote: Enumerating objects: 3, done.
>remote: Counting objects: 100% (3/3), done.
>remote: Compressing objects: 100% (2/2), done.
>remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
>Unpacking objects: 100% (3/3), done.



### 2.查看当前远程仓库

查看当前配置的远程仓库地址

```
cd /data/Mkdocs-material/JoshZhong-MkDoc
git remote -v
```

>origin  https://github.com/shenweiyan/Knowledge-Garden.git (fetch)
>origin  https://github.com/shenweiyan/Knowledge-Garden.git (push)



### 3.移除远程仓库地址

```
git remote remove origin
git remote -v	#再次查看当前配置的远程仓库地址，会发现已经没有了
```



### 4.添加您的 GitHub 仓库作为远程仓库

添加我的远程仓库地址作为作为远程仓库

```
git remote add origin https://github.com/joshzhong66/JoshZhong-MkDoc.git	$https
git remote add origin git@github.com:joshzhong66/JoshZhong-MkDoc.git		#ssh url
```

之前已经配置了 SSH 密钥并添加到 GitHub，可以选择使用 SSH URL，这样无需每次推送时输入用户名和密码

再次查看当前配置的远程仓库地址，确认地址是否变更

```
git remote -v
```

>(venv) [root@josh JoshZhong-MkDoc]# git remote -v
>origin  https://github.com/joshzhong66/JoshZhong-MkDoc.git (fetch)
>origin  https://github.com/joshzhong66/JoshZhong-MkDoc.git (push)



### 5.提交代码

```
git commit -m "Your commit message"	#提交代码
git push --force origin main		# main或者 master指分支名称
git push --force origin main		#强制推送
```



### 6.拉取更新代码

```
git pull origin main
```

- `origin` 是远程仓库的默认名称。
- `main` 是您要拉取的远程分支名称。



## 4、报错解决办法

### 1.git add报错参考

为什么会使用`git add .`，是因为远程代码和您的本地代码之间有冲突，Git 会提示您解决冲突。

#### 1.git add报错

```
(venv) [root@josh JoshZhong-MkDoc]#	git add .
```

>如果在执行 `git add .` 时遇到了删除文件未被追踪的问题。这是因为当前版本的 Git 默认不会追踪已删除的文件，您需要明确告诉 Git 记录这些删除操作。

#### 2.git add报错解决办法

使用 `git status` 检查工作区状态

```
git status		#使用 git status 检查哪些文件被删除或修改
 git add --all	#使用 git add --all 记录所有更改
```

>(venv) [root@josh JoshZhong-MkDoc]# git add --all
>(venv) [root@josh JoshZhong-MkDoc]# git commit -m "修改mkdocs.yml"
>[main 85fbf1e] 修改mkdocs.yml
> 327 files changed, 40126 insertions(+), 40303 deletions(-)
> create mode 100644 __pycache__/hooks.cpython-39.pyc
> create mode 100644 __pycache__/meta_slugs.cpython-39.pyc
> delete mode 100644 script/discussions2Mkdocs.py

使用 `git add --all` 或 `git add -A`，这样 Git 将会追踪新增、修改和删除的所有文件，执行 `git add --all` 后，您可以继续提交更改

#### 3.再次提交代码

```
git commit -m "Your commit message"
```

#### 4.推送更改到远程仓库

```
git push origin main
```



### 2.推送代码报错

```
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

### 8.推送报错解决办法

#### 1.解决办法1：合并冲突，再次提交

**1.拉取远程仓库的更改并合并**

```
git pull origin main
```

将拉取远程仓库的 `main` 分支并与您的本地 `main` 分支合并。如果有冲突，您需要手动解决冲突，然后提交合并后的结果。

推送合并后的更改

**2.如果合并成功且没有冲突，您可以推送**

```
git push origin main
```



#### 2.解决办法2：覆盖远程仓库

如果不保留远程更改，可以使用强制推送

```
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

- **Counting objects** 和 **Compressing objects**: 表示 Git 正在准备推送的对象。
- **Writing objects**: 表示这些对象已经成功写入远程仓库。
- **Resolving deltas**: 远程仓库已经成功处理并应用了这些更改。
- **forced update**: 表示您使用了强制推送，覆盖了远程仓库中的 `main` 分支。





> 参考GitHub[官方文档](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)