# 运行之前请先安装python和python库。可以使用如下命令安装
# pip install pandas openpyxl -i https://pypi.tuna.tsinghua.edu.cn/simple
# 来自哈七搭八的小猴子的提醒：任何操作之前请先备份

import os
import pandas as pd

# 获取当前目录
current_directory = os.getcwd()

# 遍历当前目录中的所有文件
for filename in os.listdir(current_directory):
    # 只处理 .xlsx 文件
    if filename.endswith('.xlsx'):
        input_file = os.path.join(current_directory, filename)
        output_file = os.path.splitext(input_file)[0] + '.csv'  # 生成相应的 .csv 文件名

        # 读取 Excel 文件
        df = pd.read_excel(input_file)

        # 用 'null' 替代空值
        df.fillna('null', inplace=True)

        # 将数据框转换为 CSV，使用分号作为分隔符
        df.to_csv(output_file, sep=';', index=False, encoding='utf-8-sig')

        print(f'转换完成！{filename} 已保存为: {output_file}')
