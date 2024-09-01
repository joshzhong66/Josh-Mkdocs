# CentOS7 部署Gitlab



> 官网地址：https://about.gitlab.com/install/#centos-7

## 一、Gitlab概念

​		Gitlab是一个基于Web的Git仓库管理工具，它提供了版本控制、代码审查、问题跟踪、持续集成等功能，适用于团队协作和软件开发管理。本文将介绍如何在CentOS 7上部署Gitlab，并提供了安装步骤、配置修改、备份和恢复等操作示例。



## 二、环境要求

- CPU >= 4C
- 内存 >= 4G
- 系统  = Linux



## 三、下载Gitlab

下载Gitlab RPM包：

- 清华大学开源软件镜像站地址：[Index of /gitlab-ce/yum/el7/ | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/)
- Gitlab rpm源下载：[el/7/gitlab-ce-15.1.2-ce.0.el7.x86_64.rpm - gitlab/gitlab-ce ·packages.gitlab.com](https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/7/gitlab-ce-15.1.2-ce.0.el7.x86_64.rpm)
- GITLAB官方文档：https://docs.gitlab.cn/jh/install/requirements.html

后台通过 `wget` 命令下载：

```bash
cd /usr/local/src
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-17.0.2-ce.0.el7.x86_64.rpm
```



## 三、安装Gitlab

### 1.设置主机名（可选）

```bash
hostnamectl set-hostname gitlab-20
```

### 2.安装依赖

```bash
yum install -y curl policycoreutils-python openssh-server perl
```

### 3.安装Gitlab

#### 3.1 rpm包安装（方法一）

进入下载包的目录，通过以下命令安装：

```bash
rpm -i gitlab-ce-17.0.2-ce.0.el7.x86_64.rpm
```

#### 3.2 脚本安装（方法二）

使用curl工具从指定URL下载Gitlab的安装脚本，并通过管道将脚本传递给bash执行。脚本的作用是设置Gitlab的安装源并执行安装过程：

```bash
curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | /bin/bash
```

> **解释说明：**
>
> - `-f` 或 `--fail`：在 HTTP 请求失败时不显示错误信息，只返回非零退出状态码。这对于脚本处理非常有用，因为它避免了将错误页面的 HTML 输出到标准输出。
> - `-s` 或 `--silent`：静默模式。不显示进度条或错误信息，常用于脚本中以避免干扰输出。
> - `-S` 或 `--show-error`：在使用 `-s` 静默模式时，如果发生错误，依然显示错误信息。这样可以在保持静默的同时确保错误信息不会被完全隐藏。
> - `-L` 或 `--location`：如果请求的资源已被重定向（HTTP 3xx 状态码），则跟随重定向到新的 URL。

#### 3.3 使用yum包管理器安装（方法三）

其中，`EXTERNAL_URL`是一个环境变量，用于指定Gitlab的访问URL，需要将"你的IP"替换为实际的IP地址或域名。`-y`选项用于自动回答安装过程中的确认提示。

