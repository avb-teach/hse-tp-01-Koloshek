import os
import sys
import shutil

def collect_files(input_dir, output_dir, max_depth=None):
    input_dir = os.path.abspath(input_dir)
    if not os.path.isdir(input_dir):
        print(f"Ошибка: '{input_dir}' не является директорией!")
        sys.exit(1)
    os.makedirs(output_dir, exist_ok=True)

    for root, dirs, files in os.walk(input_dir):
        rel_path = os.path.relpath(root, input_dir)
        depth = rel_path.count(os.sep)
        if max_depth is not None and depth >= max_depth:
            dirs[:] = []
            continue
        for file in files:
            src_path = os.path.join(root, file)
            dst_file = file
            dst_path = os.path.join(output_dir, dst_file)
            if os.path.exists(dst_path):
                base, ext = os.path.splitext(dst_file)
                counter = 1
                while os.path.exists(dst_path):
                    dst_file = f"{base}_{counter}{ext}"
                    dst_path = os.path.join(output_dir, dst_file)
                    counter += 1
            shutil.copy2(src_path, dst_path)

if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) < 2:
        print("Usage: python collect_files.py <input_dir> <output_dir> [--max_depth N]")
        sys.exit(1)
    input_dir = args[0]
    output_dir = args[1]
    max_depth = None
    if "--max_depth" in args:
        try:
            max_depth = int(args[args.index("--max_depth") + 1])
        except (IndexError, ValueError):
            print("Ошибка: max_depth должен быть числом")
            sys.exit(1)
    collect_files(input_dir, output_dir, max_depth)
