import tkinter as tk
import pyperclip

def copy_to_clipboard(mac_address):
    pyperclip.copy(mac_address)
    print(f"已复制MAC地址到剪贴板: {mac_address}")

def convert_mac():
    source_macs = entry.get("1.0", tk.END).strip().split('\n')

    results = []
    for source_mac in source_macs:
        cleaned_mac = source_mac.replace("-", "").replace(":", "")

        # 转换为第一种格式
        format1 = cleaned_mac[:2] + "-" + cleaned_mac[2:4] + "-" + cleaned_mac[4:6] + "-" + cleaned_mac[6:8] + "-" + cleaned_mac[8:10] + "-" + cleaned_mac[10:12]

        # 转换为第二种格式
        format2 = cleaned_mac[:2] + ":" + cleaned_mac[2:4] + ":" + cleaned_mac[4:6] + ":" + cleaned_mac[6:8] + ":" + cleaned_mac[8:10] + ":" + cleaned_mac[10:12]

        # 转换为第三种格式
        format3 = cleaned_mac[:2] + cleaned_mac[2:4] + "-" + cleaned_mac[4:8] + "-" + cleaned_mac[8:12]

        results.append((format1, format2, format3))

    result_label.config(text="转换后的MAC地址：\n" + "\n".join([f"格式1: {res[0]}\n格式2: {res[1]}\n格式3: {res[2]}\n" for res in results]))

    # 添加复制按钮
    selected_format = format_var.get()
    if selected_format == "格式1":
        copy_button.config(command=lambda: copy_to_clipboard("\n".join([res[0] + "\n" for res in results])))
    elif selected_format == "格式2":
        copy_button.config(command=lambda: copy_to_clipboard("\n".join([res[1] + "\n" for res in results])))
    elif selected_format == "格式3":
        copy_button.config(command=lambda: copy_to_clipboard("\n".join([res[2] + "\n" for res in results])))

# 创建GUI界面
root = tk.Tk()
root.title("MAC地址转换工具")
root.geometry("700x600")    #设置窗口大小

# 使用说明
instruction_label = tk.Label(root, text="请输入MAC地址（可包含-或:），每个MAC地址占一行，选择要复制的格式，点击按钮转换格式并复制：")
instruction_label.pack()

# 输入框
entry = tk.Text(root, height=10, width=50)
entry.pack()

# 下拉框
format_var = tk.StringVar(root)
format_var.set("格式1")  # 默认选择格式1
format_dropdown = tk.OptionMenu(root, format_var, "格式1", "格式2", "格式3")
format_dropdown.pack()

# 按钮
button = tk.Button(root, text="转换MAC地址格式并复制", command=convert_mac)
button.pack()

# 结果显示标签
result_label = tk.Label(root, text="")
result_label.pack()

# 复制按钮
copy_button = tk.Button(root, text="复制选定格式的MAC地址")
copy_button.pack()

root.mainloop()
