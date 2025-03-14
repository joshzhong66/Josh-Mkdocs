# OpenEuler 源码安装Gitlab



> 下载地址：https://gitlab.com/gitlab-org/gitlab-foss/-/tags
>
> 安装文档：https://docs.gitlab.com/install/installation/、https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/install/installation.md
>
> 参考文档：https://blog.51cto.com/blief/4901111

## 一、Gitlab概念

Gitlab是一个基于Web的Git仓库管理工具，它提供了版本控制、代码审查、问题跟踪、持续集成等功能，适用于团队协作和软件开发管理。本文将介绍如何在CentOS 7上部署Gitlab，并提供了安装步骤、配置修改、备份和恢复等操作示例。



## 二、准备工作

- 操作系统：`openEuler 22.03 (LTS-SP4)` （内存最好为 8 G)
- OpenSSL：`>= 1.1.x` 
- Ruby：`3.2.x`（在 GitLab 17.5 及更高版本中，需要 Ruby 3.2）、RubyGems：`3.5.x`
- Go：`>= 1.22.x`（在 GitLab 17.1 及更高版本中，需要 Go 1.22 或更高版本）
- Git：`>= 2.47.x`（在 GitLab 17.7 及更高版本中，需要 Git 2.47.x 及更高版本）
- Node.js：`20.13.x`（在 GitLab 17.0 及更高版本中，需要 Node.js 20.13 或更高版本）、Yarn：`1.22.x`
- PostgreSQL：`>= 14.x`（在 GitLab 17.0 及更高版本中，需要 PostgreSQL 14 或更高版本）
- Redis：`6.x` 或 `7.x` （在 GitLab 16.0 及更高版本中，需要 Redis 6.x 或 7.x）



## 三、查看系统版本

```bash
[root@localhost /root]# uname -a
Linux localhost.localdomain 5.10.0-216.0.0.115.oe2203sp4.x86_64 #1 SMP Thu Jun 27 15:13:44 CST 2024 x86_64 x86_64 x86_64 GNU/Linux
[root@localhost /root]# cat /etc/os-release
NAME="openEuler"
VERSION="22.03 (LTS-SP4)"
ID="openEuler"
VERSION_ID="22.03"
PRETTY_NAME="openEuler 22.03 (LTS-SP4)"
ANSI_COLOR="0;31"
```



## 四、安装依赖

### 1.安装基础依赖包

安装所需的软件包（编译 Ruby 和 Ruby gems 的本机扩展所需）：

```bash
yum install -y gcc gcc-c++ make curl zlib-devel libyaml-devel openssl-devel gdbm-devel re2-devel readline-devel ncurses-devel libffi-devel openssh-server libxml2-devel libxslt-devel libcurl-devel libicu-devel krb5-devel systemd-devel logrotate rsync python3-docutils pkg-config cmake

# 为了使自定义图标正常工作，必须安装 GraphicsMagick
yum install -y GraphicsMagick

# 要接收邮件通知，必须安装邮件服务器
yum install -y postfix
```

### 2.安装ExifTool

> 下载地址：https://exiftool.org
>
> GitLab Workhorse 需要 `exiftool` 从上传的图像中删除 EXIF 数据，这里安装的版本为 `13.24` 。

#### 2.1 ExifTool介绍

ExifTool 是由 Phil Harvey 开发的一款功能强大的 命令行工具，用于读取、写入和编辑 图片、视频、音频、PDF 等文件中的 元数据（Metadata）。它支持多种元数据格式，如 EXIF、IPTC、XMP、GPS 等，广泛用于 摄影、数字取证、自动化处理 等领域。

#### 2.2 下载并解压ExifTool源码包

```bash
cd /usr/local/src
wget https://exiftool.org/Image-ExifTool-13.24.tar.gz
tar -xzf Image-ExifTool-13.24.tar.gz
```

#### 2.3 编译并安装ExifTool

```bash
cd Image-ExifTool-13.24
perl Makefile.PL PREFIX=/usr/local/exiftool
make -j$(nproc)
make install
```

#### 2.4 配置环境变量

配置环境变量文件，添加 ExifTool 工具的环境变量，并设置 `PERL5LIB` 环境变量使 Perl 查找 `Image::ExifTool` 模块：

```bash
cat > /etc/profile.d/exiftool.sh <<'EOF'
# ExifTool
export PATH=/usr/local/exiftool/bin:$PATH
export PERL5LIB=/usr/local/exiftool/share/perl5:$PERL5LIB
EOF
```

加载新的环境变量：

```bash
source /etc/profile
```

#### 2.5 验证ExifTool版本

安装完成后，通过执行 `exiftool` 查看版本：

```bash
[root@localhost /root]# exiftool -ver
13.24
```

### 3.安装OpenSSL

> 使用系统自带的 `OpenSSL 1.1.1wa ` 版本即可。

查看 OpenSSL 版本：

```bash
[root@localhost /root]# openssl version
OpenSSL 1.1.1wa  16 Nov 2023
```

### 4.安装Ruby

> 下载地址：https://www.ruby-lang.org/en/downloads/
>
> 这里安装的版本为 `3.2.7` 。

#### 4.1 Ruby介绍

Ruby 是一种动态、面向对象的编程语言，由 松本行弘（Yukihiro Matsumoto） 在 1995 年开发并发布。它以简洁、优雅和高效的语法而闻名，适用于 Web 开发、自动化、数据处理和 DevOps 等多个领域。

#### 4.2 下载并解压Ruby源码包

```bash
cd /usr/local/src
wget https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.7.tar.gz
tar -xzf ruby-3.2.7.tar.gz
```

#### 4.3 编译并安装Ruby

