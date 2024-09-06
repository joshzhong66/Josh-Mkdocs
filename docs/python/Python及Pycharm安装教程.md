# Python及Pycharm安装教程



## 一、前言

### 1.Python

​		目前，Python有两个版本，一个是2.x版，一个是3.x版，这两个版本是不兼容的。由于3.x版越来越普及，我们的教程将以最新的Python 3.9.7版本为基础。（但反编译包uncompyle6不支持3.9.0以上版本）

### 2.PyCharm

​		PyCharm 是JetBrains公司研发，用于开发 Python 的 IDE 开发工具。其带有一整套可以帮助用户在使用Python语言开发时提高其效率的工具，比如调试、语法高亮、项目管理、代码跳转、智能提示、自动完成、单元测试、版本控制。此外，该IDE提供了一些高级功能，以用于支持Django框架下的专业Web开发。



## 二、Python安装

### 1.Python官网下载

#### 1.1 Python官网

​		英文版：[https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)

​		中文版：[https://python.p2hp.com/downloads/windows/index.html](https://python.p2hp.com/downloads/windows/index.html)

​		在下载页面可以看到很多不同版本的下载链接。其中，标记 x86 的为 32 位安装包，x86-64 为 64 位安装包。executable installer为完整的安装包，下载完即可安装；web-based installer 体积更小，但安装时仍需联网下载其他部分。一般网络不好时选择 executable installer，以保证安装过程不会中断。

![image-20240510110725295](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/0046c7235814bd8381618ce94edeacbb-image-20240510110725295-56a140.png)

#### 1.2 Python版本简介

​		python 包括 python2、python3 两个大版本，其中 python3 改进了 python2 的一些不足，但由于以前很多应用是用 python2 开发的，维护这些应用还需用到 python2，故 python2 尚未被完全淘汰。

#### 1.3 安装Python

打开安装包所在文件夹，双击开始安装：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/ba3e5bf778a282728be9703dc9681a19-image-20240510110833759-a38f61.png" alt="image-20240510110833759" style="zoom:50%;" />

勾选 “Add Python to PATH” 复选框，点击 “Customize installaion”：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/ebbbb0239f10cda9dbe97ed96d1fd1ac-image-20240510110809092-9cbbf8.png" alt="image-20240510110809092" style="zoom:50%;" />

保持默认设置，点击 “next”：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/4641698809036323161fe7fdc2b2c061-image-20240510110858507-b72033.png" alt="image-20240510110858507" style="zoom:50%;" />

 点击 “Install” 开始安装：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/667d62b82d30cc62f5bd7ae97c3ac4b2-image-20240510111319251-a03e14.png" alt="image-20240510111319251" style="zoom:50%;" />

<img src="C:\Users\Jerion\AppData\Roaming\Typora\typora-user-images\image-20240510111344645.png" alt="image-20240510111344645" style="zoom:50%;" />

### 2.配置环境变量

​		注：如果在安装Python时已勾选添加环境变量，则无需操作此步骤。

​		命令行在查找可执行文件时，先在当前目录找，如果找不到，就会在 Path 变量指定的目录找。因此，将可执行文件的路径添加到 Path 中，可以保证在任意路径都能执行程序。

（1）右击此电脑 -> 单击属性：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/21edd4255df62872be540a6ac77fc1be-image-20240510111438032-0ce5a2.png" alt="image-20240510111438032" style="zoom:33%;" />

（2）点击"高级系统设置"，点击 “环境变量”（有的电脑可能要手动选择上面的 “高级” 选项卡），单击选中"Path" -> 单击编辑：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/c32e0efb3f76c68ce1b0e1f2d2a2c38f-image-20240510111507983-811857.png" alt="image-20240510111507983" style="zoom:50%;" />

（3）打开 python 的安装路径（安装时设置的，可能跟笔者不同） -> 点击地址栏 -> “Ctrl+C” 复制路径：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/008bf8fd9785da471ef11281fc1c7e59-image-20240510111518824-5ff91c.png" alt="image-20240510111518824" style="zoom:50%;" />

（4）在 “编辑环境变量” 选项卡单击新建，粘贴路径 -> 点击确定：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/e9312d5c865fe391e5aa22820d31936e-image-20240510111531634-19eb79.png" alt="image-20240510111531634" style="zoom:33%;" />

**注意事项：**

有时候配置了环境变量，在命令行输入 “python” 会弹出微软商店。解决办法是将 python 的路径上移到微软商店前面：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/9ed760627349409aaf1a8324fcbfb8c2-image-20240510111557480-79fb63.png" alt="image-20240510111557480" style="zoom:50%;" />

- 从以上问题可以看到，命令行在前面找到了可运行的程序后，会忽略后面的项。
- 在环境变量窗口，我们可以看到 “用户变量” 与 “系统变量” 两种变量，两种变量的区别是：用户变量是对单一用户生效，系统变量对所有用户生效。如果电脑设置了多个用户，设置用户变量会使得安装软件只能供单一用户使用，设置系统变量则所有用户都能使用。

**pip环境变量配置**

python常常用到 pip 工具安装第三方库（模块），pip 工具通常是随着 python 一起安装好的，但是使用 pip 安装库时，可能会出现下面的错误提示：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/ee2bb43fb621db70162c7a3ff11b3ebc-image-20240510111800060-e1c396.png" alt="image-20240510111800060" style="zoom:50%;" />

pip需要配置环境变量：

这同样可以通过配置环境变量解决，配置步骤是完全一致的。要注意的是，pip 工具在 python 目录的 Scripts 文件夹下：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/accc8e8e61c11e78b6747689bb31637d-image-20240510111923166-12bab3.png" alt="image-20240510111923166" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/70bbe6b9f758325d046a2b744b271d7c-image-20240510111938445-d1d3a3.png" alt="image-20240510111938445" style="zoom:50%;" />

另外，在使用 pip 安装库时，可能会提示 pip 版本太旧了，此时只需执行提示命令即可更新 pip：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/7105525161158aed58bb38ad221e4835-image-20240510112001966-e90db0.png" alt="image-20240510112001966" style="zoom:50%;" />

### **3.运行Python**

安装成功后，打开命令提示符窗口（win+R,在输入cmd回车），敲入python后，会出现下面的情况：

![image-20240510112105899](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/8aded804d1901c9145c4c06cb0efc65e-image-20240510112105899-e3c061.png)

出现这个表示python安装成功。看到提示符 **>>>** 就表示我们已经在Python交互式环境中了，可以输入任何Python代码，回车后会立刻得到执行结果。现在，输入exit()并回车，就可以退出Python交互式环境（或直接关掉命令行窗口也可以)。 



