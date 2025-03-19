import os

# 设置主文件夹路径
main_folder = r"C:\Users\carrot\Desktop\test"
output_file = r"C:\Users\carrot\Desktop\result.txt"  # 结果文件路径

# 打开文件写入统计结果
with open(output_file, "w", encoding="utf-8") as f:
    for folder in os.listdir(main_folder):
        folder_path = os.path.join(main_folder, folder)
        if os.path.isdir(folder_path):  # 确保是文件夹
            image_count = sum(1 for file in os.listdir(folder_path) if file.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp')))
            result = f"文件夹 '{folder}' 内有 {image_count} 张图片\n"
            print(result, end="")  # 终端输出
            f.write(result)  # 写入文件
            
            
            
            