```bash
cd ruby-3.2.7
./configure --disable-install-rdoc --enable-shared --prefix=/usr/local/ruby
make -j$(nproc)
make install
```

#### 4.4 配置动态链接库路径

配置和更新系统的 Ruby 库路径，以确保系统可以正确找到并使用特定版本的 Ruby 库：

```bash
echo /usr/local/ruby/lib > /etc/ld.so.conf.d/ruby.conf
ldconfig
```

#### 4.5 配置pkg-config路径并添加到环境变量

设置环境变量，以确保系统能够正确找到并使用安装在 `/usr/local/ruby` 路径下的 Ruby 库：

```bash
cat > /etc/profile.d/ruby.sh << 'EOF'
# Ruby
export PATH=/usr/local/ruby/bin:$PATH
export PKG_CONFIG_PATH=/usr/local/ruby/lib/pkgconfig:$PKG_CONFIG_PATH
EOF
```

加载新的环境变量：

```bash
source /etc/profile
```

#### 4.6 验证Ruby版本

安装完成后，通过执行 `ruby` 命令和 `gem` 命令查看版本：

```bash
[root@localhost /usr/local/src/ruby-3.2.7]# ruby --version
ruby 3.2.7 (2025-02-04 revision 02ec315244) [x86_64-linux]
[root@localhost /usr/local/src/ruby-3.2.7]# gem --version
3.4.19
```

使用 `pkg-config` 命令来检查，显示 `3.2.0` 表示安装成功：

```bash
[root@localhost /root]# pkg-config --modversion ruby-3.2
3.2.0
```

#### 4.7 更新RubyGems版本

更新前，先将默认的 RubyGems 源（`https://rubygems.org/`）切换到国内镜像源，以阿里云为例：

```bash
gem sources --add https://mirrors.aliyun.com/rubygems/ --remove https://rubygems.org/
```

更新 RubyGems（Ruby 的包管理工具）版本：

```bash
gem update --system
gem update --system 3.4.12  # 更新指定版本
```

更新完成后，执行 `gem` 命令查看当前版本：

```bash
[root@localhost /root]# gem -v
3.6.5
```

### 5.安装Go

> 下载地址：https://go.dev/dl/
>
> 这里安装的版本为 `1.24.0` 。

#### 5.1 下载并解压go源码包

下载go源码包并解压到指定路径`/usr/local` 下：

```bash
cd /usr/local/src
wget https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz
tar -xzf go1.24.0.linux-amd64.tar.gz -C /usr/local
```

#### 5.2 配置环境变量

配置环境变量文件，添加 Go 语言的环境变量：

```bash
cat > /etc/profile.d/golang.sh <<'EOF'
# Go
export GOROOT=/usr/local/go
export GOPATH=/home/git/gopath
export GO111MODULE="on"
export GOPROXY=https://goproxy.cn,direct
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
EOF
```

> **注：**这里 `GOPATH` 变量设置为 `git` 用户家目录，目的是为git用户有权限创建。

加载新的环境变量：

```bash
source /etc/profile
```

#### 5.3 验证Go版本

安装完成后，通过执行 `go` 命令查看版本：

```bash
[root@localhost /root]# go version
go version go1.24.0 linux/amd64
```

### 6.基于Gitaly安装git

> 下载地址：https://gitlab.com/gitlab-org/gitaly/-/tags
>
> 这里安装的版本为 `17.9` 。

#### 6.1 克隆Gitaly源码包

```bash
cd /usr/local
git clone https://gitlab.com/gitlab-org/gitaly.git -b 17-9-stable gitaly
```

#### 6.2 编译并安装Git

```bash
cd gitaly
make git GIT_PREFIX=/usr/local/git
```

#### 6.3 创建软链接

```bash
ln -s /usr/local/git/bin/git* /usr/bin
```

#### 6.4 验证Git版本

配置完成后，通过执行 `git` 命令查看版本：

```bash
[root@localhost /root]# git --version
git version 2.47.2
```

#### 6.5 验证pcre是否支持

确保 git 版本能够被 pcre 支持，执行以下命令，若能看出输出即为正常：

```bash
[root@localhost /root]# ldd $(which git) | grep pcre2
        libpcre2-8.so.0 => /usr/lib64/libpcre2-8.so.0 (0x00007fc412857000)
```

#### 6.6 卸载系统Git

```bash
yum remove -y git-core
```

### 7.安装Node.js

> 下载地址：https://nodejs.org/dist/
>
> 这里安装的版本为 `20.13.0` 。

#### 7.1 下载并解压Node.js源码包

下载 Node.js 源码包，并指定解压到 `/usr/local` 目录下，并重命名为 `node` ：

```bash
cd /usr/local/src
wget https://nodejs.org/dist/v20.13.0/node-v20.13.0-linux-x64.tar.xz
tar -xJf node-v20.13.0-linux-x64.tar.xz -C /usr/local
mv /usr/local/node-v20.13.0-linux-x64 /usr/local/node
```

#### 7.2 配置环境变量

设置 Node.js 可执行文件所在路径为环境变量：

```bash
cat > /etc/profile.d/node.sh <<'EOF'
# NODEJS
export NODE_HOME=/usr/local/node
export PATH=$NODE_HOME/bin:$PATH
export NODE_PATH=$NODE_HOME/lib/node_modules
EOF
```

加载新的环境变量：

```bash
source /etc/profile
```

#### 7.3 验证Node.js版本

配置完成后，通过执行 `node` 命令和 `npm` 命令查看版本：

```bash
[root@localhost /root]# node -v
v20.13.0
[root@localhost /root]# npm -v
10.5.2
```

