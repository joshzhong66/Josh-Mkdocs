import datetime
import sys
import time

from selenium import webdriver
from selenium.webdriver.edge.service import Service
from selenium.webdriver.edge.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def get_current_time():
    return datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S') + " - [info] "


# 打开日志文件
log_file = open('/data/script/topsec_backup.log', 'a')

# 保存原始的 sys.stdout，用于后续打印到控制台
original_stdout = sys.stdout


# 将输出同时写入文件和控制台
class DualOutput:
    def __init__(self, file, original):
        self.file = file
        self.original = original

    def write(self, message):
        # 将消息同时写到文件和控制台
        self.file.write(message)
        self.original.write(message)

    def flush(self):
        # 确保所有内容都被刷新到文件和控制台
        self.file.flush()
        self.original.flush()


# 设置 sys.stdout 为 DualOutput 类实例
sys.stdout = DualOutput(log_file, original_stdout)

# 设置 Edge WebDriver 的路径
edge_driver_path = r'/data/script/edgedriver_linux64/msedgedriver'

# 配置 EdgeOptions
options = Options()
options.use_chromium = True  # 确保使用 Chromium 版本

options.add_argument('--disable-notifications')  # 禁用通知
options.add_argument('--headless')  # 无头模式
options.add_argument('--disable-gpu')  # 禁用 GPU，加快无头模式下的速度
options.add_argument('--no-sandbox')  # 解决无头模式启动问题
options.add_argument('--disable-dev-shm-usage')  # 解决无头模式启动问题

options.add_argument('--ignore-certificate-errors')
options.add_argument('--ignore-certificate-errors-spki-list')
options.add_argument('--ignore-ssl-errors')    # 忽略 SSL 错误
options.add_argument('--allow-insecure-localhost')

options.add_experimental_option("prefs", {
    "download.default_directory": "/data/backup_config",  # 设置默认下载目录
    "safebrowsing.enabled": False  # 禁用安全浏览
})

options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 Edg/111.0.1661.62')  # 设置用户代理
options.binary_location = '/opt/microsoft/msedge/msedge'  # 设置 Edge 浏览器路径

# 初始化 Edge 浏览器
service = Service(edge_driver_path)
driver = webdriver.Edge(service=service, options=options)


def login_sys(drivers, url, username, password):
    drivers.get(url)
    drivers.find_element(By.XPATH, '//*[@name="username1"]').send_keys(username)
    drivers.find_element(By.XPATH, '//*[@name="passwd1"]').send_keys(password)
    drivers.find_element(By.XPATH, '//*[@name="loginSubmitIpt"]').click()
    try:
        WebDriverWait(driver, 3).until(EC.alert_is_present())
        return False
    except:
        return True


try:
    print(get_current_time() + "开始执行防火墙备份配置文件操作...")
    if not login_sys(driver, 'https://100.100.100.2:8080/', sys.argv[1], sys.argv[2]):
        driver.quit()
        log_file.close()
        sys.stdout = original_stdout
        sys.exit(1)

    print(get_current_time() + "下载当前运行配置备份文件")
    driver.execute_script("window.open('https://100.100.100.2:8080/cgi/maincgi.cgi?Url=Fetch&Id=Running');")
    time.sleep(3)
    print(get_current_time() + "下载用户运行配置备份文件")
    driver.execute_script("window.open('https://100.100.100.2:8080/cgi/maincgi.cgi?Url=Fetch&Id=Running_user');")
    time.sleep(3)
finally:
    driver.quit()   # 关闭浏览器
    log_file.close()   # 关闭日志文件
    sys.stdout = original_stdout   # 恢复原始的 sys.stdout

