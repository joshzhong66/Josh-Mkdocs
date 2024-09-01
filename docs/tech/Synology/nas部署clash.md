### （1）安装启动docker
套件中心安装docker启动
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307981914-f84800fc-bbaf-4d35-b685-6c00743d08c1.png#averageHue=%23fdfcfa&id=vivMX&originHeight=585&originWidth=1077&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307982198-ad47270a-99d4-4306-9d61-dc545dd911ef.png#averageHue=%23fefdfd&id=PF8QG&originHeight=230&originWidth=450&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

### （2）安装clash & yacd
开启nas的ssh，通过命令访问：
ssh admin@192.168.3.79 -p 22
登录后，通过命令获取root权限：
sudo -i
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307982470-504caa42-83d2-4243-8fcf-12078a20d101.png#averageHue=%23050302&id=U8cwm&originHeight=48&originWidth=256&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)


<1>安装clash：
docker pull dreamacro/clash

<2>安装yacd：
docker pull haishanh/yacd
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307982762-ca098d63-8505-4319-91e5-2c444839bec8.png#averageHue=%230b0805&id=rxaBN&originHeight=408&originWidth=569&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
安装完成后，在web后台处显示如下：
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307983068-62a40e13-6032-4e8b-a97a-960e33df64fb.png#averageHue=%23fefefe&id=ERO2B&originHeight=314&originWidth=723&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

### （3）Clash配置
**<1>配置clash的config启动文件及目录**
在docker文件夹下创建clash文件夹用于存放clash的config配置文件
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307983359-0f199f38-ecf0-4e2a-8b0a-cc954dcfb795.png#averageHue=%23e6c898&id=mEg8Z&originHeight=188&originWidth=461&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
**<2>clash 的config.yaml文件获取及添加、更新**
如新设备、更换机场，需要更新clash.yaml按如下操作即可。
将配置文件导入windows的clash客户端
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307983635-518da826-85ce-49ac-ad7f-50d033eb2902.png#averageHue=%237c6c52&id=KqOzW&originHeight=417&originWidth=1211&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
打开clash客户端，在配置栏选择对应的机场鼠标右击显示文件夹
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307983972-d9fec8b9-2be6-48b7-b911-60d19c282d52.png#averageHue=%235e7192&id=uk3gT&originHeight=88&originWidth=87&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307984291-ee9be1f6-7f0e-4252-8241-6537332caced.png#averageHue=%23e9e9e9&id=NiXmb&originHeight=537&originWidth=1222&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
复制该配置文件，修改文件名称为config.yaml，使用记事本进行修改
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307984600-77b8c9de-53b3-44ee-8ce1-7a6858087b1a.png#averageHue=%23f9f8f6&id=JiHss&originHeight=241&originWidth=701&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
** Config.yaml基础配置文件：**
```shell
port: 7890
socks-port: 7891
redir-port: 7892
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: '0.0.0.0:9090'
dns:
    enable: true
    ipv6: false
    default-nameserver: [223.5.5.5, 119.29.29.29]
    fake-ip-range: 198.18.0.1/16
    use-hosts: true
    nameserver: ['https://doh.pub/dns-query', 'https://dns.alidns.com/dns-query']
    fallback: ['tls://1.0.0.1:853', 'https://cloudflare-dns.com/dns-query', 'https://dns.google/dns-query']
    fallback-filter: { geoip: true, ipcidr: [240.0.0.0/4, 0.0.0.0/32] }
```

**<3>上传config.yaml配置文件**

修改完的文件config.yaml，上传到dockerclash文件夹下
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307984932-e37834d9-f4d4-4820-8fe0-50bf0a78f977.png#averageHue=%23f8f8f8&id=hpX06&originHeight=100&originWidth=619&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

配置clash
<1>打开docker，在映像中，双击启动“dreamacro/clash:latest”
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307985218-036e1dc4-37aa-440b-84d1-0dc93bbd0a0e.png#averageHue=%23c9ebec&id=a93iB&originHeight=99&originWidth=344&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)


