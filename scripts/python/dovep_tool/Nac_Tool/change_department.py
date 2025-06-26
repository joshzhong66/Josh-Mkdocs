import time

from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from main import log_message, done_bar_txt


class DepartmentAssigner:
    def __init__(self, df, driver, textbox, done_bar, done_txt):
        self.df = df
        self.driver = driver
        self.textbox = textbox
        self.done_bar = done_bar
        self.done_txt = done_txt
        self.message = ""
        log_message(self.textbox, "部门模块已初始化,开始执行分配部门...")

        # 部门XPath映射
        self.department_xpath_mappings = {
            "长亮科技": '//*[@id="def44"]/table/tbody/tr/td[4]/a',
            "集团总裁办": '//*[@id="def83"]/table/tbody/tr/td[4]/a',
            "总裁办公室": '//*[@id="def47"]/table/tbody/tr/td[4]/a',
            "董事会办公室": '//*[@id="def45"]/table/tbody/tr/td[4]/a',
            "干部部": '//*[@id="def82"]/table/tbody/tr/td[4]/a',
            "战略规划部": '//*[@id="def62"]/table/tbody/tr/td[4]/a',
            "集团产品发展部": '//*[@id="def93"]/table/tbody/tr/td[4]/a',
            "研发体系": '//*[@id="def92"]/table/tbody/tr/td[4]/a',
            "研发中心": '//*[@id="def58"]/table/tbody/tr/td[4]/a',
            "销售总部": '//*[@id="def48"]/table/tbody/tr/td[4]/a',
            "集团解决方案部": '//*[@id="def84"]/table/tbody/tr/td[4]/a',
            "市场部": '//*[@id="def90"]/table/tbody/tr/td[4]/a',
            "集团项目管理部": '//*[@id="def88"]/table/tbody/tr/td[4]/a',
            "运营中心": '//*[@id="def50"]/table/tbody/tr/td[4]/a',
            "北京运营中心": '//*[@id="def85"]/table/tbody/tr/td[4]/a',
            "财务中心": '//*[@id="def56"]/table/tbody/tr/td[4]/a',
            "人力资源中心": '//*[@id="def53"]/table/tbody/tr/td[4]/a',
            "共享服务中心": '//*[@id="def57"]/table/tbody/tr/td[4]/a',
            "信息服务部": '//*[@id="def60"]/table/tbody/tr/td[4]/a',
            "内部审计部": '//*[@id="def59"]/table/tbody/tr/td[4]/a',
            "税务部": '//*[@id="def87"]/table/tbody/tr/td[4]/a',
            "公共关系部": '//*[@id="def61"]/table/tbody/tr/td[4]/a',
            "健康督导办公室": '//*[@id="def86"]/table/tbody/tr/td[4]/a',
            "战略发展部": '//*[@id="def94"]/table/tbody/tr/td[4]/a',
            "数据总部": '//*[@id="def65"]/table/tbody/tr/td[4]/a',
            "数金总部": '//*[@id="def66"]/table/tbody/tr/td[4]/a',
            "长亮合度": '//*[@id="def67"]/table/tbody/tr/td[4]/a',
            "长亮金服": '//*[@id="def71"]/table/tbody/tr/td[4]/a',
            "长亮控股": '//*[@id="def73"]/table/tbody/tr/td[4]/a',
            "临时用户": '//*[@id="def40"]/table/tbody/tr/td[4]/a',
            "来宾用户": '//*[@id="def39"]/table/tbody/tr/td[4]/a',
            "前程无忧社保咨询": '//*[@id="def91"]/table/tbody/tr/td[4]/a'
        }

    def assign_department_to_all_user(self):
        for index, row in self.df.iterrows():
            email = row['email']
            department_name = row['Department']

            # 根据部门名称找到对应的 XPath
            department_xpath = self.department_xpath_mappings.get(department_name)
            if not department_xpath:
                self.message = f"未找到 {department_name} 对应的选择器，跳过 {email}"
                done_bar_txt(self.textbox, self.message, self.done_bar, self.done_txt, index + 1, len(self.df))
                continue

            try:
                # 找到用户行
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

                    # 点击批量操作按钮并选择“更改部门”
                    self.select_change_department_option()

                    # 切换到包含部门选择的iframe并选择部门
                    self.select_department_in_iframe(department_xpath)

                    # 确认选择
                    self.confirm_department_selection(email, department_name)

            except StaleElementReferenceException:
                self.message = f"{email} 的页面元素已失效，重新加载后重试"
            except Exception as e:
                self.message = f"为 {email} 分配部门时出错：{e}"

            done_bar_txt(self.textbox, self.message, self.done_bar, self.done_txt, index + 1, len(self.df))
            time.sleep(1)

    def select_change_department_option(self):
        # 点击批量操作按钮
        batch_operation_button = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, '//*[@id="All_btn"]/span/a'))
        )
        batch_operation_button.click()

        # 点击更改部门按钮
        option = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.XPATH, '/html/body/div[2]/div[2]/table/tbody/tr/td[3]/div/div[2]'
                                                      '/table/tbody/tr/td[1]/span[2]/div/table/tbody/tr[1]/td[2]'))
        )
        option.click()

    def select_department_in_iframe(self, department_xpath):
        # 切换到iframe
        iframe = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//iframe[@name='Opendepart_tree_box']"))
        )
        self.driver.switch_to.frame(iframe)

        # 定位并点击指定部门
        department_element = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.XPATH, department_xpath))
        )
        self.driver.execute_script("arguments[0].click();", department_element)
        time.sleep(1)

        # 切换回主页面
        self.driver.switch_to.default_content()

    def confirm_department_selection(self, email, department_name):
        # 点击确定按钮
        confirm_button = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH,  '//*[@id="body_id_zh_en"]/div[1]/div/table/tbody/'
                                                   'tr[2]/td[2]/div/table/tbody/tr[3]/td/div/button[1]'))
        )
        confirm_button.click()

        self.message = f"已成功为 {email} 分配部门：{department_name}"
