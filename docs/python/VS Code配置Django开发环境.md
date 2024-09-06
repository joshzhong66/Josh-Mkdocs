# VS Code配置Django开发环境



> 参考文档：https://blog.csdn.net/weixin_40283570/article/details/97240666

## 一、为Django教程创建项目环境

这种方式下，相当于每个项目都需要建立虚拟环境运行。

### 1.创建虚拟环境

键盘 `win+R` 进入运行窗口，输入 `cmd` 命令，进入命令提示符窗口，执行以下操作：

```bash
d:	   # 进入d盘
mkdir Python\django_git    # 创建项目目录
cd Python\django_git       # 进入项目目录
python -m venv env         # 创建基于当前解释器命名的虚拟环境，名为env

D:\Python\django_git>dir
 驱动器 D 中的卷是 Data
 卷的序列号是 B262-5D6B

D:\Python\django_git>dir
 驱动器 D 中的卷是 Data
 卷的序列号是 B262-5D6B

 D:\Python\django_git 的目录

2024/08/12  22:35    <DIR>          .
2024/08/12  22:35    <DIR>          ..
2024/08/12  22:35    <DIR>          env
               0 个文件              0 字节
               3 个目录 143,806,779,392 可用字节
```

### 2.运行项目文件夹

打开VS Code，点击右上角【文件】——点击【打开文件夹】，选择刚刚创建的项目文件夹：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/ee19e99930d368b8cb11dc8d46af7423-image-20240812223942207-ef8151.png" alt="image-20240812223942207" style="zoom:50%;" />

### 3.选择python解释器

在VS Code中，打开命令选项板，点击左上方【查看】——点击【命令面板】（或者直接 Ctrl + Shift + P），输入 `Python：Select Interpreter` 命令并选择（如果这个选项，需要先去【扩展】里搜索 `python` 并安装）：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/6bf9d96d3812060c11d98eae9894e5cb-image-20240812224200173-962524.png" alt="image-20240812224200173" style="zoom:50%;" />

该命令提供了VS Code可以自动定位的可用解释器列表。从列表中，选择项目文件夹中以 `./env` 或开头的虚拟环境`.\env`：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/d2dfdaf2b0f86f2d4237ab50dffda750-image-20240812224539464-a81b75.png" alt="image-20240812224539464" style="zoom:50%;" />

### 4.配置终端

通过 Ctrl + Shift + ~ 打开新的终端（如果已经配置过的话直接通过 Ctrl + ~ 来运行），在加号旁边选择默认终端类型为 `cmd`：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/5705d271b17be7b0b4e3835f83e1cc91-image-20240812225333390-69d9c5.png" alt="image-20240812225333390" style="zoom:67%;" />

`(env)` 表示已经加载虚拟环境：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/0a6c617a2581489b0a72743302f5bfec-image-20240812225505856-d578e0.png" alt="image-20240812225505856" style="zoom: 67%;" />

也可以直接在终端内激活虚拟环境，使用以下命令：

```bash
D:\Python\django_git>.\env\Scripts\activate
```

如果要退出虚拟环境，可以使用以下命令：

```bash
(env) D:\Python\django_git>deactivate
```

这将关闭虚拟环境，并将返回到全局的 Python 环境。



## 二、创建并运行最小的Django应用程序

> 以下运行命令都在已激活虚拟环境的 VS Code 终端内运行。

### 1.安装Django

在终端内通过 `pip` 命令安装Django：

```bash
(env) D:\Python\django_git>pip install django
```

列出当前 Python 环境中已安装的所有 Python 包及其版本：

```bash
(env) D:\Python\django_git>pip freeze
asgiref==3.8.1
Django==4.2.15
sqlparse==0.5.1
typing_extensions==4.12.2
tzdata==2024.1
```

### 2.创建Django项目

创建一个名为 `git_project` 的Django项目：

```bash
(env) D:\Python\django_git>django-admin startproject git_project
```

### 3.运行并验证Django项目

进入 git_project 目录，启动 Django 项目的开发服务器，验证Django项目是否成功运行：

```bash
(env) D:\Python\django_git>cd git_project

(env) D:\Python\django_git\git_project>python manage.py runserver
```

> `python manage.py runserver` 是 Django 框架中的一个命令，用于启动 Django 项目的开发服务器。通过运行这个命令，Django 会在本地启动一个轻量级的 web 服务器，通常用于开发和调试目的。

默认情况下，Django 开发服务器会在本地的端口 `8000` 上启动，在终端窗口中看到类似以下的输出：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/2b16823945756f4d0749d6355451b432-image-20240812231206631-c7a32e.png" alt="image-20240812231206631" style="zoom:50%;" />

启动成功后，在浏览器中访问 `http://127.0.0.1:8000/` 或 `http://localhost:8000/`，查看 Django 项目：

![image-20240812231304998](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/12/33b95bff12255efc9597982be122e36d-image-20240812231304998-3ce7d2.png)

回到  VS Code 终端，输出窗口还会显示服务器日志：

```bash
[12/Aug/2024 23:13:28] "GET / HTTP/1.1" 200 10664
```

如果要使用与默认8000不同的端口，在命令行上指定端口号，例如：

```bash
python manage.py runserver 5000
```



