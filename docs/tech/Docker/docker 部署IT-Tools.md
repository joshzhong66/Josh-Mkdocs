# docker 部署IT-Tools



#### 方法一：通过 Docker Hub

```bash
docker network create --driver bridge --subnet=172.195.20.0/23 itools-bridge
docker run -d --name it-tools \
	-p 9090:80 \
	--restart unless-stopped \
	--network itools-bridge \
	corentinth/it-tools:latest
```



#### 方法二：通过github packages

```bash
docker network create --driver bridge --subnet=172.195.20.0/23 itools-bridge
docker run -d --name it-tools \
	-p 9090:80 \
	--restart unless-stopped \
	--network itools-bridge \
	ghcr.io/corentinth/it-tools:latest
```
