docker部署wizard

```


mkdir -p /data/users/admin/wizard
mkdir -p /data/users/admin/wizard/logs
chmod -R 777 /data/users/admin/wizard

#创建数据库
create database wizard;


docker run -d --name wizard \
    -e DB_HOST=10.22.51.66 \
    -e DB_PORT=3306 \
    -e DB_DATABASE=wizard \
    -e DB_USERNAME=root \
    -e DB_PASSWORD=sunline \
    -p 8087:80 \
    -e APP_DEBUG=true \
    -v /data/users/admin/wizard:/webroot/storage/app/public \
    -v /data/users/admin/wizard/logs:/webroot/storage/logs \
    mylxsw/wizard


docker exec -it wizard /bin/bash
php artisan migrate:install
php artisan migrate

chmod -R 777 /webroot/storage/logs
docker restart wizard

```

