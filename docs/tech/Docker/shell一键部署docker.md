# shell一键部署docker



shell安装docker，参考：

[官方文档]: https://docs.docker.com/engine/install/centos/

```bash
curl -fsSL https://test.docker.com -o test-docker.sh
sudo sh test-docker.sh
```

安装完，启动即可：

```bash
systemctl start docker
```

