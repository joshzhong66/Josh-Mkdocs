# docker部署jumpserver-v2.8.4	



> 在部署 Jumpserver 时，`SECRET_KEY` 和 `BOOTSTRAP_TOKEN` 都是非常重要的配置参数，它们的具体作用如下：
>
> **SECRET_KEY：**
>
> - `SECRET_KEY` 是一个安全密钥，用于加密和解密 Jumpserver 内部的一些重要数据，比如用户的密码、会话数据等。
> - 这个密钥在整个 Jumpserver 的生命周期中应保持不变，并且需要保密，防止被外部攻击者获取。
> - 如果 `SECRET_KEY` 被泄露或更改，之前加密的数据将无法解密，可能会导致数据损坏或系统无法正常运行。
>
> **BOOTSTRAP_TOKEN：**
>
> - `BOOTSTRAP_TOKEN` 是一个引导令牌，用于初次启动和初始化 Jumpserver 系统时的认证过程。
> - 在首次部署 Jumpserver 时，系统会使用这个令牌来进行初始的安全配置和注册。
> - 一旦系统初始化完成，这个令牌的作用就结束了，因此它的生命周期相对较短。
>
> 总结起来，`SECRET_KEY` 主要用于持续性的安全加密，确保系统的运行安全；而 `BOOTSTRAP_TOKEN` 主要用于系统初次部署时的安全认证，保证初始化过程的安全性。

## 一、随机生成加密密钥

以下两个分别用来生成 `SECRET_KEY` 和 `BOOTSTRAP_TOKEN`。这些变量通常用于存储安全相关的信息，比如加密密钥或者身份验证令牌。

### 1.生成`SECRET_KEY`的部分

编辑secert-key.sh，脚本内容如下：

```bash
[root@jerion ~]# vim secert-key.sh
if [ "$SECRET_KEY" = "" ]; then 
	SECRET_KEY=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50); 
	echo "export SECRET_KEY=$SECRET_KEY" >> ~/.bashrc; 
	echo $SECRET_KEY; 
else 
	echo $SECRET_KEY; 
fi

#执行脚本
[root@jerion ~]# sh secert-key.sh
WSerysaK4qK7rv3cs7KLwpJ5ZkQVI35zABLdkRN5DWy2I8b7qc
```


这段代码的逻辑是：

- 如果环境变量 `SECRET_KEY` 为空，则生成一个包含大小写字母和数字的 50 位随机密钥。

- 将生成的密钥写入 `~/.bashrc` 文件。

- 打印生成的密钥。

### 2.生成`BOOTSTRAP_TOKEN`的部分

编辑bootstrap-token.sh，脚本内容如下：

```bash
[root@jerion ~]# vim bootstrap-token.sh
if [ "$BOOTSTRAP_TOKEN" = "" ]; then 
    BOOTSTRAP_TOKEN=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16); 
	BOOTSTRAP_TOKEN=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16); 
	echo "export BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc; 
	echo $BOOTSTRAP_TOKEN; 
else 
	echo $BOOTSTRAP_TOKEN; 
fi

#执行脚本
[root@jerion ~]# sh bootstrap-token.sh
GdR3HM6fT0LOBdLj
```


这段代码的逻辑是：

- 如果环境变量 `BOOTSTRAP_TOKEN` 为空，则生成一个包含大小写字母和数字的 16 位随机令牌。
- 将生成的令牌写入 `/.baserc` 文件。
- 打印生成的令牌。

### 3.整理后的执行内容如下

- 生成 `SECRET_KEY`：
  - 生成的 `SECRET_KEY` 为：`WSerysaK4qK7rv3cs7KLwpJ5ZkQVI35zABLdkRN5DWy2I8b7qc`
  - 将 `SECRET_KEY` 写入 `~/.bashrc` 文件中

- 生成 `BOOTSTRAP_TOKEN`：
  - 生成的 `BOOTSTRAP_TOKEN` 为：`GdR3HM6fT0LOBdLj`
  - 将 `BOOTSTRAP_TOKEN` 写入 `/.baserc` 文件中

请注意，代码中的拼写错误 `/baserc` 应该是 `~/.bashrc`。您可以根据需要修改文件路径或内容。



