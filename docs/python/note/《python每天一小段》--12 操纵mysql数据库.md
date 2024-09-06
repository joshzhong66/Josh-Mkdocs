## 《python每天一小段》-- （12） 操纵mysql

### 简介

Python 是目前最流行的编程语言之一，其简单易学、可读性强、可移植性好等特点，使得其在数据分析、Web 开发、自动化等领域得到了广泛应用。在数据库领域，Python 也提供了丰富的库，可以方便地进行数据库操作。

### 安装 pymysql

要使用 Python 操作 MySQL，需要先安装 pymysql 库。使用如下命令安装：

```
pip install pymysql
```

### 连接 MySQL

使用 pymysql 连接 MySQL，可以使用 `connect()` 方法。该方法有以下参数：

- `host`：MySQL 服务器的 IP 地址或主机名
- `port`：MySQL 服务器的端口号
- `user`：MySQL 用户名
- `password`：MySQL 密码
- `db`：要连接的数据库名称
- `charset`：数据库的字符集

例如，连接到 MySQL 服务器 `192.168.31.223`，端口号 `3306`，用户名 `root`，密码 `123456`，连接到数据库 `atguigudb`，使用 UTF-8 字符集，可以使用如下代码：



```
import pymysql

db = pymysql.connect(
    host='192.168.31.223',
    port=3306,
    user='root',
    password='123456',
    db='atguigudb',
    charset='utf8'
)
```



### 执行 SQL 语句

连接到 MySQL 后，可以使用 `cursor()` 方法创建一个游标对象。使用游标对象可以执行 SQL 语句。

例如，执行查询 SQL 语句 `select version()`，可以使用如下代码：



```
cursor = db.cursor()
cursor.execute("select version()")
```



执行插入 SQL 语句 `INSERT INTO jobs(job_id,job_title,min_salary,max_salary) VALUES ('JOSH_ID_21','Operition',10000,15000)`，可以使用如下代码：



```
insert_query = "INSERT INTO jobs(job_id,job_title,min_salary,max_salary) VALUES ('JOSH_ID_21','Operition',10000,15000)"
cursor.execute(insert_query)
```



### 获取结果

执行查询 SQL 语句后，可以使用 `fetchall()` 方法获取所有结果。

例如，执行查询 SQL 语句 `select * from jobs`，获取所有结果，可以使用如下代码：



```
cursor.execute("select * from jobs")
result = cursor.fetchall()
```



### 提交事务

除了查询，其他修改操作需要使用 `commit()` 方法提交事务。

例如，执行插入 SQL 语句 `INSERT INTO jobs(job_id,job_title,min_salary,max_salary) VALUES ('JOSH_ID_21','Operition',10000,15000)`，需要使用如下代码：



```
insert_query = "INSERT INTO jobs(job_id,job_title,min_salary,max_salary) VALUES ('JOSH_ID_21','Operition',10000,15000)"
cursor.execute(insert_query)
db.commit()
```



### 关闭连接

使用完毕后，需要关闭连接。使用 `close()` 方法关闭连接。

例如，关闭连接 `db`，可以使用如下代码：



```
db.close()
```



### 代码扩展

上述代码已经基本涵盖了 Python 操作 MySQL 的基本操作。以下是一些可以进行的扩展：



- **异常处理**

在执行 SQL 语句时，可能会遇到各种异常，例如连接错误、语法错误、数据库错误等。需要对这些异常进行处理，防止程序崩溃。

例如，可以使用如下代码进行异常处理：

Python

```
try:
    cursor.execute("select version()")
except Exception as e:
    print("发生异常：", e)
```



如果发生异常，程序将打印出异常信息。

- **参数化查询**

使用参数化查询可以防止 SQL 注入攻击。

例如，可以使用如下代码进行参数化查询：



```
job_id = input("请输入职位 ID：")

sql = "select * from jobs where job_id = %s"
cursor.execute(sql, (job_id,))
```

