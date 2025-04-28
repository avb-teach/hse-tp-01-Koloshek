import os
import sys
import shutil

def collect_files(input_dir, output_dir, max_depth=None):
    input_dir = os.path.abspath(input_dir)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for root, dirs, files in os.walk(input_dir):
        rel_path = os.path.relpath(root, input_dir)
        depth = 0 if rel_path == '.' else rel_path.count(os.sep) + 1

 
        if max_depth is not None and depth > max_depth:
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
                    dst_file = f"{base}{counter}{ext}"
                    dst_path = os.path.join(output_dir, dst_file)
                    counter += 1
            shutil.copy2(src_path, dst_path)

if __name__ == "__main__":
    args = sys.argv[1:]
    max_depth = None
    if "--max_depth" in args:
        idx = args.index("--max_depth")
        try:
            max_depth = int(args[idx + 1])
            del args[idx:idx+2]
        except Exception:
            print("max_depth должно быть целым числом")
            sys.exit(1)
    if len(args) != 2:
        print("Usage: python collect_files.py input_dir output_dir [--max_depth N]")
        sys.exit(1)
    input_dir = args[0]
    output_dir = args[1]
    collect_files(input_dir, output_dir, max_depth)
