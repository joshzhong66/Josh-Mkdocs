# 查询
```
select user,host from mysql.user;       # 查询用户列表
```

# 创建用户
```
ALTER USER 'koel'@'%' IDENTIFIED BY 'Sunline2024';      # 设置koel用户的密码
FLUSH PRIVILEGES;                                       # 刷新权限
```

# 删除用户
```
DROP USER 'koel'@'%';       # 删除koel用户，需要刷新权限生效
DROP DATABASE koel;         # 删除数据库
```