在执行 SQL 语句时，将 `job_id` 作为参数传递给 `execute()` 方法。这样，即使输入的 `job_id` 包含恶意代码，也不会被执行。

- **事务管理**

事务是一系列操作的集合，要么都成功，要么都失败。

例如，可以使用如下代码进行事务管理：

```
# 开始事务
db.begin()

# 执行修改操作
cursor.execute("update jobs set min_salary = 11000 where job_id = 'JOSH_ID_11'")
cursor.execute("update jobs set max_salary = 12000 where job_id = 'JOSH_ID_11'")

# 提交事务
db.commit()
```

如果在执行修改操作时发生异常，可以使用 `rollback()` 方法回滚事务，这样可以防止数据的丢失。

- **数据类型处理**

在执行 SQL 语句时，需要注意数据类型的转换。

例如，可以使用如下代码进行数据类型转换：

Python

```
# 获取数据库版本
cursor.execute("select version()")
version = cursor.fetchone()[0]

# 将字符串转换为整数
int_version = int(version)

print("数据库版本：", int_version)
```



**结果集处理**

在执行查询 SQL 语句后，可以使用 `fetchone()`、`fetchmany()` 和 `fetchall()` 方法获取结果集。

- `fetchone()` 方法获取单条结果，返回一个元组。
- `fetchmany()` 方法获取指定数量的结果，返回一个元组列表。
- `fetchall()` 方法获取所有结果，返回一个元组列表。

例如，可以使用如下代码获取所有职位信息：

```
# 获取所有职位信息
cursor.execute("select * from jobs")
result = cursor.fetchall()

# 遍历结果集
for row in result:
    print(row)
```



输出结果如下：

```
('JOSH_ID_1', 'CEO', 100000, 200000)
('JOSH_ID_2', 'CTO', 80000, 150000)
('JOSH_ID_3', 'CFO', 70000, 130000)
...
```



如果只需要获取第一条结果，可以使用如下代码：

```
# 获取第一条结果
row = cursor.fetchone()

print(row)
```



输出结果如下：

```
('JOSH_ID_1', 'CEO', 100000, 200000)
```



如果只需要获取前 10 条结果，可以使用如下代码：

```
# 获取前 10 条结果
result = cursor.fetchmany(10)

# 遍历结果集
for row in result:
    print(row)
```



输出结果如下：

```
('JOSH_ID_1', 'CEO', 100000, 200000)
('JOSH_ID_2', 'CTO', 80000, 150000)
('JOSH_ID_3', 'CFO', 70000, 130000)
...
```

**异步操作**

在 Python 3.5 之后，可以使用 `asyncio` 库进行异步操作。使用异步操作可以提高程序的并发性，提高程序的性能。

要使用 `asyncio` 库进行异步操作，需要先导入 `asyncio` 库。

```
import asyncio
```



然后，需要创建一个 `asyncio.run()` 协程，在协程中执行异步操作。

例如，可以使用如下代码执行查询 SQL 语句：

```
async def query_jobs():
    cursor.execute("select * from jobs")
    result = cursor.fetchall()
    return result

async def main():
    result = await query_jobs()
    for row in result:
        print(row)

asyncio.run(main())
```



输出结果如下：

```
('JOSH_ID_1', 'CEO', 100000, 200000)
('JOSH_ID_2', 'CTO', 80000, 150000)
('JOSH_ID_3', 'CFO', 70000, 130000)
...
```

在上述代码中，`query_jobs()` 协程负责执行查询 SQL 语句，`main()` 协程负责调用 `query_jobs()` 协程并获取结果。

`query_jobs()` 协程使用 `asyncio.run()` 方法执行查询 SQL 语句。`asyncio.run()` 方法会阻塞当前线程，直到协程执行完毕。

`main()` 协程使用 `await` 关键字等待 `query_jobs()` 协程执行完毕。

