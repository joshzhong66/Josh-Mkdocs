import datetime
import os
import sys
import time

from tkinter import Tk, StringVar, filedialog
from tkinter.scrolledtext import ScrolledText
from ttkbootstrap import Label, Entry, Button, Style, Frame, Progressbar
from ttkbootstrap.constants import *
from ttkbootstrap.dialogs import Messagebox
from PIL import Image, ImageTk
from excel_operate import get_current_date
from selenium.webdriver.common.by import By


def log_error(message):
    Messagebox.show_error(message, title="错误信息！", alert=True)


def log_info(message):
    Messagebox.show_info(message, title="提示信息", alert=False)


def get_current_time():
    return datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')


def log_message(textbox, message):
    textbox.insert(END, f"{get_current_time()} - {message}\n")
    textbox.see(END)  # 自动滚动到最后一行
    textbox.update()  # 实时更新最新的文本框状态


def done_bar_txt(textbox, message, done_bar, done_txt, i, count):
    textbox.insert(END, f"{get_current_time()} - {message}\n")
    textbox.see(END)
    if count:
        done_bar["value"] = int(i / count * 100)
        done_txt.set(f"{i}/{count}")
    else:
        done_bar["value"] = 0
        done_txt.set("")
    textbox.update()


def delete_file():
    base_dir = os.path.join(os.path.expanduser("~"), "Downloads")
    # 删除验证码截图文件
    image_path = os.path.join(base_dir, "screenshot.png")
    if os.path.exists(image_path):
        os.remove(image_path)
    # 删除nac导出excel文件
    nac_file = os.path.join(base_dir, f"导出用户账户列表{get_current_date()}.xls")
    if os.path.exists(nac_file):
        os.remove(nac_file)
    # 删除合并后的excel文件
    merge_file = os.path.join(base_dir, f"matched_emails_departments_{get_current_date()}.xlsx")
    if os.path.exists(merge_file):
        os.remove(merge_file)
    # 删除查询离职用户后的excel文件
    delete_user_file = os.path.join(base_dir, f"matched_not_emails_{get_current_date()}.xlsx")
    if os.path.exists(delete_user_file):
        os.remove(delete_user_file)


