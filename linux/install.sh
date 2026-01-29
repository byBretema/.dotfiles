#!/usr/bin/env bash

script_path=$(cd -- "$(dirname -- "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)
source "${script_path}/scripts/bash/.bash_common"
set -e


###############################################################################
# Consts
###############################################################################

my_configs="${script_path}/../configs"
config_path="$HOME/.config"
mkdir -p "${config_path}"

################################################################################
### Actions
################################################################################

mkdir_ret() { 
    mkdir -p "$1" >/dev/null 2>&1
    echo "$1"
}


link_config_files_and_themes() {
    #! Configs
    log_header "Linking config files"

    # Fish
    ln -srf "${script_path}/.fishrc"  "$HOME/.config/fish/config.fish"

    # Zsh
    ln -srf "${script_path}/.zshrc"  "$HOME/.zshrc"
    ln -srf "${script_path}/.zshenv" "$HOME/.zshenv"

    # Git
    ln -srf "${my_configs}/.gitconfig" "$HOME/.gitconfig"
    ln -srf "${my_configs}/.gitignore" "$HOME/.gitignore"

    # Ghostty
    dst_dir=$(mkdir_ret "${config_path}/ghostty")
    ln -srf "${my_configs}/ghostty.conf" "${dst_dir}/config"

    # Alacritty
    dst_dir=$(mkdir_ret "${config_path}/alacritty")
    ln -srf "${my_configs}/alacritty.toml" "${dst_dir}/alacritty.toml"

    # Code
    dst_dir=$(mkdir_ret "${config_path}/Code/User")
    ln -srf "${my_configs}/vscode/settings.json"    "${dst_dir}/settings.json"
    ln -srf "${my_configs}/vscode/keybindings.json" "${dst_dir}/keybindings.json"

    # Helix
    dst_dir=$(mkdir_ret "${config_path}/helix")
    ln -srf "${my_configs}/helix/config.toml" "${dst_dir}/config.toml"
    ln -srf "${my_configs}/helix/languages.toml" "${dst_dir}/languages.toml"

    # Tmux
    dst_dir=$(mkdir_ret "${config_path}/tmux")
    git_url="https://github.com/tmux-plugins/tpm"
    [[ ! -d "${dst_dir}/plugins/tpm" ]] && { git clone "${git_url}" "${dst_dir}/plugins/tpm"; }
    ln -srf "${my_configs}/tmux.conf" "${dst_dir}/tmux.conf"

    # Flameshot
    dst_dir=$(mkdir_ret "${config_path}/flameshot")
    ln -srf "${my_configs}/flameshot.ini" "${dst_dir}/flameshot.ini"

    # caps2esc
    ### Symlinks could fail at boot-time
    ### So copy the files is the best approach here
    #... caps2esc config
    service_config="/etc/udevmon.yaml"
    sudo rm -rf "${service_config}"
    sudo cp "${script_path}/assets/caps2esc/udevmon.yaml" "${service_config}"
    #... caps2esc service
    service_file="/etc/systemd/system/udevmon.service"
    sudo rm -rf "${service_file}"
    sudo cp "${script_path}/assets/caps2esc/udevmon.service" "${service_file}"
    sudo chown root:root "${service_file}"
    sudo chmod 644 "${service_file}"
    #... caps2esc reload and enable
    sudo systemctl daemon-reload
    sudo systemctl enable udevmon.service
    sudo systemctl start  udevmon.service

    #! Themes
    log_header "Linking Themes"

    # Qt Creator
    dst_dir=$(mkdir_ret "${config_path}/QtProject/qtcreator/styles")
    src_dir="${my_configs}/qtcreator/themes"
    ln -srf "${src_dir}/monokai_dark.xml"     "${dst_dir}/monokai_dark_t.xml"
    ln -srf "${src_dir}/gruvbox_dark.xml"     "${dst_dir}/gruvbox_dark_t.xml"
    ln -srf "${src_dir}/catppuccin_latte.xml" "${dst_dir}/catppuccin_latte_t.xml"

    # Yazi : https://github.com/yazi-rs/flavors/blob/main/themes.md
    dst_dir=$(mkdir_ret "${config_path}/yazi")
    ln -srf "${my_configs}/yazi/themes/gruvbox_dark.toml" "${dst_dir}/theme.toml"

    # Cosmic - Floating Windows  (defined in RON format)
    dst_dir=$(mkdir_ret "${config_path}/cosmic/com.system76.CosmicSettings.WindowRules/v1")
    ln -srf "${script_path}/assets/cosmic/tiling_exception_custom" "${dst_dir}/tiling_exception_custom"
}


