# !/usr/bin/env bash

script_path=$(cd -- "$(dirname -- "${BASH_SOURCE[-1]}")" &>/dev/null && pwd)
source "${script_path}/scripts/bash/.bash_common"

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

link_config_files() {

    # --- Shell ---
    log_header "Linking config files"

    # Global exports
    sudo ln -srf "${script_path}/scripts/profile/global_exports" "/etc/profile.d/global_exports"

    # Fish
    ln -srf "${script_path}/.fishrc" "$HOME/.config/fish/config.fish"

    # Zsh
    ln -srf "${script_path}/.zshrc" "$HOME/.zshrc"
    ln -srf "${script_path}/.zshenv" "$HOME/.zshenv"

    # Ghostty
    dst_dir=$(mkdir_ret "${config_path}/ghostty")
    ln -srf "${my_configs}/ghostty.conf" "${dst_dir}/config"

    # Alacritty
    dst_dir=$(mkdir_ret "${config_path}/alacritty")
    ln -srf "${my_configs}/alacritty.toml" "${dst_dir}/alacritty.toml"

    # Tmux
    dst_dir=$(mkdir_ret "${config_path}/tmux")
    git_url="https://github.com/tmux-plugins/tpm"
    [[ ! -d "${dst_dir}/plugins/tpm" ]] && { git clone "${git_url}" "${dst_dir}/plugins/tpm"; }
    ln -srf "${my_configs}/tmux/tmux.conf" "${dst_dir}/tmux.conf"

    # --- DevEnv ---

    # Code
    dst_dir=$(mkdir_ret "${config_path}/Code/User")
    ln -srf "${my_configs}/vscode/settings.json" "${dst_dir}/settings.json"
    ln -srf "${my_configs}/vscode/keybindings.json" "${dst_dir}/keybindings.json"

    # Helix
    dst_dir=$(mkdir_ret "${config_path}/helix")
    ln -srf "${my_configs}/helix/config.toml" "${dst_dir}/config.toml"
    ln -srf "${my_configs}/helix/languages.toml" "${dst_dir}/languages.toml"
    mkdir -p "${dst_dir}/themes"
    ln -srf "${my_configs}/helix/theme.toml" "${dst_dir}/themes/bretema.toml"
    for theme_file in "${my_configs}/helix/themes/"*; do
        if [ -f "$theme_file" ]; then
            filename=$(basename "$theme_file")
            ln -srf "$theme_file" "${dst_dir}/themes/${filename}"
        fi
    done

    # Git
    ln -srf "${my_configs}/.gitconfig" "$HOME/.gitconfig"
    ln -srf "${my_configs}/.gitignore" "$HOME/.gitignore"

    # WorkTrunk : Manage git-worktrees
    dst_dir=$(mkdir_ret "${config_path}/worktrunk")
    ln -srf "${my_configs}/worktrunk.toml" "${dst_dir}/config.toml"

    # --- Apps ---

    # Flameshot
    dst_dir=$(mkdir_ret "${config_path}/flameshot")
    ln -srf "${my_configs}/flameshot.ini" "${dst_dir}/flameshot.ini"

    # --- OpenCode ---

    # Main stuff
    dst_dir=$(mkdir_ret "${config_path}/opencode")
    ln -srf "${my_configs}/opencode/opencode.json" "${dst_dir}/opencode.json"
    ln -srf "${my_configs}/opencode/tui.json" "${dst_dir}/tui.json"

    # Skills
    dst_dir=$(mkdir_ret "${config_path}/opencode")
    ln -srf "${my_configs}/opencode/skills" "${dst_dir}/skills"

    # --- Input Management ---

    # Solaar
    ### config.yaml writes battery and weird this, just copy it
    dst_dir=$(mkdir_ret "${config_path}/solaar")
    ln -srf "${script_path}/assets/solaar/rules.yaml" "${dst_dir}/rules.yaml"
    if [[ ! -f "${dst_dir}/config.yaml" ]]; then
        cp "${script_path}/assets/solaar/config.yaml" "${dst_dir}/config.yaml"
    fi
    ### Autostart
    dst_dir=$(mkdir_ret "${config_path}/autostart")
    ln -srf "/usr/share/applications/solaar.desktop" "${dst_dir}/solaar.desktop"

    # Caps 2 Esc
    ### Symlinks could fail at boot-time, so copy the files is the best approach here
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
    sudo systemctl start udevmon.service

    # drm-colortemp
    drm_config="/etc/default/drm-colortemp.conf"
    sudo mkdir -p "$(dirname "${drm_config}")"
    sudo cp "${script_path}/assets/drm-colortemp/drm-colortemp.conf" "${drm_config}"
    sudo systemctl enable drm-colortemp.service
    sudo systemctl restart drm-colortemp.service

    # --- Themes ---
    log_header "Linking Themes"

    # Qt Creator
    dst_dir=$(mkdir_ret "${config_path}/QtProject/qtcreator/styles")
    src_dir="${my_configs}/qtcreator/themes"
    ln -srf "${src_dir}/monokai_dark.xml" "${dst_dir}/monokai_dark_t.xml"
    ln -srf "${src_dir}/gruvbox_dark.xml" "${dst_dir}/gruvbox_dark_t.xml"
    ln -srf "${src_dir}/catppuccin_latte.xml" "${dst_dir}/catppuccin_latte_t.xml"

    # Yazi : https://github.com/yazi-rs/flavors/blob/main/themes.md
    dst_dir=$(mkdir_ret "${config_path}/yazi")
    mkdir -p "${config_path}/yazi/flavors"
    ya pkg add yazi-rs/flavors:catppuccin-mocha >/dev/null 2>&1 && ya pkg install || true
    ln -srf "${my_configs}/yazi/themes/theme.toml" "${dst_dir}/theme.toml"

    # --- Wallpapers ---
    log_header "Linking Wallpapers"

    dst_dir=$(mkdir_ret "/usr/share/wallpapers/bretema")
    if [[ -d "${dst_dir}" ]]; then
        sudo rm -rf "${dst_dir}"
    fi
    sudo cp -r "${script_path}/../assets/wallpapers" "${dst_dir}"

    # --- Cosmic ---
    log_header "Linking Cosmic Settings"

    dst_dir="${config_path}/cosmic"
    if [[ -d "${dst_dir}" ]]; then
        sudo rm -rf "${dst_dir}"
    fi
    ln -srfn "${script_path}/assets/cosmic" "${config_path}"
}

