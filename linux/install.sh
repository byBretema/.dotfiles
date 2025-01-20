#!/usr/bin/env bash
set -u
shopt -s xpg_echo

###############################################################################
### ARGUMENTS
###############################################################################

do_update=0
do_install=0
do_links=0

OPTIND=1
while getopts "uil" opt; do
    case $opt in
        u) do_update=1;;
        i) do_install=1;;
        l) do_links=1;;
        *) echo "Usage: install.sh [-u] [-i] [-l]"; exit 1;;
    esac
done
shift $((OPTIND-1))

###############################################################################
### VARIABLES
###############################################################################

script=$(readlink -f "$0")
scriptpath=$(dirname "$script")


###############################################################################
### UPDATE SYSTEM
###############################################################################

if [[ $do_update -eq 1 ]]; then

    echo "\n### [ UPDATE SYSTEM ]"

    paru --noconfirm -Syu  # Trigger updates

fi

###############################################################################
### INSTALL / UPDATE APPS
###############################################################################

if [[ $do_install -eq 1 ]]; then

    echo "\n### [ INSTALL / UPDATE APPS ]"

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

fi


###############################################################################
### LINK CONFIG FILES
###############################################################################

if [[ $do_links -eq 1 ]]; then

    echo "\n### [ LINK CONFIG FILES ] - $scriptpath"

    ln -srf $scriptpath/.zshrc $HOME/.zshrc
    ln -srf $scriptpath/.zshenv $HOME/.zshenv
    ln -srf $scriptpath/ghostty/config $HOME/.config/ghostty

    ln -srf $scriptpath/../common/.gitconfig $HOME/.gitconfig
    ln -srf $scriptpath/../common/.gitignore $HOME/.gitignore

    code_path="$HOME/.config/Code/User"
    ln -srf $scriptpath/../common/vscode/settings.json    "$code_path/settings.json"
    ln -srf $scriptpath/../common/vscode/keybindings.json "$code_path/keybindings.json"

fi