```bash
sudo EXTERNAL_URL="http://你的IP" yum install -y gitlab-jh
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/8ea8608dc9bab2e86104ec444a074315-image-20240830183531440-c92488.png" alt="image-20240830183531440" style="zoom:50%;" />

#### 3.4 Gitlab初始密码

除非在安装过程中指定了自定义密码，否则将随机生成一个密码并存储在 `/etc/gitlab/initial_root_password` 文件中（出于安全原因，24 小时后，此文件会被第一次 `gitlab-ctl reconfigure` 自动删除，因此若使用随机密码登录，建议安装成功初始登录成功之后，立即修改初始密码），使用此密码和用户名 `root` 登录。

```bash
cat /etc/gitlab/initial_root_password
# 显示有关密码
Password: /LivZObhurwA64YUDtEaHnXs/ylVl7JengZtylcD73Q=
```

### 4.配置Gitlab

#### 4.1 修改Gitlab配置文件

`/etc/gitlab/gitlab.rb` 是 GitLab 的主要配置文件，用于管理 GitLab 实例的各种设置。通过修改这个文件，你可以配置 GitLab 的 URL、数据库设置、备份设置、邮件通知、SSL 证书、外部服务集成等。

修改 `/etc/gitlab/gitlab.rb` 配置文件：

```bash
vim /etc/gitlab/gitlab.rb
```

修改 `external_url ` 为你的域名和端口，如：

```bash
external_url 'http://10.22.51.64:7070'
```

#### 4.2 修改Gitlab nginx配置（可选）

编辑 `/var/opt/gitlab/nginx/conf/gitlab-http.conf` 文件，设置HTTP或HTTPS的监听端口，并保存修改：

```bash
vim /var/opt/gitlab/nginx/conf/gitlab-http.conf
```

#### 4.3 查看当前绑定的域名或IP

```bash
grep "^external_url" /etc/gitlab/gitlab.rb
```

### 5.启动Gitlab服务

先启动所有 gitlab 组件：

```bash
gitlab-ctl start
```

再启动服务：

```bash
gitlab-ctl reconfigure
```



## 四、访问Gitlab

浏览器访问 `http://10.22.51.64:7070`，输入用户名 `root` 和随机密码进行登录：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/5842964fee8352943c70b42de207c35a-image-20240830170651871-64be73.png" alt="image-20240830170651871" style="zoom:50%;" />



## 五、Gitlab常用命令

```bash
gitlab-ctl start                  # 启动所有 gitlab 组件
gitlab-ctl stop                   # 停止所有 gitlab 组件
gitlab-ctl restart                # 重启所有 gitlab 组件
gitlab-ctl status                 # 查看服务状态
gitlab-ctl reconfigure            # 重载配置文件加载
gitlab-ctl tail                   # 实时查看 gitlab 的日志输出
gitlab-ctl tail nginx             # 指定查看 Nginx 的日志
```

> `gitlab-ctl reconfigure ` 是基于 `/etc/gitlab/gitlab.rb` 配置文件重新生成配置并应用更改。每当修改了 `gitlab.rb` 文件后，都需要执行这个命令以使修改生效。因此无需再重启 gitlab 组件。



## 六、使用Gitlab

### 1.创建群组

登录 Gitlab 平台，在【群组】栏中——点击【新建群组】——点击【创建群组】：

- 填写【群组名称】为 `yunwei`；
- 填写【群组 URL】为 `yunwei`；
- 其他配置自定义，然后点击【创建群组】。

![image-20240830181337218](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/f6f666736f034e91264fd8539f4140d2-image-20240830181337218-a74874.png)

### 2.创建项目

登录 Gitlab 平台，在【项目】栏中——点击【新建项目】——点击【创建空白项目】：

- 填写【项目名称】为 `Devp_Scripts`；
- 选择【项目 URL】为刚刚创建的群组 `yunwei`；
- 【项目字符串】默认就行，会自动与项目名称一致（小写），然后点击【新建项目】。

![image-20240830181358001](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/1509f822907fa54d2a7a1ed0b9ce156d-image-20240830181358001-aaeb6a.png)

### 3.创建用户并添加到群组

登录 Gitlab 平台，点击左下方【Admin】进入【Admin area】——点击【用户】——点击【新用户】，分别输入要创建的名称、用户名、电子邮件，并设置【访问级别】，然后点击【创建用户】；创建完成后，再次点击该用户的【编辑】，设置密码并保存更改：

![image-20240830182724233](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/d5984f5e1257498c44febdfdd6ee071a-image-20240830182724233-3b7ffd.png)

点击【群组】——点击创建的群组 `yunwei` ——点击【群组成员】栏中的【管理权限】——点击【邀请成员】，选择需要邀请的用户和用户角色，然后点击【邀请】：

![image-20240830182947232](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/23086bf100e708277fe0a710c6aa6911-image-20240830182947232-ae9b0e.png)

### 4.配置ssh密钥并克隆项目到本地

#### 4.1 本地生成SSH密钥

本地电脑打开命令行终端，例如：`Git Bash`、`命令提示符` 或 `PowerShell`，运行以下命令，生成一个 SSH 密钥并将其添加到 gitlab 账户：

