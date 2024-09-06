# WLAN 基础配置



```
#
wlan service-template 1
ssid MEIYANGqui
vlan 400
akm mode psk
preshared-key pass-phrase simple MEIYANG666888
cipher-suite ccmp
security-ie rsn
service-template enable
#
wlan service-template 2
ssid MEIYANG-ZB
vlan 300
akm mode psk
preshared-key pass-phrase simple my666888
cipher-suite ccmp
security-ie rsn
service-template enable
#
wlan auto-ap enable 
wlan auto-persistent enable 
#
wlan ap-group default-group 
vlan 1 #自动生成
ap-model WAP722S-W2  #AP型号
radio 1 
radio enable 
service-template 1 
service-template 2 
radi 2 
radio enable 
service-template 1 
service-template 2 
gigabitethernet 1
#
```

**删除SSID**

```
[H3C-AC]undo wlan service-template 4        #现有的ssid调整，需要删除，无法删除服务模板，被映射到了radio
Can't remove the service template. It has been mapped to a radio.
```

![image-20240424093524365](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/30df6de6801210a31865bab0f6f0c30c-image-20240424093524365-1eff93.png)

```
wlan ap-group default-group            #进入wlan ap的模板
ap-model WAP722S-W2                #选择实际ap型号
```

![image-20240424093535699](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/24/122e12ed4f6948289f7b5616469cb903-image-20240424093535699-54dbc6.png)

```
radio 1                        #选择绑定的radio
```

> [H3C-AC-wlan-ap-group-default-group-ap-model-WAP722S-W2]radio 2

```
undo service-template 4                #取消绑定
```

> [H3C-AC-wlan-ap-group-default-group-ap-model-WAP722S-W2-radio-2]undo service-template 3

```
undo wlan service-template 4            #再次删除即可
```

> [H3C-AC]undo wlan service-template 4