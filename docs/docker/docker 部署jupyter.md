## 1.搜索镜像

`docker search jupyter`: 命令用于在 Docker Hub 上搜索名为 "jupyter" 的镜像。搜索结果显示了一个名为 "jupyter/datascience-notebook" 的镜像，它是一个包含了数据科学 Jupyter 笔记本的 Python 栈。

```
root@Could:/volume1/docker/jupyter# docker search jupyter
NAME                                 DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
jupyter/datascience-notebook         Data Science Jupyter Notebook Python Stack f…   1057    

....省略n个镜像
```



## 2.拉取镜像

`docker pull jupyter/datascience-notebook`:命令用于从 Docker Hub 下载 "jupyter/datascience-notebook" 镜像。

```
docker pull  jupyter/datascience-notebook
```



## 3.创建挂载

在容器创建过程中，我发现通过映射目录的方式创建后，竟然不能将容器内的数据和配置加载到宿主机，因此容器删除后导致配置和数据丢失了，最终发现目录权限和所属用户导致该问题，以下配置可以解决该问题：



`mkdir -p /data/jupyter/notebook/data`: 命令用于创建一个目录，即 `/data/jupyter/notebook/data`，用于在主机和容器之间共享 Jupyter 笔记本文件。可以将的 Jupyter 笔记本文件放在这个目录中，以便在容器中进行访问和编辑。

```jupyter配置文件:/data/jupyter1/notebook/config```

```
#创建挂载目录
mkdir -p /data/jupyter/notebook/data
mkdir -p /data/jupyter/notebook/config
```





## 4.配置文件

先运行容器，把配置文件复制出来

```
docker run -itd \
--name jupyter \
-p 8880:8888 \
-e GRANT_SUDO=yes \
-v /data/jupyter/notebook/data:/home/jovyan/work/data \
-v 	/data/jupyter/notebook/config/jupyter_notebook_config.py:/home/jovyan/.jupyter/jupyter_notebook_config.py \
jupyter/datascience-notebook
```



复制配置文件出来

```
docker cp jupyter1:/home/jovyan/.jupyter/jupyter_notebook_config.py /data/jupyter/notebook/config/
```



停止删除该容器，

```
docker rm -f 容器id
```



## 5.文件赋权

需要为挂载的 Jupyter 配置文件赋予适当的权限，以确保 `jovyan` 用户可以读取该配置文件。以下是详细步骤：

```
chown 1000:100 /data/jupyter/notebook/config/jupyter_notebook_config.py
chmod 644 /data/jupyter/notebook/config/jupyter_notebook_config.py
```





## 6.重新创建容器

```
docker run -itd \
--name jupyter1 \
-p 8880:8888 \
-e GRANT_SUDO=yes \
-v /data/jupyter1/notebook/data:/home/jovyan/work/data \
-v 	/data/jupyter1/notebook/config/jupyter_notebook_config.py:/home/jovyan/.jupyter/jupyter_notebook_config.py \
jupyter/datascience-notebook
```



## 7.验证配置文件权限

检查配置文件在容器内的权限，确保 `jovyan` 用户可以读取：

```
docker exec -it jupyter ls -l /home/jovyan/.jupyter/jupyter_notebook_config.py
```



确保配置文件 `jupyter_notebook_config.py` 和数据文件夹 `/home/jovyan/work/data` 都具有 `jovyan` 用户的读写权限，从而确保 Jupyter Notebook 可以正常访问和读取配置。



## 8.生成无访问密码的容器

操作步骤与第一步一致，挂载目录信息自行修改

（2）生成无访问密码jupyter的容器

```
docker run -itd \
--name jupyter \
-p 8888:8888 \
-v /volume1/docker/jupyter/notebook:/home/notebook/data \
-e "JUPYTER_ENABLE_LAB=yes" \
-e "NB_USER=user" \
-e "NB_UID=1000" \
-e "GRANT_SUDO=yes" \
jupyter/datascience-notebook start-notebook.sh --NotebookApp.token=''

```



## 9.环境变量解释