```bash
ssh-keygen -t rsa -b 4096 -C "hongzelong@sunline.cn"
```

#### 4.2 Gitlab添加密钥

打开 `C:\Users\Jerion/.ssh/id_rsa.pub` 公钥文件，复制里面的密钥内容：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/28bf2d54b26a339af195ae941ff6543b-image-20240830203403574-0ea8bf.png" alt="image-20240830203403574" style="zoom:50%;" />

以自己的普通用户登录 Gitlab 平台，添加公钥，点击左上方按钮进入个人【偏好设置】——点击【SSH密钥】——点击【添加新密钥】，在【密钥】字段内填写上方的密钥内容，并填写【标题】，然后点击【添加密钥】：

![image-20240830204429915](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/2405a443d7fc0fc86bb53f3c9c1b3561-image-20240830204429915-127340.png)

#### 4.3 复制Git项目路径

登录 Gitlab 平台，在【项目】栏中点击之前创建的项目 `Devp_Scripts`，点击右方的【代码】，复制【使用 SSH 克隆】的Git项目路径：

```bash
git@10.22.51.64:yunwei/devp_scripts.git
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/a43d5bbaeb46fcabf6c383f8177aeacd-image-20240830204724961-5fe9b1.png" alt="image-20240830204724961" style="zoom:50%;" />

#### 4.4 克隆Git项目到本地

本地电脑打开命令行终端，执行以下命令进行克隆项目到本地指定路径下：

```bash
# 默认克隆仓库里的main或master分支
git clone git@10.22.51.64:yunwei/devp_scripts.git D:\devp_scripts\main
# 使用 -b 选项手动指定克隆仓库里的shell分支
git clone -b shell git@10.22.51.64:yunwei/devp_scripts.git D:\devp_scripts\shell
```

打开克隆到本地后的main分支仓库 `D:\devp_scripts\main` 路径目录如下：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/cb27dab089b566fb51f2c9b6d09a4ff7-image-20240830211939474-f6e7c9.png" alt="image-20240830211939474" style="zoom:50%;" />

打开克隆到本地后的shell分支仓库 `D:\devp_scripts\shell` 路径目录如下：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/bd4479737746c6bd15008a997e9a93d5-image-20240830212142753-4d623b.png" alt="image-20240830212142753" style="zoom:50%;" />

#### 4.5 本地提交代码到Git项目

假设在本地两个分支仓库操作了文件，如上传一个文档后，打开命令行终端，执行以下命令提交代码到Git项目中：

- 提交代码到main分支仓库：

```bash
d:	  # 进入d盘
cd devp_scripts/main    # 切换到main分支仓库目录
git add .          # 将目录下更改信息（新文件、已修改文件或已删除文件）添加到暂存区, .代表当前目录
git commit -m "shell script"    # 将暂存区中的内容提交到当前分支仓库
git push origin main            # 将本地的提交推送到远程的main分支仓库
```

- 提交代码到shell分支仓库：

```bash
d:	  # 进入d盘
cd devp_scripts/shell    # 切换到shell分支仓库目录
git add .          # 将目录下更改信息（新文件、已修改文件或已删除文件）添加到暂存区, .代表当前目录
git commit -m "shell script"    # 将暂存区中的内容提交到当前分支仓库
git push origin shell            # 将本地的提交推送到远程的shell分支仓库
```

登录 Gitlab 平台，点击【项目】栏中的项目 `Devp_Scripts`：

- 查看main分支仓库刚提交的代码：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/e9c75311ba041a80a3de30328d8d6ece-image-20240830213941530-260fa2.png" alt="image-20240830213941530" style="zoom:50%;" />

- 查看shell分支仓库刚提交的代码：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/9a8902cb48b26c943242b11ca95cfb49-image-20240830213957121-4f87a6.png" alt="image-20240830213957121" style="zoom:50%;" />

### 5.配置Gitlab数据备份

#### 5.1 设置备份目录

服务器后台创建备份目录 `/data/backup/gitlab`：

```bash
mkdir -p /data/backup/gitlab        # 创建备份目录
```

#### 5.2 修改Gitlab配置文件

修改Gitlab配置文件 `/etc/gitlab/gitlab.rb`，将备份路径设置为自定义目录：

```bash
sed -i 's@# gitlab_rails\['"'"'backup_path'"'"'\] = "/var/opt/gitlab/backups"@gitlab_rails\['"'"'backup_path'"'"'\] = "/data/backup/gitlab"@g' /etc/gitlab/gitlab.rb

