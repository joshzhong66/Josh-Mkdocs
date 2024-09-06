

#### 1、构建dockerfile

Dockerfile 文件统一放在 `/data/hexo` 目录下，并分别建立 `nodejs`、`php`、`nginx` 文件夹

```
mkdir -p /data/hexo/nodejs
mkdir -p /data/hexo/php
mkdir -p /data/hexo/nginx
mkdir -p /data/hexo/www/blog
mkdir -p /data/hexo/www/ssl
```



`vim docker-compose.yml`

> 在vim中按下 `:set paste` 进入粘贴模式，可以解决使用vim等文本编辑器进行复制粘贴操作时，有时会导致格式混乱
>
> ```
> version: '3'
> services:
>   nginx:
>     restart: always
>     build: ./nginx
>     ports:
>       - "80:80"
>       - "443:443"
>     volumes:
>       - "/data/hexo/www/blog:/var/www/blog"
>       # - "/data/hexo/www/ssl/certs:/var/www/ssl/certs" # 暂时注释掉SSL证书挂载
>       - "/data/hexo/nginx/conf.d:/etc/nginx/conf.d"
>     command: /bin/bash /start.sh
>     env_file:
>       - docker.env
>     extra_hosts:
>       - "raw.githubusercontent.com:199.232.96.133"
>     container_name: "nginx"
>   nodejs:
>     build: ./nodejs
>     ports:
>       - "4000:4000"
>     volumes:
>       - "/data/hexo/www/blog:/var/www/blog"
>     container_name: "nodejs"
>   php:
>     restart: always
>     build: ./php
>     expose:
>       - "9000"
>     volumes:
>       - "/data/hexo/www/blog:/var/www/blog"
>     container_name: "php"
> 
> ```
>



界面：

![image-20240425100508908](https://raw.githubusercontent.com/joshzhong66/Pibced/main/blog-images/2024/04/25/4fbed9511be87fbf9b9ca8c01f51e46d-image-20240425100508908-896cf6.png)



[详细参考博客](https://www.fanhaobai.com/2020/12/hexo-to-docker.html)
