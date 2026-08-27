#!/bin/bash
# https://www.nerdfonts.com/cheat-sheet + vaaleyard/tmux-dotbar

[[ $# < 1 ]] && { printf "??"; exit 0; }

window_icon="$1"
window_path="$2"

icon_space=' '

case "$window_icon" in
ssh) icon='󰌘' ;;
bat) icon='󰈈' ;;
vim | nvim ) icon='𝓥'; icon_space=' ' ;;
helix) icon='𝓗' ;;
python | python3 | .venv/bin/python*) icon='' ;;
opencode | ollama) icon='' ;;
git | lazygit) icon='' ;;
docker | docker-compose | lazydocker) icon='' ;;
node) icon='' ;;
go) icon='' ;;
cargo | rustc) icon='' ;;
make | cmake | ninja | npm | yarn | pnpm) icon='' ;;
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
*) icon="⬤"; ;;
esac

icon="$icon$icon_space"

git_info=""
if [[ -n "${2:-}" ]]; then
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
  git_info="$( git_repo_info_tmux "$window_path" )"
fi

if [[ -f "$HOME/.local/state/tmux/git_info" ]]; then
  printf " $icon $git_info"
else
  printf " $icon"
fi
