import mysql.connector
from cryptography.fernet import Fernet

# 生成密钥并保存（仅第一次运行时需要执行）
def generate_key():
    key = Fernet.generate_key()
    with open('secret.key', 'wb') as key_file:
        key_file.write(key)

# 加载密钥
def load_key():
    return open('secret.key', 'rb').read()

# 连接 MySQL 数据库
def get_connection():
    return mysql.connector.connect(
        host='10.22.51.64',
        user='root',
        password='Sunline2024',
        database='sunline_devps'
    )

# 初始化数据库并创建表
def initialize_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(255) NOT NULL UNIQUE,
            encrypted_password BLOB NOT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ''')
    conn.commit()
    conn.close()

# 加密密码并存储
def store_account(username, password):
    key = load_key()
    fernet = Fernet(key)
    encrypted_password = fernet.encrypt(password.encode())

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO accounts (username, encrypted_password)
        VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE encrypted_password = VALUES(encrypted_password);
    ''', (username, encrypted_password))
    conn.commit()
    conn.close()

# 读取并解密密码
def get_account_password(username):
    key = load_key()
    fernet = Fernet(key)

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT encrypted_password FROM accounts WHERE username = %s', (username,))
    result = cursor.fetchone()
    conn.close()

    if result:
        decrypted_password = fernet.decrypt(result[0]).decode()
        return decrypted_password
    else:
        print('账号未找到')
        return None

if __name__ == '__main__':
    #generate_key()  # 确保首次运行时生成密钥
    initialize_db()  # 初始化数据库
    username = input("请输入用户名: ")
    password = input("请输入密码: ")
    store_account(username, password)
    print(f"用户名 {username} 已成功存储到数据库中。")
