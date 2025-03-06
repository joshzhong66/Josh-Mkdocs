import os
import datetime
import pandas as pd
from datetime import datetime


def get_current_date():
    # 获取当前日期字符串，格式为：年-月-日
    return datetime.now().strftime("%Y%m%d")


def filter_emails(file_path, header_row):
    # 筛选Excel文件中包含邮箱的列和数据
    table = pd.read_excel(file_path, header=header_row)
    email_columns = table.apply(lambda col: col.astype(str).str.contains('@').any())  # 检查哪一列包含了电子邮件地址的格式，并返回所有布尔值
    tb_emails_only = table.loc[:, email_columns]  # 根据生成的 email_columns 所有布尔值，从中筛选出为 True 的电子邮件地址的列
    tb_emails_filtered = tb_emails_only.apply(
        lambda x: x if '@' in str(x) and not str(x).startswith('Guest') else None).dropna(how='all')
    return tb_emails_filtered


def merge_emails_and_departments(file1_path, file2_path):
    # 匹配两个Excel文件中的邮箱列并合并部门信息
    tb_emails_filtered = filter_emails(file1_path, 2)

    # 提取并重设索引
    emails_tb = tb_emails_filtered.stack().reset_index(drop=True)

    # 转换为DataFrame
    df_emails_tb = pd.DataFrame({'email': emails_tb})

    # 加入部门信息
    table = pd.read_excel(file2_path)
    table['Department'] = table.iloc[:, 0:3].apply(lambda x: ' '.join(x.dropna().astype(str)), axis=1)  # 合并3个部门

    # 判断合并连接结果是否存在email用户
    matched_emails = pd.merge(df_emails_tb, table, on='email', how='inner')

    if matched_emails.shape[0] > 1:   # 判断第二行是否存在内容，确保有至少两行
        base_dir = os.path.join(os.path.expanduser("~"), "Downloads")
        output_file = os.path.join(base_dir, f"matched_emails_departments_{get_current_date()}.xlsx")
        matched_emails.to_excel(output_file, index=False)

        return output_file
    else:
        return False


def search_not_emails(file1_path, file2_path):
    tb_emails_filtered = filter_emails(file1_path, 2)
    emails_tb = tb_emails_filtered.stack().reset_index(drop=True)
    df_emails_tb = pd.DataFrame({'email': emails_tb})

    # 获取第二个文件中的所有 email
    table = pd.read_excel(file2_path)
    emails_file2 = table['email'].str.lower().tolist()

    # 筛选出第一个文件中 email 不在第二个文件中的行
    matched_not_emails = df_emails_tb[~df_emails_tb['email'].str.lower().isin(emails_file2)]
    matched_not_emails1 = matched_not_emails[matched_not_emails['email'].str.contains('@', na=False)]

    if matched_not_emails1.shape[0] > 1:  # 判断第二行是否存在内容，确保有至少两行
        base_dir = os.path.join(os.path.expanduser("~"), "Downloads")
        output_file = os.path.join(base_dir, f"matched_not_emails_{get_current_date()}.xlsx")
        matched_not_emails1.to_excel(output_file, index=False)

        return output_file
    else:
        return False
