#!/usr/bin/env bash
set -u
shopt -s xpg_echo


###############################################################################
### ARGUMENTS
###############################################################################

do_links=0
do_update=0
do_install=0
do_fonts=0
do_code_extensions=0
do_themes=0

OPTIND=1
while getopts "luifet" opt; do
    case $opt in
        l) do_links=1;;
        u) do_update=1;;
        i) do_install=1;;
        f) do_fonts=1;;
        e) do_code_extensions=1;;
        t) do_themes=1;;
        *) echo "Usage: install.sh [-l] [-u] [-i] [-f] [-e] [-t]"; exit 1;;
    esac
done
shift $((OPTIND-1))


###############################################################################
### VARIABLES
###############################################################################

scriptpath=$(dirname "$(readlink -f "$0")")


###############################################################################
### LINK CONFIG FILES
###############################################################################

if [[ $do_links -eq 1 ]]; then

    echo "\n### [ LINKING CONFIG FILES ] - $scriptpath"

    mkdir -p $HOME/.config

    # Ghostty
    mkdir -p $HOME/.config/ghostty
    ln -srf $scriptpath/ghostty.cfg $HOME/.config/ghostty/config

    # Alacritty
    mkdir -p $HOME/.config/alacritty
    ln -srf $scriptpath/alacritty.toml $HOME/.config/alacritty/alacritty.toml

    # Zsh
    ln -srf $scriptpath/.zshrc $HOME/.zshrc
    ln -srf $scriptpath/.zshenv $HOME/.zshenv

    # Git
    ln -srf $scriptpath/../common/.gitconfig $HOME/.gitconfig
    ln -srf $scriptpath/../common/.gitignore $HOME/.gitignore

    # Code
    code_path="$HOME/.config/Code/User"
    mkdir -p $code_path
    ln -srf $scriptpath/../common/vscode/settings.json    "$code_path/settings.json"
    ln -srf $scriptpath/../common/vscode/keybindings.json "$code_path/keybindings.json"

    # Tmux
    tmux_path="$HOME/.config/tmux"
    if [[ ! -d "$tmux_path/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$tmux_path/plugins/tpm"
    fi
    ln -srf $scriptpath/tmux.conf $tmux_path/tmux.conf
fi


###############################################################################
### UPDATE SYSTEM
###############################################################################

if [[ $do_update -eq 1 ]]; then

    echo "\n### [ UPDATING SYSTEM ]"

    paru --noconfirm -Syu  # Trigger updates

fi


###############################################################################
### INSTALL / UPDATE APPS
###############################################################################

if [[ $do_install -eq 1 ]]; then

    echo "\n### [ INSTALLING / UPDATING APPS ]"

    paru -S --needed --noconfirm --skipreview zsh
    chsh -s /usr/bin/zsh

    paru -S --needed --noconfirm --skipreview ghostty
    paru -S --needed --noconfirm --skipreview carapace
    paru -S --needed --noconfirm --skipreview mprocs

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
    paru -S --needed --noconfirm --skipreview fzf
    paru -S --needed --noconfirm --skipreview eza
    paru -S --needed --noconfirm --skipreview dua
    paru -S --needed --noconfirm --skipreview dust
    paru -S --needed --noconfirm --skipreview kondo
    paru -S --needed --noconfirm --skipreview ripgrep
    paru -S --needed --noconfirm --skipreview hyperfine
    paru -S --needed --noconfirm --skipreview ripgrep-all
    paru -S --needed --noconfirm --skipreview fselect-bin

    paru -S --needed --noconfirm --skipreview oh-my-zsh-git
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
    paru -S --needed --noconfirm --skipreview notion-app-electron
    paru -S --needed --noconfirm --skipreview visual-studio-code-bin

    paru -S --needed --noconfirm --skipreview f3d
    paru -S --needed --noconfirm --skipreview blender

    paru -S --needed --noconfirm --skipreview handbrake
    paru -S --needed --noconfirm --skipreview obs-studio

    paru -S --needed --noconfirm --skipreview zathura
    paru -S --needed --noconfirm --skipreview obsidian

    paru -S --needed --noconfirm --skipreview tigervnc
    paru -S --needed --noconfirm --skipreview teamviewer

    paru -S --needed --noconfirm --skipreview balena-etcher
    paru -S --needed --noconfirm --skipreview localsend-bin

    # TODO: Check docs of 'ov' pager : https://noborus.github.io/ov/index.html
    # run as su: ov --completion zsh > /usr/share/zsh/site-functions/_ov

    # Enable pacman cache cleaner task
    sudo systemctl enable paccache.timer

fi


###############################################################################
### INSTALL FONTS
###############################################################################

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

        fonts_path="$HOME/.local/share/fonts/"
	    mkdir -p $fonts_path
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
### INSTALL VSCODE EXTENSIONS
###############################################################################

if [[ $do_code_extensions -eq 1 ]]; then

    echo "\n### [ INSTALLING VSCODE EXTENSIONS]"

    python $scriptpath/../common/vscode/extensions.py -i

fi


###############################################################################
### APPS THEMES
###############################################################################

if [[ $do_themes -eq 1 ]]; then

    echo "\n### [ INSTALLING / LINKING THEMES ]"

    # Qt Creator
    qt_styles="$HOME/.config/QtProject/qtcreator/styles"
    mkdir -p $qt_styles
    #-- https://github.com/byBretema/qt_monokai
    ln -snfr "$scriptpath/../common/qtcreator/styles/monokai_dark_custom.xml" "$qt_styles/monokai_dark_custom.xml"
    #-- https://github.com/morhetz/gruvbox-contrib/tree/master/qtcreator
    ln -snfr "$scriptpath/../common/qtcreator/styles/gruvbox_dark_custom.xml" "$qt_styles/gruvbox_dark_custom.xml"
    #-- https://github.com/catppuccin/qtcreator
    ln -snfr "$scriptpath/../common/qtcreator/styles/catppuccin_latte.xml" "$qt_styles/catppuccin_latte.xml"

fi
