![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710947059788-3a0776f0-05e9-4964-887b-a51083a47b19.png#averageHue=%23f7f6f6&clientId=u4941475d-f3aa-4&from=paste&height=718&id=u11f26fc8&originHeight=897&originWidth=777&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=33220&status=done&style=none&taskId=u25e5dc79-822d-4477-9611-d73d45ffd5e&title=&width=621.6)

待删除
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710949008100-7fecd6bd-fba4-43c0-b8cb-24844ff06835.png#averageHue=%23fbfafa&clientId=u4941475d-f3aa-4&from=paste&height=319&id=uc153b6ce&originHeight=399&originWidth=411&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=23038&status=done&style=none&taskId=u21733425-f7c7-4295-97f7-cbd92173895&title=&width=328.8)


配置网卡临时IP，用于访问
```python
ifconfig eth0 10.22.51.64 netmask 255.255.255.0
route add default gw 10.22.51.254 eth0
nano /etc/resolv.conf
nameserver 223.5.5.5
```


引导报错
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710994575900-132869b0-3d5e-4a5a-abc4-649e7527e27d.png#averageHue=%230c0c0c&clientId=uafd8947f-c889-4&from=paste&height=93&id=u79a9065c&originHeight=116&originWidth=395&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=16756&status=done&style=none&taskId=ub68efab2-4b3a-4855-a1a4-b91ddfd3f6b&title=&width=316)
设置STAT


不配置DNS编译引导会报错
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710994519117-b0378664-6733-4211-9ac4-fe3ac36a9696.png#averageHue=%232c2c2b&clientId=uafd8947f-c889-4&from=paste&height=420&id=u8d938340&originHeight=525&originWidth=476&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=40430&status=done&style=none&taskId=uce140592-3d35-4d44-8359-d304e8800f4&title=&width=380.8)
![d0b7b0a91aa7c02f3f0f493b4c50944.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710994534596-f5dfd23e-abe6-4578-a1e8-477b97bafe67.png#averageHue=%23272727&clientId=uafd8947f-c889-4&from=paste&height=134&id=u8aeda6e3&originHeight=168&originWidth=367&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=3131&status=done&style=none&taskId=ued56fa1a-24c9-4d60-a734-c77659392d7&title=&width=293.6)
![1a15062fad1803f3a781bdc13336f7b.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710994547984-51b020c9-d9e1-4372-b229-122c550e9ccb.png#averageHue=%23d9dbd2&clientId=uafd8947f-c889-4&from=paste&height=287&id=u7845a9da&originHeight=359&originWidth=830&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=23881&status=done&style=none&taskId=u5e66ef39-fa71-4ff4-9c69-29308144598&title=&width=664)

编译完成，点击启动，加载的界面
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1710994698530-dba90a4b-61e5-43f5-983c-aa111bcebfd8.png#averageHue=%232f2f2c&clientId=uafd8947f-c889-4&from=paste&height=427&id=u06f6d961&originHeight=534&originWidth=1293&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=42174&status=done&style=none&taskId=u6c55b2ca-0439-441b-bcad-03dad14e3e7&title=&width=1034.4)
