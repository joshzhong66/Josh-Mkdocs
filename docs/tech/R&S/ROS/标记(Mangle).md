# 标记(Mangle)



1、流量标记主要用于直观的看到整体的流量情况，方便做限速。

#### **标记  在IP-Filrewall-Mangle-  +  添加**

![image-20240424155618405](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/4302a788c180da29666bbf0f77869eae-image-20240424155618405-bda360.png)

#### **标记下载流量**

Prerouting表示路由之前，选择：prerouting，接口：入口（lan）

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/63e0d761cdd6778b312a8b298a1e5a36-image-20240424155606919-79799a.png" alt="image-20240424155606919" style="zoom:50%;" />

Action（动作）：mark packt

passthrough表示：标记之后是否放行，勾选表示放行

new packet mark(新数据包标记)：down-pack

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/ad9f59bb94d2d2cb13d711af9bcfabde-image-20240424155651053-58b7eb.png" alt="image-20240424155651053" style="zoom:50%;" />

Comment（备注）：下载流量

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/80f3f2dbf6a39ed0219f6351e203b2c0-image-20240424155658739-b07044.png" alt="image-20240424155658739" style="zoom:50%;" />

添加完成

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/eb60d7063f303aaee40960e90a8fa337-image-20240424155705371-800826.png" alt="image-20240424155705371" style="zoom:50%;" />

####  **标记上传流量**

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/45840dcda9bf761c7f526a354a7536a8-image-20240424155723136-08407d.png" alt="image-20240424155723136" style="zoom:50%;" />

prerouting名称与下载相同会报错

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/10085c86fe3458ab8c1806e69cbd3725-image-20240424155729789-27cb4a.png" alt="image-20240424155729789" style="zoom:50%;" />

选择forward

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/f08423972b3bdbb772c6fff03f938bb5-image-20240424155735808-b4c06e.png" alt="image-20240424155735808" style="zoom:50%;" />

上传流量，添加备注

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/dcef41746918bf4589bb7181ab2b6ae8-image-20240424155751148-2bb913.png" alt="image-20240424155751148" style="zoom:50%;" />

完成

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/fea14acc68146d5385f5e59cef3b576e-image-20240424155759883-d0f988.png" alt="image-20240424155759883" style="zoom:50%;" />

#### **标记一个80端口的流量**

**协议TCP，目标端口80**

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/0a57de1f41e5f53b530bbda8c6f38121-image-20240424155826179-6a1a82.png" alt="image-20240424155826179" style="zoom:50%;" />

mark connection(先标记链接)

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/507e3a39923328027494ce3f3d693337-image-20240424155838051-73a45e.png" alt="image-20240424155838051" style="zoom:50%;" />

链接标记完，再标记包，使用+ 新建，选择web conn

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/e8507fffa381b48ef65817e3a0eeab82-image-20240424155841506-65c42e.png" alt="image-20240424155841506" style="zoom:50%;" />

mark peaket，取名web-paek

取消勾选passthough代表流量不往下传递

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/4419210349dffbf2ca987c34a872b119-image-20240424155857071-67dc64.png" alt="image-20240424155857071" style="zoom:50%;" />

创建完成

<img src="https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/247ba1b98839e1d684bab38a1255d5dc-image-20240424155903569-c2ce7c.png" alt="image-20240424155903569" style="zoom:50%;" />

打开网页，

看是否有流量显示。