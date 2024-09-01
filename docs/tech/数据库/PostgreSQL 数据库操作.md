### PostgreSQL 数据库操作

### 1. **创建用户**
创建一个新用户：

```sql
CREATE USER username WITH PASSWORD 'password';
```

### 2. **修改用户密码**
修改现有用户的密码：

```sql
ALTER USER username WITH PASSWORD 'new_password';
```

### 3. **删除用户**
删除一个用户：

```sql
DROP USER username;
```

### 4. **授予权限**
授予用户对某个数据库的访问权限：

```sql
GRANT ALL PRIVILEGES ON DATABASE dbname TO username;
```

### 5. **撤销权限**
撤销用户对某个数据库的访问权限：

```sql
REVOKE ALL PRIVILEGES ON DATABASE dbname FROM username;
```

### 6. **授予角色**
授予用户一个角色（例如超级用户权限）：

```sql
ALTER USER username WITH SUPERUSER;
```

### 7. **列出用户的权限**
查看某个用户的权限：

```sql
\du username
```

在 PostgreSQL 命令行中使用 `\du` 可以列出所有用户及其权限。如果你想查看特定用户的详细信息，可以使用：

```sql
\du+ username
```

### 8. **锁定用户**
锁定一个用户帐户：

```sql
ALTER USER username WITH NOLOGIN;
```

### 9. **解锁用户**
解锁一个用户帐户：

```sql
ALTER USER username WITH LOGIN;
```

### 10. **更改用户的属性**
例如，将用户设置为不能创建数据库：

```sql
ALTER USER username WITH NOCREATEDB;
```

### 11.查询数据库用户

```
SELECT usename FROM pg_user;
```



```
create table tsetbs (name varchar(50));
insert into tsetbs values('百度');
insert into tsetbs values('阿里');
insert into tsetbs values('腾讯');
insert into tsetbs values('www.baidu.com');
insert into tsetbs values('wx');
insert into tsetbs values('yone-com');
insert into tsetbs values('wx-gzh');
insert into tsetbs values('yone_com');
insert into tsetbs values('oracle');
insert into tsetbs values('mysql');
insert into tsetbs values('nosql');
insert into tsetbs values('pgsql');
insert into tsetbs values('深圳');
insert into tsetbs values('广州');
select * from tsetbs;
```

