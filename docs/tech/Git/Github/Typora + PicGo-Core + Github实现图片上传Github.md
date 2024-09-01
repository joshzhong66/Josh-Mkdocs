# Typora + PicGo-Core + Github实现图片上传Github



> 参考博客：https://blog.csdn.net/qq_43351000/article/details/123560560

## 一、配置Nodejs环境

### 1.下载nodejs

下载地址：https://nodejs.org/en/download/

### 2.安装nodejs

设置路径：`D:\GitHub\nodejs`，下一步到完成。

### 3.检测nodejs安装

当执行完上步安装包安装后，需要进行安装是否成功，win+r打开运行，输入cmd后进入命令行界面。

分别输入`node -v`和`npm -v`命令进行node的版本号。

```bash
C:\Users\jerion>node -v
v20.12.2

C:\Users\jerion>npm -v
10.5.0
```

### 4.配置npm安装全局模块的路径与缓存路径

管理员运行cmd，进入命令行界面，分别输入以下内容执行：

```bash
npm config set prefix "D:\Program Files\nodejs\node_global"
npm config set cache  "D:\Program Files\nodejs\node_cache"
```

再打开D:\GitHub\nodejs路径，创建两个文件夹：

```bash
node_global
node_cache
```

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/90922a36c8820340d6e7b3c2b7fce18f-image-20240425003357610-1d3bd0.png" alt="image-20240425003357610" style="zoom:50%;" />

### 5.添加环境变量

在**系统变量**中新建`NODE_PATH`：

```bash
NODE_PATH   D:\GitHub\nodejs\node_global\node_modules
```

编辑**用户变量的path**，修改对应的npm的路径值为上文中自定义的`node_global`路径：

```bash
D:\GitHub\nodejs\node_global
```

管理员运行cmd，执行：```npm install webpack -g```：

```bash
C:\Users\jerion>npm install webpack -g

added 78 packages in 20s

9 packages are looking for funding
run `npm fund` for details
npm notice
npm notice New patch version of npm available! 10.5.0 -> 10.5.2
npm notice Changelog: https://github.com/npm/cli/releases/tag/v10.5.2
npm notice Run npm install -g npm@10.5.2 to update!
npm notice
```



## 二、安装picgo

### 1.执行安装命令

执行命令```npm install picgo -g```：

```bash
npm WARN deprecated @types/bson@4.2.0: This is a stub types definition. bson provides its own type definitions, so you do not need this installed.

added 297 packages in 37s

30 packages are looking for funding
run `npm fund` for details
```

### 2.添加环境变量

添加picgo到用户环境变量Path：

```bash
D:\GitHub\nodejs\node_global\node_modules\picgo\bin
```

添加picgo到系统环境变量Path：

```bash
D:\GitHub\nodejs\node_global\node_modules\picgo\bin
```

### 3.安装github-plus

执行命令```picgo install github-plus```：

```bash
C:\Users\jerion>picgo install github-plus

added 74 packages, and audited 75 packages in 13s

2 packages are looking for funding
  run `npm fund` for details

3 high severity vulnerabilities

Some issues need review, and may require choosing
a different dependency.

Run `npm audit` for details.
[PicGo SUCCESS]: 插件安装成功
```



## 三、Github配置

### 1.新建仓库Picbed

![image-20240425003930100](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/818514a7e6ec8701669ab1128c906101-image-20240425003930100-996c7d.png)

### 2.Token设置

个人头像-设置-Developer settings-Persomal access tokens->Tokens-->生成如下：

```bash
xxx
```

![image-20220317174949176](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/89a89a420259a1427056092ed05412b8-5f7db59cc548eecfde4348e48b3d927c-0929b9.png)

![image-20220317175218256](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/503449f7ab7039d77e31e281528f9b98-fad268d8d4d2670bcd36afe8f9a320e7-08216b.png)



## 四、Typora配置

在Typora中配置图像上传信息，设置PicGo的配置信息：

![image-20240425005740803](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/7092f4c7c9594d94ef4a21af2f5a588b-image-20240425005740803-bc4a73.png)

- 首先上传服务选择```PicGo-Core(command line)```；
- 打开配置文件（在C:\Users\Jerion\\.picgo路径下），添加相关信息：

```bash
{
  "picBed": {
    "uploader": "githubPlus",
    "current": "githubPlus",
    "githubPlus": {
      "repo": "zyx3721/Picbed",
      "branch": "main",
      "token": "xxx",
      "path": "blog-images",
      "customUrl": "",
      "origin": "github"
    }
  },
  "picgoPlugins": {
    "picgo-plugin-github-plus": true,
    "picgo-plugin-rename-file": true
  },
  "picgo-plugin-github-plus": {
    "lastSync": "2024-04-25 12:40:25"
  },
  "picgo-plugin-rename-file": {
    "format": "{y}/{m}/{d}/{hash}-{origin}-{rand:6}"
  }
}
```

- 图片上传，安装改名插件：

```bash
C:\Windows\System32>picgo install rename-file

added 1 package, and audited 76 packages in 3s

2 packages are looking for funding
  run `npm fund` for details

3 high severity vulnerabilities

Some issues need review, and may require choosing
a different dependency.

Run `npm audit` for details.
[PicGo SUCCESS]: 插件安装成功
```

- 点击“验证图片上传选项“进行测试，显示验证成功：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/04/25/63bd0a95c4394a447156f01c58111cd6-image-20240425010149422-a00fdf.png" alt="image-20240425010149422" style="zoom:50%;" />

如弹出验证失败，需要先点击`下载或更新`再点击`验证图片上传选项`。

