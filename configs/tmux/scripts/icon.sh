#!/bin/bash
# https://www.nerdfonts.com/cheat-sheet + vaaleyard/tmux-dotbar

[[ $# < 1 ]] && { printf "??"; exit 0; }

window_icon="$1"
window_path="$2"

case "$window_icon" in
ssh) icon='󰌘' ;;
bat) icon='󰈈' ;;
vim | nvim | helix) icon='' ;;
opencode) icon='' ;;
fish | bash | zsh) icon='' ;;
python | python3 | .venv/bin/python*) icon='' ;;
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
hyperfine) icon='' ;;
"") icon="??" ;;
*) icon="$window_icon" ;;
esac

git_info=""
if [[ -n "${2:-}" ]]; then
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
  git_info="  $( git_repo_info_tmux "$window_path" )"
fi

printf "${icon:+ $icon}$git_info"
