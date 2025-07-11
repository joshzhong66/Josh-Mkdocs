import time

from password import Nac_User, Nac_Password

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains



# 初始化浏览器并打开登录页面
def create_driver(url):
    chrome_options = Options()
    chrome_options.add_argument("--start-maximized")
    
    #chrome_options.add_argument('--headless')  # 无头模式
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--ignore-certificate-errors')
    chrome_options.add_argument('--ignore-ssl-errors')
    chrome_options.add_argument('--allow-insecure-localhost')
    chrome_options.add_argument('--disable-web-security')

    driver = webdriver.Chrome(options=chrome_options)
    driver.get(url)
    time.sleep(2)
    return driver

# 登录功能
def login(driver, username, password):
    driver.find_element(By.XPATH, '//*[@id="login"]').send_keys(username)
    driver.find_element(By.XPATH, '//*[@id="password"]').send_keys(password)
    captcha_code = input("请输入验证码：")
    driver.find_element(By.XPATH, '//*[@id="textfield"]').send_keys(captcha_code)
    driver.find_element(By.XPATH, '//*[@id="submit_login_sub"]').click()
    time.sleep(3)

# 判断验证码是否正确
def code_judge(driver, captcha):
    captcha_field = driver.find_element(By.XPATH, '//*[@id="textfield"]')
    captcha_field.clear()
    captcha_field.send_keys(captcha)
    driver.find_element(By.XPATH, '//*[@id="submit_login_sub"]').click()
    time.sleep(3)
    try:
        driver.find_element(By.XPATH, '//*[@id="message"]')
        return False
    except:
        return True

def jump_to_trust_page_and_confirm(driver):
    iframe = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, 'iframe[src*="set_trust.html"]'))
    )
    trust_url = iframe.get_attribute("src")
    print(f"🎯 已获取弹窗链接：{trust_url}")

    # 3. 跳转到 iframe 链接（在当前窗口打开）
    driver.get(trust_url)
    print("已跳转到设置可信的页面")

    # 4. 选择“永久可信”
    radio_permanent = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.ID, "trust_type_1"))
    )
    radio_permanent.click()
    print("✅ 已选择“永久可信”选项")

    time.sleep(0.5)  # JS 有点慢，等待选项应用

    # 5. 点击“确定”按钮
    confirm_btn = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.ID, "sub_btn"))
    )
    confirm_btn.click()
    print("🎉 已点击“确定”，等待结果...")

def ego_to_mac_trust_page(driver):
    print("正在跳转到“首页”界面以操作 MAC 可信...")

    # 进入首页
    current_url = driver.current_url.split("key=")[1]
    jump_url = f"https://nac.sunline.cn/tp/index.html?sysflag=1&key={current_url}"
    driver.get(jump_url)
    time.sleep(2)

    # 悬停“全网资源”
    menu = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '//span[text()="全网资源"]'))
    )
    ActionChains(driver).move_to_element(menu).perform()
    time.sleep(1)

    # 点击“设备视图”
    device_view = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '/html/body/table/tbody/tr[1]/td/div/div/table/tbody/tr/td[2]/table/tbody/tr/td[1]/div/div/div[1]/ul/li[3]/a[2]/div'))
    )
    driver.execute_script("arguments[0].click();", device_view)
    time.sleep(3)

    # 切换 iframe[1]，点击“用户设备”
    iframe1 = WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.ID, "jerichotabiframe_1"))
    )
    driver.switch_to.frame(iframe1)
    user_device_btn = WebDriverWait(driver, 15).until(
        EC.element_to_be_clickable((By.XPATH, '//a[contains(@onclick, "networkclient.html")]'))
    )
    driver.execute_script("arguments[0].click();", user_device_btn)
    driver.switch_to.default_content()

    # 切换 iframe[2]
    iframe2 = WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.ID, "jerichotabiframe_2"))
    )
    driver.switch_to.frame(iframe2)

    # 筛选「开机、不可信、苹果PC」
    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, '//button[contains(text(), "高级搜索")]'))).click()
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "networkclient_List_SearchFilter_status"))).find_element(By.XPATH, './option[@value="1"]').click()
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "networkclient_List_SearchFilter_IsTrustDev"))).find_element(By.XPATH, './option[@value="0"]').click()
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "networkclient_List_Type"))).find_element(By.XPATH, './option[@value="110"]').click()
    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, '//button[contains(text(), "确定")]'))).click()

    print("已完成对苹果PC类型不可信设备的筛选，等待数据加载...")

    # 勾选所有行
    try:
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.XPATH, '//table[@id="networkclient_mid"]/tbody/tr[contains(@id, "networkclient_tr_")]'))
        )
        time.sleep(1)
        rows = driver.find_elements(By.XPATH, '//table[@id="networkclient_mid"]/tbody/tr[contains(@id, "networkclient_tr_")]')
        print(f"共找到 {len(rows)} 行设备数据")

        for idx, row in enumerate(rows):
            try:
                checkbox = row.find_element(By.XPATH, './/input[@type="checkbox"]')
                driver.execute_script("arguments[0].click();", checkbox)
                print(f"第 {idx + 1} 行设备已勾选")
            except Exception as e:
                print(f"第 {idx + 1} 行设备无法勾选：{e}")
    except Exception as e:
        print("未找到设备行")
        raise e

    selected = driver.find_elements(By.XPATH, '//input[@type="checkbox" and @checked]')
    print(f"已勾选 {len(selected)} 台设备")

    # 提取已选中的 device_ids
    checked_rows = driver.find_elements(By.XPATH, '//table[@id="networkclient_mid"]/tbody/tr[contains(@id, "networkclient_tr_")]/td[1]/input[@checked]')
    device_ids = [row.get_attribute("value") for row in checked_rows]
    device_ids_str = ",".join(device_ids)
    print(f"当前 device_ids: {device_ids_str}")

    # 点击“批量操作” -> “设置可信”
    driver.execute_script("arguments[0].click();", WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[@btntype='Multi_Menu' and @tradcode='device']"))
    ))
    print("点击“批量操作”菜单")

    driver.execute_script("arguments[0].click();", WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//tr[@class='items' and contains(@onclick, 'SetTrust')]"))
    ))


    jump_to_trust_page_and_confirm(driver)


def main():
    login_url = "https://nac.sunline.cn/tp/login.html"
    driver = create_driver(login_url)
    login(driver, Nac_User, Nac_Password)

    ego_to_mac_trust_page(driver)
    print("跳转完成。")
    input("已跳转用户账户页面，按 Enter 键退出程序：")


if __name__ == "__main__":
    main()
