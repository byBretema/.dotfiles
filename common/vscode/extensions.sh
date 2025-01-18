#!/bin/bash
set -u

extensions="./extensions.txt"

# Arguments
#----------------------------
do_install=0
do_update=0
do_overwrite=0
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--updates)
            do_update=1
            shift
            ;;
        -o|--overwrite)
            do_overwrite=1
            shift
            ;;
        -i|--install)
            do_install=1
            shift
            ;;
    esac
done

# Install
#----------------------------
if [[ $do_install -eq 1 && -f "$extensions" ]]; then
    command="code "
    while IFS= read -r extension; do
        command+="--install-extension $extension --force "
    done < "$extensions"
    $command
fi

# Update
#----------------------------
if [[ $do_update -eq 1 || $do_overwrite -eq 1 ]]; then
    temp_file=$(mktemp)
    if [[ $do_overwrite -eq 0 && -f "$extensions" ]]; then
        cat $extensions >> $temp_file
    fi
    code --list-extensions >> "$temp_file"
    sort -u "$temp_file" > $extensions
    rm $temp_file
fi