class CaptchaGUI(object):
    def __init__(self, master, driver=None):
        self.master = master
        self.driver = driver
        self.master.title("准入行为系统")    # 给主窗口设置标题内容
        self.master.geometry("780x650")    # 设置窗口大小
        self.master.protocol('WM_DELETE_WINDOW', self.my_close)  # 关闭窗口添加一个响应事件

        self.file_path = StringVar()     # 存储上传的Excel文件路径
        self.graphic_code = StringVar()  # 存储图形码
        self.done_txt = StringVar()      # 进度条加载
        self.button_clicked = False      # 初始化启动程序状态
        self.login_judge = False         # 判断是否登录

        self.create_widgets()  # 布局窗口控件

    def create_widgets(self):
        self.create_labels()
        self.create_entries()
        self.create_buttons()
        self.create_info_log()

    def create_labels(self):
        self.text_prompts_lbl = Label(self.master, text="提示：先上传Boss用户表，再点击启动", font=("宋体", 12),
                                      bootstyle=DANGER)
        self.upload_excel_lbl = Label(self.master, text="Excel文件：", font=("宋体", 12))
        self.loading_image_lbl = Label(self.master, text="请输入验证码：", font=("宋体", 12))

        self.text_prompts_lbl.place(x=245, y=55)
        self.upload_excel_lbl.place(x=173, y=100)
        self.loading_image_lbl.place(x=150, y=140)

    def create_entries(self):
        # 上传 Excel文件 && 验证码
        self.upload_excel_entry = Entry(master=self.master, width=35, textvariable=self.file_path)
        self.image_captcha_entry = Entry(master=self.master, width=35, textvariable=self.graphic_code)

        self.upload_excel_entry.place(x=260, y=95)
        self.image_captcha_entry.place(x=260, y=135)

    def create_buttons(self):
        # 启动程序
        self.start_button = Button(self.master, text="启 动 程 序", width=10, bootstyle=SUCCESS, cursor="hand2",
                                   command=self.program_startup)
        self.start_button.place(x=270, y=10)
        # 关闭程序
        self.start_button = Button(self.master, text="关 动 程 序", width=10, bootstyle=SUCCESS, cursor="hand2",
                                   command=self.program_shutdown)
        self.start_button.place(x=410, y=10)
        # 浏览按钮
        self.browse_button = Button(self.master, text="浏 览", width=4, bootstyle=INFO, cursor="hand2",
                                    command=self.browse_file)
        self.browse_button.place(x=530, y=95)
        # 登录按钮
        self.login_button = Button(self.master, text="登 录", width=4, bootstyle=INFO, cursor="hand2",
                                     command=self.login_execution)
        self.login_button.place(x=530, y=135)
        # 修改按钮
        self.modify_button = Button(self.master, text="修 改", width=4, bootstyle=INFO, cursor="hand2",
                                     command=self.modify_execution)
        self.modify_button.place(x=300, y=175)
        # 删除按钮
        self.delete_button = Button(self.master, text="删 除", width=4, bootstyle=INFO, cursor="hand2",
                                     command=self.delete_execution)
        self.delete_button.place(x=420, y=175)

    def create_info_log(self):
        # 日志信息
        self.log = Label(master=self.master, text="日志信息：", font=("宋体", 12), style=SUCCESS)

        style = Style()
        self.textbox = ScrolledText(
            master=self.master,
            highlightcolor=(style.colors.primary),
            highlightbackground=(style.colors.border),
            highlightthickness=1,
            height=20,
            width=105)

        self.container2 = Frame(self.master)
        # 已完成
        self.done = Label(master=self.container2, text="已完成:", style=DANGER)
        # 进度条方框
        self.done_bar = Progressbar(
            master=self.container2,
            orient=HORIZONTAL,
            value=0,
            bootstyle=(SUCCESS, STRIPED))
        # 进度条加载
        self.txt_done = Label(master=self.container2, textvariable=self.done_txt, style=SUCCESS)

        self.log.place(x=10, y=240)
        self.textbox.place(x=10, y=270)
        self.container2.place(x=10, y=625, width=770)
        self.done.pack(side=LEFT)
        self.done_bar.pack(fill=X, padx=5, pady=5, expand=YES, side=LEFT)
        self.txt_done.pack(padx=5, side=LEFT)

    def load_image(self, driver):
        base_dir = os.path.join(os.path.expanduser("~"), "Downloads")
        image_path = os.path.join(base_dir, "screenshot.png")
        driver.save_screenshot(image_path)  # 捕获整个屏幕截图
        self.image_file = Image.open(image_path)  # 加载图片

        # 获取验证码图片元素的位置和尺寸
        captcha_element = driver.find_element(By.CSS_SELECTOR,'.login_content .center .input ul .code img')
        location = captcha_element.location
        size = captcha_element.size

        # 计算裁剪区域的坐标
        x1 = location['x']
        y1 = location['y']
        x2 = x1 + size['width']  # 使用元素宽度
        y2 = y1 + size['height']  # 使用元素高度

        # 裁剪验证码图片
        cropped_image = self.image_file.crop((x1, y1, x2, y2))  
        resized_image = cropped_image.resize((120, 40))  # 修改图片大小
        self.loading_image_photo = ImageTk.PhotoImage(resized_image)
        self.image_label = Label(self.master, image=self.loading_image_photo)  # 使用Label来显示图片
        self.image_label.place(x=320, y=220)

    def browse_file(self):
        # 打开文件选择框并将路径填入Excel输入框
        file_path = filedialog.askopenfilename(
            title="选择Excel文件",
            filetypes=[("Excel文件", "*.xls *.xlsx")]
        )
        if not file_path:
            return
        self.file_path.set(file_path)

    def login_execution(self):
        # 获取用户输入的验证码并执行操作
        captcha = self.graphic_code.get()  # 获取用户输入的验证码

        if not self.driver:
            log_error("请先启动程序再执行！")
            return
        elif not captcha:
            log_error("验证码不能为空，请重新输入！")
            return

        log_message(self.textbox, f"输入验证码：{captcha}")
        from login_nac import code_judge
        captcha_judge = code_judge(self.driver, captcha)

        if not captcha_judge:
            log_message(self.textbox, f"验证码错误，请重新输入！")
            self.load_image(self.driver)
            return

        log_message(self.textbox, "登录准入系统成功！请执行相关操作...")
        self.login_judge = True

    def modify_execution(self):
        if not self.login_judge:
            log_error("请先登录系统！")
            return

        xlsx_file = self.file_path.get()  # 获取excel文件路径
        if not os.path.exists(xlsx_file):
            log_error("Excel文件路径不能为空或文件不存在，请重新检查！")
            return

        from login_nac import export_excel_judge, modify_execution
        excel_judge = export_excel_judge(self.textbox, self.driver, "modify")

        if not excel_judge or not modify_execution(self.driver, self.textbox, self.done_bar, self.done_txt, xlsx_file):
            log_message(self.textbox, "未检测到有新的准入用户存在.")

        self.close_system()

    def delete_execution(self):
        if not self.login_judge:
            log_error("请先登录系统！")
            return

        xlsx_file = self.file_path.get()  # 获取excel文件路径
        if not os.path.exists(xlsx_file):
            log_error("Excel文件路径不能为空或文件不存在，请重新检查！")
            return

        from login_nac import export_excel_judge, delete_execution
        export_excel_judge(self.textbox, self.driver, "delete")
        if not delete_execution(self.driver, self.textbox, self.done_bar, self.done_txt, xlsx_file):
            log_message(self.textbox, "未检测到有离职用户存在.")

        self.close_system()

    def program_startup(self):
        # 点击开始启动程序
        if not self.button_clicked:
            self.button_clicked = True

            from login_nac import login_sys
            done_bar_txt(self.textbox, "准入系统开启中...", self.done_bar, self.done_txt, 0, 0)
            self.driver = login_sys("https://nac.sunline.cn/tp/login.html", self.textbox)
            self.load_image(self.driver)
        else:
            log_info("程序已在执行，请勿重复启动！")

    def program_shutdown(self):
        # 点击关闭程序
        if self.button_clicked:
            self.button_clicked = False

            self.driver.quit()
            delete_file()
            log_message(self.textbox, "准入系统已关闭.")
            self.image_label.place_forget()
        else:
            log_info("程序已停止，请勿重复关闭！")

    def close_system(self):
        log_message(self.textbox, "执行完成.")
        delete_file()
        res = Messagebox.yesno(title="提示", message="是否退出系统？")
        if res == "Yes" or res == "确认":
            self.on_quit()
            log_message(self.textbox, "退出系统.\n")

    def my_close(self):
        if self.button_clicked:
            log_info("请先关闭程序后再退出！")
            return
        delete_file()
        sys.exit(0)

    def on_quit(self):
        if self.driver:
            self.driver.quit()
            self.button_clicked = False
        self.image_label.place_forget()


if __name__ == "__main__":
    root = Tk()
    CaptchaGUI(root)
    root.resizable(False, False)  # 锁定窗体尺寸
    icon_path = os.path.join(os.path.dirname(__file__), 'sunline.ico')
    root.iconbitmap(icon_path)
    root.mainloop()
