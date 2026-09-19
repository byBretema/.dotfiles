#!/usr/bin/env bash

script_path=$(cd -- "$(dirname -- "${BASH_SOURCE[-1]}")" &>/dev/null && pwd)
source "${script_path}/scripts/.bash_common"


# --- Consts -------------------------------------------------------------------

DOT_CONFIGS="${script_path}/../configs"

HOME_CONFIG="$HOME/.config"
mkdir -p "${HOME_CONFIG}"


# --- Actions ------------------------------------------------------------------

mkdir_ret() {
    mkdir -p "$1" >/dev/null 2>&1
    echo "$1"
}

link_config_files() {

    # --- Shell ---
    log_header "Linking - Shell stuff"

    # Fish
    log_info "Fish"
    ln -srf "${script_path}/.fishrc" "$HOME/.config/fish/config.fish"

    # Zsh
    log_info "Zsh"
    ln -srf "${script_path}/.zshrc" "$HOME/.zshrc"
    # ln -srf "${script_path}/.zshenv" "$HOME/.zshenv"  # uncomment if you drop fish and want zshenv

    # Ghostty
    log_info "Ghostty"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/ghostty")
    ln -srf "${DOT_CONFIGS}/ghostty.conf" "${dst_dir}/config"

    # Alacritty
    log_info "Alacritty"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/alacritty")
    ln -srf "${DOT_CONFIGS}/alacritty.toml" "${dst_dir}/alacritty.toml"

    # Tmux
    log_info "Tmux"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/tmux")
    git_url="https://github.com/tmux-plugins/tpm"
    [[ ! -d "${dst_dir}/plugins/tpm" ]] && { git clone "${git_url}" "${dst_dir}/plugins/tpm"; }
    ln -srf "${DOT_CONFIGS}/tmux/tmux.conf" "${dst_dir}/tmux.conf"


    # --- DevEnv ---
    log_header "Linking - Dev env"

    # # Code
    # log_info "VS Code"
    # dst_dir=$(mkdir_ret "${config_path}/Code/User")
    # ln -srf "${my_configs}/vscode/settings.json" "${dst_dir}/settings.json"
    # ln -srf "${my_configs}/vscode/keybindings.json" "${dst_dir}/keybindings.json"

    # Helix
    log_info "Helix"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/helix")
    ln -srf "${DOT_CONFIGS}/helix/config.toml" "${dst_dir}/config.toml"
    ln -srf "${DOT_CONFIGS}/helix/languages.toml" "${dst_dir}/languages.toml"
    mkdir -p "${dst_dir}/themes"
    ln -srf "${DOT_CONFIGS}/helix/theme.toml" "${dst_dir}/themes/bretema.toml"
    for theme_file in "${DOT_CONFIGS}/helix/themes/"*; do
        if [ -f "$theme_file" ]; then
            filename=$(basename "$theme_file")
            ln -srf "$theme_file" "${dst_dir}/themes/${filename}"
        fi
    done

    # Git
    log_info "Git"
    ln -srf "${DOT_CONFIGS}/.gitconfig" "$HOME/.gitconfig"
    ln -srf "${DOT_CONFIGS}/.gitignore" "$HOME/.gitignore"

    # WorkTrunk : Manage git-worktrees
    log_info "WorkTrunk"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/worktrunk")
    ln -srf "${DOT_CONFIGS}/worktrunk.toml" "${dst_dir}/config.toml"


    # --- Apps ---
    log_header "Linking - Apps settings"

    # Flameshot
    log_info "Flameshot"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/flameshot")
    ln -srf "${DOT_CONFIGS}/flameshot.ini" "${dst_dir}/flameshot.ini"

    # CopyQ
    log_info "CopyQ"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/copyq")
    ln -srf "${DOT_CONFIGS}/copyq/copyq.conf" "${dst_dir}/copyq.conf"
    ln -srf "${DOT_CONFIGS}/copyq/copyq-commands.ini" "${dst_dir}/copyq-commands.ini"

    # LazyGit
    log_info "LazyGit"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/lazygit")
    ln -srf "${DOT_CONFIGS}/lazygit/config.yml" "${dst_dir}/config.yml"

    # Glow
    log_info "Glow"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/glow")
    cat > "${dst_dir}/glow.yml" <<EOF
style: "${HOME}/.config/glow/themes/catppuccin-mocha.json"
EOF
    dst_dir=$(mkdir_ret "${dst_dir}/themes")
    ln -srf "${DOT_CONFIGS}/glow/themes/catppuccin-mocha.json" "${dst_dir}/catppuccin-mocha.json"

    # Hunk
    log_info "Hunk"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/hunk")
    ln -srf "${DOT_CONFIGS}/hunk/config.toml" "${dst_dir}/config.toml"

    # MPV
    log_info "MPV"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/mpv")
    ln -srf "${DOT_CONFIGS}/mpv/mpv.conf" "${dst_dir}/mpv.conf"

    # OBS Studio
    log_info "OBS Studio"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/obs-studio")
    ln -srf "${DOT_CONFIGS}/obs-studio/global.ini" "${dst_dir}/global.ini"
    ln -srf "${DOT_CONFIGS}/obs-studio/user.ini" "${dst_dir}/user.ini"
    profile_dir=$(mkdir_ret "${dst_dir}/basic/profiles/Untitled")
    ln -srf "${DOT_CONFIGS}/obs-studio/basic/profiles/Untitled/basic.ini" "${profile_dir}/basic.ini"
    scenes_dir=$(mkdir_ret "${dst_dir}/basic/scenes")
    ln -srf "${DOT_CONFIGS}/obs-studio/basic/scenes/Untitled.json" "${scenes_dir}/Untitled.json"

    # Yazi : https://github.com/yazi-rs/flavors/blob/main/themes.md
    log_info "Yazi"

    dst_dir=$(mkdir_ret "${HOME_CONFIG}/yazi")
    ln -srf "${DOT_CONFIGS}/yazi/yazi.toml" "${dst_dir}/yazi.toml"
    ln -srf "${DOT_CONFIGS}/yazi/themes/theme.toml" "${dst_dir}/theme.toml"

    log_info "  -- catppuccin"
    mkdir -p "${HOME_CONFIG}/yazi/flavors"
    ya pkg add yazi-rs/flavors:catppuccin-mocha >/dev/null 2>&1 && ya pkg install || true

    log_info "  -- piper"
    ya pkg add yazi-rs/plugins:piper >/dev/null 2>&1 && ya pkg install || true

    # Qt Creator
    log_info "Qt Creator"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/QtProject/qtcreator/styles")
    src_dir="${DOT_CONFIGS}/qtcreator/themes"
    ln -srf "${src_dir}/monokai_dark.xml" "${dst_dir}/monokai_dark_t.xml"
    ln -srf "${src_dir}/gruvbox_dark.xml" "${dst_dir}/gruvbox_dark_t.xml"
    ln -srf "${src_dir}/catppuccin_latte.xml" "${dst_dir}/catppuccin_latte_t.xml"


    # --- OpenCode ---
    log_header "Linking - OpenCode"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/opencode")

    log_info "AGENTS.md"
    ln -srf "${DOT_CONFIGS}/opencode/AGENTS.md" "${dst_dir}/AGENTS.md"
    log_info "Settings"
    ln -srf "${DOT_CONFIGS}/opencode/opencode.jsonc" "${dst_dir}/opencode.jsonc"
    log_info "TUI"
    ln -srf "${DOT_CONFIGS}/opencode/tui.json" "${dst_dir}/tui.json"
    log_info "Commands"
    ln -srfn "${DOT_CONFIGS}/opencode/commands" "${dst_dir}/commands"
    log_info "Agents"
    ln -srfn "${DOT_CONFIGS}/opencode/agents" "${dst_dir}/agents"
    log_info "Skills"
    ln -srfn "${DOT_CONFIGS}/opencode/skills" "${dst_dir}/skills"
    log_info "Plugins"
    ln -srfn "${DOT_CONFIGS}/opencode/plugin" "${dst_dir}/plugin"
    log_info "Scripts"
    mkdir -p "$(pnpm bin -g 2>/dev/null || echo "$HOME/.local/share/pnpm/bin")"
    ln -srf "${DOT_CONFIGS}/opencode/scripts/mocha-report" "$(pnpm bin -g 2>/dev/null || echo "$HOME/.local/share/pnpm/bin")/mocha-report"


    # --- Environment ---
    log_header "Linking - Env vars"

    # Global environment
    log_info "Global"
    sudo cp "${script_path}/assets/etc/environment" "/etc/environment"

    # Per app/tool env settings
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/environment.d")

    log_info "Qt"
    ln -srf "${script_path}/assets/env/10-qt.conf" "${dst_dir}/10-qt.conf"

    log_info "SSH"
    ln -srf "${script_path}/assets/env/10-ssh.conf" "${dst_dir}/10-ssh.conf"


    # --- GNOME ---
    log_header "Linking - Gnome fixs"

    # Keyring
    log_info "Keyring"

    #... Unmask socket (was masked to /dev/null when using gcr-ssh-agent only)
    if [[ -L "${HOME}/.config/systemd/user/gnome-keyring-daemon.socket" ]]; then
        rm "${HOME}/.config/systemd/user/gnome-keyring-daemon.socket"
        systemctl --user daemon-reload 2>/dev/null || true
        systemctl --user enable gnome-keyring-daemon.socket 2>/dev/null || true
    fi

    #... Autostart overrides for COSMIC (OnlyShowIn in /etc/xdg/autostart excludes COSMIC)
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/autostart")
    ln -srf "${script_path}/assets/autostart/gnome-keyring-secrets.desktop" "${dst_dir}/gnome-keyring-secrets.desktop"
    ln -srf "${script_path}/assets/autostart/gnome-keyring-pkcs11.desktop" "${dst_dir}/gnome-keyring-pkcs11.desktop"

    #... PAM unlock: login service holds user session via greetd (Service=login)
    if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/login 2>/dev/null; then
        sudo cp "${script_path}/assets/pam/login" /etc/pam.d/login
    fi

    # XDG Desktop Portal
    log_info "XDG Desktop portal"
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/xdg-desktop-portal")
    ln -srf "${script_path}/assets/xdg-desktop-portal/portals.conf" "${dst_dir}/portals.conf"

    # GTK
    log_info "Gtk theme"

    dst_dir=$(mkdir_ret "${HOME_CONFIG}/gtk-3.0")
    ln -srf "${script_path}/assets/gtk/gtk-3.0/settings.ini" "${dst_dir}/settings.ini"

    dst_dir=$(mkdir_ret "${HOME_CONFIG}/gtk-4.0")
    ln -srf "${script_path}/assets/gtk/gtk-4.0/settings.ini" "${dst_dir}/settings.ini"


    # --- Input Management ---
    log_header "Linking - Input management"

    # Solaar
    log_info "Solaar"

    #... config.yaml writes battery and weird this, just copy it
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/solaar")
    ln -srf "${script_path}/assets/solaar/rules.yaml" "${dst_dir}/rules.yaml"
    if [[ ! -f "${dst_dir}/config.yaml" ]]; then
        cp "${script_path}/assets/solaar/config.yaml" "${dst_dir}/config.yaml"
    fi

    #... autostart hidden
    dst_dir=$(mkdir_ret "${HOME_CONFIG}/autostart")
    ln -srf "${script_path}/assets/solaar/solaar.desktop" "${dst_dir}/solaar.desktop"

    # Caps 2 Esc
    log_info "Caps-2-Esc"
    # -- Symlinks could fail at boot-time
    # -- so copy the files is the best approach here

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
    log_info "DRM ColorTemp"
    drm_config="/etc/default/drm-colortemp.conf"
    sudo mkdir -p "$(dirname "${drm_config}")"
    sudo cp "${script_path}/assets/drm-colortemp/drm-colortemp.conf" "${drm_config}"
    sudo systemctl enable drm-colortemp.service
    sudo systemctl restart drm-colortemp.service


    # --- Wallpapers ---
    log_header "Linking Wallpapers"

    dst_dir=$(mkdir_ret "/usr/share/wallpapers/bretema")
    if [[ -d "${dst_dir}" ]]; then
        sudo rm -rf "${dst_dir}"
    fi
    sudo cp -r "${script_path}/../assets/wallpapers" "${dst_dir}"
    log_info "Availables at: $dst_dir"


    # --- Cosmic ---
    log_header "Linking Cosmic Settings"

    dst_dir="${HOME_CONFIG}/cosmic"
    if [[ -d "${dst_dir}" ]]; then
        sudo rm -rf "${dst_dir}"
    fi
    ln -srfn "${script_path}/assets/cosmic" "${HOME_CONFIG}"
}

