#!/bin/bash

maxdepth=""
src=""
dst=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --max_depth)
            maxdepth="-maxdepth $2"
            shift 2
            ;;
        *)
            if [[ -z "$src" ]]; then
                src="$1"
            else
                dst="\$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$src" || -z "$dst" ]]; then
    echo "Usage: \$0 [--max_depth <depth>] <input_dir> <output_dir>"
    exit 1
fi

if [[ ! -d "$src" ]]; then
    echo "Ошибка: '$src' не является директорией"
    exit 1
fi

mkdir -p "$dst" || {
    echo "Ошибка: невозможно создать директорию '$dst'"
    exit 1
}

get_new_name() {
    filepath="$1"
    outdir="$2"
    fname=$(basename "$filepath")
    base="${fname%.*}"
    ext="${fname##*.}"
    [[ "$base" == "$ext" ]] && ext="" || ext=".$ext"
    idx=1
    newfile="$fname"
    while [[ -f "$outdir/$newfile" ]]; do
        newfile="${base}_${idx}${ext}"
        ((idx++))
    done
    echo "$newfile"
}

find "$src" -type f $maxdepth | while read -r file; do
    newname=$(get_new_name "$file" "$dst")
    cp -v "$file" "$dst/$newname" || {
        echo "Ошибка: не удалось скопировать '$file'"
        exit 1
    }
done

exit 0
