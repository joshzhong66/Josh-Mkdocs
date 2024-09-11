import mysql.connector
from datetime import datetime

# 获取当前日期，格式化为 YYYYMMDD
current_date_str = datetime.now().strftime("%Y%m%d")

# 动态创建的表名
table_name = f"chat_history_{current_date_str}"

# 创建数据库连接，连接参数为：
# host: 数据库主机地址
# user: 数据库用户名
# password: 数据库用户密码
# database: 数据库名
# charset: 连接字符集
db = mysql.connector.connect(
    host="192.168.31.223",
    user="your_username",
    password="your_password",
    database="openai_chat_logs",
    charset='utf8mb4'
)

# 创建数据库游标
cursor = db.cursor()

# 创建表的 SQL 命令，使用动态表名为：
# table_name = f"chat_history_{current_date_str}"
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {table_name} (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
"""

# 执行创建表的命令
cursor.execute(create_table_query)
db.commit()

# 关闭数据库游标和连接
cursor.close()
db.close()