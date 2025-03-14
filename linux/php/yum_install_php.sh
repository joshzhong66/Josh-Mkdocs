
# 启用EPEL仓库，仓库中包含了许多额外的包
yum install -y epel-release
yum install -y libzstd libsodium libraqm


yum install -y https://mirrors.aliyun.com/remi/enterprise/remi-release-7.rpm

yum clean all
yum makecache
# 检查当前系统中所有启用和禁用的仓库
yum repolist all


# 安装yum-utils并启用PHP 7.4的Remi仓库
yum install -y yum-utils
yum-config-manager --disable 'remi-php*'
yum-config-manager --enable remi-php83

# 禁用 PHP 8.3 的 Remi 仓库
yum-config-manager --disable remi-php83 remi-safe

# 检查 PHP 8.3 版本
/opt/remi/php83/root/usr/bin/php -v

# 启动 PHP 8.3 的 FPM 服务
systemctl start php83-php-fpm.service
# 检查 PHP 8.3 的 FPM 服务状态
systemctl status php83-php-fpm.service
# 开机启动 PHP 8.3 的 FPM 服务
systemctl enable php83-php-fpm.service
