import os
from tkinter import *

def enable_proxy():
    proxy_server = proxy_entry.get()
    
    # Enable proxy
    os.system('reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f')
    os.system(f'reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "{proxy_server}" /f')
    os.system('netsh winhttp import proxy source=ie')
    
    result_label.config(text=f'代理已修改为：{proxy_server}')
    
def disable_proxy():
    # Disable proxy
    os.system('reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f')
    os.system('netsh winhttp reset proxy')
    
    result_label.config(text='已关闭代理。')

# Create GUI
root = Tk()
root.title('Windows代理设置')

proxy_label = Label(root, text='代理服务器地址和端口：')
proxy_label.pack()

proxy_entry = Entry(root, width=30)
proxy_entry.pack()

enable_button = Button(root, text='启用代理', command=enable_proxy)
enable_button.pack()

disable_button = Button(root, text='关闭代理', command=disable_proxy)
disable_button.pack()

result_label = Label(root, text='')
result_label.pack()

root.mainloop()
