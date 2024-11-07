'''
wget https://storage.googleapis.com/chrome-for-testing-public/130.0.6723.93/linux64/chromedriver-linux64.zip
echo 'export PATH=$PATH:/data/chrome/chrome-linux64:/data/chrome' >> ~/.bashrc
source ~/.bashrc

pip install urllib3==1.26.15    #降级到 urllib3 支持 OpenSSL 1.0.2 的版本 或者安装 OpenSSL 1.1.1

python3 -m venv venv
source venv/bin/activate
pip install selenium 
pip install webdriver_manager
'''

import time
from selenium import webdriver
from selenium.webdriver.edge.service import Service
from selenium.webdriver.edge.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC



edge_driver_path = r'/data/script/edgedriver_linux64/msedgedriver'


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


options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 Edg/111.0.1661.62')  # 设置用户代理
options.binary_location = '/opt/microsoft/msedge/msedge'  # 设置 Edge 浏览器路径

# 初始化 Edge 浏览器
service = Service(edge_driver_path)
driver = webdriver.Edge(service=service, options=options)

driver.get("https://ip111.cn")
time.sleep(3)

domestic_test = driver.find_element(By.XPATH, "//div[contains(text(),'从国内测试')]/following-sibling::div/p").text
print("从国内测试:", domestic_test)

driver.switch_to.frame(driver.find_element(By.XPATH, "//iframe[@src='https://us.ip111.cn/ip.php']"))
foreign_test = driver.find_element(By.TAG_NAME, "body").text
driver.switch_to.default_content()
print("从国外测试:", foreign_test)

driver.switch_to.frame(driver.find_element(By.XPATH, "//iframe[@src='https://sspanel.net/ip.php']"))
google_test = driver.find_element(By.TAG_NAME, "body").text
driver.switch_to.default_content()
print("从谷歌测试:", google_test)

driver.quit()


