# arp



> Core_Sw ARP/6/DUPIFIP: Duplicate address 10.0.4.1 on interface Vlan-interface70, sourced from 4044-fd9f-46fd
>
> #日志信息
>
> disp mac-address 7460-faec-46b1   ##查找mac地址来源，是在接口8下，查看lldp发现对端是ac控制器，vlan id 70为无线的网段；

MAC Address      VLAN ID    State            Port/Nickname            Aging

7460-faec-46b1   70         Learned          GE1/0/8                  Y

> [Core_Sw]mac-address blackhole 7460-faec-46b1 vlan 70  #添加黑洞mac，所有发送或接收该mac的流量全部丢弃
>
> mac-address blackhole fe80-6510-dea1 vlan 70



> dhcp server forbidden-ip 10.0.4.181  #禁止分配的ip
>
> 在查找这个问题的时候，发现荣耀手机连接WiFi时，使用的是随机mac地址，上网搜寻了下相关知识：
>
> 有人利用WiFi探针收集用户个人信息问题，手默认开启MAC地址随机化功能，能有效的防范WiFi探针，MAC地址随机化是指手机WiFi开启后，每次在扫描周围WiFi热点时携带的MAC地址都是随机生成的，就算被WiFi探针获取也无法做正确的大数据匹配。WiFi探针获取的手机MAC地址并非你手机的真实MAC地址，这样WiFi探针就无法收集用户的隐私信息。



> arp user-ip-conflict record enable  #启ARP记录终端用户间IP地址冲突功能
>
> disp arp user-ip-conflict record    #显示ARP记录的终端用户间IP地址冲突表项信息



> arp check log enable #开启ARP日志信息功能
>
> arp ip-conflict log prompt #开启源IP地址冲突提示功能