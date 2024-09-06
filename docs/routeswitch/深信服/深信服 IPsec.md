成都设备： H3C GR3200 路由器地址：192.168.3.1，内网网段：192.168.3.0/24
厦门设备： sangfor vpn sangfor vpn旁挂核心交换机，设备IP：10.0.0.43
厦门出口为固定IP地址：110.80.44.42 深圳、成都为拨号，出口为动态IP，sangfor使用野蛮模式配置。
厦门配置如下：
[https://10.0.0.43:4430/](https://10.0.0.43:4430/)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724414431-944ac698-976a-4429-8c51-d05edd87f935.png#averageHue=%23e6eef8&clientId=ucc3ed422-b3fe-4&from=paste&id=u4c192ce0&originHeight=756&originWidth=641&originalType=url&ratio=1.25&rotation=0&showTitle=false&size=34083&status=done&style=none&taskId=u5d432869-5dea-49a1-949c-3c846f47b08&title=)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724435530-1f9f76b6-3660-4836-944c-e9b9a659d43e.png#averageHue=%23dde8f5&clientId=ucc3ed422-b3fe-4&from=paste&height=222&id=u270ec6aa&originHeight=277&originWidth=1716&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=16634&status=done&style=none&taskId=ua4fc8256-6699-43d8-99ae-a719dee18db&title=&width=1372.8)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724440962-97bbf498-d5cf-402c-b234-b5225a719fb2.png#averageHue=%23f3f7fb&clientId=ucc3ed422-b3fe-4&from=paste&height=391&id=u85b926b5&originHeight=489&originWidth=360&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=13009&status=done&style=none&taskId=ubffd7cc9-6587-4d3a-b265-482ee9c3bd7&title=&width=288)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724445151-6eeda459-1025-4dd9-b98b-a4f3e9a0b2e8.png#averageHue=%23f3f7fb&clientId=ucc3ed422-b3fe-4&from=paste&height=391&id=u1783301b&originHeight=489&originWidth=360&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=13059&status=done&style=none&taskId=u0fa1ffe1-6720-40e5-a6c6-ba1cdcdd96b&title=&width=288)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724449933-c4d46e68-e026-4c58-86fb-faee24c1df58.png#averageHue=%23c7ebe0&clientId=ucc3ed422-b3fe-4&from=paste&height=404&id=u916cab9a&originHeight=505&originWidth=1708&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=28338&status=done&style=none&taskId=u402fd773-f240-40c0-b35a-29859e2c892&title=&width=1366.4)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724454379-9ef8f78e-caf3-4140-a8cf-6bf6c6dbb4a0.png#averageHue=%23f3f7fa&clientId=ucc3ed422-b3fe-4&from=paste&height=444&id=ua313906e&originHeight=555&originWidth=894&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=28041&status=done&style=none&taskId=uf1d48780-6997-40a7-b9b9-325d355d7cf&title=&width=715.2)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724460810-03f0a128-a1c9-4c45-ba37-0acb5b0b68c6.png#averageHue=%23f3f7fb&clientId=ucc3ed422-b3fe-4&from=paste&height=448&id=ubce29762&originHeight=560&originWidth=900&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=23501&status=done&style=none&taskId=u2f31f84d-09a7-49bb-bf14-305e9a97142&title=&width=720)
```python
核心交换机配置：
192.168.1.0/24 Static 60 0 10.0.0.43 Vlan10 #深圳
192.168.3.0/24 Static 60 0 10.0.0.43 Vlan10 #成都
成都路由器配置如下：
```
静态路由
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724482898-64abaefa-d683-4235-9412-460f84fe07c8.png#averageHue=%23bebab4&clientId=ucc3ed422-b3fe-4&from=paste&height=412&id=uded78271&originHeight=515&originWidth=1141&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=43039&status=done&style=none&taskId=u7c9e6217-597e-4d56-8e96-65219de067e&title=&width=912.8)
虚接口
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724488203-0ed5cc95-9c7e-4fa5-a715-d35944a7239d.png#averageHue=%23bbbbbb&clientId=ucc3ed422-b3fe-4&from=paste&height=312&id=ub703457e&originHeight=390&originWidth=1109&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=36526&status=done&style=none&taskId=u98bcede1-9379-4afa-8b22-0b2cd3f3962&title=&width=887.2)
IKE安全提议
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724492522-9da922e1-18b9-43e4-9831-1992eae6a4c8.png#averageHue=%23b9b7b4&clientId=ucc3ed422-b3fe-4&from=paste&height=445&id=ue72dbf25&originHeight=556&originWidth=1191&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=53559&status=done&style=none&taskId=u47467b27-f27e-4204-a765-de06f89230f&title=&width=952.8)
IKE对等体
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724498573-896aee12-88d2-418f-a39f-a7e654101a95.png#averageHue=%23c2c0bd&clientId=ucc3ed422-b3fe-4&from=paste&height=623&id=u981132b2&originHeight=779&originWidth=1178&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=83633&status=done&style=none&taskId=u15ea47ff-bb78-4f62-bc7a-a58bac9d5d7&title=&width=942.4)
IPSec安全提议
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724503209-7274b55f-2f9d-4780-b777-2b45febebe0f.png#averageHue=%23b9b7b4&clientId=ucc3ed422-b3fe-4&from=paste&height=486&id=uaeb47376&originHeight=607&originWidth=1265&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=55421&status=done&style=none&taskId=u016892a8-05de-4595-a2e3-b57339bef5f&title=&width=1012)
IPsec安全策略
![image.png](https://cdn.nlark.com/yuque/0/2024/png/40407567/1711724507165-0134b0b5-487c-4b5d-9793-8fb155fb5020.png#averageHue=%23c8c6c2&clientId=ucc3ed422-b3fe-4&from=paste&height=548&id=uc7eb2c24&originHeight=685&originWidth=1229&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=85913&status=done&style=none&taskId=u0467eaee-619c-4770-ae41-8f7dfa0147f&title=&width=983.2)
