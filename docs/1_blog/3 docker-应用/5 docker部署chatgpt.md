# docker部署chatgpt



> 本地搭建ChatGPT教程：https://www.techxiaofei.com/post/chatgpt/local/
>
> docker手册：https://docs.docker.com/
>
> docker hub容器镜像库：https://hub.docker.com/

## 一、背景

​		我相信很多小伙伴在国内使用机场使用ChatGPT有被**封号**的，因为公共机场的IP都是大家共用的，很容易被ChatGPT识别出来并封号。

​		比如你使用ChatGPT的时候可能会遇到各种各样的错误，`机场IP被封`或者`账号被封`等。

​		本节教大家如何在本机电脑（`Windows`，当然也支持MacOS并且更简单）上搭建ChatGPT，`无需翻墙，免费体验`服务器进行转发。

​		当然如果你有国内的`云服务器`，也可以直接在云服务器里面安装访问。

​		给大家展示一下效果。可以看一下，跟ChatGPT不说是长得很像，可以说是毫无区别。

![image-20240529205849074](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/2ced140deba6f95c7f6be70e89651c2f-image-20240529205849074-b2941e.png)

​		同时我们使用的是OpenAI的`Access Token`登录，不需要API，我们都知道API除了注册的时候送的几美金到期之后就无法使用了，需要充值。所以我们使用完全免费的网页版登录的token。



## 二、软件安装

​		想要在本地搭建ChatGPT，只需要几步简单的安装即可。

### 1.docker

​		Docker是一个全球最流行的镜像服务管理平台，里面是打包好的应用程序，直接下载就能使用，而不需要自己进行复杂的环境配置，免去了自己安装依赖的麻烦。

​		使用Docker你什么都不需要装，只需要一键下载Docker镜像就可以运行了。