#### 7.4 更换npm镜像源

设置 npm 镜像源为国内源加快编译拉包速度，这里设置为阿里云镜像源：

```bash
npm config set registry https://registry.npmmirror.com
```

检查当前的 registry 是否已成功更改为阿里云的镜像地址：

```bash
npm config get registry
```

#### 7.5 安装yarn包

GitLab 需要使用 Node.js 来编译 JavaScript assets，使用 yarn 来管理 javascript 依赖。执行以下命令安装：

```bash
npm install -g yarn
```

安装后可通过执行 `yarn` 命令查看版本：

```bash
[root@localhost /root]# yarn -v
1.22.22
```

同样地，设置 yarn 镜像源为国内源加快编译拉包速度，这里设置为阿里云镜像源：

```bash
yarn config set registry https://registry.npmmirror.com
```

验证当前的 Yarn 镜像源配置：

```bash
yarn config get registry
```

### 8.创建Gitlab服务用户

为 GitLab 服务创建一个名为 `git` 的系统用户，并设置 GECOS 字段为 `GitLab`，通常用来描述用户的角色或身份：

```bash
useradd -c 'Gitlab' git
```

为 `git` 用户设置密码：

```bash
passwd git
```

为 `git` 用户赋予 `sudo` 权限，将其添加到 `sudoers` 文件中：

```bash
visudo

# 添加以下内容
git ALL=(ALL) ALL
```

### 9.安装PostgreSQL

> 在 GitLab 12.1 及更高版本中，仅支持 PostgreSQL。在 GitLab 14.0 及更高版本中，需要 12+ 版本以上。
>
> 下载地址：https://ftp.postgresql.org/pub/source
>
> 这里安装的版本为 `17.4` 。

#### 9.1 下载并解压PostgreSQL源码包

```bash
cd /usr/local/src
wget https://ftp.postgresql.org/pub/source/v17.4/postgresql-17.4.tar.gz
tar -xzf postgresql-17.4.tar.gz
cd postgresql-17.4
```

#### 9.2 编译并安装PostgreSQL

```bash
./configure \
--prefix=/usr/local/psql \
--with-openssl \
--with-libxml \
--with-libxslt \
--with-systemd \
--without-icu
make -j $(nproc)
make install
```

#### 9.3 创建数据目录

在安装完后的 PostgreSQL 安装目录下，创建 PostgreSQL 所需的数据目录：

```bash
mkdir -p /usr/local/psql/{data,log}
```

#### 9.4 创建PostgreSQL用户

```bash
useradd -r -s /sbin/nologin -M postgres
```

#### 9.5 设置目录所有权

设置 PostgreSQL 安装目录所有权为 `postgres` 用户：

```bash
chown -R postgres:postgres /usr/local/psql
```

#### 9.6 配置动态链接库路径

配置和更新系统的 PostgreSQL 库路径，以确保系统可以正确找到并使用特定版本的 PostgreSQL 库：

```bash
echo /usr/local/psql/lib > /etc/ld.so.conf.d/psql.conf
ldconfig
```

#### 9.7 配置环境变量

设置 PostgreSQL 可执行文件所在路径为环境变量，并将 pkg-config 文件路径并添加到环境变量中：

```bash
cat > /etc/profile.d/psql.sh <<'EOF'
# PostgreSQL
export PSQL_HOME=/usr/local/psql
export PATH=$PSQL_HOME/bin:$PSQL_HOME/lib:$PATH
export PKG_CONFIG_PATH=$PSQL_HOME/lib/pkgconfig:$PKG_CONFIG_PATH
EOF
```

加载新的环境变量：

```bash
source /etc/profile
```

#### 9.8 验证PostgreSQL版本

配置完成后，通过执行 `psql` 命令查看版本：

```bash
[root@localhost /root]# psql --version
psql (PostgreSQL) 17.4
```

#### 9.9 初始化数据库

通过 PostgreSQL 安装目录的 `bin` 目录下的 `initdb` 可执行文件命令，并且使用postgres用户来初始化PostgreSQL数据库集群，执行后会生成数据目录和一些必要的配置文件：

```bash
sudo -u postgres /usr/local/psql/bin/initdb -D /usr/local/psql/data
```

#### 9.10 修改PostgreSQL配置文件

在初始化后的 `data` 目录下，编辑主配置文件 `postgresql.conf`，修改以下内容：

```bash
cd /usr/local/psql/data

# 修改监听地址，否则无法远程连接
sed -i "s/#listen_addresses = 'localhost'/listen_addresses ='*'/g" postgresql.conf
sed -i "s/#port = 5432/port = 5432/g" postgresql.conf

# 修改最大连接数
sed -i "s/max_connections = 100/max_connections = 1024/g" postgresql.conf

# 开启日志获取
sed -i "s/#logging_collector = off/logging_collector = on/g" postgresql.conf

# 设置日志目录
sed -i "s@#log_directory = 'log'@log_directory = '/usr/local/psql/log'@g" postgresql.conf

# 设置日志文件名称格式
sed -i "s/#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'/log_filename = 'postgresql-%Y-%m-%d.log'/g" postgresql.conf

# 开启日志轮转
sed -i "s/#log_truncate_on_rotation = off/log_truncate_on_rotation = on/g" postgresql.conf
```

#### 9.11 修改pg_hba配置文件

`pg_hba.conf` 文件用于控制 PostgreSQL 的客户端访问权限，需要修改它，允许从指定的远程 IP 地址连接。

在初始化后的 `data` 目录下，编辑客户端认证配置文件 `pg_hba.conf`，添加以下内容：

```bash
cd /usr/local/psql/data
echo "host all all 0.0.0.0/0 md5" >> pg_hba.conf
```