- `docker run -itd`: 这是运行 Docker 容器的命令。`-itd` 参数将容器运行在后台，并将标准输入连接到 TTY（终端）。
- `--name jupyter`: 通过这个选项，您为容器指定了一个名称，即 "jupyter"。
- `-p 8888:8888`: 这个选项将容器内部的端口 8888 映射到宿主机的端口 8888，以便可以通过 `localhost:8888` 访问 Jupyter。
- `-v /volume1/docker/jupyter/notebook:/home/notebook/data`: 这个选项将宿主机的目录 `/volume1/docker/jupyter/notebook` 挂载到容器内的 `/home/notebook/data` 目录，以便您可以在 Jupyter 中访问宿主机上的数据。
- `-e "JUPYTER_ENABLE_LAB=yes"`: 这个选项设置 Jupyter 启用 JupyterLab 界面。
- `-e "NB_USER=user"`: 这个选项设置 Jupyter 使用用户名 "user"。
- `-e "NB_UID=1000"`: 这个选项设置 Jupyter 使用用户 ID 为 1000。
- `-e "GRANT_SUDO=yes"`: 这个选项允许 Jupyter 用户拥有管理员权限。
- `jupyter/datascience-notebook`: 这是要使用的 Docker 镜像的名称，即 Jupyter 数据科学笔记本镜像。
- `start-notebook.sh --NotebookApp.token=''`: 这是在容器内部运行的命令。`start-notebook.sh` 脚本会启动 Jupyter 服务器，并使用空的访问令牌，即无密码访问模式。

通过运行上述命令，将启动一个名为 "jupyter" 的容器，并以无密码访问模式启动 Jupyter。您可以在浏览器中访问 `IP:8888` 来使用 Jupyter 笔记本。







## 10.查看容器运行状态

```docker ps```命令，用于查看运行的 Jupyter 数据科学笔记本容器的详细信息如下：

```
root@Could:~# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS                   PORTS                    NAMES
4cd0ddf5a966   jupyter/datascience-notebook     "tini -g -- start-no…"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:8888->8888/tcp   jupyter
```



- `CONTAINER ID`: 容器的唯一标识符，用于在 Docker 中标识容器。
- `IMAGE`: 容器所使用的镜像名称，即 "jupyter/datascience-notebook"。
- `COMMAND`: 容器启动时执行的命令。
- `CREATED`: 容器的创建时间。
- `STATUS`: 容器的状态。在这种情况下，容器的状态为 "Up"，表示容器正在运行。
- `PORTS`: 容器的端口映射配置。在这种情况下，容器的端口 8888 映射到主机的端口 8888。
- `NAMES`: 容器的名称。

容器的名称为 "mystifying_shirley"，它已经运行了大约 15 分钟，并且状态为 "Up"，表示容器正常运行。







## 11.token查看

无密码容器跳过本步骤：

```
docker logs jupyter | cat >> /tmp/jupyter.txt
cat  /tmp/jupyter.txt | grep token
```

具体解释如下：

1. `docker logs jupyter`：使用`docker logs`命令查看名为"jupyter"的容器的日志。
2. `|`：管道符号，将前一个命令的输出作为后一个命令的输入。
3. `cat >> /tmp/jupyter.txt`：`cat`命令用于将输入内容输出到终端，`>>`表示追加模式，将输出内容追加到`/tmp/jupyter.txt`文件中。
4. `cat /tmp/jupyter.txt`：使用`cat`命令查看`/tmp/jupyter.txt`文件的内容。
5. `grep token`：使用`grep`命令在输入中搜索包含"token"的行。

通过这个命令，你可以查看Jupyter容器的日志，并搜索包含"token"的行，以找到Jupyter Notebook的访问令牌（token）。





```
复制
token=49d38b2f29a6971f9abb8301da66de1073f57d627804200e
```









## 12.访问jupyter

http://192.168.31.100:8888/

通过token修改密码

![image-20231203152033485](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/05/11/ade251c3cbb2ecab323eecf89c5347f2-image-20231203152033485-33dd03.png)



## 13、nginx反向代理

确保 Nginx 配置正确地代理请求到 Jupyter 服务器，并且包含正确的 WebSocket 配置。以下是一个示例配置：

不加载WebSocket 配置，会导致：`使用域名访问 Jupyter Notebook 时无法执行脚本，而使用 IP 地址访问正常`

```
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
```



## 14.检查Jupyter Notebook 配置

在 Jupyter Notebook 配置文件中（通常是 `~/.jupyter/jupyter_notebook_config.py`），添加或更新以下配置：

```
pythonCopy codec.NotebookApp.allow_origin = '*'
c.NotebookApp.trust_xheaders = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
```

如果没有该配置文件，可以使用以下命令生成：

```
jupyter notebook --generate-config
```



## 15. 重启 Nginx 和 Jupyter 服务

重启 Nginx 和 Jupyter Notebook 服务以应用更改：

```
systemctl restart nginx
docker restart jupyter
```



## 16.测试jupyter

在应用这些更改后，通过域名再次访问 Jupyter Notebook，确认是否可以正常执行脚本。如果仍然有问题，可以检查浏览器控制台中的错误日志，进一步诊断问题。

![image-20240511102908726](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/05/11/468149b74c62d00ba0061979efd2cd3e-image-20240511102908726-abbbe8.png)
