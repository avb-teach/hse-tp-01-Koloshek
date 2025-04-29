#!/bin/bash

depth_limit=""
source_dir=""
destination_dir=""

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --max_depth)
                depth_limit="$2"
                shift 2
                ;;
            *)
                if [[ -z "$source_dir" ]]; then
                    source_dir="$1"
                else
                    destination_dir="\$1"
                fi
                shift
                ;;
        esac
    done
}

check_arguments() {
    if [[ -z "$source_dir" || -z "$destination_dir" ]]; then
        echo "Usage: \$0 [--max_depth <depth>] <input_dir> <output_dir>"
        exit 1
    fi

    if [[ ! -d "$source_dir" ]]; then
        echo "Error: '$source_dir' is not a directory"
        exit 1
    fi

    mkdir -p "$destination_dir" || {
        echo "Error: Unable to create directory '$destination_dir'"
        exit 1
    }
}

generate_unique_name() {
    input_file="$1"
    target_dir="$2"

    file_name=$(basename "$input_file")
    name_part="${file_name%.*}"
    extension="${file_name##*.}"
    counter=1
    unique_name="$file_name"

    if [[ "$file_name" == "$extension" ]]; then
        extension=""
    else
        extension=".$extension"
    fi

    while [[ -e "$target_dir/$unique_name" ]]; do
        unique_name="${name_part}_${counter}${extension}"
        ((counter++))
    done

    echo "$unique_name"
}

copy_files() {
    find_options=""
    if [[ -n "$depth_limit" ]]; then
        find_options="-maxdepth $depth_limit"
    fi

    while IFS= read -r file_path; do
        unique_name=$(generate_unique_name "$file_path" "$destination_dir")
        target_path="$destination_dir/$unique_name"
        cp -v "$file_path" "$target_path" || {
            echo "Error: Failed to copy $file_path to $target_path"
            exit 1
        }
    done < <(find "$source_dir" -type f $find_options)
}

main() {
    parse_args "$@"
    check_arguments
    copy_files
}

main "$@"