#### 9.12 配置启动服务

创建一个名为 `psql.service` 的 systemd 服务单元文件，用于管理 PostgreSQL 服务，存放于 `/etc/systemd/system` 目录下，并添加以下内容：

```bash
cat > /etc/systemd/system/psql.service <<'EOF'
[Unit]
Description=PostgreSQL database server
After=network.target

[Service]
Type=forking
User=postgres
ExecStart=/usr/local/psql/bin/pg_ctl start -D /usr/local/psql/data
ExecStop=/usr/local/psql/bin/pg_ctl stop -D /usr/local/psql/data
ExecReload=/usr/local/psql/bin/pg_ctl reload -D /usr/local/psql/data
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF
```

#### 9.13 启动PostgreSQL服务

配置完成后，启动 PostgreSQL 服务，默认端口为 `5432`：

```bash
systemctl daemon-reload   # 加载systemd服务配置
systemctl start psql      # 启动PostgreSQL服务
systemctl enable psql     # 设置开机自启服务
```

#### 9.14 设置PostgreSQL postgres密码

先登录 PostgreSQL 数据库，这里不需要密码：

```bash
psql -Upostgres
```

进入 PostgreSQL 数据库后，设置PostgreSQL postgres密码：

```mysql
alter user postgres password 'Sunline2025';
```

> 如果忘记密码需要重置，也是这样的步骤。退出数据库命令：`\q` 或 `exit` 。

#### 9.15 安装并创建扩展

进入PostgreSQL 的源代码目录，再进入 `contrib` 目录，编译并安装 `pg_trgm` 扩展和  `btree_gist` 扩展：

```bash
# 编译并安装 pg_trgm 扩展
cd /usr/local/src/postgresql-17.4/contrib/pg_trgm
make -j$(nproc)
make install

# 编译并安装 btree_gist 扩展
cd /usr/local/src/postgresql-17.4/contrib/btree_gist
make -j$(nproc)
make install
```

> 在 PostgreSQL 中：
>
> - `pg_trgm` 是一个用于支持 模糊搜索 和 相似性匹配 的扩展模块。它提供了基于三元组（trigram）的算法，常用于实现高效的字符串匹配和搜索功能。
> - `btree_gist` 是一个扩展模块，它允许在 GiST 索引 中使用 B-tree 操作符。通过启用 `btree_gist`，你可以在 GiST 索引中同时支持范围查询和等值查询，从而优化某些复杂的查询场景。

创建完成后，重新设置 PostgreSQL 目录的所有权：

```bash
chown -R postgres:postgres /usr/local/psql
```

登录 PostgreSQL 数据库，创建这两个扩展：

```bash
psql -Upostgres
create extension if not exists pg_trgm;
create extension if not exists btree_gist;
```

#### 9.16 创建GitLab数据库用户

在 PostgreSQL 中创建一个名为 `git` 的新用户，并授予其创建数据库的权限（`CREATEDB`），并设置用户密码为 `Sunline2025` ：

```mysql
create user git CREATEDB password 'your_password';
```

#### 9.17 创建数据库并赋予用户权限

创建一个名为 `gitlabhq_production` 的 GitLab 生产数据库，并授予数据库的所有权限为 `git` 用户：

```mysql
create database gitlabhq_production owner git;
```

#### 9.18 尝试使用git用户连接数据库

创建后，尝试以 `git` 用户身份连接到 `gitlabhq_production` 数据库，如果连接成功，表示 `git` 用户已正确创建，并且拥有访问该数据库的权限：

```mysql
psql -U git -d gitlabhq_production -h localhost -p 5432
```

#### 9.19 检查扩展是否已启用

回到默认管理员的 PostgreSQL 数据库中：

```
psql -Upostgres
```

执行以下命令，检查 `pg_trgm` 扩展是否已经安装并生效：

```bash
SELECT true AS enabled
FROM pg_available_extensions
WHERE name = 'pg_trgm'
AND installed_version IS NOT NULL;
```

如果生效，会返回一行 `t` 表示 true：

```bash
 enabled 
---------
 t
(1 row)
```

同样地，检查 `btree_gist` 扩展是否已经安装并生效：

```bash
SELECT true AS enabled
FROM pg_available_extensions
WHERE name = 'btree_gist'
AND installed_version IS NOT NULL;
```

如果生效，会返回一行 `t` 表示 true：

```bash
 enabled 
---------
 t
(1 row)
```

### 10.安装redis

> 下载地址：https://github.com/redis/redis/releases
>
> 这里安装的版本为 `7.4.2` 。

#### 10.1 下载并解压redis源码包

```bash
cd /usr/local/src
wget -O redis-7.4.2.tar.gz https://github.com/redis/redis/archive/refs/tags/7.4.2.tar.gz
tar -xzf redis-7.4.2.tar.gz
```

#### 10.2 编译并安装redis

```bash
cd redis-7.4.2
make -j$(nproc)
make install PREFIX=/usr/local/redis
```

#### 10.3 配置环境变量

设置 Redis 可执行文件所在路径为环境变量：

```bash
cat > /etc/profile.d/redis.sh <<'EOF'
# Redis
export REDIS_HOME=/usr/local/redis
export PATH=$REDIS_HOME/bin:$PATH
EOF
```

加载新的环境变量：

```bash
source /etc/profile
```

#### 10.4 验证redis版本

配置完成后，通过执行 `redis-server` 命令和 `redis-cli` 命令查看版本：

```bash
[root@localhost /root]# redis-server -v
Redis server v=7.4.2 sha=00000000:1 malloc=jemalloc-5.3.0 bits=64 build=51599edac1ca2182
[root@localhost /root]# redis-cli -v
redis-cli 7.4.2
```

