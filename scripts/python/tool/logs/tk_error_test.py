import tkinter as tk
from tkinter import messagebox

def log_error(message):
    messagebox.showerror("错误信息!", message)

def log_info(message):
    messagebox.showinfo("提示信息!", message)

root = tk.Tk()
root.title("错误演示程序")

def trigger_error():
    log_error("这是一个模拟的错误信息！")

def trigger_info():
    log_info("这是一个模拟的提示信息！")

info_button = tk.Button(root, text="触发提示", command=trigger_info)
info_button.pack()

error_button = tk.Button(root, text="触发错误", command=trigger_error)
error_button.pack()

root.geometry("300x200")
root.mainloop()