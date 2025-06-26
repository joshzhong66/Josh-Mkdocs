import time
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from main import log_message, done_bar_txt


class RoleAssignment:
    def __init__(self, df, driver, textbox, done_bar, done_txt):
        self.df = df
        self.driver = driver
        self.textbox = textbox
        self.done_bar = done_bar
        self.done_txt = done_txt
        self.message = ""
        log_message(self.textbox, "角色模块已初始化,开始执行分配角色...")

        self.department_to_role_name = {
            "数据总部": "数据总部角色",
            "数金总部": "数金总部角色",
            "长亮合度": "长亮合度角色",
            "长亮金服": "长亮金服角色",
            "长亮控股": "长亮控股角色",
            "集团总裁办": "全网角色",
            "研发中心": "平台研发角色",
            "集团解决方案部": "集团解决方案角色",
            "财务中心": "财务系统角色",
            "信息运维中心": "BOSS开发角色",
            "内部审计部": "内审部角色",
            "总裁办公室": "职能角色",
            "董事会办公室": "职能角色",
            "干部部": "职能角色",
            "战略规划部": "职能角色",
            "集团产品发展部": "职能角色",
            "研发体系": "职能角色",
            "销售总部": "职能角色",
            "市场部": "职能角色",
            "集团项目管理部": "职能角色",
            "运营中心": "职能角色",
            "北京运营中心": "职能角色",
            "人力资源中心": "职能角色",
            "共享服务中心": "职能角色",
            "税务部": "职能角色",
            "公共关系部": "职能角色",
            "健康督导办公室": "职能角色",
            "战略发展部": "职能角色"
        }

        self.role_xpath_mappings = {
            "缺省角色": "//*[@id='box']/table/tbody/tr[1]",
            "来宾角色": "//*[@id='box']/table/tbody/tr[2]",
            "可信角色": "//*[@id='box']/table/tbody/tr[3]",
            "test": "//*[@id='box']/table/tbody/tr[4]",
            "财务系统角色": "//*[@id='box']/table/tbody/tr[5]",
            "临时角色": "//*[@id='box']/table/tbody/tr[6]",
            "BOSS开发角色": "//*[@id='box']/table/tbody/tr[7]",
            "运维角色": "//*[@id='box']/table/tbody/tr[8]",
            "平台研发角色": "//*[@id='box']/table/tbody/tr[9]",
            "职能角色": "//*[@id='box']/table/tbody/tr[10]",
            "长亮合度角色": "//*[@id='box']/table/tbody/tr[11]",
            "数据总部角色": "//*[@id='box']/table/tbody/tr[12]",
            "数金总部角色": "//*[@id='box']/table/tbody/tr[13]",
            "长亮控股角色": "//*[@id='box']/table/tbody/tr[14]",
            "长亮金服角色": "//*[@id='box']/table/tbody/tr[15]",
            "内审角色": "//*[@id='box']/table/tbody/tr[16]",
            "全网角色": "//*[@id='box']/table/tbody/tr[17]",
            "考勤管理角色": "//*[@id='box']/table/tbody/tr[18]",
            "内网角色": "//*[@id='box']/table/tbody/tr[19]",
            "研发来宾码申请角色": "//*[@id='box']/table/tbody/tr[20]",
            "职能决策申请角色": "//*[@id='box']/table/tbody/tr[21]",
            "集团解决方案角色": "//*[@id='box']/table/tbody/tr[22]"
        }

    def assign_roles(self):
        # 遍历DataFrame，根据部门分配角色
        for index, row in self.df.iterrows():
            email = row['email']
            department = row['Department']

            # 根据部门找到角色名称和对应的 XPath
            role_name = self.department_to_role_name.get(department)
            role_xpath = self.role_xpath_mappings.get(role_name)
            if not role_xpath:
                self.message = f"未找到 {department} 对应的角色映射，跳过 {email}"
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

                    # 点击批量更改角色按钮
                    change_role_button = WebDriverWait(self.driver, 10).until(
                        EC.element_to_be_clickable((By.XPATH, '//*[@id="role_btn"]/span/a'))
                    )
                    change_role_button.click()

                    # 点击对应的角色
                    role_option = WebDriverWait(self.driver, 10).until(
                        EC.element_to_be_clickable((By.XPATH, role_xpath))
                    )
                    role_option.click()
                    self.message = f"已成功为 {email} 分配角色：{role_name}"
            except Exception as e:
                self.message = f"为 {email} 分配角色时出错：{e}"

            done_bar_txt(self.textbox, self.message, self.done_bar, self.done_txt, index + 1, len(self.df))
            time.sleep(1)
