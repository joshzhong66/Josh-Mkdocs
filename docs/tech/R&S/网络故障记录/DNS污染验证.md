# DNS污染验证



获取dig和nc工具

安装dig

```
yum -y install bind-utils
```

安装nc

```
yum install -y nc
```

验证DNS污染

```
# 通过 114 解析 google 域名
dig google.com @114.114.114.114 +short


# 检测 IP 是否属于 Google
# 例如 我获取到的是 142.251.42.238
[root@k8s-master-30 ~]# echo -e 'begin\n142.251.42.238\nend' | nc bgp.tools 43
15169   | 142.251.42.238   | 142.251.42.0/24     | US | ARIN     | 2000-03-30 | Google LLC

如果返回的运营商名非google llc，则可判断DNS被污染
```



参考

https://wener.me/notes/howto/network/dns-prevent-spoofing