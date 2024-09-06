# Switch 配置 ntp server



NTP概述：

​		NTP为UDP协议，端口为123，时间配置模式分none和ntp，none缺陷设备运行一段时间，时间会对不上，而配置ntp模式，将配置保存设备，即使断电也不影响开机时间，让设备与时间服务器进行自动同步。



none配置（经常需要手动修改H3C交换机的时间，不建议配置）：

> clock protocol none			#时间协议
>
> clock timezone beijing add 8		#默认采用utc时区，北京时间为utc+8
>
> clock datetime 11:55:40 2022/05/25	#实际时间



ntp server配置，使用核心交换机作为ntp服务器（192.168.100.1），需要服务器交换机可以联网与公共时间服务器进行通信，而ntp server与客户端必须要ping通。

阿里云公共时间服务器有这些：

> 120.25.108.11、182.92.12.11、203.107.6.88、120.25.115.20



NTP配置：

> ntp-service enable 				#开启NTP服务
>
> clock protocol ntp 				#使用Nt协议
>
> clock timezone beijing add 8   			#默认采用utc时区，北京时间为utc+8
>
> ntp-service unicast-server 120.25.108.11	#配置ntp时间服务器
>
> display ntp-service status 			#查看ntp状态
>
> display ntp-service sessions 			#查看ntp会话信息



注意：

可以通过多次执行ntp-service unicast-peer命令或ntp-service ipv6 unicast-peer命令为设备指定多个被动对等体。

ntp client只需要将unicast-server指向192.168.100.1即可。



内网其它的交换机作为ntp-client，参考如下配置:

> system-view
>
> clock timezone beijing add 8
>
> clock protocol ntp
>
> ntp-service enable
>
> ntp-service unicast-server 192.168.100.1
>
> save force

​				