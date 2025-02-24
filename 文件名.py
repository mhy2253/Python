import os
import pandas as pd

path = r'C:\Users\carrot\Downloads\空调'
if not os.path.exists(path):
	raise FileNotFoundError(f"目录不存在: {path}")

folders = [name for name in os.listdir(path) if os.path.isdir(os.path.join(path, name))]
files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]
data = {
    'Folders': folders,
    'Files': files
}

df = pd.DataFrame(dict([(k, pd.Series(v)) for k, v in data.items()]))
output_path = r'C:\Users\carrot\Downloads\空调\output.xlsx'
df.to_excel(output_path, index=False)