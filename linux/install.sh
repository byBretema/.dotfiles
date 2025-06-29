#!/usr/bin/env bash
set -eEu -o pipefail
shopt -s xpg_echo


###############################################################################
### ARGs

show_usage() {
    echo "usage: install.sh [-l] [-u] [-i] [-f] [-e] [-t]"
    echo "\nManage configs and system apps, fonts, themes...\n"
    echo "options:"
    echo "  -l  --  Link dotfiles"
    echo "  -u  --  Update system"
    echo "  -i  --  Install listed apps"
    echo "  -f  --  Install fonts"
    echo "  -e  --  Install code extensions"
    echo "  -t  --  Link themes for different apps"
}

do_links=0
do_update=0
do_install=0
do_fonts=0
do_code_extensions=0
do_themes=0

OPTIND=1
while getopts "luifeth" opt; do
    case $opt in
        l) do_links=1;;
        u) do_update=1;;
        i) do_install=1;;
        f) do_fonts=1;;
        e) do_code_extensions=1;;
        t) do_themes=1;;
        *) show_usage; return;;
    esac
done
shift $((OPTIND-1))


###############################################################################
## VARs

script_path=$(dirname "$(readlink -f "$0")")
my_configs="$script_path/../configs"
config_path="$HOME/.config"


###############################################################################
## FOLDERS

mkdir_ret() { mkdir -p "$1" >/dev/null 2>&1; echo "$1"; }
mkdir -p "$config_path"


###############################################################################
## LINK CONFIG FILES

if [[ $do_links -eq 1 ]]; then

    echo "\n### [ LINKING CONFIG FILES ] - $script_path"

    # Zsh
    ln -srf "$script_path/.zshrc" "$HOME/.zshrc"
    ln -srf "$script_path/.zshenv" "$HOME/.zshenv"

    # Git
    ln -srf "$my_configs/.gitconfig" "$HOME/.gitconfig"
    ln -srf "$my_configs/.gitignore" "$HOME/.gitignore"

    # Ghostty
    dst_path=$(mkdir_ret "$config_path/ghostty")
    ln -srf "$my_configs/ghostty.conf" "$dst_path/config"

    # Alacritty
    dst_path=$(mkdir_ret "$config_path/alacritty")
    ln -srf "$my_configs/alacritty.toml" "$dst_path/alacritty.toml"

    # Code
    dst_path=$(mkdir_ret "$config_path/Code/User")
    ln -srf "$my_configs/vscode/settings.json"    "$dst_path/settings.json"
    ln -srf "$my_configs/vscode/keybindings.json" "$dst_path/keybindings.json"

    # Helix
    dst_path=$(mkdir_ret "$config_path/helix")
    ln -srf "$my_configs/helix.toml" "$dst_path/config.toml"

    # Tmux
    dst_path=$(mkdir_ret "$config_path/tmux")
    if [[ ! -d "$dst_path/plugins/tpm" ]]; then
        git clone "https://github.com/tmux-plugins/tpm" "$dst_path/plugins/tpm"
    fi
    ln -srf "$my_configs/tmux.conf" "$dst_path/tmux.conf"

fi


###############################################################################
## UPDATE SYSTEM

if [[ $do_update -eq 1 ]]; then

    echo "\n### [ UPDATING SYSTEM ]"

    paru --noconfirm -Syu  # Trigger updates

fi


###############################################################################
## INSTALL / UPDATE APPS

