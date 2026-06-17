#!/bin/bash

# https://www.nerdfonts.com/cheat-sheet

case "$1" in
ssh) icon='󰌘' ;;
vim | nvim | helix) icon='' ;;
opencode) icon='' ;;
fish | bash | zsh) icon='' ;;
python | python3) icon='' ;;
git | lazygit) icon='' ;;
docker | docker-compose | lazydocker) icon='' ;;
node) icon='' ;;
npm | yarn | pnpm) icon='' ;;
go) icon='' ;;
cargo | rustc) icon='' ;;
make | cmake | ninja) icon='' ;;
lua) icon='' ;;
ruby) icon='' ;;
gcc | g++ | clang | clang++) icon='' ;;
htop | btop | top) icon='' ;;
tmux) icon='' ;;
man) icon='' ;;
kubectl) icon='󱃾' ;;
paru | yay | pacman) icon='󰮯' ;;
yazi) icon='󰇥' ;;
*) icon="$1" ;;
esac

printf '%s' "$icon"