process_packages() {
    local list_file=$1 check_cmd=$2 action_cmd=$3 sanitize=$4 invert_check=${5:-false}

    while IFS= read -r line <&3; do
        local pkg=${line//$sanitize/}
        [[ -n $pkg ]] || continue
        [[ $line != \#* ]] || continue
        eval "$check_cmd \"$pkg\"" &>/dev/null
        # local status=$?
        { [[ $invert_check == false && $status -eq 0 ]] || [[ $invert_check == true ]]; } && continue
        log_header ">>> Package: $pkg"
        $action_cmd "$pkg"
    done 3<"$list_file"
}

pnpm_installed() {
    # 'pnpm list -g' exits 0 even when the package is missing, so match the name@version line
    pnpm list -g "$1" 2>/dev/null | grep -qF "$1@"
}

install_packages() {
    log_header "Installing packages"

    process_packages "$script_path/pacman_install.conf" \
        "pacman -Qq | grep -Fx" "paru -S $paru_confirm --skipreview" "[^a-zA-Z0-9_-]" false

    process_packages "$script_path/flatpak_install.conf" \
        "flatpak info" "flatpak -y install" "[^a-zA-Z0-9.]" false

    process_packages "$script_path/pnpm_install.conf" \
        "pnpm_installed" "pnpm add -g" "[^a-zA-Z0-9@\/._-]" false
}

remove_packages() {
    log_header "Removing packages"

    process_packages "$script_path/pacman_remove.conf" \
        "pacman -Qq | grep -Fx" "paru -Rns $paru_confirm" "[^a-zA-Z0-9_-]" true

    process_packages "$script_path/flatpak_remove.conf" \
        "flatpak info" "flatpak -y uninstall" "[^a-zA-Z0-9.]" true
    flatpak uninstall --unused -y

    process_packages "$script_path/pnpm_remove.conf" \
        "pnpm_installed" "pnpm remove -g" "[^a-zA-Z0-9@\/._-]" true
}

system_update() {
    log_header "Updating system"
    paru $paru_confirm -Syu
    flatpak update -y
}


# --- Parse Args ---------------------------------------------------------------

#! Help

usage() {
    echo "Usage: $(basename "${BASH_SOURCE[-1]}") [options]"
    echo ""
    echo "Manage configs and system apps, themes..."
    echo ""
    echo "Options:"
    echo "  --rm | --remove            Remove discarded packages"
    echo "    -u | --update            System update"
    echo "    -i | --install           Install packages / apps"
    echo "    -l | --links             Link configs / themes"
    echo "  --all                      Run --rm, -u, -i, and -l in sequence"
    echo "    --confirm-pacman         Prompt before each package action (removes --noconfirm)"
    echo "    -h | --help              Show this message"
    echo "    --                       Extra args after this"
}

#! Defaults

do_remove=false
do_update=false
do_install=false
do_links=false
confirm_pacman=false

#! Process options

while [[ "${#}" > 0 ]]; do
    case "${1}" in
    --rm | --remove) shift && do_remove=true ;;
    -u | --update) shift && do_update=true ;;
    -i | --install) shift && do_install=true ;;
    -l | --link) shift && do_links=true ;;
    --all) shift && do_remove=true && do_update=true && do_install=true && do_links=true ;;
    -h | --help) shift && usage ;;
    --confirm-pacman) shift && confirm_pacman=true ;;
    --) shift && break ;;
    *) break ;;
esac
done


# --- Execution ----------------------------------------------------------------

paru_confirm="--noconfirm"
[[ $confirm_pacman == true ]] && paru_confirm=""

[[ "${do_remove}" == "true" ]] && remove_packages
[[ "${do_update}" == "true" ]] && system_update
[[ "${do_install}" == "true" ]] && install_packages
[[ "${do_links}" == "true" ]] && link_config_files
