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

    echo "### [ LINKING CONFIG FILES ] - $scriptpath"

    mkdir -p $HOME/.config
    mkdir -p $HOME/.config/ghostty
    mkdir -p $HOME/.config/alacritty

    # Terminal emulators
    ln -srf $scriptpath/ghostty.cfg $HOME/.config/ghostty/config
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

    # Kde stuff
    ln -srf $scriptpath/kde/kdeglobals $HOME/.config/kdeglobals
fi


###############################################################################
### UPDATE SYSTEM
###############################################################################

if [[ $do_update -eq 1 ]]; then

    echo "### [ UPDATING SYSTEM ]"

    paru --noconfirm -Syu  # Trigger updates

fi


###############################################################################
### INSTALL / UPDATE APPS
###############################################################################

if [[ $do_install -eq 1 ]]; then

    echo "### [ INSTALLING / UPDATING APPS ]"

   # paru -Sy --noconfirm --needed \
    paru -Sy --noconfirm --needed git
    paru -Sy --noconfirm --needed lazygit
    paru -Sy --noconfirm --needed superfile-bin
    paru -Sy --noconfirm --needed tmux
    paru -Sy --noconfirm --needed neovim
    paru -Sy --noconfirm --needed superfile-bin
    paru -Sy --noconfirm --needed starship
    paru -Sy --noconfirm --needed zsh-autosuggestions
    paru -Sy --noconfirm --needed zsh-syntax-highlighting
    paru -Sy --noconfirm --needed zsh-history-substring-search
    paru -Sy --noconfirm --needed inter-font
    paru -Sy --noconfirm --needed uv
    paru -Sy --noconfirm --needed gdb
    paru -Sy --noconfirm --needed cmake
    paru -Sy --noconfirm --needed vulkan-devel
    paru -Sy --noconfirm --needed cppman
    paru -Sy --noconfirm --needed zed
    paru -Sy --noconfirm --needed visual-studio-code-bin
    paru -Sy --noconfirm --needed copyq
    paru -Sy --noconfirm --needed f3d
    paru -Sy --noconfirm --needed blender
    paru -Sy --noconfirm --needed handbrake
    paru -Sy --noconfirm --needed bitwarden
    paru -Sy --noconfirm --needed obs-studio
    paru -Sy --noconfirm --needed zathura
    paru -Sy --noconfirm --needed obsidian
    paru -Sy --noconfirm --needed ulauncher
    paru -Sy --noconfirm --needed teamviewer
    paru -Sy --noconfirm --needed balena-etcher
    paru -Sy --noconfirm --needed slack-desktop
    paru -Sy --noconfirm --needed localsend-bin
    paru -Sy --noconfirm --needed google-chrome
    paru -Sy --noconfirm --needed notion-app-electron

    # TODO: Check docs of 'ov' pager : https://noborus.github.io/ov/index.html
    # run as su: ov --completion zsh > /usr/share/zsh/site-functions/_ov

    # Enable pacman cache cleaner task
    sudo systemctl enable paccache.timer

fi


###############################################################################
### INSTALL FONTS
###############################################################################

if [[ $do_fonts -eq 1 ]]; then

    echo "### [ INSTALLING FONTS ]"

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

    echo "### [ INSTALLING VSCODE EXTENSIONS]"

    $scriptpath/../common/vscode/extensions.sh -i

fi


###############################################################################
### APPS THEMES
###############################################################################

if [[ $do_themes -eq 1 ]]; then

    echo "### [ INSTALLING / LINKING THEMES ]"

    # Qt Creator
    qt_styles="$HOME/.config/QtProject/qtcreator/styles"
    mkdir -p $qt_styles
    # https://github.com/byBretema/qt_monokai
    ln -snfr "$scriptpath/../common/qtcreator/styles/monokai_dark_custom.xml" "$qt_styles/monokai_dark_custom.xml"
    # https://github.com/morhetz/gruvbox-contrib/tree/master/qtcreator
    ln -snfr "$scriptpath/../common/qtcreator/styles/gruvbox_dark_custom.xml" "$qt_styles/gruvbox_dark_custom.xml"
    # https://github.com/catppuccin/qtcreator
    ln -snfr "$scriptpath/../common/qtcreator/styles/catppuccin_latte.xml" "$qt_styles/catppuccin_latte.xml"

    # # Ulauncher (https://github.com/gustavothecoder/ulauncher-gruvbox-material)
    # ulauncher_dir="$HOME/.config/ulauncher/user-themes"
    # mkdir -p $ulauncher_dir
    # ln -snfr $scriptpath/themes/ulauncher/gruvbox-material-dark-hard/ $ulauncher_dir
fi