#### 10.5 创建数据目录

在 redis 安装目录下，创建所需的数据目录：

```bash
mkdir -p /usr/local/redis/{logs,data,conf,run}
```

#### 10.6 复制redis配置文件

将 redis 源码包目录下的 `redis.conf` 配置文件复制到 redis 安装目录下的 `conf` 数据目录中：

```bash
cp -f /usr/local/src/redis-7.4.2/redis.conf /usr/local/redis/conf
```

#### 10.7 修改redis配置文件

进入 `/usr/local/redis/conf` 目录，编辑 `redis.conf` 配置文件，修改以下内容：

```bash
cd /usr/local/redis/conf

sed -i "s@bind 127.0.0.1 -::1@bind 0.0.0.0@g" redis.conf
sed -i "s@protected-mode yes@protected-mode no@g" redis.conf
sed -i "s@tcp-backlog 511@tcp-backlog 65535@g" redis.conf
sed -i "s@# unixsocket /run/redis.sock@unixsocket /usr/local/redis/run/redis.sock@g" redis.conf
sed -i "s@# unixsocketperm 700@unixsocketperm 770@g" redis.conf
sed -i "s@daemonize no@daemonize yes@g" redis.conf
sed -i "s@pidfile /var/run/redis_6379.pid@pidfile /usr/local/redis/run/redis.pid@g" redis.conf
sed -i "s@logfile \"\"@logfile \"/usr/local/redis/logs/redis.log\"@g" redis.conf
sed -i "s@dir ./@dir /usr/local/redis/data@g" redis.conf
```

#### 10.8 创建redis用户

```bash
useradd -r -s /sbin/nologin -M redis
```

#### 10.9 修改目录权限及所有权

设置 Redis 安装目录权限为 `755` ，并设置所有权和所属组为 `redis` 用户：

```bash
chmod -R 755 /usr/local/redis
chown -R redis:redis /usr/local/redis
```

#### 10.10 配置启动服务

创建一个名为 `redis.service` 的 systemd 服务单元文件，用于管理 redis 服务，存放于`/etc/systemd/system`目录下，并添加以下内容：

```bash
cat > /etc/systemd/system/redis.service <<'EOF'
[Unit]
Description=redis-7.4.0
After=network.target

[Service]
User=redis
Group=redis
Type=forking
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```

#### 10.11 启动Redis服务

```bash
systemctl daemon-reload     # 加载systemd服务配置
systemctl start redis		# 启动 Redis
systemctl enable redis		# 启用 Redis 开机自启
systemctl status redis		# 检查 Redis 服务状态
systemctl restart redis		# 重启服务
```

#### 10.12 将git用户加入到redis组

将git用户加入到redis组以方便访问 `redis.socket` ：

```bash
usermod -aG redis git
```

### 11.安装Nginx

> 下载地址：http://nginx.org/download
>
> 这里安装的版本为 `1.27.4` 。

#### 11.1 下载并解压Nginx源码包

```bash
cd /usr/local/src
wget http://nginx.org/download/nginx-1.27.4.tar.gz
tar -xzf nginx-1.27.4.tar.gz
cd nginx-1.27.4
```

#### 11.2 编译并安装Nginx

在编译 nginx 时，指定安装路径，这里安装到 `/usr/local/nginx` ：

```bash
./configure \
--prefix=/usr/local/nginx \
--user=git \
--group=git \
--modules-path=/usr/local/nginx/modules \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' \
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'
```

开始编译并安装 `nginx` ：

```bash
make -j$(nproc)
make install
```

#### 11.3 创建Nginx软链接

```bash
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
```

#### 11.4 验证Nginx版本

配置完成后，通过执行 `nginx` 命令查看版本：

```bash
[root@localhost /root]# nginx -v
nginx version: nginx/1.27.4
```

#### 11.5 修改Nginx配置文件

在 Nginx 安装目录的 `conf` 目录中，`nginx.conf` 是 Nginx 的主配置文件，这里以基础的配置文件内容参考为例：

```bash
# 备份原有配置文件
cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak

# 修改nginx配置文件
cat > /usr/local/nginx/conf/nginx.conf <<'EOF'
user git;
worker_processes auto;
error_log logs/error.log;
pid logs/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log          logs/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    server_tokens       off;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             mime.types;
    default_type        application/octet-stream;
    
    gzip                on;
    gzip_types          text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    include conf.d/*.conf;
}
EOF
```

#### 11.6 创建站点配置目录

```bash
mkdir -p /usr/local/nginx/conf/conf.d
```

#### 11.7 设置目录所有权

```bash
chown -R git.git /usr/local/nginx
```

#### 11.8 配置启动服务

创建一个名为 `nginx.service` 的 systemd 服务单元文件，用于管理 Nginx 服务，存放于`/usr/lib/systemd/system`目录下，并添加以下内容：

```bash
cat > /usr/lib/systemd/system/nginx.service <<'EOF'
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```

#### 11.9 启动Nginx服务

```bash
systemctl daemon-reload   # 重载服务配置
systemctl start nginx     # 启动 nginx 服务
systemctl status nginx    # 查看 nginx 服务状态
systemctl enable nginx    # 设置开机自启服务
systemctl restart nginx   # 重启服务
```



## 五、安装Gitlab

> 这里安装的版本为 `17.9` 。

### 1.克隆Gitlab仓库

切换到 `git` 用户，克隆 Gitlab 仓库：

