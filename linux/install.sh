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
    ln -srf "$script_path/.zshrc"  "$HOME/.zshrc"
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

    while IFS= read -r line; do
        pkg=${line//[^a-zA-Z0-9_-]/}
        if [[ -n $pkg ]] && [[ $line != \#* ]]; then
            paru -S --needed --noconfirm --skipreview $pkg
        fi
    done < "$script_path/pacman_list.conf"

    while IFS= read -r line; do
        pkg=${line//[^a-zA-Z0-9.]/}
        if [[ -n $pkg ]] && [[ $line != \#* ]]; then
            flatpak -y install $pkg
        fi
    done < "$script_path/flatpak_list.conf"
    flatpak update


    if [[ "$SHELL" != *zsh ]]; then
        chsh -s "/usr/bin/zsh"
    fi
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
        font_unzip="$temp_dir/${filename}_unzip"

        curl -fsSL "$url" -o "$font_zip"
        unzip -q "$font_zip" -d "$font_unzip"

        fonts_path=$(mkdir_ret "$HOME/.local/share/fonts")

        find "$font_unzip" -type f -name "*.ttf" -o -name "*.otf" | while read font; do
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