异步操作的案例还有很多，例如：

- 使用异步操作可以批量执行查询 SQL 语句。
- 使用异步操作可以批量执行修改 SQL 语句。
- 使用异步操作可以批量执行删除 SQL 语句







案例：连接 MySQL 功能

测试使用 `assert` 语句来断言连接是否成功。

```
def test_connect():
    # 创建连接
    db = pymysql.connect(
        host='192.168.31.223',
        port=3306,
        user='root',
        password='123456',
        db='atguigudb',
        charset='utf8'
    )

    # 断言连接是否成功
    assert db is not None

    # 关闭连接
    db.close()

```





案例：执行增删改查操作

```
#pip install pymysql  提前导入pymysql
import pymysql


# 连接 MySQL
# 参数说明：
# host：MySQL 服务器的 IP 地址或主机名
# port：MySQL 服务器的端口号
# user：MySQL 用户名
# password：MySQL 密码
# db：要连接的数据库名称
# charset：数据库的字符集


#登录数据库的信息
db = pymysql.connect(
    host='192.168.31.223',
    port=3306,
    user='连接数据库的账号',
    password='连接数据库的密码',
    db='mysql',
    charset='utf8'
)

#执行基本的数据库命令
cursor=db.cursor()
cursor.execute("select version()")
cursor.execute("show databases")
cursor.execute("use atguigudb")
cursor.execute("show tables")

#查询数据
select_query = "select * from jobs"
cursor.execute(select_query)

#除了查询，其他修改操作需要db.commit()提交事务
#插入数据
insert_query =  "INSERT INTO jobs(job_id,job_title,min_salary,max_salary) VALUES ('JOSH_ID_21','Operition',10000,15000)"
cursor.execute(insert_query)
db.commit()     


#修改数据
update_query = "UPDATE jobs set min_salary=11000,max_salary=12000 WHERE job_id='JOSH_ID_11'"
cursor.execute(update_query)
db.commit()

#删除数据
delete_query = "DELETE FROM jobs WHERE job_id='JOSH_ID_10'"
cursor.execute(delete_query)
db.commit()



result = cursor.fetchall()
for row in result:
    print(row)

#获取mysql版本
cursor.execute("select version()")
data = cursor.fetchone()
print("数据库连接正常，数据库版本是：%s" %data[0])

db.close()

```







```
# 连接 MySQL

def connect_mysql(host: str, port: int, user: str, password: str, db: str, charset: str) -> pymysql.Connection:
    """
    连接 MySQL

    Args:
        host: MySQL 服务器的 IP 地址或主机名
        port: MySQL 服务器的端口号
        user: MySQL 用户名
        password: MySQL 密码
        db: 要连接的数据库名称
        charset: 数据库的字符集

    Returns:
        MySQL 连接对象
    """

    conn = pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        db=db,
        charset=charset,
    )
    return conn


# 执行基本的数据库命令

def execute_sql(conn: pymysql.Connection, sql: str) -> None:
    """
    执行 SQL 语句

    Args:
        conn: MySQL 连接对象
        sql: SQL 语句
    """

    cursor = conn.cursor()
    cursor.execute(sql)
    conn.commit()
    cursor.close()


# 查询数据

def query_data(conn: pymysql.Connection, sql: str) -> list:
    """
    查询数据

    Args:
        conn: MySQL 连接对象
        sql: SQL 语句

    Returns:
        查询结果
    """

    cursor = conn.cursor()
    cursor.execute(sql)
    result = cursor.fetchall()
    cursor.close()
    return result


# 插入数据

def insert_data(conn: pymysql.Connection, sql: str) -> None:
    """
    插入数据

    Args:
        conn: MySQL 连接对象
        sql: SQL 语句
    """

    execute_sql(conn, sql)


# 修改数据

def update_data(conn: pymysql.Connection, sql: str) -> None:
    """
    修改数据

    Args:
        conn: MySQL 连接对象
        sql: SQL 语句
    """

    execute_sql(conn, sql)


# 删除数据

def delete_data(conn: pymysql.Connection, sql: str) -> None:
    """
    删除数据

    Args:
        conn: MySQL 连接对象
        sql: SQL 语句
    """

    execute_sql(conn, sql)


# 获取 MySQL 版本

def get_mysql_version(conn: pymysql.Connection) -> str:
    """
    获取 MySQL 版本

    Args:
        conn: MySQL 连接对象

    Returns:
        MySQL 版本
    """

    sql = "select version()"
    result = query_data(conn, sql)[0][0]
    return result


# 主函数

def main():
    conn = connect_mysql(host="192.168.31.223", port=3306, user="root", password="123456", db="atguigudb", charset="utf8")

    # 执行基本的数据库命令
    execute_sql(conn, "select version()")
    execute_sql(conn, "show databases")
    execute_sql(conn, "use atguigudb")
    execute_sql(conn, "show tables")

    # 查询数据
    result = query_data(conn, "select * from jobs")
    for row in result:
        print(row)

    # 插入数据
    insert_data(conn, "INSERT INTO jobs(job_id,job_title,min_salary,max_salary

```