system_update() {
    log_header "Updating system"
    paru --noconfirm -Syu  # Trigger updates
}


install_packages() {
    log_header "Installing / updating apps"

    # Install pacman packages
    while IFS= read -r line; do
        pkg=${line//[^a-zA-Z0-9_-]/}
        [[ -n $pkg ]] && [[ $line != \#* ]] && { paru -S --needed --noconfirm --skipreview $pkg; }
    done < "$script_path/pacman_list.conf"

    # Install flatpaks
    while IFS= read -r line; do
        pkg=${line//[^a-zA-Z0-9.]/}
        [[ -n $pkg ]] && [[ $line != \#* ]] && { flatpak -y install $pkg; }
    done < "$script_path/flatpak_list.conf"
    flatpak update

    # Fix for ncspot - https://github.com/hrkfdn/ncspot/issues/1676#issuecomment-3168197941
    ncspot_entry="0.0.0.0 apresolve.spotify.com";
    if ! grep -qFx "$ncspot_entry" /etc/hosts; then
        echo "$ncspot_entry" | sudo tee -a /etc/hosts > /dev/null
    fi
}


install_font_from_zip()
{
    local url=$1; shift
    local filename=$(basename "${url}")

    local temp_dir=$(mktemp -d)
    local font_zip="${temp_dir}/${filename}"
    local font_unzip="${temp_dir}/${filename}_unzip"

    curl -fsSL "${url}" -o "${font_zip}"
    unzip -q "${font_zip}" -d "${font_unzip}"

    local fonts_path=$(mkdir_ret "$HOME/.local/share/fonts")

    find "${font_unzip}" -type f -name "*.ttf" -o -name "*.otf" | \
    while read font; do
        cp "${font}" "${fonts_path}" || log_error "Installing font : $(basename "${font}")"
    done

    rm -rf "$temp_dir"
}


install_fonts() {
    log_header "Installing fonts"

    install_font_from_zip "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
    install_font_from_zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    install_font_from_zip "https://rubjo.github.io/victor-mono/VictorMonoAll.zip"

    fc-cache -f
}


vscode_extensions() {
    log_header "Installing vscode extensions"
    python "$my_configs/vscode/extensions.py" -i
}



################################################################################
### Parse args
################################################################################

#! Help

usage() {
    echo "Usage: $(basename "${BASH_SOURCE[-1]}") [options]"
    echo ""
    echo "Manage configs and system apps, fonts, themes..."
    echo ""
    echo "Options:"
    echo "  -u | --update         System update"
    echo "  -l | --links          Link configs / themes"
    echo "  -i | --install        Install packages / apps"
    echo "  -f | --fonts          Install fonts"
    echo "  -c | --code [PARAMS]  Manage code extensions"
    echo "  -h | --help           Show this message"
    echo "  --                    Extra args after this"
}

#! Defaults

do_links=false
do_update=false
do_install=false
do_fonts=false
do_code_extensions=false


#! Process options

while [[ "${#}" > 0 ]]; do
    case "${1}" in
        -u | --update   ) shift; do_update=true          ;;
        -l | --links    ) shift; do_links=true           ;;
        -i | --install  ) shift; do_install=true         ;;
        -f | --fonts    ) shift; do_fonts=true           ;;
        -c | --code     ) shift; do_code_extensions=true ;;
        -h | --help     ) shift; usage                   ;;
        --              ) shift; break                   ;;
        *               )        break                   ;;
    esac
done


###############################################################################
### Execution
###############################################################################

[[ ${do_links}           == true ]] && link_config_files_and_themes
[[ ${do_update}          == true ]] && system_update
[[ ${do_install}         == true ]] && install_packages
[[ ${do_fonts}           == true ]] && install_fonts
[[ ${do_code_extensions} == true ]] && vscode_extensions

