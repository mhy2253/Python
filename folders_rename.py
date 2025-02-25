import os
import pandas as pd

# 读取映射表
mapping_file = r'D:\Desktop\rename\rename.xlsx'  # 你的映射文件
folder_path = r'D:\Desktop\rename'  # 文件夹所在目录

# 读取 CSV 文件
df = pd.read_excel(mapping_file, dtype=str)  # 读取为字符串，防止数字格式化问题
mapping = dict(zip(df["订单号"], df["编号"]))  # 创建映射字典

# 遍历文件夹并重命名
for order_id, serial_number in mapping.items():
    old_folder = os.path.join(folder_path, order_id)
    new_folder = os.path.join(folder_path, serial_number)
    if os.path.exists(old_folder):
        os.rename(old_folder, new_folder)
        print(f"已重命名: {old_folder} -> {new_folder}")
    else:
        print(f"未找到文件夹: {old_folder}")

print("批量重命名完成！")
