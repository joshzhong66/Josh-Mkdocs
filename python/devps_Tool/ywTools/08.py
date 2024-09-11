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

        format1 = cleaned_mac[:2] + "-" + cleaned_mac[2:4] + "-" + cleaned_mac[4:6] + "-" + cleaned_mac[6:8] + "-" + cleaned_mac[8:10] + "-" + cleaned_mac[10:12]
        format2 = cleaned_mac[:2] + ":" + cleaned_mac[2:4] + ":" + cleaned_mac[4:6] + ":" + cleaned_mac[6:8] + ":" + cleaned_mac[8:10] + ":" + cleaned_mac[10:12]
        format3 = cleaned_mac[:2] + cleaned_mac[2:4] + "-" + cleaned_mac[4:8] + "-" + cleaned_mac[8:12]

        results.append((format1, format2, format3))

    result_label.config(text="转换后的MAC地址：\n" + "\n".join([f"格式1: {res[0]}\n格式2: {res[1]}\n格式3: {res[2]}\n" for res in results]))

    copy_button.config(command=lambda: copy_to_clipboard("\n".join([f"{res[0]}\n{res[1]}\n{res[2]}\n" for res in results])))

root = tk.Tk()
root.title("MAC地址转换工具")
root.geometry("500x400") 


instruction_label = tk.Label(root, text="请输入MAC地址（可包含-或:），每个MAC地址占一行，点击按钮转换格式：")
instruction_label.pack()

entry = tk.Text(root, height=10, width=50)
entry.pack()

button = tk.Button(root, text="转换MAC地址格式", command=convert_mac)
button.pack()

result_label = tk.Label(root, text="")
result_label.pack()

copy_button = tk.Button(root, text="复制转换后的MAC地址")
copy_button.pack()

root.mainloop()