```
# 代码格式

# 使用四个空格进行缩进。
# 行长不要超过 79 个字符。
# 使用驼峰命名法。
# 使用 `self` 关键字来引用类的属性和方法。

# 注释

# 注释应该解释代码的功能和目的。
# 注释应该简洁明了，易于理解。
# 注释应该放在代码的适当位置。

# 单元测试

# 单元测试应该覆盖代码的所有功能。
# 单元测试应该尽量简洁。
# 单元测试应该独立于其他代码。

# 代码扩展

# 使用 `try-except` 语句来处理异常。
# 使用 `logging` 模块来记录日志。
# 使用 `paramiko` 模块来实现 SSH 连接。

# 具体案例和解释

# 使用 `try-except` 语句来处理异常

def execute_sql(conn: pymysql.Connection, sql: str) -> None:
    """
    执行 SQL 语句

    Args:
        conn: MySQL 连接对象
        sql: SQL 语句
    """

    try:
        cursor = conn.cursor()
        cursor.execute(sql)
        conn.commit()
        cursor.close()
    except Exception as e:
        print(e)

# 使用 `logging` 模块来记录日志

def main():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s: %(message)s"))

    logger.addHandler(handler)

    conn = connect_mysql(host="192.168.31.223", port=3306, user="root", password="123456", db="atguigudb", charset="utf8")

    # 执行基本的数据库命令
    logger.info("执行基本的数据库命令")
    cursor = conn.cursor()
    cursor.execute("select version()")
    cursor.execute("show databases")
    cursor.execute("use atguigudb")
    cursor.execute("show tables")

    # 查询数据
    logger.info("查询数据")
    result = cursor.fetchall()
    for row in result:
        print(row)

    # 插入数据
    logger.info("插入数据")
    insert_query = "INSERT INTO jobs(job_id,job_title,min_salary,max_salary) VALUES ('JOSH_ID_21','Operition',10000,15000)"
    cursor.execute(insert_query)
    conn.commit()

    # 修改数据
    logger.info("修改数据")
    update_query = "UPDATE jobs set min_salary=11000,max_salary=12000 WHERE job_id='JOSH_ID_11'"
    cursor.execute(update_query)
    conn.commit()

    # 删除数据
    logger.info("删除数据")
    delete_query = "DELETE FROM jobs WHERE job_id='JOSH_ID_10'"
    cursor.execute(delete_query)
    conn.commit()

    # 获取 MySQL 版本
    logger.info("获取 MySQL 版本")
    cursor.execute("select version()")
    data = cursor.fetchone()
    print("数据库连接正常，数据库版本是：%s" % data[0])

    conn.close()


# 主函数

if __name__ == "__main__":
    main()

```





