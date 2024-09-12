import tkinter as tk
from tkinter import filedialog
import pandas as pd

def upload_file():
    file_path = filedialog.askopenfilename(filetypes=[("CSV files", "*.csv")])
    if file_path:
        df = pd.read_csv(file_path)
        print(df.head())  # 打印前五行作为示例

# 创建主窗口
root = tk.Tk()
root.title("CSV上传器")

# 创建上传按钮
upload_button = tk.Button(root, text="上传CSV文件", command=upload_file)
upload_button.pack(pady=20)

# 运行主循环
root.mainloop()
