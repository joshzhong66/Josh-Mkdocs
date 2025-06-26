# RH294 ansible自动化教案 

```
version: Du Tong
date: latest 
```

人工运维时代：

  所有的操作都是人来操作的，一个一个命令的去敲，一个一个去登录服务器敲打命令。大部分的运维人员几乎都是在做一个重复性的工作，比如说：安装软件包、修改配置文件、管理服务、收集主机日志信息、调整内核参数等等之类。 你管理了100台机器，都需要去安装软件包、管理服务..

自动化运维时代：

  现在的机器数量对比之前很多；机器多了， 你的重复性工作可能也会更多。这个时候，运维人员编写shell脚本，下发到所有机器上运行。但是如果要实现更加复杂的操作和判断呢？比如说管理Linux系统、window系统、网络设备、公私有云。所以出现了更好的一些解决方案，也就是现在的自动化运维工具；ansible、或者是saltstack、puppet工具，这些工具都可以帮助实现自动化。

    自动化工具的出现，解决了什么样 的问题？
    
      人工偷懒的问题，减少人工劳动，解放双手，无需去重复性的操作。通过自动化工具实现


​      

  # ansible的历史

  2012年被开发的，德哈恩开发，同年，创建了一个ansible works

  经历过3年的开发和发展，2015年红帽直接收购了，红帽对于ansible进行开发和改进，2017年直接开源

    红帽非常重视ansible，因为在红帽的培训课程中，有多门都是关于ansible的课程
    
    RHCE 专门ansible的内容
    
    RHCA 358 ansible的自动化服务管理   447（374） ansible高级课程自动化平台


​    

  # ansible是一个自动化运维工具？？到底能够帮助我们干什么？？

  ansible最强大的地方就在于可以对所有的资源进行自动化管理，比如Linux系统、windows系统、交换机路由器、云平台..

比如说，现在你搭建部署和上线一个官网门户网站：
  1. 装修机房，购买服务器，上架服务器，拉网线，装空调..（基础设施硬件）
  2. 服务器安装操作系统（光盘、U盘、IPMI接口、网络PXE）
  3. 配置网络
  4. 部署软件（httpd/nginx  mysql/mariadb  php）
  5. 修改服务的配置文件
  6. 管理服务、防火墙管理，SELinux

上面这些步骤中，你认为ansible能够管理哪些？？ 

  ansible是一个软件工具；基于网络管理

如果同时上线10台机器，利用ansible工具实现自动化





# ansible和其他的自动化运维工具对比

ansible、或者是saltstack、puppet工具

语言：ansible和saltstack都是基于python编写的，puppet ruby语言

支持的系统：ansible和puppet支持所有的系统，saltstack只能够管理Linux系统

客户端：ansible是不需要在被控节点上安装代理软件或者客户端软件包，puppet saltstack都需要安装





# ansible的一些特性

无代理架构：ansible管控被控节点是不需要在被控节点上安装代理，通过系统原生的方式管理

模块化管理：通过ansible来在不同的机器上实现操作。可以使用各类的语言来开发模块

自动化工具：无需配置服务和启动服务，本身只是一个工具

多级控制：也就是ansible可以有多个主控节点，来减轻主控的压力

配置文件简单：通过yaml文件编写（类似于shell脚本），专门的一个写配置文件的格式

幂等性：执行一次和重复执行多次，结果都是一样的





# ansible架构和工作原理

