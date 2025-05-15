# .acme申请域名证书

1.域名后台添加解析，例如添加泛域名解析（*.joshzhong.top）

2.[登陆Freessl](https://freessl.cn/)，添加域名授权（选择CNAME类型）

3.复制授权验证信息，登陆域名后台，将授权添加解析记录

```
主机记录: _acme-challenge.upload

记录类型: CNAME

记录值: 6dd9e7kwneceow1o4qnl.dcv2.httpsauto.com

检测状态: 待配置DCV
```

4.添加后，Freessl仍显示（待配置DCV），需要点击申请ACME客户端证书，点击后就会显示【已通过DCV检测】，如果需要申请复制执行即可（参考步骤6）

5.服务器安装.acme客户端

```bash
mkdir -p /data/acme
cd /data/acme
git clone https://github.com/acmesh-official/acme.sh.git

cd acme.sh
./acme.sh --install -m xxxx@qq.com		# 指定一个邮箱
```

6.执行申请证书命令

```bash
cd /root/.acme
acme.sh --issue -d pic.joshzhong.top --dns dns_dp --server https://acme.freessl.cn/v2/DV90/directory/xxxxx --force
```



