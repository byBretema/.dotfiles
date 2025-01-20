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

    extra_v3="cachyos-extra-v3"
    core_v3="cachyos-core-v3"

    paru --noconfirm --needed -Sy \
        aur/ulauncher \
        $core_v3/net-tools \
        extra/zsh-autosuggestions \
        extra/zsh-syntax-highlighting \
        extra/zsh-history-substring-search \
        aur/logiops \
        aur/balena-etcher \
        $extra_v3/f3d \
        $extra_v3/blender \
        $extra_v3/obs-studio \
        $extra_v3/handbrake \
        $extra_v3/thunderbird \
        aur/teamviewer \
        aur/slack-desktop \
        aur/brave-bin \
        aur/notion-app-electron \
        extra/obsidian \
        $extra_v3/cmake \
        $extra_v3/starship \
        $extra_v3/lazygit \
        aur/visual-studio-code-bin \
        $extra_v3/bitwarden \
        aur/localsend-bin

fi


###############################################################################
### LINK CONFIG FILES
###############################################################################

if [[ $do_links -eq 1 ]]; then

    echo "\n### [ LINK CONFIG FILES ] - $scriptpath"

    ln -srf $scriptpath/.zshrc $HOME/.zshrc
    ln -srf $scriptpath/ghostty/config $HOME/.config/ghostty

    ln -srf $scriptpath/../common/.gitconfig $HOME/.gitconfig
    ln -srf $scriptpath/../common/.gitignore $HOME/.gitignore

    code_path="$HOME/.config/Code/User"
    ln -srf $scriptpath/../common/vscode/settings.json    "$code_path/settings.json"
    ln -srf $scriptpath/../common/vscode/keybindings.json "$code_path/keybindings.json"

fi