![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307985473-83f816cf-1feb-450e-8b26-22f715de46db.png#averageHue=%23ebd1a9&id=CeGGe&originHeight=552&originWidth=605&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307985760-3e93d7a3-d5cd-452e-842b-f2eefb573cc3.png#averageHue=%23ecd3ae&id=HC43L&originHeight=569&originWidth=615&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
<2>端口设置(对应congig.yaml配置即可)：


![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307986007-2d72ec07-9263-4a51-9690-b820cb7b31b4.png#averageHue=%23ebcea3&id=RGx4f&originHeight=559&originWidth=605&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
<3>设置文件路径：/docker/clash/config.yaml
映射到容器的/root/.config/clash/config.yaml

![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307986320-bc452ef4-2372-4426-ba59-ab83d8999f9b.png#averageHue=%23e4caa3&id=jVbZv&originHeight=547&originWidth=601&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
	
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307986684-d486c64f-3e9e-4f46-acfa-8de19900056d.png#averageHue=%23e9ca9e&id=K8753&originHeight=559&originWidth=613&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)


![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307986942-543f579a-a6a7-4ac1-9a78-593d8c1531ab.png#averageHue=%23fcfcfc&id=lUvBY&originHeight=564&originWidth=863&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307987259-f837d639-46b2-4dd6-abb7-ac6b28de717d.png#averageHue=%23e9d0ac&id=JHmMu&originHeight=557&originWidth=613&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
<3>下一步…直至完成，不需要设置文件及文件夹的路径
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307987565-0253c6ff-8bc7-4f2e-be19-60a257200b4d.png#averageHue=%23fbfbfa&id=ovHNq&originHeight=566&originWidth=614&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
<4>添加yacd管理页面
通过[http://10.0.0.42:8081/](http://10.0.0.42:8081/)   #IP+yacd的端口8081打开，在api base url中，输入[http://10.0.0.42:9090](http://10.0.0.42:9090)，点击add,下图框起来的为成功标识
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307987859-32478d78-2358-4546-b97c-eb40d6710130.png#averageHue=%23232323&id=chaqN&originHeight=763&originWidth=1392&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
		<5>节点切换
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307988219-08f12a9e-4195-4199-8de4-22b95cc2d9e3.png#averageHue=%232d2c2b&id=BZa8Z&originHeight=935&originWidth=1848&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
<6>windows使用clash代理
打开nas的clash地址，[http://10.0.0.42:8081/#/configs](http://10.0.0.42:8081/#/configs)，在配置中，可以看到http的地址端口
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307988670-78129ae6-3c85-4cd9-bc8e-a1b36b2a919a.png#averageHue=%23222221&id=sJoKC&originHeight=751&originWidth=1176&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
打开系统代理，配置IP及端口
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307989023-e589840d-ed6b-4e46-a81d-76700dc8eb32.png#averageHue=%23f3f3f3&id=FkAPi&originHeight=506&originWidth=822&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)
访问测试：[http://ip111.cn/](http://ip111.cn/)
![](https://cdn.nlark.com/yuque/0/2023/png/40407567/1702307989587-a055c092-1bd2-4e4d-9ed9-7794c201c5f7.png#averageHue=%23fcfcfb&id=qCIRD&originHeight=268&originWidth=1349&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

<7>自动更新脚本
#脚本存放位置：/volume1/docker/clash/reload-clash.sh
#nas执行脚本定义：bash /volume1/docker/clash/reload-clash.sh
# 下载节点配置文件，根据实际的订阅地址填写
wget -O /volume1/docker/clash/config.yaml [https://www.v2fast.site/api/v1/client/subscribe?token=113e6672a91d1c603c00b3fea8c7df3e](https://www.v2fast.site/api/v1/client/subscribe?token=113e6672a91d1c603c00b3fea8c7df3e)
# external-controller地址为0.0.0.0:9090，方便UI访问（可选）
sed -i 's/127.0.0.1:9090/0.0.0.0:9090/g' /volume1/docker/clash/config.yaml
# 增加安全性，配置使用代理的用户名和密码（可选）
sed -i 's/allow-lan: true/allow-lan: true\r\nauthentication:\r\n - "josh:josh123456"\r\n - "pino:pino123456"/g' /volume1/docker/clash/config.yaml
# 重启 clash 容器，名字为实际的容器名字
docker container restart dreamarco-clash1

<8>win10启用代理脚本
@echo off

REM 设置代理服务器地址和端口
set "proxyServer=192.168.3.79:7890"

REM 启用代理服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f

REM 设置代理服务器地址和端口
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "%proxyServer%" /f

REM 刷新代理设置
netsh winhttp import proxy source=ie

echo 代理设置已修改为：%proxyServer%
<9>win10关闭代理脚本
@echo off

REM 关闭代理服务器
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f

REM 刷新代理设置
netsh winhttp reset proxy

echo 代理已关闭。


日常维护：
<1>订阅地址更新（机场失效、更换机场），登录nas，替换docker文件夹下的config.yaml文件，替换完成，重启clash即可。
<2>节点切换，通过yacd管理页面打开，点击需要切换的节点即可
