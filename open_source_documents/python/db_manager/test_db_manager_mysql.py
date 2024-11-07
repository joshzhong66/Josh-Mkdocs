import db_manager_mysql

class Test:
    def __init__(self, username, password):
        self.username = username
        self.password = password

    def display_info(self):
        print(f"用户名: {self.username}")
        print(f"解密后的密码: {self.password}")

if __name__ == '__main__':
    username = '31314'  # 示例用户名
    password = db_manager_mysql.get_account_password(username)

    if password:
        test_instance = Test(username, password)
        test_instance.display_info()
    else:
        print(f'未找到用户名 {username} 的记录。')