if [[ $do_install -eq 1 ]]; then

    echo "\n### [ INSTALLING / UPDATING APPS ]"

    paru -S --needed --noconfirm --skipreview zsh
    if [[ "$SHELL" != *zsh ]]; then
        chsh -s "/usr/bin/zsh"
    fi

    paru -S --needed --noconfirm --skipreview ghostty
    paru -S --needed --noconfirm --skipreview carapace
    paru -S --needed --noconfirm --skipreview mprocs-bin

    paru -S --needed --noconfirm --skipreview git
    paru -S --needed --noconfirm --skipreview gitui
    paru -S --needed --noconfirm --skipreview lazygit
    paru -S --needed --noconfirm --skipreview git-delta

    paru -S --needed --noconfirm --skipreview tmux
    paru -S --needed --noconfirm --skipreview neovim
    paru -S --needed --noconfirm --skipreview evil-helix-bin

    paru -S --needed --noconfirm --skipreview yazi
    paru -S --needed --noconfirm --skipreview ncspot
    paru -S --needed --noconfirm --skipreview starship
    paru -S --needed --noconfirm --skipreview presenterm

    paru -S --needed --noconfirm --skipreview fd
    paru -S --needed --noconfirm --skipreview jq
    paru -S --needed --noconfirm --skipreview fzf
    paru -S --needed --noconfirm --skipreview eza
    paru -S --needed --noconfirm --skipreview dua-cli
    paru -S --needed --noconfirm --skipreview dust
    paru -S --needed --noconfirm --skipreview 7zip
    paru -S --needed --noconfirm --skipreview kondo
    paru -S --needed --noconfirm --skipreview resvg
    paru -S --needed --noconfirm --skipreview xclip
    paru -S --needed --noconfirm --skipreview zoxide
    paru -S --needed --noconfirm --skipreview ripgrep
    paru -S --needed --noconfirm --skipreview poppler
    paru -S --needed --noconfirm --skipreview hyperfine
    paru -S --needed --noconfirm --skipreview ripgrep-all
    paru -S --needed --noconfirm --skipreview fselect-bin
    paru -S --needed --noconfirm --skipreview imagemagick

    paru -S --needed --noconfirm --skipreview oh-my-zsh-git # TODO : Try to remove this zsh deps
    paru -S --needed --noconfirm --skipreview zsh-autosuggestions
    paru -S --needed --noconfirm --skipreview zsh-syntax-highlighting
    paru -S --needed --noconfirm --skipreview zsh-history-substring-search

    paru -S --needed --noconfirm --skipreview inter-font

    paru -S --needed --noconfirm --skipreview uv
    paru -S --needed --noconfirm --skipreview python
    paru -S --needed --noconfirm --skipreview python310

    paru -S --needed --noconfirm --skipreview gdb
    paru -S --needed --noconfirm --skipreview cmake
    paru -S --needed --noconfirm --skipreview cppman
    paru -S --needed --noconfirm --skipreview vulkan-devel

    paru -S --needed --noconfirm --skipreview copyq
    paru -S --needed --noconfirm --skipreview bitwarden
    paru -S --needed --noconfirm --skipreview slack-desktop
    paru -S --needed --noconfirm --skipreview google-chrome
    paru -S --needed --noconfirm --skipreview zen-browser-bin
    paru -S --needed --noconfirm --skipreview notion-app-electron
    paru -S --needed --noconfirm --skipreview visual-studio-code-bin

    paru -S --needed --noconfirm --skipreview f3d
    paru -S --needed --noconfirm --skipreview blender

    paru -S --needed --noconfirm --skipreview mpv
    paru -S --needed --noconfirm --skipreview handbrake
    paru -S --needed --noconfirm --skipreview obs-studio

    paru -S --needed --noconfirm --skipreview zathura
    paru -S --needed --noconfirm --skipreview obsidian

    paru -S --needed --noconfirm --skipreview tigervnc
    paru -S --needed --noconfirm --skipreview teamviewer

    # paru -S --needed --noconfirm --skipreview balena-etcher
    paru -S --needed --noconfirm --skipreview localsend-bin

    # Enable pacman cache cleaner task
    sudo systemctl enable paccache.timer

fi


###############################################################################
## INSTALL FONTS

if [[ $do_fonts -eq 1 ]]; then

    echo "\n### [ INSTALLING FONTS ]"

    function install_font()
    {
        local url=$1
        local filename=$(basename "$1")

        temp_dir=$(mktemp -d)
        font_zip="$temp_dir/$filename"
        font_extracted="$temp_dir/${filename}_extracted"

        curl -fsSL "$url" -o "$font_zip"
        unzip -q "$font_zip" -d "$font_extracted"

        fonts_path=$(mkdir_ret "$HOME/.local/share/fonts")

        find "$font_extracted" -type f -name "*.ttf" -o -name "*.otf" | while read font; do
            cp "$font" $fonts_path || echo "[x] Failed to install: $(basename "$font")"
        done

        rm -rf "$temp_dir"
    }

    install_font "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
    install_font "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    install_font "https://rubjo.github.io/victor-mono/VictorMonoAll.zip"

    fc-cache -f

fi


###############################################################################
## INSTALL VSCODE EXTENSIONS

if [[ $do_code_extensions -eq 1 ]]; then

    echo "\n### [ INSTALLING VSCODE EXTENSIONS]"

    python "$my_configs/vscode/extensions.py" -i

fi


###############################################################################
## APPS THEMES

if [[ $do_themes -eq 1 ]]; then

    echo "\n### [ INSTALLING / LINKING THEMES ]"

    #--------------------------------------------------------------------------
    #-- Qt Creator
    dst_path=$(mkdir_ret "$config_path/QtProject/qtcreator/styles")
    ln -srf "$my_configs/qtcreator/themes/monokai_dark.xml"     "$dst_path/monokai_dark_t.xml"
    ln -srf "$my_configs/qtcreator/themes/gruvbox_dark.xml"     "$dst_path/gruvbox_dark_t.xml"
    ln -srf "$my_configs/qtcreator/themes/catppuccin_latte.xml" "$dst_path/catppuccin_latte_t.xml"

    #--------------------------------------------------------------------------
    #-- Yazi  (https://github.com/yazi-rs/flavors/blob/main/themes.md)
    dst_path=$(mkdir_ret "$config_path/yazi")
    ln -srf "$my_configs/yazi/themes/gruvbox_dark.toml" "$dst_path/theme.toml"
fi
