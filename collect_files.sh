#!/bin/bash

src_dir="$1"
dst_dir="$2"
depth_limit=-1

shift 2

while [ $# -gt 0 ]; do
    if [ "$1" = "--max_depth" ]; then
        if ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "Ошибка: Параметр --max_depth должен быть целым числом"
            exit 1
        fi
        depth_limit="\$2"
        shift 2
    else
        echo "Ошибка: Недопустимый аргумент \$1"
        exit 1
    fi
done

mkdir -p "$dst_dir"

declare -A file_index

find "$src_dir" ${depth_limit:+-maxdepth "$depth_limit"} -mindepth 1 | while IFS= read -r entry; do
    if [ -d "$entry" ]; then
        relative_path="${entry#$src_dir/}"
        mkdir -p "$dst_dir/$relative_path"
    elif [ -f "$entry" ]; then
        relative_path="${entry#$src_dir/}"
        target_path="$dst_dir/$relative_path"

        filename=$(basename "$target_path")
        dirname=$(dirname "$target_path")

        mkdir -p "$dirname"

        if [ -e "$target_path" ]; then
            name_without_ext="${filename%.*}"
            extension="${filename##*.}"

            if [ "$name_without_ext" = "$extension" ]; then
                name_without_ext="$filename"
                extension=""
            fi

            file_index["$filename"]=$((file_index["$filename"] + 1))
            file_suffix="${file_index["$filename"]}"
            
            if [ -n "$extension" ]; then
                target_path="$dirname/${name_without_ext}_$file_suffix.$extension"
            else
                target_path="$dirname/${name_without_ext}_$file_suffix"
            fi
        fi

        cp "$entry" "$target_path"
    fi
done