## 三、开发工具PyCharm安装

### **1.PyCharm官网下载**

#### 1.1 PyCharm官网

​		[https://www.jetbrains.com/zh-cn/pycharm/download/?section=windows](https://www.jetbrains.com/zh-cn/pycharm/download/?section=windows)

​		下方为PyCharm的官网及下载页面，Pycharm提供了两个版本的下载，一个是专业版Professional（付费），另一个是社区版Community（免费）。用来学习只需要下载社区版即可。苹果电脑用户根据电脑芯片自行选择。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/3d9ae8ac01a3277a65777855879e7c89-image-20240510112259599-8b7ddb.png" alt="image-20240510112259599" style="zoom: 33%;" />

#### 1.2 安装PyCharm

打开安装包所在文件夹，双击开始安装：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/0b64d6cb6803ca9b726582a026bbcf6a-image-20240510112328070-aab888.png" alt="image-20240510112328070" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/5b9a9f87a4ae4d4b91aa9a8489efcdad-image-20240510112343479-9c2001.png" alt="image-20240510112343479" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/57af4ce32d78c065847c1437f3eb9b30-image-20240510112351824-30a2e9.png" alt="image-20240510112351824" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/19783d584b83b697f3b8a76d83591a5d-image-20240510112402418-97337c.png" alt="image-20240510112402418" style="zoom:33%;" />

截止到此时，PyCharm安装完成。

### **2.PyCharm的使用**

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/2c203be2f8f68711f673afd2e42fa528-image-20240510112429819-c0d700.png" alt="image-20240510112429819" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/bc24b083f1fb5e81806e901007960294-image-20240510112442277-965d89.png" alt="image-20240510112442277" style="zoom:33%;" />

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/31fbaa121080d98831212b3ce0ca5de9-image-20240510112458714-7ad144.png" alt="image-20240510112458714" style="zoom: 33%;" />

​		接下来我们会遇到一个虚拟环境的概念，我先给大家阐述一下关于虚拟环境的作用：
​		虚拟环境，在Python中是相当重要的存在，它起到了项目隔离的作用。前边我们安装的Python，相当于在本地安装了一个Python的全局环境，在任何地方都可以使用到这个Python的全局环境。
​		但是大家有没有想过这个问题：我同时接手了**Demo A**和**Demo B**两个项目，两个项目同时用到了同一个**模块X**，但是Demo A要求使用模块X的1.0版本，Demo B要求使用模块X的2.0版本。全局环境中只能安装一个模块的一个版本，那么就遇到问题了，怎样才能让两个项目同时正常运行呢？
​		这时虚拟环境就能发挥作用了，我使用全局的Python环境分别创建两个虚拟环境给Demo A和Demo B。相当于两个项目分别有自己的环境，这个时候我把各自需要的模块安装进各自的虚拟环境，就成功的实现了项目隔离。假如这个项目我不需要了，直接删除就可以（一个虚拟环境相当于一个拥有Python环境的文件夹，可以自行指定路径）。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/6687d3bd7e95b456230d63a880885aa7-image-20240510112529875-acc7be.png" alt="image-20240510112529875" style="zoom:50%;" />

截止到此时，一个Python项目在PyCharm中就创建完成。

### **3.PyCharm文件的创建**

（1）从刚才创建的项目上右键，点击New，选择Python File，即可创建一个Python文件：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/f489327f75772ff35c4c53c96c8172ad-image-20240510112609271-bee4b1.png" alt="image-20240510112609271" style="zoom:50%;" />

（2）接下来给这个文件起一个名字，比如说hello_world，回车即可：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/09dc0bc7afb84d03f4bee86f0b3ba726-image-20240510112618247-9df986.png" alt="image-20240510112618247" style="zoom:50%;" />

（3）从创建好的Python文件中编写代码，然后右键选择Run文件名，即可运行此代码文件：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/05/10/51e84cbdd5e1e5ecfbfc592f41644d7a-image-20240510112624369-08984f.png" alt="image-20240510112624369" style="zoom:50%;" />

这便是如何在PyCharm中创建项目、编写及运行代码。