process_packages() {
    local list_file=$1 check_cmd=$2 action_cmd=$3 sanitize=$4 invert_check=${5:-false}

    while IFS= read -r line; do
        local pkg=${line//$sanitize/}
        [[ -n $pkg ]] || continue
        [[ $line != \#* ]] || continue
        if [[ $invert_check == true ]]; then
            $check_cmd "$pkg" &>/dev/null || continue
        else
            $check_cmd "$pkg" &>/dev/null && continue
        fi
        $action_cmd "$pkg"
    done <"$list_file"
}

install_packages() {
    log_header "Installing packages"

    process_packages "$script_path/pacman_install.conf" \
        "pacman -Qi" "paru -S --noconfirm --skipreview" "[^a-zA-Z0-9_-]"

    process_packages "$script_path/flatpak_install.conf" \
        "flatpak info" "flatpak -y install" "[^a-zA-Z0-9.]"

    # Fix for ncspot - https://github.com/hrkfdn/ncspot/issues/1676#issuecomment-3168197941
    ncspot_entry="0.0.0.0 apresolve.spotify.com"
    if ! grep -qFx "$ncspot_entry" /etc/hosts; then
        echo "$ncspot_entry" | sudo tee -a /etc/hosts >/dev/null
    fi
}

remove_discarded_packages() {
    log_header "Removing packages"

    process_packages "$script_path/pacman_remove.conf" \
        "pacman -Qi" "paru -Rns --noconfirm" "[^a-zA-Z0-9_-]" true

    process_packages "$script_path/flatpak_remove.conf" \
        "flatpak info" "flatpak -y uninstall" "[^a-zA-Z0-9.]" true
    flatpak uninstall --unused -y
}

system_update() {
    log_header "Updating system"
    paru --noconfirm -Syu
    flatpak update -y
}

################################################################################
### Parse args
################################################################################

#! Help

usage() {
    echo "Usage: $(basename "${BASH_SOURCE[-1]}") [options]"
    echo ""
    echo "Manage configs and system apps, themes..."
    echo ""
    echo "Options:"
    echo "  --rm | --remove-discarded  Remove discarded packages"
    echo "    -u | --update            System update"
    echo "    -i | --install           Install packages / apps"
    echo "    -l | --links             Link configs / themes"
    echo "    -h | --help              Show this message"
    echo "    --                       Extra args after this"
}

#! Defaults

do_remove_discarded=false
do_update=false
do_install=false
do_links=false

#! Process options

while [[ "${#}" > 0 ]]; do
    case "${1}" in
    --rm | --remove-discarded) shift && do_remove_discarded=true ;;
    -u | --update) shift && do_update=true ;;
    -i | --install) shift && do_install=true ;;
    -l | --link) shift && do_links=true ;;
    -h | --help) shift && usage ;;
    --) shift && break ;;
    *) break ;;
    esac
done

###############################################################################
### Execution
###############################################################################

[[ "${do_remove_discarded}" == "true" ]] && remove_discarded_packages
[[ "${do_update}" == "true" ]] && system_update
[[ "${do_install}" == "true" ]] && install_packages
[[ "${do_links}" == "true" ]] && link_config_files
