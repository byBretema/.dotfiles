#!/bin/bash

case "$1" in
     ssh)                icon='󰌘' ;;
     vim | nvim | helix) icon='' ;;
     opencode)           icon='' ;;
     fish | bash | zsh)  icon='' ;;
     *)                  icon="$1" ;;
esac

printf '%s' "$icon"