```bash
su - git
# 克隆社区版
git clone https://gitlab.com/gitlab-org/gitlab-foss.git -b 17-9-stable gitlab
# 克隆企业版（暂时没有）
git clone https://gitlab.com/gitlab-org/gitlab-foss.git -b 17-9-stable-ee gitlab
```

### 2.修改Gitlab相关组件配置文件

#### 2.1 复制并修改GitLab配置文件

进入 `gitlab` 目录，复制 `config/gitlab.yml.example` 为 `config/gitlab.yml ` 配置文件，并编辑该文件，修改以下内容（默认情况下无需修改）：

```bash
cd gitlab
cp config/gitlab.yml.example config/gitlab.yml
vim config/gitlab.yml

# 找到 GitLab settings 配置
  gitlab:
    host:localhost    # 默认无需修改，若使用域名可修改
    port: 80          # 如果需要 https 访问，修改为 443

# 找到 Git settings 配置
  git:
    bin_path: /usr/bin/git   # 修改git可执行文件路径

# 修改时区
sed -i "s@# time_zone: 'UTC'@time_zone: 'Asia/Shanghai'@g" config/gitlab.yml
```

#### 2.2 复制secrets配置文件

复制 `config/secrets.yml.example` 为 `config/secrets.yml ` 配置文件：

```bash
cp config/secrets.yml.example config/secrets.yml
```

修改配置文件权限为 `600` ：

```bash
chmod 600 config/secrets.yml
```

#### 2.3 复制并修改puma配置文件

复制 `config/puma.rb.example` 为 `config/puma.rb ` 配置文件，并编辑该文件，修改以下内容：

```bash
cp config/puma.rb.example config/puma.rb

# 修改为服务器的cpu数
sed -i 's@workers 3@workers 4@g' config/puma.rb
```

#### 2.4 复制并修改redis连接配置文件

复制 `config/resque.yml.example` 为 `config/resque.yml ` 配置文件，并编辑该文件，修改以下内容：

```bash
cp config/resque.yml.example config/resque.yml

# 修改redis套接字路径
sed -i 's@url: unix:/var/run/redis/redis.sock@url: unix:/usr/local/redis/run/redis.sock@g' config/resque.yml
```

复制 `config/cable.yml.example` 为 `config/cable.yml ` 配置文件，并编辑该文件，修改以下内容：

```bash
cp config/cable.yml.example config/cable.yml

# 修改redis套接字路径
sed -i 's@url: unix:/var/run/redis/redis.sock@url: unix:/usr/local/redis/run/redis.sock@g' config/cable.yml
```

#### 2.5 复制并修改database配置文件

复制 `config/database.yml.postgresql` 为 `config/database.yml ` 配置文件，并编辑该文件，修改以下内容：

```bash
cp config/database.yml.postgresql config/database.yml
cat > config/database.yml <<'EOF'
production:
  main:
    adapter: postgresql
    encoding: unicode
    database: gitlabhq_production
    username: git
    password: "Sunline2025"
    host: localhost
  ci:
    adapter: postgresql
    encoding: unicode
    database: gitlabhq_production
    database_tasks: false
    username: git
    password: "Sunline2025"
    host: localhost
EOF
```

> 如果是远程 PostgreSQL 服务器，还需更改 `host` 参数。

移除其他用户（Others）对 `config/database.yml` 文件的所有权限：

```bash
chmod o-rwx config/database.yml
```

#### 2.6 创建并授权Gitlab相关目录

```bash
# 确保 git 用户对tmp,log,public,shared等目录有读写权限
chown -R git log/
chown -R git tmp/
chmod -R u+rwX,go-w log/
chmod -R u+rwX tmp/
chmod -R u+rwX tmp/pids/
chmod -R u+rwX tmp/sockets/
mkdir -p public/uploads/
chmod 0700 public/uploads
chmod -R u+rwX builds/
chmod -R u+rwX shared/artifacts/
chmod -R ug+rwX shared/pages/
```

#### 2.7 配置git全局默认参数

1. 设置 Git 如何处理换行符：

   ```bash
   git config --global core.autocrlf input
   ```

   - `core.autocrlf` 控制 Git 在检出和提交文件时如何处理换行符。
   - 设置为 `input` 时，Git 在提交时将换行符统一转换为 `LF`（Unix 风格），但在检出时不转换。这适用于跨平台开发（如在 Linux 或 macOS 上开发，但代码可能在其他平台上运行）。

2. 禁用自动垃圾回收：

   ```bash
   git config --global gc.auto 0
   ```

   - `gc.auto` 控制 Git 何时自动执行垃圾回收（清理不必要的文件并优化仓库）。
   - 设置为 `0` 时，禁用自动垃圾回收。这可以避免在大型仓库中自动执行垃圾回收导致的性能问题，但需要手动运行 `git gc` 来优化仓库。

3. 在重新打包仓库时生成位图索引：

   ```bash
   git config --global repack.writeBitmaps true
   ```

   - `repack.writeBitmaps` 控制 Git 在重新打包仓库时是否生成位图索引。
   - 设置为 `true` 时，生成位图索引可以加速克隆和拉取操作，尤其是在大型仓库中。

4. 启用推送选项支持：

   ```bash
   git config --global receive.advertisePushOptions true
   ```

   - `receive.advertisePushOptions` 控制 Git 服务器是否支持推送选项。
   - 设置为 `true` 时，Git 服务器会告知客户端它支持推送选项。这可以用于实现一些高级功能，如 CI/CD 中的自定义钩子。

5. 确保 Git 对象文件在写入时同步到磁盘：

   ```bash
   git config --global core.fsyncObjectFiles true
   ```

   - `core.fsyncObjectFiles` 控制 Git 是否在写入对象文件时调用 `fsync`，以确保数据写入磁盘。
   - 设置为 `true` 时，可以提高数据一致性，防止在系统崩溃时丢失数据，但可能会降低性能。

