import sqlite3
from cryptography.fernet import Fernet

# 生成密钥并保存（仅在第一次运行时需要执行）
def generate_key():
    key = Fernet.generate_key()
    with open('secret.key', 'wb') as key_file:
        key_file.write(key)

# 加载密钥
def load_key():
    return open('secret.key', 'rb').read()

# 初始化数据库并创建表
def initialize_db():
    conn = sqlite3.connect('sunline_devps.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            encrypted_password BLOB NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

# 加密密码并存储
def store_account(username, password):
    key = load_key()
    fernet = Fernet(key)
    encrypted_password = fernet.encrypt(password.encode())

    conn = sqlite3.connect('sunline_devps.db')
    cursor = conn.cursor()
    cursor.execute('''
        INSERT OR REPLACE INTO accounts (username, encrypted_password)
        VALUES (?, ?)
    ''', (username, encrypted_password))
    conn.commit()
    conn.close()



# 读取并解密密码
def get_account_password(username):
    key = load_key()  # 加载密钥
    fernet = Fernet(key)  # 创建 Fernet 对象
    conn = sqlite3.connect('sunline_devps.db')  # 连接到 SQLite 数据库
    cursor = conn.cursor()
    cursor.execute('SELECT encrypted_password FROM accounts WHERE username = ?', (username,))   # 查询指定用户名的加密密码
    result = cursor.fetchone()
    conn.close()  # 关闭数据库连接

    if result:
        decrypted_password = fernet.decrypt(result[0]).decode()     # 解密并返回密码
        return decrypted_password
    else:
        print('账号未找到')
        return None


if __name__ == '__main__':
    #generate_key()  # 确保 首次运行时生成密钥
    initialize_db()  # 初始化数据库
    username = input("请输入用户名: ")     # 如需创建用户
    password = input("请输入密码: ")       # 如需创建密码
    store_account(username, password)     # 存储账号信息
    print(f"用户名 {username} 已成功存储到数据库中。")