![](https://secure2.wostatic.cn/static/b4C6SFNeWkdFmJsmyFzvkS/image.png?auth_key=1720575454-2H43S9ACFMtUDUWwwU3eTX-0-f609a36d172900e6c66431e565c7a04d)

![](https://secure2.wostatic.cn/static/d7bTpZaLkYQvnvEwNQCqbL/image.png?auth_key=1720575455-bLSbxkeat3bZFxFZyVGK4S-0-94ab89f10873f131dadbec00b0ec1ad1)

# ansible的安装

- 源码包安装：
    - ansible有两个版本的源码包：官网版本，官方的稳定版本
    - 官方社区开源版（最新版）：[https://github.com/ansible/ansible](https://github.com/ansible/ansible)
    - 官方的稳定版本（更新到ansible 2.9版本）：[https://releases.ansible.com/](https://releases.ansible.com/)

    如果通过github下载比较慢，可以通过kk代理进行下载

```Bash
wget https://kkgithub.com/ansible/ansible/archive/refs/tags/v2.9.0.zip

# 解压源码包
unzip v2.9.0.zip

# 构建和安装
python setup.py build
python setup.py install

```


- 发行版安装（rpm）
    - 官方的稳定版本（更新到ansible 2.9版本）：[https://releases.ansible.com/](https://releases.ansible.com/)
    - 通过本地的ISO镜像文件安装
        - 从RHEL9开始，安装是ansible-core 
        - RHEL8安装的是ansible

        ansible-core是一个不完整的ansible，从RHEL9开始，已经分为了两部分

          ansible-core 核心软件，提供了少量的模块

          扩展软件，通过安装集合的方式来得到模块

          [https://galaxy.ansible.com](https://galaxy.ansible.com) 

          ![](https://secure2.wostatic.cn/static/dTPVkdf1B9sjQB49qYVkRT/image.png?auth_key=1720575454-ujjrgY4dg9EFCb7ZegMXz2-0-aa9e2339fda5bfb010de47bf5a051d7c)

          本地ISO安装

![](https://secure2.wostatic.cn/static/bGwCTeFFsXeGBb8U9SGPeK/image.png?auth_key=1720575455-kX2XWCQYNKDFej7BbYMKtQ-0-7a906bbd7abafc96bbee419d9dc2b7ba)

源码包安装

![](https://secure2.wostatic.cn/static/sX5QLx21GETvV6kBBouPug/image.png?auth_key=1720575454-q1WjAwxixGD2vC3BmngoLR-0-16096da9bae8cdb493a8ff701f0870e9)

- 通过pip包管理器安装ansible

```Bash
pip install ansible==2.9.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
  -i https://pypi.tuna.tsinghua.edu.cn/simple 加速器

```

pip install ansible==2.9.0 -i [https://pypi.tuna.tsinghua.edu.cn/simple](https://pypi.tuna.tsinghua.edu.cn/simple)





- 通过容器安装—ansible的导航器

必须要有容器镜像，拉取镜像需要订阅（开发者订阅也可以拉取）

安装ansible的导航器

拉取容器镜像

启动容器管理ansible

每次启动容器默认都是会从网上拉取镜像，我们需要配置一个本地自动化执行环境，如果本地有镜像，就使用本地的镜像

```Bash
[root@node1 ~]# cat .ansible-navigator.yml
ansible-navigator:
 execution-environment:
  image: registry.redhat.io/ansible-automation-platform-22/ee-supported-rhel8
  pull:
   policy: missing

```





源码包和pip安装都没有配置文件，可以去github拉取一个配置文件

源码包的配置文件，在解压后的目录中有。

pip没有



# 定义ansible的主机清单



```Bash
# 通过IP地址定义
192.168.68.133 
192.168.68.134
192.168.68.135

# 通过主机名定义
node1
node2
node3
test01

# 通过范围定义
devops[1:10].example.com
192.168.1.[1:254]

# 通过主机组定义
[webserver]
web01
web02


[mysql]
mariadb01
mariadb02

# 通过主机组嵌套定义
[webserver:children]
mysql

```

P：如果一个主机清单中，有主机也有主机组，确保主机的位置位于主机组的上面。



# 查看主机清单主机

```Bash
# 直接通过主机名/主机组 查询
ansible node1 --list-hosts     匹配单个主机
ansible webserver--list-hosts  匹配主机组
ansible node1,node2 --list-hosts  匹配多个主机
ansible webserver,mysql --list-hosts 匹配多个主机组

# 通过通配符匹配查询
 ansible 'web01,!mysql,&webserver' --list-hosts
 ！取反
 & 表示取交集
  组合使用
 
# 通过正则表达式查询
ansible '~(n|t).*' --list-hosts

```





# ansible配置文件优先级

从高到低：

  ANSIBLE_CONFIG

  当前的工作目录

  用户家目录下的.ansible.cfg配置文件

  /etc/ansible/ansible.cfg配置文件





# ansible配置文件

ansible.cfg的配置默认分为十段：[defaults]：通用配置项[inventory]：与主机清单相关的配置项[privilege_escalation]：特权升级相关的配置项[paramiko_connection]：使用paramiko连接的相关配置项，Paramiko在RHEL6之后的版本中默认使用的ssh连接方式[ssh_connection]：使用OpenSSH连接的相关配置项，OpenSSH是Ansible在RHEL6之后默认使用的ssh连接方式[persistent_connection]：持久连接的配置项[accelerate]：加速模式配置项[selinux]：selinux相关的配置项[colors]：ansible命令输出的颜色相关的配置项[diff]：定义是否在运行时打印diff（变更前与变更后的差异）



# 执行ansible来运行任务

- ad-hoc：类似于直接在shell终端敲打命令，执行简单的任务
- playbook：剧本，类似于你的shell脚本，执行复杂的任务
- 导航器也能够执行任务，但是只能够执行playbook无法执行ad-hoc



ad-hoc执行任务

```Bash
格式：ansible  主机/主机组  -m  模块   -a ‘模块的参数’  ansible的参数
  eg： ansible all -m shell -a 'useradd devops' -u root -k
    -u 指定用户
    -k 使用密码认证

```

![](https://secure2.wostatic.cn/static/4qQoya281yheoRTeStedJp/image.png?auth_key=1720575457-tgvGeZtGo12JjXSZpFqEb4-0-a75edb3ea207b2fb4626f0d234368fb4)

如果出现这样的问题，是因为ansible 2.9.0的版本和系统的python版本（python版本太高了）不匹配，不是推荐的一个版本。人家建议你升级ansible的版本。

可以通过在ansible.cfg配置文件中的[defaults]添加内容

![](https://secure2.wostatic.cn/static/wZwdhGbKepiRsML5bfUAcJ/image.png?auth_key=1720575457-agfoXiXFNh3AdPspLmKZ7y-0-a29809bc8fafda1ac64531e3e357656b)



```Bash
配置ansible：
 [root@0420 ansible]# pwd
/etc/ansible
[root@0420 ansible]# cat ansible.cfg
[defaults]
inventory      = /etc/ansible/hosts
ask_pass      = False
remote_user = devops
deprecation_warnings=False

[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False

[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s

# 配置被控提权
ansible all -m shell -a 'echo "devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers' -u root -k
# 创建被控的管理用户
ansible all -m shell -a 'echo "useradd devops && echo redhat|passwd --stdin devops" >> /etc/sudoers' -u root -k

# 做主机名和IP映射
[root@0420 ansible]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.68.133 node1
192.168.68.134 node2
192.168.68.135 node3

# 做免密登录
ssh-keygen 生成公私钥
ssh-copy-id devops@node1
ssh-copy-id devops@node2
ssh-copy-id devops@node3

# 主机清单配置
[root@0420 ansible]# cat hosts
node1
node2
node3


测试是否能够管控：
  ansible all -m ping

```





# ansible的模块的使用

```Bash
ansible-doc -l 列出所有的模块
ansible-doc -s yum 查看指定模块的参数
ansible-doc yum 查看指定模块的详细信息，包括用法和案例
```



# ansible常用模块

## 命令执行模块

```Bash
command模块： 在执行的时候如果命令中带有‘< > | &’ 是不执行的

shell模块：就跟你在终端上敲打shell命令一模一样，没有任何的区别。同时还支持一些高阶特性，比如 chdir、creates、removes等参数
  chdir，在执行命令之前修改当前的默认工作目录
  creates，当文件存在，则命令不执行
  removes，当文件不存在，则命令不执行（当文件存在，则命令执行）

raw模块：用法和shell模块一模一样，只是不支持 chdir creates removes 高级参数

script模块：将管理端的shell脚本中的指令放到被控节点运行；原理就是读取脚本中的命令，然后放到被控执行；脚本文件不需要任何的可执行权限；也不会将脚本文件拷贝到被控
```

## 文件相关模块

```Bash
file模块：创建、删除文件/目录；是在被控节点去创建文件/目录
  path：指定文件/目录路径
  state：
    file【默认动作】 查看文件目录的属性信息
    touch 创建文件和更新时间戳
    directory 创建目录
    mode 指定权限
    owner 指定拥有人
    grup 指定拥有组
    link 创建软链接
    hard 创建硬链接
    force 强制创建，只针对软连接生效
    src 指定源路径
    dest 指定目标路径
      src和dest在创建链接文件的时候需要使用上
      
copy模块：将主控节点的文件传到被控节点上
  src：源路径  
    如果src后面带有/ ，表示拷贝这个目录下的所有内容
    如果src后面没有/ ，表示拷贝的是这个目录
  dest：目标路径
  backup: 如果发现文件覆盖，在覆盖之前会备份源文件（默认是false，需要改为yes生效）
  remote_src：表示在被控节点拷贝被控节点的文件（cp）
  force：默认是yes，表示会覆盖文件内容；如果是no，这个文件不存在则创建，文件存在则不会进行覆盖
  

fetch模块：将被控节点的文件传到主控节点（和copy模块正好相反） 不可以拷贝目录，只能拷贝文件
  flat： 默认是no，默认的情况下，拉取的文件到主控节点。会以被控节点主机名的方式来生成一个目录
    如果修改为yes，则不会以为被控节点的主机名来命名。而是直接拷贝文件。注意dest后面要加 /
  src： 被控的路径
  dest： 主控的路径
 
 案例：ansible node3 -m fetch -a 'src=/etc/hosts dest=/opt/ flat=yes'
 案例：ansible node3 -m fetch -a 'src=/etc/hosts dest=/opt'
  
      
```



## 软件相关模块

yum和yum_repository

```Bash
yum_repository模块：用来配置yum仓库的，创建的是yum 的配置文件
  案例：在所有的主机上，创建一个文件/etc/yum.repos.d/dvd.repo ；
      第一个仓库名 BaseOS  描述信息是BaseOS 仓库地址 /media/BaseOS 不校验包
      第一个仓库名 AppStream 描述信息是AppStream 仓库地址 /media/AppStream 不校验包
  file：指定配置文件名（不需要加上.repo 因为模块会自动添加）
  name：仓库的名字
  description：仓库的描述信息
  baseurl：仓库的地址
  gpgcheck： 是否校验软件包
  gpgkey：指定密钥的路径
  enabled：是否开启仓库
  state： present / absent  添加/删除
 如果要删除某个配置文件中的仓库，必须指定file和name
 如果使用ad-hoc去编写仓库的话，多个仓库需要多次ad-hoc调用，不要将 所有的仓库写到一个ad-hoc
 
 
 yum模块：安装、删除、卸载软件包/软件包组
   name： 软件包/软件包组名字
   state：present/absent/latest 安装/删除/更新
   
        
   安装包组（使用@）：ansible node3 -m yum -a 'name="@Development tools" state=present'
   安装包：ansible node3 -m yum -a 'name=httpd state=present'
```



## 服务管理模块

systemd和service

```Bash
service模块：管理服务、启动、停止、重启、开机自启动
  name: 服务的名字
  state：
    started 开启
    stopped 停止
    restarted 重启
    reloaded 重新加载配置
  eneabled： 开机自启
 
systemd模块：管理服务、启动、停止、重启、开机自启动
  name: 服务的名字
  state：
    started 开启
    stopped 停止
    restarted 重启
  
  eneabled： 开机自启
  daemon_reload：是否加载配置

```



## 周期性任务模块

cron

```Bash
cron模块：专门编写周期性计划任务
  name：这个任务的名字（很重要，如果通过ansible删除任务需要这个name）
  minute:分钟
  hour：小时
  day：日
  month：月
  weekday：周
  job：就是任务要执行的内容
  cron_file：指定任务保存的文件（默认是保存到/var/spoo/cron）
  state： present/absent 默认就是present创建，删除使用absent

```



## 用户管理模块

user、group

```Bash
user模块：创建、修改、删除用户
  name：用户名
  state：present/absent 创建、删除
  home：家目录
  shell：登录shell
  comment：描述信息
  remove：只有state=absent有效，等价于userdel -r
  password：设置密码（只不过是明文的）
 
案例：创建用户abc，uid是2022，描述信息：mysql user，登录shell是/bin/bash，家目录是/tmp/abc
ansible node3 -m user -a 'name=abc uid=2022 comment="mysql user" shell=/bin/bash home=/tmp/abc state=present password="$6$aMfu1fr8AG.Otwyq$ow5IIy4AHaqlWpbwhgEGrByfCZgSaHF8tfRHW8izqI7bmSi3184ozaz7NUpc4M6r7eYBmyQGx7gx8CW6Bm5p0."'
注意：password参数是明文的，所以这个地方需要借助openssl passwd 生成一个加密的密码 

group模块：创建、修改、删除用户组
  name： 组的名字
  gid：  组的id
  state： present/absent

```



## 文件下载模块

get_url

```Bash
get_url模块：下载文件 等价于wget
  url：下载的文件地址
  dest：下载到哪个目录
  url_username：如果需要验证账户密码，这里写账号
  url_password：如果需要验证账户密码，这里写密码
  mode：权限
  owner：拥有人
  group：拥有组

```



## 解压缩模块

unarchive

```Bash
用于解压文件，模块包含如下选项：
  src：则需要指定压缩文件的源路径
  dest：远程主机上的一个路径，即文件解压的路径
  remote_src：如果为yes，则文件会从主控端端复制到被控端。否则会直接尝试从被控端查找文件。默认为yes。
  owner：解压后文件或目录的属主
  group：解压后的目录或文件的属组
  mode：解决后文件的权限
  creates：指定一个文件名，当该文件存在时，则解压指令不执行
  list_files：如果为yes，则会列出压缩包里的文件，默认为no

```



## 同步模块

```Bash
synchronize模块：
  src：要复制的文件，目录以/结尾表示包含目录本身，目录不以/结尾表示不包含目录本身
  dest：目录路径
  archive: 归档，相当于同时开启recursive(递归)、links、perms、times、owner、group、-D选项都为yes ，默认该项为开启
  compress：是否开启压缩
  rsync_opts：rsync的选项，选项之间用逗号隔开，例如-a,-v,-z等等
  delete: 删除不存在的文件，默认no
  dest_port：默认目录主机上的端口 ，默认是22，走的ssh协议
  mode: push或pull 模块，push模式的话，一般用于从本机向远程主机上传文件，pull 模式用于从远程主机上取文件，默认是push。

```



## firewalld模块

```Bash
firewalld模块：管理防火墙
  service：服务名
  port：端口
  state： enabled（accept接受） disabled（reject 拒绝）
  permanent：是否永久生效
  immediate：是否立即生效


案例：放行http服务
ansible all -m firewalld -a 'service=http state=enabled permanent=yes immediate=yes'
```









# ansible的playbook



playbook又叫做剧本，一系列ansible模块的集合，利用yaml文件进行编写；

playbook里面是通过任务来实现了，每一个任务其实就是调用了一个模块。执行的顺序是从上而下一次执行。

同时playbook当中，支持更多的特性。变量、jinja2模板、循环、判断。允许你抓取一个任务的返回状态作为变量给另外一个任务来调用。



你要去配置软件仓库，安装软件包，生成网页文件，防火墙放行，服务启动

用ad-hoc去写，至少需要执行5次ad-hoc

playbook去写，直接将任务写到这个剧本中，然后执行剧本



playbook的调用使用命令ansible-playbook去调用，同样的，也支持参数。

 -k -K -u，这些指令也可以写到playbook中



## yaml语言编写

yaml语言：非标记行语言 

  标记型语言：有头有尾有标签；最典型的一个例子就是html

yaml语言有一些明显的约束：
  1. 大小写是严格区分的—大写变量和小写变量
  2. 使用缩进来表示一个层级关系
  3. 使用空格来进行缩进（tab不允许）
  4. 支持注释，使用#注释





编写一个playbook，来完成配置仓库、安装软件包、放行防火墙、启动服务、编写网页文件，。，从而实现访问这个网站

```Bash
[root@0420 opt]# vim web.yml
- name: webserver
  hosts: node1,node2,node3
  tasks:
    #- name: mount /dev/cdrom
    #shell: mount /dev/cdrom /media
  - name: config yum repository baseos
    yum_repository:
     file: dvd
     name: BaseOS
     description: BaseOS
     baseurl: file:///media/BaseOS
     gpgcheck: no
     enabled: yes
  - name: config yum repository appstream
    yum_repository:
     file: dvd
     name: AppStream
     description: AppStream
     baseurl: file:///media/AppStream
     gpgcheck: no
     enabled: yes

  - name: dnf makecache
    shell: dnf clean all && dnf makecache

  - name: install http packge
    yum:
     name: httpd
     state: present

  - name: allow  firewalld
    firewalld:
     service: http
     state: enabled
     permanent: yes
     immediate: yes

  - name: start httpd service
    systemd:
     name: httpd
     state: started
     enabled: yes

  - name: touch /var/www/html/index.html
    copy:
     content: "This is a rhce\n"
     dest: /var/www/html/index.html
     

[root@0420 opt]# ansible-playbook web.yml

```



## ansible-playbook选项

```Bash
执行的时候检查语法格式
  ansible-playbook abc.yml --syntax-check
 
模拟执行剧本，但不会真的在被控节点执行
  ansible-playbook abc.yml -C
  

打印详细信息：
  -v 查看调用的是哪个配置文件
  -vv  查看到ansible和python的版本
  -vvv  查看到更多的信息，包括ssh的连接信息
  如果有更多的v，那么和-vvv是一样的效果

```





## multiple plays

在一个剧本中，可以写多个play，每一个play可以应用到不同的主机上面

```Bash
## 第一个play
- name: create user
  hosts: all
  gather_facts: false
  tasks:
  - name: create zhangsan
    user:
     name: zhangsan
     state: present
  

## 第二个play
- name: install nfs-utils
  hosts: node3
  tasks:
  - name: dnf install
    yum:
      name: nfs-utils
      state: present

```



playbook是由一个play或者多个play进行组成，每一个play的下面有一个tasks任务列表，任务列表下面定义的task任务就是我们需要执行的需求，每一个task任务都是对一个模块的调用,因为playbook就是根据一定的逻辑顺序来编写一个完整的复杂的任务，这种方式称之为playbook的编排





## playbook的组成结构

Target section： 用于定义将要执行playbook的远程主机组及远程主机组上的用户，还包括定义通过什么样的方式连接远程主机（默认ssh，定义远程操作的用户，是否提权 提权的方式等等）
Variable section： 定义playbook运行时需要使用的变量（剧本中定义的变量优先级更高）
Task section： 定义将要在远程主机上执行的任务列表（每一个taks任务都是对一个模块的调用）
Handler section： 定义task执行完成以后需要调用的任务（只有触发了，才会执行这个特殊的任务，在所有的taks任务执行完成之后才会执行handler的任务）



## tasks任务列表

所有的task任务都是定义在tasks任务列表下
  1. 任务列表在执行的时候是安装顺序从上往下依次执行
  2. 如果有一个task任务执行失败，playbook停止执行

如果任务执行失败，只有失败的主机才会停止执行任务

ansible具有幂等性，如果任务列表中的task任务反复执行，一次执行和多次执行，结果都是一样。

  也就是ansible具有期望值，任务执行的结果和期望值保持一致，则任务就是成功的

  

我们在执行tasks任务列表的时候，如果出现的任务失败的情况，task任务会停止执行，那么该怎么解决？？
  1. 如果调用的是命令执行模块，可以直接在后面加上 true 命令或者一个可以执行的命令

      因为是执行的shell命令，也会有命令的返回值，叫做rc，如果是0则执行成功，非0执行失败

      可以通过 || 来让返回值变成0
  2. 如果调用的是其他的命令，我们可以通过关键字 ignore_errors: yes 来忽略这个错误



## handlers触发器

handlers是一个特殊tasks任务列表，需要借用notify关键字来监听某个task任务的执行状态， 只有状态为 changed 的时候才会触发handlers任务，并且handlers任务是在所有的task任务执行完成后，才会执行，也就是最后执行handlers任务

如果在执行handlers任务之前，有task任务执行失败了，handlers任务也不会去执行

通过关键字 force_handlers: yes 来强制让handlers任务执行，前提条件是handlers会触发

![](https://secure2.wostatic.cn/static/gvYqjBKVzdJwjpDCLzTfZP/image.png?auth_key=1720575459-h5tCR5ShU1BchVZq2NdUtA-0-c88c47a39d54a15d58967d009be86c3f)



# ansible变量

![](https://secure2.wostatic.cn/static/k8sArahUaEgR8v16KYPaJ6/image.png?auth_key=1720575459-nA4wrcXgmsDMzPisP5sWnS-0-3abf0be2866f11eae2ebdaf8086de713)

定义变量：
  1. 数字、字母、下划线组成
  2. 不能以数字开头
  3. 不能使用本地自带的变量，最好不要定义以ansible开头的变量，因为会和ansible的内置冲突





## debug模块调试变量

可以通过debug模块直接输出内容或者引用变量

```Bash
debug有两个参数：msg、var
  msg 后面会直接输出内容
  var 后面接的是变量名，会输出变量值
  
  并且msg和var两个不能联合使用

```

## 通过vars关键字定义变量

```Bash
- name: use module
  hosts: all
  gather_facts: false
  vars:
    host_name: rhel9.example.com
    os: rhe9
  tasks:
  - name: use shell
    shell: touch "{{ host_name }}"
```

引导变量的时候使用： "{{  变量名 }}"

vars关键字是在playbook中定义的！！！！！



## 通过vars_files定义变量文件

vars_files应用于playbook当中，可以引用外部的变量文件

```Bash
- name: use module
  hosts: all
  gather_facts: false
  vars:
    host_name: rhel9.example.com
    os: rhe9
  vars_files:
    - os.file
  tasks:
  - debug:
     msg: "{{ abc }}"
```



## 通过主机清单来定义变量

```Bash
node1 ansible_host=192.168.68.133  os=rhel9   # 给主机定义变量
node2
node3
controller ansible_hosts=192.168.68.130 ansible_connection=local

[webserver]
node1
node2
node3

[webserver:vars]   # 给主机组定义变量
web=nginx
os=centos

 P：如果主机变量和主机组变量冲突，主机变量优先级更高
 ansible的内置变量，调用的其实就是ansible.cfg配置文件中的参数，只不过是以ansible_ 开头
```



## 通过host_vars和group_vars定义变量

host_vars和group_vars必须和主机清单处于一个目录下，host_vats目录下文件的名字就是主机，group_vars目录下面的文件名就是主机组

```Bash
[root@0420 ansible]# ls -R
.:
ansible.cfg  ansible.cfg.bak  group_vars  hosts  host_vars  shell.sh

./group_vars:
webserver

./host_vars:
node1  node2


文件名是哪个主机，那么这个文件中定义的变量只能给哪个主机使用
```





## facts变量

facts变量会收集被控节点的所有主机信息，包括不限于 主机名、网卡设备名、IP地址、cpu、内存、操作系统版本、bios版本等等。facts变量专门来收集主机的主机信息，可以通过模块setup来开启，默认在执行playbook的时候就是收集facts变量。所有的变量的值都会保存到ansible_facts变量中

```Bash
通过setup收集主机信息
  ansible node1 -m setup 

使用filter来过滤内容
  ansible node1 -m setup  -a 'filter=ansible_hostname'
  P：注意！一定不要写上ansible_facts，只能过滤到ansible_facts的下一个层级
  
通过通配符来收集变量
  ansible node1 -m setup  -a 'filter=ansible*'
  
导出facts变量
  ansible node1 -m setup > 文件名
  ansible node1 -m setup --tree 文件名 （只不过显示的都是一样内容，不太好看）

```



```Bash
# 引用facts变量 （默认会收集facts变量）
- name: use module 
  hosts: node3
  tasks:
  - debug:
     msg: "{{ ansible_ens160.ipv4.address }}"
     通过 . 来便是下一个层级
     
# 关闭facts变量
gather_facts: false

# 通过setup模块手动获取facts变量
[root@0420 opt]# cat test.yml
- name: use module 
  hosts: node3
  gather_facts: false
  tasks:
  - setup:
  - debug:
     msg: "{{ ansible_ens160.ipv4.address }}"


```



自定义facts变量，让每一个主机都有自己的facts变量，在（是被控节点的主机）主机的/etc/ansible/facts.d目录下创建变量文件，这个变量文件后缀必须是 .fact结尾

  配置文件格式一般为ini或者yaml格式。ini就是RHEL9配置网卡的格式

  自定义的facts变量保存到ansible_local 变量下

```Bash
在被控节点创建 /etc/ansible/facts.d/user.fact 文件
[user]
name=zhangsan
age=28

调用的话  {{ ansible_local.user.user.anme }}


```



## set_fact 整合多个变量为一个变量

```Bash
[root@0420 opt]# cat /opt/test.yml
- name: use module 
  hosts: node1,node2,node3
  tasks:
  - set_fact:
     get_status: "{{ ansible_ens160.ipv4.address }} - {{ ansible_hostname }}"
  - debug:
     msg: "{{ get_status }}"
```



## loopup生成变量

在一些特殊情况下，需要从外部引用变量；比如读取本地主机公钥作为变量，然后放到被控节点下；比如创建用户的时候指定密码，可以利用命令的执行结果作为密码的值...

```Bash
通过ansible-doc -t lookup -l 查看支持的数据源

# 使用文件的内容作为变量的值 "{{ lookup('file','/etc/passwd') }}"
# 使用环境变量作为变量的值 "{{ lookup('env','HOME') }}"
# 使用命令的执行结果作为变量的值："{{ lookup('pipe','openssl passwd -6 redhat') }}"
[root@0420 opt]# cat test.yml 
- name: use module 
  hosts: node1,node2,node3
  gather_facts: false
  tasks:
  - set_fact:
     content: "{{ lookup('file','/etc/passwd') }}"
  - set_fact:
     content_env: "{{ lookup('env','HOME') }}"
  - set_fact:
     content_command: "{{ lookup('pipe','openssl passwd -6 redhat') }}"

  - user:
     name: abc
     password: "{{ lookup('pipe','openssl passwd -6 redhat') }}"


```





## ansible魔法变量

其实就是属于ansible的内置变量，只不过有特殊的用法，所以称之为魔法变量

现在主机清单有node1 node2 node3，收集主机的主机名

```Bash
hostvars 魔法变量：指定获取主机的facts变量信息
- name: use module
  hosts: node1,node2,node3
  tasks:
  - debug:
     msg: "{{ hostvars['node1'].ansible_ens160.ipv4.address }}"
     
inventory_hostname 列出当前正在执行任务的主机
- name: use module
  hosts: node1,node2,node3
  tasks:
  - debug:
     msg: "{{ inventory_hostname  }}"
  when: inventory_hostname  == 'node1'
  通常和when判断联合使用
  
groups： 列出主机清单中的所有主机  （groups.all 列出所有的主机）
[root@0420 opt]# cat test.yml
- name: use module 
  hosts: node1,node2,node3
  gather_facts: false
  tasks:
  - debug: 
     msg: "{{ groups }}"

```

ansible的魔法变量，无法通过命令查询，必须查询ansible的官方文档

docs.ansible.com 



```Bash
让node1主机的/etc/hosts文件，收集所有主机的IP地址和主机名以及fqdn
魔法变量！
```







# ansible的when条件判断

比如说要给所有的被控节点去安装软件，如果被控节点的磁盘空间不够了， 你还能安装？？？

对于这种需要进行判断筛选的情况，我们就需要借助于when判断。（类似于shell中if判断）

shell是通过if判断，ansible通过when判断

### 通过比较运算符来进行判断

```Bash
  == 比较两边的对象是否一致
  > < 比较两边的对象大小
  >= <= 比较两边的对象大小
  != 比较两边的对象是否不一致
  
 # 如果主机名是node1，则执行task任务
 - name: use module 
  hosts: node1,node2,node3
  vars:
     hostname: node1
  tasks:
  - shell: ls /etc/passwd
    when: hostname == "node1"

 # 如果主机的内存大小大于3000，则执行task任务
 - name: use module
  hosts: node1,node2,node3
  tasks:
  - shell: ls /etc/passwd
    when: ansible_memfree_mb > 3000
    
 # 如果主机名不是node1，则执行task任务
 [root@0420 opt]# cat test.yml
- name: use module 
  hosts: node1,node2,node3
  tasks:
  - shell: ls /etc/passwd
    when: ansible_hostname != "node1"
```

when判断后面默认会识别变量，所以不需要加上 "{{ }}"  ，默认就识别变量；如果要用字符串比较，最好使用双引号和单引号共同引起来哦





## 通过逻辑运算符进行判断

```Bash
and： 逻辑与 两边表达式同时为真条件满足
or：  逻辑非 两边任意一个表达式为真则条件满足
not： 逻辑否 对表达式取反
（）：逻辑组合，括号内的逻辑表达式都是逻辑与的关系
```

```Bash
# 判断1：当主机名是node1的时候，并且ens160网卡的IP地址是192.168.68.133则执行task任务
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  tasks:
  - name: create file 
    file:
      path: /opt/node1.txt
      state: touch
    when: ansible_hostname == "node1" and ansible_ens160.ipv4.address == "192.168.68.133"


# 判断2：当主机名是node1或者ens160网卡的IP地址是192.168.68.134的时候，执行task任务
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  tasks:
  - name: create file 
    file:
      path: /opt/node1.txt
      state: touch
    when: ansible_hostname == "node1" or ansible_ens160.ipv4.address == "192.168.68.134"
    
# 判断3：主机名是node1并且操作系统版本是RedHat 或者 主机的ens160网卡IP地址是192.168.68.134并且主机的空闲内存大于3000M


# 判断4：主机名不是node1的，则执行task任务
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  tasks:
  - name: create file 
    file:
      path: /opt/node1.txt
      state: touch
    when: not ansible_hostname == "node1"


```



## 借助register注册变量来进行when判断

可以根据rc的返回值来判断task任务是否执行成功

```Bash
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  tasks:
  - shell: ls /etc/passwdabc
    register: get_status 
  - debug:
     msg: "{{ get_status }}"
  - debug:
     msg: rhce is ok
    when: get_status.rc == 0
```



## 通过判断是否是一个文件、目录、挂载点、连接文件 是否存在文件/目录

```Bash
shell通过 -f -d 来判断是否是一个文件/目录
ansible通过 file 、directory、mount、link、exists

- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    filepath: /etc/group
  tasks:
  - debug:
     msg: file
    when: filepath is file
  - debug:
     msg: directory
    when: filepath is directory
  - debug:
     msg: exists
    when: "'/etc/passwd' is exists"

```





## 判断变量

```Bash
defined   判断变量是否定义 如果定义则条件为真
undefined 如果变量没有定义，条件为真
none      定义了变量，但是没有赋予值，条件为真

- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    ns01: dns
  tasks:
  - debug:
     msg: ns01
    when: ns01 is defined
  - debug:
     msg: ns02
    when: ns02 is none
  - debug:
     msg: ns03
    when: ns03 is undefined

```





## block块

在一些情况下，我们需要对多个task任务来进行同一个when判断条件；

ansible通过block可以使用一个when判断条件，来执行多个task任务；

block和when是处于一个层级，只要when判断条件成立， 则block里面的所有task任务执行。

```Bash
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    user3: lsii
       
  tasks:
    - name: use block
      block:
      - debug:
         msg: ok
      - yum:
         name: httpd
         state: present
      when: user3 == 'lsii'
```



## rescue来进行错误处理

当block中的task任务执行失败了，才会触发rescue下面的task任务。如果block中的task任务都是成功，则不会执行rescue

```Bash
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    user3: lsii
       
  tasks:
    - name: use block
      block:
      - debug:
         msg: ok
      - shell: ls
      rescue:
      - debug:
         msg: rescue
      when: user3 == 'lsii'

```



## always关键字

不管block中，task任务执行成功还是失败，我最终都要去执行always下面的task任务

```Bash
[root@0420 opt]# cat when.yml 
- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    user3: lsii
       
  tasks:
    - name: use block
      block:
      - debug:
         msg: ok
      - shell: la
      rescue:
      - debug:
         msg: rescue
      always:
      - name: always
        debug:
           msg: always
      when: user3 == 'lsii'
```





## fail模块

当一个条件满足的时候，直接退出整个playbook。类似于shell中的exit，退出。

```Bash
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  gather_facts: false
  tasks:
  - name: use shell module
    shell: ls /etc/passwd
    ignore_errors: yes
    register: get_status 
  - name: use failed
    fail:
      msg: /etc/paswda is not exist  # 输出错误的信息
    when: get_status.rc != 0
  - debug: 
      msg: msg


```

除了fail模块可以终止playbook的运行，还可以使用failed_when来进行判断，只要判断成功，则直接退出

```Bash
- name: use
  hosts: node1,node2
  gather_facts: false
  tasks:
  - name: use shell module
    shell: ls /etc/passwda
    ignore_errors: yes
    register: get_status
  - debug:
     msg: /etc/passwda is not exist
    failed_when: get_status.rc != 0
  - debug:
      msg: msg
```







# ansible的循环语句

**with_items循环列表**

```Bash
# 1. 利用变量的方式
- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    username:
      - zhangsan
      - lisi
      - wangwu
  tasks:
  - name: debug
    debug:
       msg: "{{ item }}"
    with_items: "{{ username }}"
    
# 2. 直接编写列表
- name: use
  hosts: node1,node2
  gather_facts: false
  tasks:
  - name: debug
    debug:
       msg: "{{ item }}"
    with_items:
      - zhangsan
      - lisi
      - wangwu
# 3. 行内对象
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1,node2
  gather_facts: false
  vars:
    username:
      - zhangsan
      - lisi
      - wangwu 
  tasks:
  - name: debug 
    debug:
       msg: "{{ item }}"
    with_items: ["zhangsan","lisi","wangwu"]

```



**with_dict循环字典/**对象

```Bash
[root@0420 opt]# cat when.yml
- name: use
  hosts: node1
  gather_facts: false
  vars:
    users:
      username01: zhangsan
      username02: lisi
  tasks:
  - name: debug 
    debug:
       msg: "{{ item.value }}"
    with_dict: "{{ users }}"
```





loop循环，loop循环是在ansible 2.6版本开始的，不需要通过with_x 关键字去循环，但是依旧可以使用。loop循环天生支持列表循环，默认不支持字典循环，除非利用jinja2的过滤器才可以让loop循环字典。

```Bash
loop循环列表
- name: use
  hosts: node1
  gather_facts: false
  vars:
    pkgs:
      - httpd
      - nginx
      - maridb
  tasks:
  - name: debug
    debug:
      msg: "{{ item }}"
    loop: "{{ pkgs }}"


loop循环字典？ 需要接住dict2items 的过滤器
- name: use
  hosts: node1
  gather_facts: false
  vars:
    username:
      user01: zhangsan
      user02: lisi
  tasks:
  - name: debug
    debug:
      msg: "{{ item }}"
    loop: "{{ username|dict2items }}"
```

dict2items是jinja2的过滤器：

常用的过滤器：

  dict2items  

  default   

  password_hash将字符串进行加密

```Bash
default过滤器
- name: use
  hosts: node1
  gather_facts: false
  vars:
    username:
      user01: zhangsan
      user02: lisi
    a100: rhcsa
  tasks:
  - name: debug
    debug:
      msg: "{{ a100|default('rhce') }}"
      
 password_hash过滤器
- name: use
  hosts: node1
  gather_facts: false
  vars:
    username:
      user01: zhangsan
      user02: lisi
    a100: rhcsa
    passabc: redhat
  tasks:
  - name: debug 
    debug:
      msg: "{{ passabc|password_hash('sha512') }}"

```





# 文件管理模块lineinfile和blockinfile

- lineinfile修改文件的单行内容
- blockinfile修改文件的多行内容

```Bash
将/etc/httpd/conf/httpd.conf的80端口修改为82端口
- name: config httpd config
  hosts: node1,node2,node3
  gather_facts: false
  tasks:
  - name: replace httpd conf content
    lineinfile:
      path: /etc/httpd/conf/httpd.conf
      backup: yes
      regexp: "^Listen 80"
      line: "Listen 82"
      backrefs: yes   
      validate: httpd -tf %s

backrefs：默认是false。如果匹配到了行怎么进行替换，没匹配到则追加内容
          如果是yes，匹配到了行则替换，没匹配到则不做修改
backup： 如果是yes 则修改配置文件之前进行备份一份
validate： 校验机制；是服务本身的校验机制而不是ansible的模块来提供的
  比如httpd  httpd -t
            nginx -t
 
create： yes/no 如果文件不存在则创建

```

如果只写的path和line，那么会直接追加内容；

如果匹配到了多行内容，只会去修改最后一行匹配到的内容；

如果删除匹配的行，会删除所有匹配到的行；



blockinfile模块的用法和lineinfile差距不大，支持的参数几乎都有；区别在于支持 block 插入的文本内容，marker去标记

```Bash
删除mark标记的内容
- name: config httpd config
  hosts: node1,node2,node3
  gather_facts: false
  tasks:
  - name: replace httpd conf content
    blockinfile:
      path: /etc/httpd/conf/httpd.conf
      backup: yes
      marker: "# {mark} ANSIBLE MANAGED BLOCK"
      state: absent
      
新增多行内容
- name: config httpd config
  hosts: node1,node2,node3
  gather_facts: false
  tasks:
  - name: replace httpd conf content
    blockinfile:
      path: /etc/httpd/conf/httpd.conf
      backup: yes
      marker: "# {mark} ANSIBLE MANAGED BLOCK"
      block: |
       Listen 8080
       Listen 9090

```

如果删除的时候，匹配到了多个mark标记，则都会进行删除



# jinja2模板

大部分修改配置文件的时候，都只是修改一个小部分的地方，大部分的配置都不会去修改。而且每一个主机的配置文件修改的内容的地方都是一个地方。

```Bash
node1机器上httpd配置文件监听到 它自身的ens160网卡的IP上
node2机器上httpd配置文件监听到 它自身的ens160网卡的IP上
node3机器上httpd配置文件监听到 它自身的ens160网卡的IP上

拷贝模板文件的时候，不要使用copy模块，因为模板文件中用变量的存在，copy模块会原封不动的拷贝过去。
需要使用template模块来拷贝，因为会识别变量，用法和copy一样
千万不要关闭facts变量，因为在使用模板文件会依赖于facts变量
- name: use
  hosts: node1,node2,node3
  tasks:
  - name: not use copuy
    template:
       src: httpd.conf
       dest: /opt

```

支持if判断

```Bash

格式：
{% if 表达式 %}
执行语句
{% elif 表达式 %}
执行语句
{% else %}
执行语句
{% endif %}

如果主机名是node1，则配置文件中的内容为node1
如果主机名是node2，则配置文件中的内容为node2
如果主机名是node3，则配置文件中的内容为node3
{% if ansible_hostname == "node1" %}
node1
{% elif ansible_hostname == "node2" %}
node2
{% else %}
abc
{% endif %}

```

jinja2模板的for循环

```Bash
格式：
{% for 变量 in 循环的对象的 %}
执行语句
{% endfor %}

在node1机器上的/etc/hosts文件中，去保存node1 node2 node3 它们的主机和IP地址的对应关系
[root@0420 opt]# cat hosts (模板文件）
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
{% for host in groups.all %}
{{ hostvars[host].ansible_ens160.ipv4.address }} {{ hostvars[host].ansible_hostname }}
{% endfor %}


```





# roles角色

ansible的roles就是将playbokk中的内容进行拆分出来了，把每一个结构都分为了不同的文件和目录，task任务的文件，变量文件，handers触发器的文件、template模板文件放到不同的目录下，以前是独权，现在是多权分力。

  target section：执行的主机，远程操控的用户等等

  变量：定义的变量

  tasks任务列表

  handlers触发器



因为一个playbook如果直接移植复制给其他人使用，那么。如果playbook中有使用vars_files引用外部的变量文件，或者类似于copy template这种模块，要拷贝主控节点的文件到被控；其他主机没有这些文件，执行这个palybook就会失败。

所以这个时候，使用role去管理，所有的task任务、引用的普通文件、变量文件都在一个目录下。

所以role解决的最大的问题就是playbook的移植性问题。让你的playbook可以在任何的ansible主控节点执行。





ansible 2.9之前的版本使用的是role角色→taks任务列表、变量文件、handlers触发器等等

ansible 2.9之后的版本使用的集合 （collections） 包含role角色、module模块、plugin插件

  ansible-core 不完整的ansible，模块很少；比如没有firewalld模块、lvol模块

    必须要通过安装collections也就是集合来得到模块
    
    访问网址：galaxy.ansible.com



role角色结构

```Bash
roles角色的结构
files：用于存放一些非模板文件的文件，如https证书等。
tempaltes：用于存放角色相关的Jinja2模板文件，当使用角色相关的模板时，如未明确指定模板路径，则默认使用此目录中的模板
tasks：角色所要执行的所有任务文件都存放于此，包含一个主文件main.yml，可以在主文件中通过include的方式引入其他任务文件
handlers：用于定义角色中需要调用 的handlers，包含一个主配置文件main.yml，可通过include引入其他的handlers文件。
vars：用于定义此角色用到的变量，包含一个主文件main.yml
meta：用于存储角色的元数据信息，这些元数据用于描述角色的相关属性，包括作者，角色的主要作用，角色的依赖关系等。默认这些信息会写入到当前目录下的main.yml文件中
defaults：除了vars目录，defaults目录也用于定义此角色用到的变量，与vars不同的是，defaults中定义的变量的优先级最低。
```

默认路径：/etc/ansible/roles 通过修改ansible.cfg配置文件可以指定角色路径

  角色的名字就是目录的名字，通过ansible-galaxy init role-name 可以初始化角色目录结构，生成目录和文件

```Bash
[root@rhel9 roles]# ansible-galaxy init apahce
- Role apache was created successfully
[root@rhel9 roles]# ls 
apache  
[root@controller roles]# ls apache/
defaults  handlers  README.md  templates  vars
files     meta      tasks      tests
```



在playbook中调用role

```Bash
[root@rhel9 ansible]# cat roles.yml
- hosts: all
  roles:
    - apache
```



## include_tasks引入task任务文件

在使用role的时候，task目录下的main.yml文件中，写入的task任务太多。这个时候可以通过 include_tasks来进行拆分，将task任务写入到外部的文件，然后通过include_tasks来引入外部的task任务文件。

![](https://secure2.wostatic.cn/static/kvZtjxavMySriKkt214HTA/image.png?auth_key=1720575520-xd2jg9fN7WNb7H9TPD1vqG-0-81e359b34cb4d6edb5c441fba84db3c3)

![](https://secure2.wostatic.cn/static/rzutkFHLAA8LNu7VVvNsHs/image.png?auth_key=1720575520-dyBPG3nasPEqUFBaF4XRRG-0-77195a82b55ad0a0d29f69cf0a0424bd)



## **pre_tasks和post_tasks**

pre_tasks会在执行roles之前执行task任务，post_tasks在执行roles之后执行任务。它们的层级和tasks是处于同一个层级。

```Bash
- hosts: all
  roles:
    - apache
  pre_tasks:
    - debug:
       msg: pre_tasks
  post_tasks:
    - debug:
       msg: post_tasks
```

执行的时候，无关pre_tasks和post_tasks的顺序。永远是先执行pre_tasks的任务，然后执行role，最后执行post_tasks



## 获取role角色

1. 通过网站 galaxy.ansible.com
2. 通过本地软件包 rhel-system-roles

    红帽自带的role（timesync时间同步 selinux管理 firewalld防火墙），是自带的系统管理role

    

```Bash
ansible-galaxy init role-name  初始化role目录结构
ansible-galaxy role search role-name   查找角色
ansible-galaxy role install   role-name  安装角色
  -r 指定文件、从文件中下载（或者指定url地址）
  -p 指定路径
ansible-galaxy role list  列出系统上角色

```





# collection集合

在RHEL9中，如果安装的是ansible-core，那么自带的模块是非常少的；只有大概70个核心模块，类似于filesystem（创建文件系统）、firewalld、lvol（管理逻辑卷）、parted（管理分区）等这些模块都没有，我们需要通过安装集合的方式来获取模块

  安装集合，可以获取 模块、角色、插件

  从网站 galaxy.ansible.com 可以下载集合

```Bash
ansible-galaxy collection list 列出集合
ansible-galaxy collection install 《collection> 安装集合
  -r 指定文件
  -p 指定路径

```

![](https://secure2.wostatic.cn/static/wWQVWk1aUW8J5NEw8mDctG/image.png?auth_key=1720575513-68XDkBpCHqTGp4nmoJpc9D-0-e281baf2b911b032255f6e405e0958f7)





# ansible-vault加密

在一些场景下，我们的ansible的文件非常私密，内容不能外传；所以需要对其进行加密

```Bash
创建一个加密文件：    ansible-vault create filename
查看一个加密文件：    ansible-vault view filename
解密一个加密文件：    ansible-vault decrypt filename
加密一个已存在的文件： ansible-vault encrypt filename
修改一个加密文件密码： ansible-vault rekey filename

执行一个加密的剧本？
  （如果playbook中调用的外部文件是通过ansible-valut进行加密的，那么执行的时候就需要密码解密）
1.在命令行直接输入密码
  ansible-playbook debug.yml --ask-vault-pass
2.通过密码文件执行playbook 
  ansible-playbook debug.yml --vault-password-file=passwd.txt
  
 

```



# ansible导航器

使用容器来运行ansible，安装导航器获取容器镜像。使用导航器运行ansible的playbook，无法执行ad-hoc指令

```Bash
ansible-navigator run debug.yml  -m stdout
  run 运行playbook
  -m 指定输出模式（默认不写-m 是可视化模式，stdout是字符模式，和ansible-playbook执行一样显示）

```



我们每一次导航器执行playbook的时候，都需要从网上拉取最新的镜像，配置一个自动化执行环境，从本地镜像中执行；在用户家目录下创建一个隐藏文件  .ansible-navigator.yml 

```Bash
[root@rhel9 ~]# cat .ansible-navigator.yml 
ansible-navigator:
 execution-environment:
  image: registry.redhat.io/ansible-automation-platform-22/ee-supported-rhel8
  pull:
   policy: missing
```



导航器的操作

```Bash
ansible-navigator doc -l 查看导航器的模块
ansible-navigator doc firewalld 查看模块的帮助信息

ansible-navigator inventory  --list   可视化模式列出所有的主机
```