6. 查看当前配置后的信息：

   ```bash
   git config --global --list
   ```

### 3.安装Gems组件

从 Bundler 1.5.2 开始，可以调用 `bundle install -jN` （其中N是处理器内核的数量）并享受并行 gems 安装，完成时间有可测量的差异（快约 60%），使用 `$(nproc)` 可查看核心数量。

1. 先查看 bundle 版本，确保版本 `>= 1.5.2` ：

   ```bash
   [git@localhost /home/git/gitlab]# bundle -v
   Bundler version 2.6.5
   ```

2. 由于默认的ruby源地址访问会存在网络访问慢的问题，所以需要将 `Gemfile` 和 `Gemfile.lock` 文件内更换为国内的ruby源：

   ```bash
   sed 's/rubygems.org/gems.ruby-china.com/g' -i Gemfile
   sed 's/rubygems.org/gems.ruby-china.com/g' -i Gemfile.lock
   ```

3. 默认情况下 `bundle` 的镜像源也为国外源，将其更换为国内的镜像源：

   ```bash
   # 更换为 Ruby China 镜像源
   bundle config mirror.https://rubygems.org https://gems.ruby-china.com/
   # 更换为阿里云镜像源
   bundle config mirror.https://rubygems.org https://mirrors.aliyun.com/rubygems/
   ```

4. 更换后可执行 `bundle config` 命令查看是否已更换成功：

   ```bash
   [git@localhost /home/git/gitlab]# bundle config
   Settings are listed in order of priority. The top value will be used.
   mirror.https://rubygems.org/
   Set for your local app (/home/git/gitlab/.bundle/config): "https://gems.ruby-china.com/"
   ```

5. 开始安装 Gems：

   - 将 Bundler 的部署模式设置为 `true` ：

     ```bash
     bundle config set --local deployment 'true'
     ```

     - `bundle config set`：设置 Bundler 的配置。
     - `--local`：将配置保存到当前项目的 `.bundle/config` 文件中，而不是全局配置。
     - `deployment 'true'`：启用部署模式。在部署模式下，Bundler 会确保 `Gemfile.lock` 文件存在，并且依赖项与 `Gemfile.lock` 完全一致。

   - 排除开发、测试和 Kerberos 相关的依赖项（如果使用 Kerberos 进行用户身份验证，在 `--without` 选项中省略掉）：

     ```bash
     bundle config set --local without 'development test kerberos'
     ```

     - `without 'development test kerberos'`：指定不安装 `development`、`test` 和 `kerberos` 组的依赖项。这可以减少安装的依赖项数量，适用于生产环境。

   - 设置 Bundler 安装依赖项的路径：

     ```bash
     bundle config path /home/git/gitlab/vendor/bundle
     ```

     - `path /home/git/gitlab/vendor/bundle`：将依赖项安装到 `/home/git/gitlab/vendor/bundle` 目录中。这是 GitLab 的标准依赖项安装路径。

   - 安装 `Gemfile` 中指定的所有依赖项：

     ```bash
     bundle install
     ```

     - `bundle install`：根据 `Gemfile` 和 `Gemfile.lock` 文件安装依赖项，依赖项会安装到上一步指定的路径。

### 4.安装GitLab Shell组件

GitLab Shell 是专为 GitLab 开发的 SSH 访问和存储库管理软件。执行以下命令安装 GitLab Shell：

```bash
bundle exec rake gitlab:shell:install RAILS_ENV=production	
```

- `bundle exec rake`：使用 `bundle` 执行 `rake` 任务。`bundle` 是 Ruby 的依赖管理工具，`rake` 是 Ruby 的任务执行工具。
- `gitlab:shell:install`：这是 GitLab 的一个 Rake 任务，用于安装和配置 GitLab Shell。GitLab Shell 是 GitLab 与 Git 交互的核心组件。
- `RAILS_ENV=production`：设置环境为 `production`，表示在生产环境中执行任务。

### 5.安装GitLab Workhorse组件

GitLab-Workhorse 使用 GNU Make，执行以下命令安装 GitLab-Workhorse：

```bash
bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

- `bundle exec rake`：使用 Bundler 执行 Rake 任务。
- `gitlab:workhorse:install[/home/git/gitlab-workhorse]`：安装 GitLab Workhorse，并将其安装到 `/home/git/gitlab-workhorse` 目录。
- `RAILS_ENV=production`：指定环境为生产环境。

### 6.安装Gitaly组件

先创建并限制对 Git 存储库数据目录的访问：

```bash
mkdir -p /home/git/repositories
chmod 0700 /home/git/repositories
```

开始安装 Gitaly 组件：

```bash
bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

安装后，限制对 Gitaly socket 目录的访问：

```bash
chmod 0700 /home/git/gitlab/tmp/sockets/private
chown git /home/git/gitlab/tmp/sockets/private
```

### 7.配置GitLab相关服务

创建 `/usr/local/lib/systemd/system` 目录，用于存放 GitLab 相关服务：

```bash
sudo mkdir -p /usr/local/lib/systemd/system
```

复制  GitLab 相关服务到该目录下：

```bash
sudo cp /home/git/gitlab/lib/support/systemd/* /usr/local/lib/systemd/system/
```

如果与 GitLab 相同的机器上运行 Redis 和 PostgreSQL 服务，还需要修改 Puma 服务，添加以下内容并保存文件：

```bash
sudo vim /usr/local/lib/systemd/system/gitlab-puma.service

# 在 [Unit] 中添加以下内容
[Unit]
Wants=redis-server.service postgresql.service
After=redis-server.service postgresql.service
```

