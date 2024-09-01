# ensp云连接pc



### **<1>添加“云”与”交换机“**

（1）拓扑：

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/788fbe59fbe1187695d00b9025ce894e-image-20240424140325817-9d0ea3.png" alt="image-20240424140325817" style="zoom:50%;" />

（2）云配置

连线：使用Auto线

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/beb7dd937c2ce648841b460f1ffc0b49-image-20240424140332647-7363f5.png" alt="image-20240424140332647" style="zoom:67%;" />

添加顺序：

1>>绑定信息--选择udp网卡，增加

2>>绑定信息--选择virtualBox 网卡，增加

3>>端口映射设置--入1 出2

4>>端口映射设置--入2 出1



### **云没有virtualbox网卡，解决办法**

<1>如果云无法获取virtualbox网卡，请卸载重装winpcap

![image-20240424140357545](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/1af6fe9269c443182c814a0c2df569ed-image-20240424140357545-6defde.png)

<2>如卸载重装winpacp报错

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/3f423c18f35b6494a7ddae3cdee68e2e-image-20240424140404097-3a1536.png" alt="image-20240424140404097" style="zoom:50%;" />

解决方式：

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/fbfb91de5440c6bafed8fe3f3de94c09-image-20240424140412284-18264a.png" alt="image-20240424140412284" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/9ed889691d697e9771beb21f5c22089f-image-20240424140415173-5504be.png" alt="image-20240424140415173" style="zoom:50%;" />

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/7ff233a6a35cc54d8378c2bd3968b830-image-20240424140419261-49c46f.png" alt="image-20240424140419261" style="zoom:50%;" />