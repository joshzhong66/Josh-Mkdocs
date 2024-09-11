import tkinter as tk
from tkinter import filedialog
import os

def replace_text(file_path, old_text, new_text):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = file.read()
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
    old_text = entry_old_text.get()
    new_text = entry_new_text.get()
    replace_text(file_path, old_text, new_text)

root = tk.Tk()
root.title("Text Replacer")

frame = tk.Frame(root)
frame.pack(pady=10)

entry_file_path = tk.Entry(frame, width=50)
entry_file_path.pack(side=tk.LEFT, padx=5)
button_browse = tk.Button(frame, text="Browse", command=open_file)
button_browse.pack(side=tk.LEFT)

label_old_text = tk.Label(root, text="Old Text")
label_old_text.pack()
entry_old_text = tk.Entry(root, width=50)
entry_old_text.pack()

label_new_text = tk.Label(root, text="New Text")
label_new_text.pack()
entry_new_text = tk.Entry(root, width=50)
entry_new_text.pack()

button_replace = tk.Button(root, text="Replace", command=start_replacement)
button_replace.pack(pady=5)

root.mainloop()
