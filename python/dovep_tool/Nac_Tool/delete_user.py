import time

from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from main import log_message, done_bar_txt


class DeleteUsers:
    def __init__(self, df, driver, textbox, done_bar, done_txt):
        self.df = df
        self.driver = driver
        self.textbox = textbox
        self.done_bar = done_bar
        self.done_txt = done_txt
        self.message = ""
        log_message(self.textbox, "开始执行删除离职用户...")

    def delete_nac_user(self):
        for index, row in self.df.iterrows():
            email = row['email']
            try:
                self.confirm_delete_user(email)
            except StaleElementReferenceException:
                self.message = f"{email} 的页面元素已失效，重新加载后重试"
            except Exception as e:
                self.message = f"删除 {email} 用户时出错：{e}"

            done_bar_txt(self.textbox, self.message, self.done_bar, self.done_txt, index + 1, len(self.df))
            time.sleep(1)

    def confirm_delete_user(self, email):
        # 找到 '过滤条件' 按钮
        filter_button = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="editor"]/a[1]'))
        )
        filter_button.click()

        # 输入用户帐户信息
        user_field = self.driver.find_element(By.XPATH, '//*[@id="userlist_List_SearchFilter_UserName"]')
        user_field.clear()
        user_field.send_keys(email)

        # 点击确定
        confirm1_button = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="body_id_zh_en"]/div[1]/div/table/tbody/tr[2]/td['
                                                  '2]/div/table/tbody/tr[3]/td/div/button[1]'))
        )
        confirm1_button.click()
        time.sleep(1)

        user_row = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located(
                (By.XPATH, f"//table[@id='userlist_mid']//tr[td[contains(text(), '{email}')]]"))
        )
        if user_row:
            user_row_id = user_row.get_attribute("id").split("_")[-1]
            # 找到并点击勾选按钮
            checkbox = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable((By.ID, f"row{user_row_id}_checkbox"))
            )
            checkbox.click()

        # 点击删除用户按钮
        delete_user_button = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="delUser_btn"]'))
        )
        delete_user_button.click()

        # 点击确定按钮
        confirm2_button = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="body_id_zh_en"]/div[1]/div/table/tbody/tr[2]/td['
                                                  '2]/div/table/tbody/tr[3]/td/div/button[1]'))
        )
        confirm2_button.click()

        self.message = f"已成功删除 {email} 用户"
