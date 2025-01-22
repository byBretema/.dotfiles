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
do_qt_themes=0

OPTIND=1
while getopts "luifet" opt; do
    case $opt in
        l) do_links=1;;
        u) do_update=1;;
        i) do_install=1;;
        f) do_fonts=1;;
        e) do_code_extensions=1;;
        t) do_qt_themes=1;;
        *) echo "Usage: install.sh [-l] [-u] [-i] [-f] [-e] [-t]"; exit 1;;
    esac
done
shift $((OPTIND-1))


###############################################################################
### VARIABLES
###############################################################################

script=$(readlink -f "$0")
scriptpath=$(dirname "$script")


###############################################################################
### LINK CONFIG FILES
###############################################################################

if [[ $do_links -eq 1 ]]; then

    echo "### [ LINKING CONFIG FILES ] - $scriptpath"

    ln -srf $scriptpath/.zshrc $HOME/.zshrc
    ln -srf $scriptpath/.zshenv $HOME/.zshenv
    ln -srf $scriptpath/ghostty.cfg $HOME/.config/ghostty/config
    ln -srf $scriptpath/zellij.kdl $HOME/.config/zellij/config.kdl

    ln -srf $scriptpath/../common/.gitconfig $HOME/.gitconfig
    ln -srf $scriptpath/../common/.gitignore $HOME/.gitignore

    code_path="$HOME/.config/Code/User"
    ln -srf $scriptpath/../common/vscode/settings.json    "$code_path/settings.json"
    ln -srf $scriptpath/../common/vscode/keybindings.json "$code_path/keybindings.json"

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
        logiops \
        net-tools \
        git \
        lazygit \
        zellij \
        starship \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        zsh-history-substring-search \
        gdb \
        cmake \
        cppman \
        visual-studio-code-bin \
        f3d \
        blender \
        handbrake \
        bitwarden \
        obs-studio \
        thunderbird \
        obsidian \
        brave-bin \
        ulauncher \
        teamviewer \
        balena-etcher \
        slack-desktop \
        localsend-bin \
        notion-app-electron

        # TODO: Check docs of 'ov' pager : https://noborus.github.io/ov/index.html
        # run as su: ov --completion zsh > /usr/share/zsh/site-functions/_ov

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
### QT CREATOR THEME
###############################################################################

if [[ $do_qt_themes -eq 1 ]]; then

    echo "### [ INSTALLING / LINKING QT CREATOR THEMES ]"

    qtcs_dir="$HOME/.config/QtProject/qtcreator/styles"
    mkdir -p $qtcs_dir

    function install_theme()
    {
        local url=$1; shift

        if [[ $# -lt 1 ]]; then
            local filename=$(basename "$url")
        else
            local filename=$1; shift
        fi

        curl -fsSL "$url" -o "$qtcs_dir/$filename"
    }

    # install_theme "https://raw.githubusercontent.com/konchunas/gruvbox-qtcreator/refs/heads/master/gruvbox-dark.xml" "gruvbox-dark-2.xml"
    # install_theme "https://raw.githubusercontent.com/morhetz/gruvbox-contrib/refs/heads/master/qtcreator/gruvbox-dark.xml"
    # install_theme https://raw.githubusercontent.com/morhetz/gruvbox-contrib/refs/heads/master/qtcreator/gruvbox-light.xml

    ln -srf "$scriptpath/../common/qtcreator/themes/gruvbox_dark_custom.xml" "$qtcs_dir/gruvbox_dark_custom.xml"
    ln -srf "$scriptpath/../common/qtcreator/themes/monokai_dark_custom.xml" "$qtcs_dir/monokai_dark_custom.xml"

fi
