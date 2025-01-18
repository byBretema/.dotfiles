#!/bin/bash
set -u

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
        *) echo "Usage: install.sh [-u] [-i] [-i]"; exit 1;;
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

    echo "### [ UPDATE SYSTEM ]"

    paru --noconfirm -Syu # Trigger updates

fi

###############################################################################
### INSTALL / UPDATE APPS
###############################################################################

if [[ $do_install -eq 1 ]]; then

    echo "### [ INSTALL / UPDATE APPS ]"

    extra_v3="cachyos-extra-v3"
    core_v3="cachyos-core-v3"

    # OS Uitls
    #----------------------------
    paru --noconfirm -Sy aur/ulauncher  # App launcher
    paru --noconfirm -Sy $core_v3/net-tools  # Legacy but fine for some scripts

    # Media
    #----------------------------
    paru --noconfirm -Sy aur/balena-etcher  # Burn ISOs
    paru --noconfirm -Sy $extra_v3/f3d  # 3D Previewer
    paru --noconfirm -Sy $extra_v3/blender  # Blender
    paru --noconfirm -Sy $extra_v3/obs-studio  # OBS Studio
    paru --noconfirm -Sy $extra_v3/handbrake  # Video enconder

    # Communications
    #----------------------------
    paru --noconfirm -Sy $extra_v3/thunderbird  # Mail manager
    paru --noconfirm -Sy aur/teamviewer  # Remote support
    paru --noconfirm -Sy aur/slack-desktop  # Team communication

    # Information
    #----------------------------
    paru --noconfirm -Sy aur/brave-bin  # A better Chrome
    paru --noconfirm -Sy aur/notion-app-electron  # Notion
    paru --noconfirm -Sy extra/obsidian  # Obsidian

    # Dev
    #----------------------------
    paru --noconfirm -Sy $extra_v3/cmake  # CMake
    paru --noconfirm -Sy $extra_v3/starship  # Prompt customization
    paru --noconfirm -Sy $extra_v3/lazygit  # Just a TUI for Git
    paru --noconfirm -Sy aur/visual-studio-code-bin

    # Personal
    #----------------------------
    paru --noconfirm -Sy $extra_v3/bitwarden  # Password manager
    paru --noconfirm -Sy aur/localsend-bin  # Airdrop wannabe

fi


###############################################################################
### LINK CONFIG FILES
###############################################################################

if [[ $do_links -eq 1 ]]; then

    echo "### [ LINK CONFIG FILES ] - $scriptpath"

    ln -srf $scriptpath/.zshrc $HOME/.zshrc
    ln -srf $scriptpath/ghostty/config $HOME/.config/ghostty

    ln -srf $scriptpath/../common/.gitconfig $HOME/.gitconfig
    ln -srf $scriptpath/../common/.gitignore $HOME/.gitignore

    code_path="$HOME/.config/Code/User"
    ln -srf $scriptpath/../common/vscode/settings.json    "$code_path/settings.json"
    ln -srf $scriptpath/../common/vscode/keybindings.json "$code_path/keybindings.json"

fi
