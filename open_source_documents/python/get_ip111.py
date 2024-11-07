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
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager


options = webdriver.ChromeOptions()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
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