## 二、安装jumpserver

```bash
docker run -itd \
--name jumpserver \
--restart=always \
-p 8081:80 -p 2222:2222 \
-e SECRET_KEY=WSerysaK4qK7rv3cs7KLwpJ5ZkQVI35zABLdkRN5DWy2I8b7qc \
-e BOOTSTRAP_TOKEN=GdR3HM6fT0LOBdLj \
-v /data/jumpserver/data/:/opt/jumpserver/data/ \
-v /data/jumpserver/mysql/:/var/lib/mysql \
jumpserver/jms_all:v2.8.4
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/00dc4e263562f75a443f92bb227a33e2-image-20240510131010219-0ddeb1.png" alt="image-20240510131010219" style="zoom:50%;" />



## 三、访问jumpserver

打开浏览器，访问http://10.22.51.63:8081/core/auth/login/登录页面：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/46f631aa005937c83aef427ebe986456-image-20240510131020932-bacde8.png" alt="image-20240510131020932" style="zoom: 33%;" />

首次登录的用户名和密码均为admin，登录后会提示需要修改密码，修改后重新登录。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/61bdce22e98496372c0d620066642a7e-image-20240510131026142-f8871d.png" alt="image-20240510131026142" style="zoom: 25%;" />



## 四、jumpserver相关配置

### 1.管理用户

​		管理用户是资产被控服务器上的root，jumpserver使用此用户可以【推送系统用户】【获取资产硬件信息】等，需要注意的是【jumpserver需要先与资产节点做免密，将私钥发送到资产主机】。

```bash
[root@0ebb95bb883b ~]# ssh-keygen
[root@0ebb95bb883b ~]# ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.22.51.63
[root@0ebb95bb883b ~]# ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.22.51.64
 
## 将私钥保存下来，要使用
[root@0ebb95bb883b ~]# exit
[root@jerion ~]# docker cp jumpserver:/root/.ssh/id_rsa /root
[root@jerion ~]# sz id_rsa
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/14/0ac839965693bf9b7fae670db7ddde48-image-20240510131044358-5b0b27.png" alt="image-20240510131044358" style="zoom:50%;" />

![image-20240510131049456](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/2dc6f8b1eb37214c51ef295b2de4671a-image-20240510131049456-196504.png)

创建管理用户：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/0be32c2d84ca2b01e7bce3647e2201c1-image-20240510131059618-34e1a8.png" alt="image-20240510131059618" style="zoom: 50%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/ba131c4774188bac497dcccb6b66e3d5-image-20240510131108069-557bc4.png" alt="image-20240510131108069" style="zoom:33%;" />

### 2.系统用户

用于登录资产的用户：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/06/17/e88e9d169ebbd4ebf0aa27831f6a887b-image-20240617165209265-7cff5a.png" alt="image-20240617165209265" style="zoom: 33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/612d8c02a8415ff5514863ebcdc3ca56-image-20240510131124533-d81139.png" alt="image-20240510131124533" style="zoom:33%;" />

![image-20240510131134742](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/5c66382cf6586f588fc9981fe5d5e2b8-image-20240510131134742-59dd7b.png)

### 3.普通用户

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/9ab3a30c09f154f46771967a009ac889-image-20240510131138536-c38a26.png" alt="image-20240510103405303" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/34ae143da5c2a30dd15befa13cf7ecc3-image-20240510133430542-6edaa3.png" alt="image-20240510133430542" style="zoom: 25%;" />

创建用户组，将用户添加到用户组，便于管理：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/b25611ebe1a926a73d0c741ac7b38a1a-image-20240510133420424-807c65.png" alt="image-20240510133420424" style="zoom:25%;" />

### 4.添加节点

资料列表中，右键Default节点进行创建：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/041de00fee15427187efa601309ada8a-image-20240510132135216-8188f4.png" alt="image-20240510132135216" style="zoom:33%;" />

### 5.添加资产

可以添加的有：服务器、网络设备、数据库应用。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/3c23198ef4fc919d5e9533f1bdfa337b-image-20240510132234356-a2172f.png" alt="image-20240510132234356" style="zoom: 33%;" />

![image-20240510132833210](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/6f2ace34c70df85984bd35c7f29b5606-image-20240510132833210-cf513e.png)

