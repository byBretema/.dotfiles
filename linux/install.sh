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
    ln -srf $scriptpath/../common/vscode/settings.json    "$code_path/settings.json"
    ln -srf $scriptpath/../common/vscode/keybindings.json "$code_path/keybindings.json"

    # Tmux
    if [[ ! -d $HOME/.config/tmux/plugins/tpm ]]; then
        git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
    fi
    ln -srf $scriptpath/tmux.conf $HOME/.config/tmux/tmux.conf

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

    paru --noconfirm --needed -Sy \
        git \
        lazygit \
        superfile-bin \
        tmux \
        neovim \
        superfile-bin \
        starship \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        zsh-history-substring-search \
        inter-font\
        uv \
        gdb \
        cmake \
        vulkan-devel \
        cppman \
        zed \
        visual-studio-code-bin \
        copyq \
        f3d \
        blender \
        handbrake \
        bitwarden \
        obs-studio \
        zathura \
        obsidian \
        ulauncher \
        teamviewer \
        balena-etcher \
        slack-desktop \
        localsend-bin \
        google-chrome \
        notion-app-electron

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

        find "$font_extracted" -type f -name "*.ttf" -o -name "*.otf" | while read font; do
            cp "$font" "$HOME/.local/share/fonts/" || echo "[x] Failed to install: $(basename "$font")"
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
