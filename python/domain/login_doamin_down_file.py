from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import time

# 设置登录信息和URL
username = 'admin'
password = 'Sunline2024'
login_url = 'https://domain.joshzhong.top/#/login'
monitor_certificates_xpath = '//*[@id="app"]/div/div[2]/div[1]/div/div[1]/div[1]/div[1]/div/ul/li[1]/div/span'
certificate_list_xpath = '//*[@id="app"]/div/div[2]/div[1]/div/div[1]/div[1]/div[1]/div/ul/li[1]/ul/li[1]'
export_button_xpath = '//*[@id="app"]/div/div[2]/div[2]/div/div/div[3]/div[2]/a[4]/span'
export_format_xpath = '//*[@id="el-id-3701-96"]/label[2]/span[1]'
confirm_button_xpath = '//*[@id="el-id-3701-53"]/div/form/div[2]/div/button[2]/span'

# 初始化浏览器
driver = webdriver.Chrome()
driver.get(login_url)

def login_to_domain_admin():
    # 等待登录页面加载
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, '//input[@placeholder="用户名"]')))
    print("登录页面已加载")
    
    # 输入用户名和密码
    username_field = driver.find_element(By.XPATH, '//input[@placeholder="用户名"]')
    password_field = driver.find_element(By.XPATH, '//input[@placeholder="密码"]')
    
    username_field.send_keys(username)
    password_field.send_keys(password)
    
    # 提交表单
    password_field.send_keys(Keys.RETURN)
    
    # 等待页面跳转完成并点击“证书监控”
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, monitor_certificates_xpath)))
    print("已找到证书监控")
    monitor_certificates_link = driver.find_element(By.XPATH, monitor_certificates_xpath)
    monitor_certificates_link.click()
    
    # 等待并点击“证书列表”
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, certificate_list_xpath)))
    print("已找到证书列表")
    certificate_list_link = driver.find_element(By.XPATH, certificate_list_xpath)
    driver.execute_script("arguments[0].click();", certificate_list_link)
    
    # 等待页面加载完成
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, export_button_xpath)))
    print("已找到导出按钮")

def export_certificates():
    # 点击导出按钮
    export_button = driver.find_element(By.XPATH, export_button_xpath)
    export_button.click()
    
    # 增加等待时间，确保弹出窗口完全加载
    time.sleep(5)
    
    # 等待并选择导出格式
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, export_format_xpath)))
    print("已找到导出格式选项")
    export_format_option = driver.find_element(By.XPATH, export_format_xpath)
    export_format_option.click()
    
    # 点击确认按钮
    WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, confirm_button_xpath)))
    print("已找到确认按钮")
    confirm_button = driver.find_element(By.XPATH, confirm_button_xpath)
    driver.execute_script("arguments[0].click();", confirm_button)
    
    # 等待导出完成，可以通过等待文件下载或其他方式确认
    time.sleep(10)

if __name__ == "__main__":
    try:
        login_to_domain_admin()
        export_certificates()
        print("Certificates export initiated.")
    finally:
        driver.quit()
