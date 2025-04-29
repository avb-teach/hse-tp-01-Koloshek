#!/bin/bash

src=$1
dst=$2
depth=-1

[ $# -lt 2 ] && { echo "need paths"; exit 1; }

while [ -n "\$3" ]; do
    case "$3" in
        --max_depth)
            depth=\$4
            [[ ! $depth =~ ^[0-9]+$ ]] && exit 1
            shift 4
            ;;
        *) 
            exit 1
            ;;
    esac
done

[ ! -d "$dst" ] && mkdir "$dst"

for f in $(find "$src" -type f); do
    path=${f#$src/}
    levels=$(echo "$path" | tr -cd '/' | wc -c)
    
    if [ $depth -ge 0 ] && [ $levels -ge $depth ]; then
        cut_levels=$((levels - depth + 1))
        path=$(echo "$path" | cut -d/ -f$((cut_levels+1))-)
    fi
    
    target="$dst/$path"
    
    if [ -f "$target" ]; then
        name=${target%.*}
        ext=${target##*.}
        num=1
        
        while [ -f "$target" ]; do
            [ "$name" = "$ext" ] && target="${name}_$num" || target="${name}_$num.$ext"
            num=$((num+1))
        done
    fi
    
    mdir=$(dirname "$target")
    [ ! -d "$mdir" ] && mkdir -p "$mdir"
    cp "$f" "$target"
done
