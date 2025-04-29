#!/bin/bash

source_directory=""
target_directory=""
depth_parameter=""

process_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --max_depth)
                depth_parameter="$2"
                shift 2
                ;;
            *)
                if [[ -z "$source_directory" ]]; then
                    source_directory="$1"
                else
                    target_directory="\$1"
                fi
                shift
                ;;
        esac
    done
}

validate_input() {
    if [[ -z "$source_directory" || -z "$target_directory" ]]; then
        echo "Использование: \$0 [--max_depth N] <исходная_директория> <целевая_директория>"
        exit 1
    fi

    if [[ ! -d "$source_directory" ]]; then
        echo "Ошибка: '$source_directory' не является директорией"
        exit 1
    fi
}

generate_unique_filename() {
    local file_path="$1"
    local output_dir="$2"
    
    local name=$(basename "$file_path")
    local name_part="${name%.*}"
    local extension="${name##*.}"
    
    if [[ "$name" == "$extension" ]]; then
        extension=""
    else
        extension=".$extension"
    fi
    
    local counter=1
    local new_name="$name"
    
    while [[ -f "$output_dir/$new_name" ]]; do
        new_name="${name_part}_${counter}${extension}"
        ((counter++))
    done
    
    echo "$new_name"
}

copy_files() {
    mkdir -p "$target_directory" || {
        echo "Ошибка: Не удалось создать директорию '$target_directory'"
        exit 1
    }

    local depth_option=""
    if [[ -n "$depth_parameter" ]]; then
        depth_option="-maxdepth $depth_parameter"
    fi

    find "$source_directory" -type f $depth_option | while read -r file; do
        local new_filename=$(generate_unique_filename "$file" "$target_directory")
        cp -v "$file" "$target_directory/$new_filename" || {
            echo "Ошибка: Не удалось скопировать '$file' в '$target_directory/$new_filename'"
            exit 1
        }
    done
}

main() {
    process_arguments "$@"
    validate_input
    copy_files
}

main "$@"
