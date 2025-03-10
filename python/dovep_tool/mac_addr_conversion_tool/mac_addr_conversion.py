import re
import pyperclip

from tkinter import font, messagebox
from tkinter import *


def is_valid_mac_address(mac):
    # 正则表达式匹配12个十六进制字符
    pattern = r'^[0-9A-Fa-f]{12}$'
    return bool(re.match(pattern, mac))


def convert_mac():
    source_macs = entry.get("1.0", END).strip().split('\n')

    # 清空结果区域
    for widget in result_frame.winfo_children():
        widget.destroy()

    # 检查MAC地址格式
    for source_mac in source_macs:
        cleaned_mac = source_mac.replace("-", "").replace(":", "")
        if not is_valid_mac_address(cleaned_mac):
            messagebox.showinfo("错误信息！", "MAC地址格式有误，请重新填写！", icon="error")
            return

    format1 = ''
    format2 = ''
    format3 = ''
    format4 = ''
    # 转换并显示MAC地址
    for index, source_mac in enumerate(source_macs):
        cleaned_mac = source_mac.replace("-", "").replace(":", "")

        # 转换格式如下
        format1 += cleaned_mac[:2] + "-" + cleaned_mac[2:4] + "-" + cleaned_mac[4:6] + "-" + cleaned_mac[6:8] + "-" + cleaned_mac[8:10] + "-" + cleaned_mac[10:12]
        format2 += cleaned_mac[:2] + ":" + cleaned_mac[2:4] + ":" + cleaned_mac[4:6] + ":" + cleaned_mac[6:8] + ":" + cleaned_mac[8:10] + ":" + cleaned_mac[10:12]
        format3 += cleaned_mac[:2] + cleaned_mac[2:4] + "-" + cleaned_mac[4:8] + "-" + cleaned_mac[8:12]
        format4 += cleaned_mac.upper()

        if len(source_macs) != 1 and index != len(source_macs) - 1:
            format1 += '\n'
            format2 += '\n'
            format3 += '\n'
            format4 += '\n'


    # 显示并创建复制按钮
    add_result_with_copy_button("格式1: \n" + format1, format1, "red")
    add_result_with_copy_button("格式2: \n" + format2, format2, "red")
    add_result_with_copy_button("格式3: \n" + format3, format3, "red")
    add_result_with_copy_button("格式4: \n" + format4, format4, "red")

    # 动态调整窗口高度
    root.update_idletasks()
    canvas.config(scrollregion=canvas.bbox("all"))


def add_result_with_copy_button(text, mac_address, color):
    result_label = Label(result_frame, text=text, font=bold_font, fg=color)
    result_label.pack(anchor='center', pady=2)
    copy_button = Button(result_frame, text="复制", command=lambda: copy_to_clipboard(mac_address), font=normal_font)
    copy_button.pack(anchor='center', pady=2)


def copy_to_clipboard(mac_address):
    pyperclip.copy(mac_address)
    messagebox.showinfo("复制成功", f"已复制MAC地址到剪贴板: \n{mac_address}", icon="info")


def on_mouse_wheel(event):
    # 支持鼠标滚轮滚动
    canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")


if __name__ == "__main__":
    root = Tk()
    root.title("MAC地址转换工具")
    root.geometry('600x400')

    bold_font = font.Font(family="Arial", size=12, weight="bold")
    normal_font = font.Font(family="Arial", size=10)

    instruction_label = Label(root, text="请输入MAC地址（支持任意格式），每个MAC地址占一行，点击按钮转换：", font=bold_font, justify="center")
    instruction_label.pack(pady=5)

    entry = Text(root, height=3, width=50, font=normal_font)
    entry.pack(pady=5)

    button = Button(root, text="点击转换MAC地址格式", command=convert_mac, font=bold_font)
    button.pack(pady=5)

    # 创建Canvas和Scrollbar
    canvas = Canvas(root)
    canvas.pack(side=LEFT, padx=(225, 0), expand=True)

    scrollbar = Scrollbar(root, orient=VERTICAL, command=canvas.yview)
    scrollbar.pack(side=RIGHT, fill=Y)

    canvas.configure(yscrollcommand=scrollbar.set)
    canvas.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))

    # 绑定鼠标滚轮事件
    canvas.bind_all("<MouseWheel>", on_mouse_wheel)

    # 将result_frame放入Canvas中
    result_frame = Frame(canvas)
    canvas.create_window((0, 0), window=result_frame, anchor="nw")

    root.resizable(False, False)  # 锁定窗体尺寸
    root.mainloop()  # 运行主循环