同样地，也需要修改 Sidekiq 服务，添加以下内容并保存文件：

```bash
sudo vim /usr/local/lib/systemd/system/gitlab-sidekiq.service

# 在 [Unit] 中添加以下内容
[Unit]
Wants=redis-server.service postgresql.service
After=redis-server.service postgresql.service
```

重载服务以便生效：

```bash
sudo systemctl daemon-reload
```

使 GitLab 在启动时启动：

```bash
sudo systemctl enable gitlab.target
```

### 8.配置GitLab日志轮转

日志轮转是管理日志文件的重要机制，可以防止日志文件过大，占用过多磁盘空间。

将 `lib/support/logrotate/gitlab` 文件复制到 `/etc/logrotate.d/gitlab` ：

```bash
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
```

### 9.启动Gitaly服务

```bash
sudo systemctl start gitlab-gitaly.service    # 启动 gitlab-gitaly 服务
sudo systemctl status gitlab-gitaly.service   # 查看 gitlab-gitaly 服务状态
sudo systemctl restart gitlab-gitaly.service  # 重启 gitlab-gitaly 服务
```

### 10.初始化数据库并激活高级功能

执行以下命令，开始创建数据库表：

```bash
bundle exec rake gitlab:setup RAILS_ENV=production

# 可通过添加 force=yes 参数默认创建
bundle exec rake gitlab:setup RAILS_ENV=production force=yes
```

执行后输入 `yes` 创建数据库表：

```bash
This will create the necessary database tables and seed the database.
You will lose any previous data stored in the database.
Do you want to continue (yes/no)? yes

Dropped database 'gitlabhq_production'
Created database 'gitlabhq_production'
.....
Administrator account created:

login:    root
password: You'll be prompted to create one on your first visit.

== /home/git/gitlab/db/fixtures/production/003_admin.rb took 1.61 seconds
......
== Seeding took 3.64 seconds
```

`GITLAB_ROOT_PASSWORD` 可以通过在环境变量和中提供它们来设置管理员 root 密码和电子邮件`GITLAB_ROOT_EMAIL`，如果不设置密码（并且设置为默认密码），等待 GitLab 暴露给公共互联网，直到安装完成并且首次登录服务器。在第一次登录期间，将被迫更改默认密码。

可以在创建时添加以下参数进行设置：

```bash
bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=Sunline2025 GITLAB_ROOT_EMAIL=yunwei@sunline.cn
```

### 11.检查GitLab环境配置

执行以下命令，检查 GitLab 及其环境是否配置正确：

```bash
bundle exec rake gitlab:env:info RAILS_ENV=production
```

输出信息如下：

```bash
System information
System:
Current User:   git
Using RVM:      no
Ruby Version:   3.2.7
Gem Version:    3.6.5
Bundler Version:2.5.11
Rake Version:   13.0.6
Redis Version:  7.4.2
Sidekiq Version:7.2.4
Go Version:     go1.24.0 linux/amd64

GitLab information
Version:        17.9.1
Revision:       998f540a579
Directory:      /home/git/gitlab
DB Adapter:     PostgreSQL
DB Version:     17.4
URL:            http://localhost
HTTP Clone URL: http://localhost/some-group/some-project.git
SSH Clone URL:  git@localhost:some-group/some-project.git
Using LDAP:     no
Using Omniauth: yes
Omniauth Providers: 

GitLab Shell
Version:        14.40.0
Repository storages:
- default:      unix:/home/git/gitlab/tmp/sockets/private/gitaly.socket
GitLab Shell path:              /home/git/gitlab-shell

Gitaly
- default Address:      unix:/home/git/gitlab/tmp/sockets/private/gitaly.socket
- default Version:      17.9.1
- default Git Version:  2.47.2
```

### 12.编译GitLab资产

开始安装依赖和编译 GitLab 的前端资源：

1. 使用 `yarn` 安装 GitLab 的前端依赖项：

   ```bash
   yarn install --production --pure-lockfile
   ```

   - `--production`：仅安装生产环境所需的依赖项（不包括开发依赖）。
   - `--pure-lockfile`：使用 `yarn.lock` 文件中的精确版本，不更新锁文件。
   - 执行后会安装所有前端依赖项到 `node_modules` 目录。

2. 编译 GitLab 的前端资源（如 JavaScript、CSS、图片等）：

   ```bash
   bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production
   ```

   - `RAILS_ENV=production`：指定 Rails 环境为生产环境。
   - `NODE_ENV=production`：指定 Node.js 环境为生产环境。

   如果 `rake` 出现错误，尝试使用如下设置 `JavaScript heap out of memory` 来运行：

   ```bash
   bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"
   ```

   - `NODE_OPTIONS="--max_old_space_size=4096"`：设置 Node.js 的最大内存限制为 4GB（4096 MB）。

### 13.启动GitLab服务

完成所有配置后，可以开启 GitLab 服务了：

```bash
sudo systemctl start gitlab.target
```

### 14.复制并修改站点配置文件

将 `lib/support/nginx/gitlab` 配置文件复制到 Nginx 站点目录下，并重命名为 `gitlab.conf` ：

```bash
sudo -u git cp lib/support/nginx/gitlab /usr/local/nginx/conf/conf.d/gitlab.conf
```

修改站点配置文件中的日志路径：

```bash
sed -i 's@/var/log/nginx@/usr/local/nginx/logs@g' /usr/local/nginx/conf/conf.d/gitlab.conf
```

### 15.重载Nginx

```bash
sudo nginx -t
sudo nginx -s reload
```



