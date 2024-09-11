import tkinter as tk
from tkinter import filedialog

def replace_text(file_path, replacements):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = file.read()
        for old_text, new_text in replacements.items():
            data = data.replace(old_text, new_text)
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(data)

def open_file():
    path = filedialog.askopenfilename()
    if path:
        entry_file_path.delete(0, tk.END)
        entry_file_path.insert(0, path)

def start_replacement():
    file_path = entry_file_path.get()
    replacements_str = entry_replacements.get()
    replacements_list = replacements_str.split(',')
    replacements = {}
    for replacement in replacements_list:
        old_new_pair = replacement.split('=')
        if len(old_new_pair) == 2:
            replacements[old_new_pair[0].strip()] = old_new_pair[1].strip()
    replace_text(file_path, replacements)

root = tk.Tk()
root.title("文本替换工具")

frame = tk.Frame(root)
frame.pack(pady=10)

entry_file_path = tk.Entry(frame, width=50)
entry_file_path.pack(side=tk.LEFT, padx=5)
button_browse = tk.Button(frame, text="浏览", command=open_file)
button_browse.pack(side=tk.LEFT)

label_replacements = tk.Label(root, text="替换规则（格式：旧文本1=新文本1, 旧文本2=新文本2）")
label_replacements.pack()
entry_replacements = tk.Entry(root, width=50)
entry_replacements.pack()

button_replace = tk.Button(root, text="替换", command=start_replacement)
button_replace.pack(pady=5)

root.mainloop()
