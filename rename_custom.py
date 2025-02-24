import os
import shutil

def rename_and_delete_files_recursively(directory, old_text, new_text):
    # 对指定目录进行递归遍历
    for root, dirs, files in os.walk(directory):
        for filename in files:
            # 检查文件名是否包含需要替换的文本
            if old_text in filename:
                # 替换文件名中的文本
                new_filename = filename.replace(old_text, new_text)
                old_file_path = os.path.join(root, filename)
                new_file_path = os.path.join(root, new_filename)
                # 重命名文件
                os.rename(old_file_path, new_file_path)
                print(f"文件 {filename} 已重命名为 {new_filename}")

# 用户输入
directory = input("请输入目录路径: ").strip()
old_text = input("请输入需要替换的文本: ").strip()
new_text = input("请输入新的文本: ").strip()

rename_and_delete_files_recursively(directory, old_text, new_text)