### 6.权限划分

将运维组划分为（测试服务器1、测试服务器2），将开发组划分为（测试服务器1）：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/1922355289971e7c89ba213589931f1f-image-20240510133738171-5e9ff1.png" alt="image-20240510133738171" style="zoom:33%;" />

![image-20240510133812955](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/533a893e9f0320a0f2d376672e79138f-image-20240510133812955-00d907.png)

### 7.验证

使用普通用户登录资产：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/38cf37bfa39686067d0377501420f1d9-image-20240510135236199-4d655f.png" alt="image-20240510135236199" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/f62efce65924f8c6a0f28729748ff4e8-image-20240510135253130-ee3d76.png" alt="image-20240510135253130" style="zoom: 33%;" />

### 8.查看是否有记录

![image-20240510140043900](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/99bbd83269e15cbdc2919388e44837b7-image-20240510140043900-abab2d.png)

![image-20240510140425783](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/454fd6cc81250199b79f47b9865ad648-image-20240510140425783-62755f.png)

### 9.添加数据库资产

注：需先将jumpserver的公钥发送给数据库资产，即前面管理用户中的配置命令。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/e5a8d40a2e454a44dc9ec3aac9a59d9a-image-20240510141005474-3d1d82.png" alt="image-20240510141005474" style="zoom:33%;" />

### 10.创建登录mysql的系统用户（创建专门登录mysql的用户）

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/78f44e9495810b36e8f901d8de05207e-image-20240510141412768-bf8998.png" alt="image-20240510141412768" style="zoom:33%;" />

### 11.数据库资产授权

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/c2df5d173b78c9b13462f1dab5a1b87a-image-20240510141747843-1f375a.png" alt="image-20240510141747843" style="zoom:33%;" />

### 12.测试登录数据库

![image-20240510142014481](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/0cef536881951cdf645ed6ebdad5f4e7-image-20240510142014481-0d12bc.png)

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/cc04c6d3c8babc1682e83fc33f8f085b-image-20240510142042387-e29620.png" alt="image-20240510142042387" style="zoom:33%;" />

### 13.限制用户使用危险命令

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/6668252013c5ffec5f704bd424b85f86-image-20240510142354459-51385e.png" alt="image-20240510142354459" style="zoom:33%;" />

![image-20240510142422634](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/6c4fc2fddd3f94e7f6d01e4fdf142560-image-20240510142422634-a5c300.png)

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/2546e9bda123f1ebd847330c7c41d58c-image-20240510142959512-b282b7.png" alt="image-20240510142959512" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/47b1f3439a89de4935efba8f5967383a-image-20240510142547097-5388f6.png" alt="image-20240510142547097" style="zoom: 25%;" />

### 14.测试危险命令是否禁止

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/a43c2666762f88b7d940a60873dd3522-image-20240510143021427-842d2c.png" alt="image-20240510143021427" style="zoom:33%;" />

### 15.文件管理

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/bc7a8ec6dfdf16bdda39b8274d2ac67f-image-20240510143351645-8dd494.png" alt="image-20240510143351645" style="zoom:33%;" />

将文件直接拖拽上传，默认的存放位置在/tmp下，可以在koko的配置文件中修改：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/5920831e6b0830532e69caeb02233958-image-20240510143448089-a8eb87.png" alt="image-20240510143448089" style="zoom: 33%;" />

![image-20240510143514553](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/9e96e57baff241daa4c29f33365e3898-image-20240510143514553-d96d74.png)



## 五、忘记admin密码，修改步骤

```bash
#忘记 jumpserver 超级用户密码
docker exec -it 容器id /bin/bash

#如果没有按装django 需执行下面命令进行安装(如安装过 此步骤可忽略)
python3 -m pip install --upgrade pip setuptools
python3 -m pip install django


source /opt/py3/bin/activate
python /opt/jumpserver/apps/manage.py changepassword admin
Changing password for user 'Administrator(admin)'
Password: 
Password (again): 
The password is too similar to the 用户名.
This password is too short. It must contain at least 8 characters.
This password is too common.
Password: 
Password (again): 
Password changed successfully for user 'Administrator(admin)'
```

