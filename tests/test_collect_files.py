import os
import shutil
import tempfile
import pytest

def test_basic():
    with tempfile.TemporaryDirectory() as input_dir, \
         tempfile.TemporaryDirectory() as output_dir:
        

        os.makedirs(os.path.join(input_dir, "dir_2"))
        with open(os.path.join(input_dir, "file1.txt"), "w") as f:
            f.write("test1")
        with open(os.path.join(input_dir, "dir_2/file2.txt"), "w") as f:
            f.write("test2")


        from collect_files import collect_files
        collect_files(input_dir, output_dir)


        assert os.path.exists(os.path.join(output_dir, "file1.txt"))
        assert os.path.exists(os.path.join(output_dir, "file2.txt"))

def test_max_depth():
    with tempfile.TemporaryDirectory() as input_dir, \
         tempfile.TemporaryDirectory() as output_dir:
        

        os.makedirs(os.path.join(input_dir, "dir_2/dir_3/dir_4"))
        

        test_files = [
            "file1.txt",
            "dir_2/file2.txt",
            "dir_2/dir_3/file3.txt",
            "dir_2/dir_3/dir_4/file4.txt"
        ]
        
        for file_path in test_files:
            full_path = os.path.join(input_dir, file_path)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            with open(full_path, "w") as f:
                f.write("test")


        from collect_files import collect_files
        collect_files(input_dir, output_dir, max_depth=2)

        assert os.path.exists(os.path.join(output_dir, "file1.txt"))
        assert os.path.exists(os.path.join(output_dir, "dir_2/file2.txt"))
        assert os.path.exists(os.path.join(output_dir, "dir_2/file3.txt"))
        assert os.path.exists(os.path.join(output_dir, "dir_2/file4.txt"))

def test_duplicate_names():
    with tempfile.TemporaryDirectory() as input_dir, \
         tempfile.TemporaryDirectory() as output_dir:
        

        os.makedirs(os.path.join(input_dir, "dir1"))
        os.makedirs(os.path.join(input_dir, "dir2"))
        
        with open(os.path.join(input_dir, "dir1/same.txt"), "w") as f:
            f.write("test1")
        with open(os.path.join(input_dir, "dir2/same.txt"), "w") as f:
            f.write("test2")

        from collect_files import collect_files
        collect_files(input_dir, output_dir)

        assert os.path.exists(os.path.join(output_dir, "same.txt"))
        assert os.path.exists(os.path.join(output_dir, "same_1.txt"))
