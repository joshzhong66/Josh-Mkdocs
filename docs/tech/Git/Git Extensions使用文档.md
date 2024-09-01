# Git Extensions使用文档

 

## 一、 菜单栏—工具—设置

查看基本设置是否有报错：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/ae4e58b22000a5c95aa5c7c59e9162e4-wps1-96600f.jpg" alt="img" style="zoom: 50%;" />

 确认SSH设置：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/680ae70e371df02b66fcb770167a7b15-image-20240830143833294-8eebf3.png" alt="image-20240830143833294" style="zoom: 50%;" />

若为第一次使用Git，需生成ssh-key：

- 菜单栏—工具—Git base命令行；

- ssh-keygen -t rsa -C"公司邮箱地址"；

- 且会提示id_rsa.pub文件存放路径。

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/ffccc1654fc895e88773693dc5b9c1a4-wps3-72cff9.jpg" alt="img" style="zoom:67%;" />

 

## 二、 登入Gitlab Web端

http://gitlab16.com:8999/	（Gitlab只支持管理员建立账号）

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/d5f15c95d85e2241b605110fa26e8f2d-image-20240830143955547-5d6514.png" alt="image-20240830143955547" style="zoom:50%;" />



<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/6a54375032783bf7eab0c02060f383be-image-20240830144004334-eb2912.png" alt="image-20240830144004334" style="zoom:50%;" />

进入上步骤生成的id_rsa.pub文件存放路径，将id_rsa.pub文件内容复制并黏贴至“Profile Setting”—“SSH Keys”—“ADD SSH KEY”。

Gitlab Web端进入Projects，获取Project ssh地址：

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/8503bcb6c8c37e455921fc2725f53ee6-wps6-fa9907.jpg" alt="img" style="zoom: 50%;" />

 

## 三、 在Git Extensions 选择克隆版本库

<img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/6020d0cdd5da4e15a34a5967171861b8-image-20240830144136461-8b0772.png" alt="image-20240830144136461" style="zoom:50%;" />

 <img src="https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/6e54d481b61a8ccbcde8616616493ff0-image-20240830144143361-3e5307.png" alt="image-20240830144143361" style="zoom:67%;" />



## 四、 提交

1区是对应文件夹下的所有文件，选择你需要上传的文件，双击它进入3区！

（注意：1区只显示最新修改的文件，未修改的文件不会显示出来）

2区是显示文本文件的内容。

3区是选择好后需要上传的文件，双击它取消选择

4区是填写操作原因

文件选择完毕之后，填写原因.然后点击提交

![img](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/6635c3212eb6339a975295f86f8c0893-wps9-a5b2b1.jpg) 



## 五、 拉取

![img](https://raw.githubusercontent.com/zyx3721/Picbed/main/blog-images/2024/08/30/14a5956f3e28be3a72da1d4d87f112af-wps10-35752a.jpg) 