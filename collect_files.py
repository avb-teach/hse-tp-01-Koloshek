import os
import sys
import shutil

def collect_files(input_dir, output_dir, max_depth=None):
    if not os.path.exists(input_dir):
        print(f"Input directory '{input_dir}' does not exist")
        return

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    input_dir = os.path.abspath(input_dir)
    for root, dirs, files in os.walk(input_dir):
        rel_path = os.path.relpath(root, input_dir)
        depth = rel_path.count(os.sep)
        # Если используем max_depth
        if max_depth is not None and depth >= max_depth:
            # Не углубляемся дальше
            dirs[:] = []
            continue

        for file in files:
            src_path = os.path.join(root, file)
            dst_path = os.path.join(output_dir, file)
            if os.path.exists(dst_path):
                base, ext = os.path.splitext(file)
                counter = 1
                while os.path.exists(dst_path):
                    new_name = f"{base}{counter}{ext}"
                    dst_path = os.path.join(output_dir, new_name)
                    counter += 1
            shutil.copy2(src_path, dst_path)

if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) not in (2, 4):
        print("Usage: python collect_files.py input_dir output_dir [--max_depth N]")
        sys.exit(1)
    input_dir = args[0]
    output_dir = args[1]
    max_depth = None
    if len(args) == 4 and args[2] == "--max_depth":
        try:
            max_depth = int(args[3])
        except ValueError:
            print("max_depth must be an integer")
            sys.exit(1)
    collect_files(input_dir, output_dir, max_depth)