# 查看是否修改成功
grep "/data/backup/gitlab" /etc/gitlab/gitlab.rb
```

修改配置文件后，需重新加载配置并确保所有更改生效：

```bash
gitlab-ctl reconfigure
```

#### 5.3 赋予目录权限

设置备份目录的所有权为 git 用户，所属组为 root，并设置权限为 `700`：

```bash
chown -R git.root /data/backup/gitlab
chmod 700 /data/backup/gitlab
```

#### 5.4 创建Gitlab数据备份

执行以下命令创建Gitlab数据备份，将相关的数据（如数据库、上传文件、Git 存储库等）备份到配置的备份目录中：

```bash
gitlab-rake gitlab:backup:create
```

> **备份过程：**
>
> - **备份内容**：数据库、仓库、上传的文件等。
> - **备份文件名**：通常会根据当前日期和时间生成一个文件名，例如：`1631966741_2024_08_30_13.0.6_gitlab_backup.tar`。

#### 5.5 查看备份文件

使用`ls` 命令查看备份文件：

```bash
ls -l /data/backup/gitlab

# 显示备份文件信息
-rw------- 1 git git 768000 Aug 30 21:59 1725026349_2024_08_30_17.3.1-jh_gitlab_backup.tar

# 1725026349是一个时间戳,从1970年1月1日0时到当前时间的秒数。这个压缩包包含Gitlab所有数据（例如：管理员、普通账户以及仓库等等）
```

#### 5.6 设置自动备份

使用 `crontab -e` 命令编辑定时任务，设置每天执行备份的时间：

```bash
crontab -e

# 添加定时任务,每天凌晨2点自动创建 Gitlab 备份
0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1
```

> `CRON=1`：设置环境变量 `CRON=1`，这在某些环境下用于指定任务是通过 Cron 触发的，而不是手动执行。

### 6.修改Gitlab数据存储路径

当Gitlab服务器的存储空间不足情况下，希望修改新挂载的目录作为存储目录，操作如下：

#### 6.1 新建数据存储目录

复制原默认目录存储路径 `/var/opt/gitlab/git-data/repositories` 的数据到新目录 `/data/gitlab` 下：

```bash
mkdir -p /data/gitlab
cp -ar /var/opt/gitlab/git-data/repositories /data/gitlab
```

#### 6.2 修改Gitlab配置文件

修改Gitlab配置文件 `/etc/gitlab/gitlab.rb`，将数据存储路径设置为自定义目录：

```bash
vim /etc/gitlab/gitlab.rb

# 找到并修改以下内容
git_data_dirs({
  "default" => {
    "path" => "/data/gitlab"
   }
})
```

修改配置文件后，需重新加载配置并确保所有更改生效：

```bash
gitlab-ctl reconfigure
```

#### 6.3 重启Gitlab服务

修改配置文件后，需重启Gitlab服务方可生效：

```bash
gitlab-ctl stop         # 停止Gitlab服务
gitlab-ctl reconfigure  # 重载配置文件加载
gitlab-ctl start        # 启动Gitlab服务
```

### 7.备份恢复

- **修改存储路径：**创建新的存储路径并将原有的Git仓库数据迁移至新路径。
- **停止Gitlab服务：**运行 `gitlab-ctl stop` 命令停止Gitlab服务。
- **重新配置Gitlab：**运行 `gitlab-ctl reconfigure` 命令重新配置Gitlab。
- **启动Gitlab服务：**运行`gitlab-ctl start`命令启动Gitlab服务。