​		我们去官网下载 [Docker](https://www.docker.com/)，我们根据我们的电脑系统选择对应的版本下载即可。我用的是Windows，所以下载Windows版本，下载完直接安装。

![image-20240529210218434](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/e0e760c4d65f3599c6c60922e8c60788-image-20240529210218434-d4d4a7.png)

​		安装完成之后可能会提示：**Docker桌面版需要一个新的WSL内核版本。**

​		在Windows搜索框输入**powershell**打开`Windows PowerShell`应用。然后执行 `wsl --update`即可。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/0b2b20e49ca7372e20eae78892cb45de-image-20240529212634920-7b2921.png" alt="image-20240529212634920" style="zoom:50%;" />

​		同时，还需要开启docker服务，搜索框输入`services.msc`打开服务，开启`Docker Desktop Service`服务：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/9bf7704a2aa499bac2e234d9a47c0460-image-20240529214639376-b2d5cd.png" alt="image-20240529214639376" style="zoom:50%;" />

### 2.下载Docker镜像

​		Docker程序下载好之后，我们就可以使用`docker命令`下载ChatGPT的Docker镜像了，这是一个开源的项目，名字叫 **Pandora（潘多拉）**，在 [Github](https://github.com/pengzhile/pandora) 上的源码，有8千多个star。当然我们不需要下载这份源码来安装。我们只需要执行`docker`命令从docker的服务器下载别人上传的镜像即可。

### 3.执行命令

​		搜索框输入cmd找到`命令提示符`，以管理员身份运行。

#### 3.1 下载docker镜像

```bash
docker pull pengzhile/pandora
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/8b21608753b82bc53a488529244a688f-image-20240529215025274-80aaeb.png" alt="image-20240529215025274" style="zoom:67%;" />

#### 3.2 运行docker镜像

```bash
docker run -d -p 8899:8899 -e PANDORA_CLOUD=cloud -e PANDORA_SERVER=0.0.0.0:8899 pengzhile/pandora
```

![image-20240529215040834](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/b28e030beba2013f2acdbe5ac96da9af-image-20240529215040834-1df30a.png)



## 三、浏览器打开IP端口

​		运行成功之后下一步我们就可以在浏览器打开 [http://127.0.0.1:8899](http://127.0.0.1:8899/)。

​		然后可以看到有两种登录方式，一种是使用账号密码登录，一种是使用`Access Token`登录。

​		当然我是推荐使用`Access Token`登录的。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/c12a211c2cf375cdeb34a79747196910-image-20240529215158089-2b280e.png" alt="image-20240529215158089" style="zoom:50%;" />

### 1.Access Token

​		这个Token怎么获得呢？我们打开下面这个地址。

​		Token获得地址：http://chat.openai.com/api/auth/session（用谷歌打开）

​		我给小伙伴解释下，`Access Token`就是你使用账号密码登录的ChatGPT的网站会生成一个Token，这个Token是30天过期，下次重新生成就行，网页版是完全免费的，所以这个使用方法也是完全免费的。

​		关注accessToken和expires就行，就是具体的token和过期时间。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/a57480aa375bf426f24fc697731da61c-image-20240529220040568-d4e02c.png" alt="image-20240529220040568" style="zoom:67%;" />

```bash
{
  "user": {
    "id": "user-idNAxWDUK6FwBfyvkuZLt9LM",
    "name": "龍龍",
    "email": "whizhzl@gmail.com",
    "image": "https://lh3.googleusercontent.com/a/ACg8ocJw_k-lGj6ZTIVDasQHY5MbuLzDa4w3yRexUxz0MQbyZyfP8Q=s96-c",
    "picture": "https://lh3.googleusercontent.com/a/ACg8ocJw_k-lGj6ZTIVDasQHY5MbuLzDa4w3yRexUxz0MQbyZyfP8Q=s96-c",
    "idp": "google-oauth2",
    "iat": 1715965459,
    "mfa": false,
    "groups": [],
    "intercom_hash": "b42fb87b6916a8423310361888ef0816411d4030d2874b0f012832c967263f58"
  },
  "expires": "2024-08-27T13:54:24.872Z",
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik1UaEVOVUpHTkVNMVFURTRNMEZCTWpkQ05UZzVNRFUxUlRVd1FVSkRNRU13UmtGRVFrRXpSZyJ9.eyJodHRwczovL2FwaS5vcGVuYWkuY29tL3Byb2ZpbGUiOnsiZW1haWwiOiJ3aGl6aHpsQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlfSwiaHR0cHM6Ly9hcGkub3BlbmFpLmNvbS9hdXRoIjp7InBvaWQiOiJvcmctT0FMaGNqd1pnR0E3RWlYT3dNN3I5SDlZIiwidXNlcl9pZCI6InVzZXItaWROQXhXRFVLNkZ3QmZ5dmt1Wkx0OUxNIn0sImlzcyI6Imh0dHBzOi8vYXV0aDAub3BlbmFpLmNvbS8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDEwMjA0ODY1OTUxMTQ1MDUwMDg0NiIsImF1ZCI6WyJodHRwczovL2FwaS5vcGVuYWkuY29tL3YxIiwiaHR0cHM6Ly9vcGVuYWkub3BlbmFpLmF1dGgwYXBwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE3MTY5MDA0NDgsImV4cCI6MTcxNzc2NDQ0OCwic2NvcGUiOiJvcGVuaWQgZW1haWwgcHJvZmlsZSBtb2RlbC5yZWFkIG1vZGVsLnJlcXVlc3Qgb3JnYW5pemF0aW9uLnJlYWQgb3JnYW5pemF0aW9uLndyaXRlIG9mZmxpbmVfYWNjZXNzIiwiYXpwIjoiVGRKSWNiZTE2V29USHROOTVueXl3aDVFNHlPbzZJdEcifQ.NmXJMEVV75nCCCnT6ytwYqRCIizSOb1px1V-6qxO5RvqcYkAdJIK_O-okkvlIvCOSSMJVTwbRl_vNOFCIfeCiPiSTo49c_-COtKhzI3jPqMH8E_wx1p1Q0FMMLL7P9YJmIeNdGI_fyZWklXi_ZFLH6eW1Xrh_4gpBZrMikbWe0kSCimfHWjxI2FR7rhmfX4qayjEJQApHp7mutlSFUv0D8-HRyTINlPX2F4-eeWIarZNfh-D6Oy3_cw0br-5OPs_lLukq5Acm8s9PKeX4zruv_KutlNlN7HFHVS9FS_rEoRDYChhW86F9pTJY8xaN-arsDPFFSRauT7lV4elE79lxg",
  "authProvider": "login-web"
}
```

**注意：** 获取Token是通过访问OpenAI官网的链接获取的，所以在国内的小伙伴需要开启全局代理，如果你开启代理还无法访问，那就是你使用的机场IP被污染了，被OpenAI封禁了，你需要找到干净的机场访问，或者直接找国外的朋友帮你登录生成Token。

### 2.访问

​		复制accessToken的值，然后粘贴到刚才的网站就可以使用了。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/29/bf6e40cf36f49ccb085a43d0df472613-image-20240529220906458-b93d1a.png" alt="image-20240529220906458" style="zoom: 50%;" />
