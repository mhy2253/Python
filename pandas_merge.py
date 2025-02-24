import pandas as pd
df_1 = pd.read_excel(r'C:\Users\carrot\OneDrive\文档\Python\data_1.xlsx', sheet_name='sheet1')
df_2 = pd.read_excel(r'C:\Users\carrot\OneDrive\文档\Python\data_2.xlsx', sheet_name='sheet1')
df_3 = pd.merge(df_1,df_2,how='inner',on=['valu','valu2'])
print(df_3.head())
df_3.to_excel('./output.xlsx',index=False)