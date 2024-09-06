

docker部署gitlab



```
[root@josh-clound data]# mkdir -p /data/gitlab/etc
[root@josh-clound data]# mkdir -p /data//gitlab/log
[root@josh-clound data]# mkdir -p /data/gitlab/opt



# 启动容器
docker run \
 -itd  \
 -p 8380:80 \
 -p 8322:22 \
 -v /data/gitlab/etc:/etc/gitlab  \
 -v /data/gitlab/log:/var/log/gitlab \
 -v /data/gitlab/opt:/var/opt/gitlab \
 --restart always \
 --privileged=true \
 --name gitlab \
 gitlab/gitlab-ce
 
 
 
 #修改gitlab.rb
vi /etc/gitlab/gitlab.rb
 
#加入如下
#gitlab访问地址，可以写域名。如果端口不写的话默认为80端口
external_url 'http://192.168.124.194'
#ssh主机ip
gitlab_rails['gitlab_ssh_host'] = '192.168.124.194'
#ssh连接端口
gitlab_rails['gitlab_shell_ssh_port'] = 8322
 
# 让配置生效
gitlab-ctl reconfigure


# 修改http和ssh配置
vi /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
 
  gitlab:
    host: 192.168.124.194
    port: 8380 # 这里改8380
    https: false
    
    
#重启gitlab 
gitlab-ctl restart
#退出容器 
exit
```

