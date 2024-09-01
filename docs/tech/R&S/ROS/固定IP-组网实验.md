# 固定IP-组网实验



#### **实验拓扑**

![image-20240424160115968](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/86d153971bf04f5ee24930035e96b240-image-20240424160115968-76e9f5.png)

Interface->修改ether1 ether2 的名称，区分内外网

![image-20240424160206974](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/9c15f8b45badb935e26f70cc68460099-image-20240424160206974-4be1c4.png)

打开 IP -> Adresses  ，增加地址及接口

![image-20240424160214015](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/e25bc29859883135acbe6cb22404851a-image-20240424160214015-d755b4.png)

![image-20240424160217869](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/f82009ba2908d14ee60e56fda02f0d7a-image-20240424160217869-8c36f8.png)

增加IP pool地址池，IP ->  Pool

![image-20240424160223995](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/18c3858aa8368020f4124aaccbf4dee3-image-20240424160223995-5c432b.png)

建立DHCP Server（服务端）给你的电脑跟其它客户机进行自动分配IP地址。

![image-20240424160230466](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/2117d1b2c4760bedbdfe1b0eeb5c548f-image-20240424160230466-705da9.png)

**伪装**

![image-20240424160241472](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/f08afd008f5dc5b82fadf6294a5c1bbc-image-20240424160241472-04bfc5.png)

![image-20240424160244087](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/646ec6eda1d294a41010f44b9b667938-image-20240424160244087-1ef23d.png)





博客：https://blog.csdn.net/awfiihmmmm/article/details/106029920