
###############################################################################
### INSTALL / UPDATE APPS
###############################################################################

paru paru -Syu # Trigger updates
main="cachyos-extra-v3"

# OS Uitls
#---------------------
paru -Sy aur/ulauncher  # App launcher
paru -Sy $main/net-tools  # Legacy but fine for some scripts

# Media
#---------------------
paru -Sy aur/balena-etcher  # Burn ISOs
paru -Sy $main/f3d  # 3D Previewer
paru -Sy $main/blender  # Blender
paru -Sy $main/obs-studio  # OBS Studio
paru -Sy $main/handbrake  # Video enconder

# Communications
#---------------------
paru -Sy $main/thunderbird  # Mail manager
paru -Sy aur/teamviewer  # Remote support
paru -Sy aur/slack-desktop-wayland  # Team communication

# Information
#---------------------
paru -Sy aur/brave-bin  # A better Chrome
paru -Sy aur/notion-app-electron  # Notion
paru -Sy extra/obsidian  # Obsidian

# Dev
#---------------------
paru -Sy $main/cmake  # CMake
paru -Sy $main/starship  # Prompt customization
paru -Sy $main/lazygit  # Just a TUI for Git
paru -Sy aur/visual-studio-code-bin

# Personal
#---------------------
paru -Sy $main/bitwarden  # Password manager
paru -Sy aur/localsend-bin  # Airdrop wannabe

###############################################################################
### LINK CONFIG FILES
###############################################################################

ln -srf .zshrc $HOME/.zshrc
ln -srf .gitconfig $HOME/.gitconfig
ln -srf .gitignore $HOME/.gitignore

code_path="$HOME/.config/Code/User"
ln -srf ./vscode/settings.json    "$code_path/settings.json"
ln -srf ./vscode/keybindings.json "$code_path/keybindings.json"


## todo: link Ghostty config
