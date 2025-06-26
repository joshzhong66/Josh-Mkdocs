import pandas as pd

"""
脚本说明：读取excel表格，将第二行开始的第一列数据，以'/'拼接，打印字段
依赖：pip install openpyxl pandas
"""
excel_path = r'E:\vpn_excel\vpn1.xlsx'
df = pd.read_excel(excel_path)
data = df.iloc[1:, 0].apply(lambda x: str(x).strip()).tolist() 
result = '/'.join(data) + '/'
print(result)



