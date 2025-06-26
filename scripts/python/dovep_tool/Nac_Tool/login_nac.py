import os
import time
import pandas as pd

from password import Nac_User, Nac_Password

from excel_operate import merge_emails_and_departments, get_current_date, search_not_emails
from change_role import RoleAssignment
from change_department import DepartmentAssigner
from data_filtering import DataFiltering
from delete_user import DeleteUsers

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from main import log_message


def login_sys(url, textbox):  # 登录准入行为系统
    chrome_options = Options()

    # chrome_options.add_argument("--window-size=1920x1080")     # 固定窗口大小
    chrome_options.add_argument("--start-maximized")

    chrome_options.add_argument('--headless')  # 无头模式
    chrome_options.add_argument('--disable-gpu')  # 禁用 GPU，加快无头模式下的速度
    chrome_options.add_argument('--no-sandbox')  # 解决无头模式启动问题
    chrome_options.add_argument('--disable-dev-shm-usage')  # 解决无头模式启动问题

    chrome_options.add_argument('--ignore-certificate-errors')
    chrome_options.add_argument('--ignore-certificate-errors-spki-list')
    chrome_options.add_argument('--ignore-ssl-errors')
    chrome_options.add_argument('--allow-insecure-localhost')
    chrome_options.add_argument('--disable-web-security')

    driver = webdriver.Chrome(options=chrome_options)
    driver.get(url)
    time.sleep(3)

    driver.find_element(By.XPATH, '//*[@id="login"]').send_keys(Nac_User)
    log_message(textbox, f"输入账号：{Nac_User}")
    driver.find_element(By.XPATH, '//*[@id="password"]').send_keys(Nac_Password)
    log_message(textbox, f"输入密码：******")

    return driver


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


def export_excel_judge(textbox, driver, execute):
    log_message(textbox, "正在重定向到“用户账户列表”界面.")
    current_url = driver.current_url.split("key=")[1]
    page_jump_url = f"https://nac.sunline.cn/tp/mod/userinfo/userlist.html?menuid=97&TipScroll=baseCenter&key={current_url}"
    driver.get(page_jump_url)
    time.sleep(2)

    if execute == "modify":
        # 长亮科技用户-最顶层导航栏
        log_message(textbox, "点击“组织架构”栏顶层导航栏.")
        selprnnode_xpath = driver.find_element(By.XPATH, '//*[@id="def0"]/table/tbody/tr/td[4]/a')
        selprnnode_xpath.click()
        time.sleep(1)

        try:
            WebDriverWait(driver, 3).until(
                EC.presence_of_element_located(
                    (By.XPATH, f"//table[@id='userlist_mid']//tr[td[contains(text(), 'Email用户')]]"))
            )
        except:
            return False

        # 全选default用户
        log_message(textbox, "选中当前部门所有用户,导出为Excel文件.")
        select_all_user_xpath = driver.find_element(By.XPATH, '//*[@id="userlistallcheckbox"]/input')
        select_all_user_xpath.click()
        time.sleep(1)

        # 导出 Excel 文件，自动命名规则：导出用户账户列表20241023.xls（日期是变化的）
        export_excel_xpath = driver.find_element(By.XPATH, '//*[@id="left_departlist"]/div/div[1]/div[2]/i')
        export_excel_xpath.click()
        time.sleep(1)

        selprnnode_xpath.click()
        time.sleep(1)

        return True
    else:
        log_message(textbox, "导出所有用户为Excel文件.")
        export_excel_xpath = driver.find_element(By.XPATH, '//*[@id="left_departlist"]/div/div[1]/div[2]/i')
        export_excel_xpath.click()
        time.sleep(3)


def modify_execution(driver, textbox, done_bar, done_txt, xlsx_file):
    # 合并两个Excel文件
    base_dir = os.path.join(os.path.expanduser("~"), "Downloads")
    file_path = os.path.join(base_dir, f"导出用户账户列表{get_current_date()}.xls")
    file1_path = f"{file_path}"
    file2_path = f"{xlsx_file}"
    output_path = merge_emails_and_departments(file1_path, file2_path)

    if output_path:
        # 筛选部门数据
        dataFiltering = DataFiltering(pd.read_excel(output_path), output_path)
        dataFiltering.department_modification()

        # 角色分配
        roleAssignment = RoleAssignment(pd.read_excel(output_path), driver, textbox, done_bar, done_txt)
        roleAssignment.assign_roles()

        done_bar["value"] = 0
        done_txt.set("")
        textbox.update()

        # 部门分配
        departmentAssigner = DepartmentAssigner(pd.read_excel(output_path), driver, textbox, done_bar, done_txt)
        departmentAssigner.assign_department_to_all_user()

        return True
    else:
        return False


def delete_execution(driver, textbox, done_bar, done_txt, xlsx_file):
    # 筛选Excel文件中不存在的行
    base_dir = os.path.join(os.path.expanduser("~"), "Downloads")
    file_path = os.path.join(base_dir, f"导出用户账户列表{get_current_date()}.xls")
    file1_path = f"{file_path}"
    file2_path = f"{xlsx_file}"
    output_path = search_not_emails(file1_path, file2_path)

    if output_path:
        deleteusers = DeleteUsers(pd.read_excel(output_path), driver, textbox, done_bar, done_txt)
        deleteusers.delete_nac_user()

        return True
    else:
        return False
