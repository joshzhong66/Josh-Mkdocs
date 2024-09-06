# 建立PPTP VPN服务器及创建用户连接VPN



#### **第一步、先建立IP地址池**

![image-20240424160548477](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/5c823496e64989a71ddd19a8d81b11d6-image-20240424160548477-10dd5a.png)

地址池名称及地址范围

![image-20240424160555289](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/ffd70e5af56b83a3ec3461e9b3e4f99f-image-20240424160555289-95509e.png)

#### **第二步、在PPP视图下建立一个配置文件**

![image-20240424160602955](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/198be4be02eab5a8d9a07ac1a65d2205-image-20240424160602955-e5bea7.png)

![image-20240424160606127](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/6bc9624a973b4b3c1baa30113ffd931f-image-20240424160606127-b75dbc.png)

![image-20240424160609801](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/e3b91182fa93c3b47232ccb0a09281f9-image-20240424160609801-1dfe60.png)

![image-20240424160613224](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/e29281a5ba1752fae44009f0748ea05a-image-20240424160613224-35db39.png)

限速

![image-20240424160622381](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/d5d72071927b584bb978bd14b0b4d377-image-20240424160622381-238eae.png)

#### **第三步、启用PPP server**

![image-20240424160628474](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/158ca2a24f5a36c1fd9ef8ee2bbab11b-image-20240424160628474-3a04f8.png)

#### **第四步、建立完成，创建PPTP账号**

![image-20240424160639153](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/42add294016e316831af9cef6c4efcd7-image-20240424160639153-35128a.png)

通过此账号拨号

![image-20240424160648588](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/981c5ff2af6d352a8af95cefd87bee3f-image-20240424160648588-7d5f70.png)

#### **第五、连接VPN**

输入名称随意，公网IP ，协议PPTP，用户名密码

![image-20240424160659479](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/81651f04ae35865121fd2096c387a0dc-image-20240424160659479-6c92fb.png)

如果要使VPN能上网，需要将VPN的地址段加入伪装。