# 陌生iP欲登入ROS，限制在30秒內连续登入5次



陌生iP欲登入ROS，在30秒內连续登入5次（不管是否登入成功與否），

于第六次登入,对方的IP就被拉黑無法再嘗試( Address-list 裏面拉黑1天).

```
/ip firewall filter
add action=drop chain=input comment="\A2b\A2c\A2d\A2e\A2f\A2g\A2h 1 \A2h\A2g\A2f\A2e\A2d\A2c\A2b" disabled=no dst-port=21,22,23,8291 protocol=tcp src-address-list=login_error_ip
add action=add-src-to-address-list address-list=login_error_ip address-list-timeout=1d chain=input comment="\A2b\A2c\A2d\A2e\A2f\A2g\A2h 2 \A2h\A2g\A2f\A2e\A2d\A2c\A2b" connection-state=new disabled=no dst-port=21,22,23,8291 protocol=tcp 
src-address-list=ros_service_login5
add action=add-src-to-address-list address-list=ros_service_login5 address-list-timeout=1d30s chain=input comment="\A2b\A2c\A2d\A2e\A2f\A2g\A2h 3 \A2h\A2g\A2f\A2e\A2d\A2c\A2b" connection-state=new disabled=no dst-port=21,22,23,8291 \
protocol=tcp src-address-list=ros_service_login4
add action=add-src-to-address-list address-list=ros_service_login4 address-list-timeout=30s chain=input comment="\A2b\A2c\A2d\A2e\A2f\A2g\A2h 4 \A2h\A2g\A2f\A2e\A2d\A2c\A2b" connection-state=new disabled=no dst-port=21,22,23,8291 protocol=\
tcp src-address-list=ros_service_login3
add action=add-src-to-address-list address-list=ros_service_login3 address-list-timeout=30s chain=input comment="\A2b\A2c\A2d\A2e\A2f\A2g\A2h 5 \A2h\A2g\A2f\A2e\A2d\A2c\A2b" connection-state=new disabled=no dst-port=21,22,23,8291 protocol=\
tcp src-address-list=ros_service_login2
add action=add-src-to-address-list address-list=ros_service_login2 address-list-timeout=30s
```

实际遭遇登录：

![image-20240424160902346](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/9d41a4335a29591fb29316929e5915d2-image-20240424160902346-cf7ffe.png)