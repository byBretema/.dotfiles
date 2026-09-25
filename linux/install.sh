#!/usr/bin/env bash

script_path=$(cd -- "$(dirname -- "${BASH_SOURCE[-1]}")" &>/dev/null && pwd)
source "${script_path}/scripts/.bash_common"


# --- Consts -------------------------------------------------------------------

DOT_CONFIGS="${script_path}/../configs"
DOT_ASSETS="${script_path}/../assets"
DOT_LINUX_ASSETS="${script_path}/assets"

HOME_CONFIG="$HOME/.config"
mkdir -p "${HOME_CONFIG}"


# --- Actions ------------------------------------------------------------------

mkdir_ret() {
    mkdir -p "$1" &>/dev/null
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
    ghostty_dir=$(mkdir_ret "${HOME_CONFIG}/ghostty")
    ln -srf "${DOT_CONFIGS}/ghostty.conf" "${ghostty_dir}/config"

    # Alacritty
    log_info "Alacritty"
    alacritty_dir=$(mkdir_ret "${HOME_CONFIG}/alacritty")
    ln -srf "${DOT_CONFIGS}/alacritty.toml" "${alacritty_dir}/alacritty.toml"

    # Tmux
    log_info "Tmux"
    tmux_dir=$(mkdir_ret "${HOME_CONFIG}/tmux")
    git_url="https://github.com/tmux-plugins/tpm"
    [[ ! -d "${tmux_dir}/plugins/tpm" ]] && { git clone "${git_url}" "${tmux_dir}/plugins/tpm"; }
    ln -srf "${DOT_CONFIGS}/tmux/tmux.conf" "${tmux_dir}/tmux.conf"


    # --- DevEnv ---
    log_header "Linking - Dev env"

    # # Code
    # log_info "VS Code"
    # vscode_dir=$(mkdir_ret "${config_path}/Code/User")
    # ln -srf "${my_configs}/vscode/settings.json" "${vscode_dir}/settings.json"
    # ln -srf "${my_configs}/vscode/keybindings.json" "${vscode_dir}/keybindings.json"

    # Helix
    log_info "Helix"
    helix_dir=$(mkdir_ret "${HOME_CONFIG}/helix")
    ln -srf "${DOT_CONFIGS}/helix/config.toml" "${helix_dir}/config.toml"
    ln -srf "${DOT_CONFIGS}/helix/languages.toml" "${helix_dir}/languages.toml"
    helix_themes_dir=$(mkdir_ret "${helix_dir}/themes")
    ln -srf "${DOT_CONFIGS}/helix/theme.toml" "${helix_themes_dir}/bretema.toml"
    for theme_file in "${DOT_CONFIGS}/helix/themes/"*; do
        if [ -f "$theme_file" ]; then
            filename=$(basename "$theme_file")
            ln -srf "$theme_file" "${helix_themes_dir}/${filename}"
        fi
    done

    # Git
    log_info "Git"
    ln -srf "${DOT_CONFIGS}/.gitconfig" "$HOME/.gitconfig"
    ln -srf "${DOT_CONFIGS}/.gitignore" "$HOME/.gitignore"

    # WorkTrunk : Manage git-worktrees
    log_info "WorkTrunk"
    worktrunk_dir=$(mkdir_ret "${HOME_CONFIG}/worktrunk")
    ln -srf "${DOT_CONFIGS}/worktrunk.toml" "${worktrunk_dir}/config.toml"


    # --- Apps ---
    log_header "Linking - Apps settings"

    # Flameshot
    log_info "Flameshot"
    flameshot_dir=$(mkdir_ret "${HOME_CONFIG}/flameshot")
    ln -srf "${DOT_CONFIGS}/flameshot.ini" "${flameshot_dir}/flameshot.ini"

    # CopyQ
    log_info "CopyQ"
    copyq_dir=$(mkdir_ret "${HOME_CONFIG}/copyq")
    ln -srf "${DOT_CONFIGS}/copyq/copyq.conf" "${copyq_dir}/copyq.conf"
    ln -srf "${DOT_CONFIGS}/copyq/copyq-commands.ini" "${copyq_dir}/copyq-commands.ini"

    # LazyGit
    log_info "LazyGit"
    lazygit_dir=$(mkdir_ret "${HOME_CONFIG}/lazygit")
    ln -srf "${DOT_CONFIGS}/lazygit/config.yml" "${lazygit_dir}/config.yml"

    # Glow
    log_info "Glow"
    glow_dir=$(mkdir_ret "${HOME_CONFIG}/glow")
    cat > "${glow_dir}/glow.yml" <<EOF
style: "${HOME}/.config/glow/themes/catppuccin-mocha.json"
EOF
    glow_theme_dir=$(mkdir_ret "${glow_dir}/themes")
    ln -srf "${DOT_CONFIGS}/glow/themes/catppuccin-mocha.json" "${glow_theme_dir}/catppuccin-mocha.json"

    # Hunk
    log_info "Hunk"
    hunk_dir=$(mkdir_ret "${HOME_CONFIG}/hunk")
    ln -srf "${DOT_CONFIGS}/hunk/config.toml" "${hunk_dir}/config.toml"

    # MPV
    log_info "MPV"
    mpv_dir=$(mkdir_ret "${HOME_CONFIG}/mpv")
    ln -srf "${DOT_CONFIGS}/mpv/mpv.conf" "${mpv_dir}/mpv.conf"

    # OBS Studio
    log_info "OBS Studio"
    obs_dir=$(mkdir_ret "${HOME_CONFIG}/obs-studio")
    ln -srf "${DOT_CONFIGS}/obs-studio/global.ini" "${obs_dir}/global.ini"
    ln -srf "${DOT_CONFIGS}/obs-studio/user.ini" "${obs_dir}/user.ini"
    obs_profiles_dir=$(mkdir_ret "${obs_dir}/basic/profiles")
    obs_profile_dir="$(mkdir_ret "${obs_profiles_dir}/Untitled")"
    ln -srf "${DOT_CONFIGS}/obs-studio/basic/profiles/Untitled/basic.ini" "${obs_profile_dir}/basic.ini"
    obs_scenes_dir=$(mkdir_ret "${obs_dir}/basic/scenes")
    ln -srf "${DOT_CONFIGS}/obs-studio/basic/scenes/Untitled.json" "${obs_scenes_dir}/Untitled.json"

    # Yazi : https://github.com/yazi-rs/flavors/blob/main/themes.md
    log_info "Yazi"

    yazi_dir=$(mkdir_ret "${HOME_CONFIG}/yazi")
    ln -srf "${DOT_CONFIGS}/yazi/yazi.toml" "${yazi_dir}/yazi.toml"
    ln -srf "${DOT_CONFIGS}/yazi/themes/theme.toml" "${yazi_dir}/theme.toml"

    log_info "-- catppuccin"
    yazi_flavors_dir=$(mkdir_ret "${yazi_dir}/flavors")
    ya pkg add yazi-rs/flavors:catppuccin-mocha &>/dev/null && ya pkg install || true

    log_info "-- piper"
    ya pkg add yazi-rs/plugins:piper &>/dev/null && ya pkg install || true

    # Qt Creator
    log_info "Qt Creator"
    qtcreator_styles_dir=$(mkdir_ret "${HOME_CONFIG}/QtProject/qtcreator/styles")
    src_dir="${DOT_CONFIGS}/qtcreator/themes"
    ln -srf "${src_dir}/monokai_dark.xml" "${qtcreator_styles_dir}/monokai_dark_t.xml"
    ln -srf "${src_dir}/gruvbox_dark.xml" "${qtcreator_styles_dir}/gruvbox_dark_t.xml"
    ln -srf "${src_dir}/catppuccin_latte.xml" "${qtcreator_styles_dir}/catppuccin_latte_t.xml"


    # --- OpenCode ---
    log_header "Linking - OpenCode"
    opencode_dir=$(mkdir_ret "${HOME_CONFIG}/opencode")

    log_info "AGENTS.md"
    ln -srf "${DOT_CONFIGS}/opencode/AGENTS.md" "${opencode_dir}/AGENTS.md"
    log_info "Settings"
    ln -srf "${DOT_CONFIGS}/opencode/opencode.jsonc" "${opencode_dir}/opencode.jsonc"
    ln -srf "${DOT_CONFIGS}/opencode/cli.json" "${opencode_dir}/cli.json"
    log_info "TUI"
    ln -srf "${DOT_CONFIGS}/opencode/tui.json" "${opencode_dir}/tui.json"
    themes_dir=$(mkdir_ret "${opencode_dir}/themes")
    ln -srf "${DOT_CONFIGS}/opencode/themes/catppuccin-transparent.json" "${themes_dir}/catppuccin-transparent.json"
    log_info "Commands"
    ln -srfn "${DOT_CONFIGS}/opencode/commands" "${opencode_dir}/commands"
    log_info "Agents"
    ln -srfn "${DOT_CONFIGS}/opencode/agents" "${opencode_dir}/agents"
    log_info "Skills"
    ln -srfn "${DOT_CONFIGS}/opencode/skills" "${opencode_dir}/skills"
    log_info "Plugins"
    ln -srfn "${DOT_CONFIGS}/opencode/plugin" "${opencode_dir}/plugin"
    log_info "Scripts"
    pnpm_bin_dir=$(mkdir_ret "$(pnpm bin -g 2>/dev/null || echo "$HOME/.local/share/pnpm/bin")")
    ln -srf "${DOT_CONFIGS}/opencode/scripts/mocha-report" "${pnpm_bin_dir}/mocha-report"


    # --- Environment ---
    log_header "Linking - Env vars"

    # Global environment
    log_info "Global"
    sudo cp "$DOT_LINUX_ASSETS/etc/environment" "/etc/environment"

    # Per app/tool env settings
    env_dir=$(mkdir_ret "${HOME_CONFIG}/environment.d")

    log_info "Shell"
    ln -srf "$DOT_LINUX_ASSETS/env/10-shell.conf" "${env_dir}/10-shell.conf"

    log_info "Qt"
    ln -srf "$DOT_LINUX_ASSETS/env/10-qt.conf" "${env_dir}/10-qt.conf"

    log_info "SSH"
    ln -srf "$DOT_LINUX_ASSETS/env/10-ssh.conf" "${env_dir}/10-ssh.conf"


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
    autostart_dir=$(mkdir_ret "${HOME_CONFIG}/autostart")
    ln -srf "$DOT_LINUX_ASSETS/autostart/gnome-keyring-secrets.desktop" "${autostart_dir}/gnome-keyring-secrets.desktop"
    ln -srf "$DOT_LINUX_ASSETS/autostart/gnome-keyring-pkcs11.desktop" "${autostart_dir}/gnome-keyring-pkcs11.desktop"

    #... PAM unlock: login service holds user session via greetd (Service=login)
    if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/login 2>/dev/null; then
        sudo cp "$DOT_LINUX_ASSETS/pam/login" /etc/pam.d/login
    fi

    # XDG Desktop Portal
    log_info "XDG Desktop portal"
    portal_dir=$(mkdir_ret "${HOME_CONFIG}/xdg-desktop-portal")
    ln -srf "$DOT_LINUX_ASSETS/xdg-desktop-portal/portals.conf" "${portal_dir}/portals.conf"

    # GTK
    log_info "Gtk theme"

    gtk3_dir=$(mkdir_ret "${HOME_CONFIG}/gtk-3.0")
    ln -srf "$DOT_LINUX_ASSETS/gtk/gtk-3.0/settings.ini" "${gtk3_dir}/settings.ini"

    gtk4_dir=$(mkdir_ret "${HOME_CONFIG}/gtk-4.0")
    ln -srf "$DOT_LINUX_ASSETS/gtk/gtk-4.0/settings.ini" "${gtk4_dir}/settings.ini"


    # --- Input Management ---
    log_header "Linking - Input management"

    # Solaar
    log_info "Solaar"

    #... config.yaml ///writes battery and weird things, just copy it
    solaar_dir=$(mkdir_ret "${HOME_CONFIG}/solaar")
    ln -srf "$DOT_LINUX_ASSETS/solaar/rules.yaml" "${solaar_dir}/rules.yaml"
    ln -srf "$DOT_LINUX_ASSETS/solaar/config.yaml" "${solaar_dir}/config.yaml"
    # if [[ ! -f "${solaar_dir}/config.yaml" ]]; then
    #     cp "$DOT_LINUX_ASSETS/solaar/config.yaml" "${solaar_dir}/config.yaml"
    # fi

    #... autostart hidden
    autostart_dir=$(mkdir_ret "${HOME_CONFIG}/autostart")
    ln -srf "$DOT_LINUX_ASSETS/solaar/solaar.desktop" "${autostart_dir}/solaar.desktop"

    # Caps 2 Esc
    log_info "Caps-2-Esc"
    # -- Symlinks could fail at boot-time
    # -- so copy the files is the best approach here

    #... caps2esc config
    service_config="/etc/udevmon.yaml"
    sudo rm -rf "${service_config}"
    sudo cp "$DOT_LINUX_ASSETS/caps2esc/udevmon.yaml" "${service_config}"

    #... caps2esc service
    service_file="/etc/systemd/system/udevmon.service"
    sudo rm -rf "${service_file}"
    sudo cp "$DOT_LINUX_ASSETS/caps2esc/udevmon.service" "${service_file}"
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
    sudo cp "$DOT_LINUX_ASSETS/drm-colortemp/drm-colortemp.conf" "${drm_config}"
    sudo systemctl enable drm-colortemp.service
    sudo systemctl restart drm-colortemp.service


    # --- Wallpapers ---
    log_header "Linking Wallpapers"

    wallpapers_dir="/usr/share/wallpapers/bretema"
    if [[ -d "${wallpapers_dir}" ]]; then
        sudo rm -rf "${wallpapers_dir}"
    fi
    sudo mkdir -p "$wallpapers_dir"
    sudo cp -r "$DOT_ASSETS/wallpapers/." "${wallpapers_dir}"
    log_info "Availables at: $wallpapers_dir"


    # --- Cosmic ---
    log_header "Linking Cosmic Settings"

    cosmic_dir="${HOME_CONFIG}/cosmic"
    if [[ -d "${cosmic_dir}" ]]; then
        sudo rm -rf "${cosmic_dir}"
    fi
    ln -srfn "$DOT_LINUX_ASSETS/cosmic" "${HOME_CONFIG}"
}

collect_packages() {
    local list_file=$1 check_cmd=$2 sanitize=$3 invert=${4:-0}
    local result=()

    while IFS= read -r line; do
        [[ $line != \#* ]] || continue
        local pkg=${line//$sanitize/}
        [[ -n $pkg ]] || continue
        eval "$check_cmd \"$pkg\"" &>/dev/null
        local status=$?
        [[ $(( status ^ invert )) -eq 1 ]] && result+=("$pkg")
    done < "$list_file"

    echo "${result[@]}"
}

pnpm_installed() {
    # 'pnpm list -g' exits 0 even when the package is missing, so match the name@version line
    pnpm list -g "$1" 2>/dev/null | grep -qF "$1@"
}

install_packages() {
    log_header "Installing packages"

    log_header "-- Pacman"
    is_cmd "paru" || sudo pacman -S paru
    _pkgs=( $(collect_packages "$script_path/pacman_install.conf" "paru -Q" "[^a-zA-Z0-9_-]") )
    [[ ${#_pkgs[@]} -gt 0 ]] && paru -S $paru_confirm --skipreview "${_pkgs[@]}"

    log_header "-- Flatpak"
    is_cmd "flatpak" || sudo pacman -S flatpak
    _pkgs=( $(collect_packages "$script_path/flatpak_install.conf" "flatpak info" "[^a-zA-Z0-9.]") )
    [[ ${#_pkgs[@]} -gt 0 ]] && flatpak -y install "${_pkgs[@]}"

    log_header "-- Pnpm"
    _pkgs=( $(collect_packages "$script_path/pnpm_install.conf" "pnpm_installed" "[^a-zA-Z0-9@\/._-]") )
    [[ ${#_pkgs[@]} -gt 0 ]] && pnpm add -g "${_pkgs[@]}"
}

remove_packages() {
    log_header "Removing packages"

    _pkgs=( $(collect_packages "$script_path/pacman_remove.conf" "paru -Q" "[^a-zA-Z0-9_-]" 1) )
    [[ ${#_pkgs[@]} -gt 0 ]] && paru -Rns $paru_confirm "${_pkgs[@]}"

    _pkgs=( $(collect_packages "$script_path/flatpak_remove.conf" "flatpak info" "[^a-zA-Z0-9.]" 1) )
    [[ ${#_pkgs[@]} -gt 0 ]] && flatpak -y uninstall "${_pkgs[@]}"
    flatpak uninstall --unused -y

    _pkgs=( $(collect_packages "$script_path/pnpm_remove.conf" "pnpm_installed" "[^a-zA-Z0-9@\/._-]" 1) )
    [[ ${#_pkgs[@]} -gt 0 ]] && pnpm remove -g "${_pkgs[@]}"
}

system_update() {
    log_header "Updating system"
    paru $paru_confirm -Syu
    flatpak update -y
}

configure_git_filters() {
    log_header "Configuring Git filters"

    local repo_root git_dir attributes_file helper rectangle_command
    local solaar_attribute cosmic_attribute

    repo_root=$(git -C "$script_path" rev-parse --show-toplevel 2>/dev/null) || {
        log_info "Not inside a Git repository"
        return 1
    }
    git_dir=$(git -C "$repo_root" rev-parse --absolute-git-dir)
    attributes_file="${git_dir}/info/attributes"
    helper="${git_dir}/cosmic-rectangle-clean.py"
    solaar_attribute="linux/assets/solaar/config.yaml filter=solaar-cookie"
    cosmic_attribute="linux/assets/cosmic/com.system76.CosmicPortal/v1/screenshot filter=cosmic-rectangle"

    mkdir -p "$(dirname "$attributes_file")"
    touch "$attributes_file"
    grep -Fqx -- "$solaar_attribute" "$attributes_file" || printf '%s\n' "$solaar_attribute" >> "$attributes_file"
    grep -Fqx -- "$cosmic_attribute" "$attributes_file" || printf '%s\n' "$cosmic_attribute" >> "$attributes_file"

    git -C "$repo_root" config --local filter.solaar-cookie.clean "sed '/^[[:space:]]*_config_cookie:/d'"

    cat > "$helper" <<'PY'
import re
import subprocess
import sys


path = sys.argv[1]
pattern = re.compile(rb"(?ms)^[ \t]*last_rectangle: Some\(\(\n.*?^[ \t]*\)\),")
baseline = subprocess.check_output(["git", "show", f":{path}"])
source = sys.stdin.buffer.read()
match = pattern.search(baseline)

if match:
    source = pattern.sub(lambda _: match.group(0), source, count=1)

sys.stdout.buffer.write(source)
PY

    printf -v rectangle_command 'python3 %q %%f' "$helper"
    git -C "$repo_root" config --local filter.cosmic-rectangle.clean "$rectangle_command"

    log_info "Solaar and Cosmic filters configured for ${repo_root}"
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
    echo "       --set-git-filters  Configure local Solaar and Cosmic Git filters"
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
do_filters=false
confirm_pacman=false

#! Process options

while [[ "${#}" > 0 ]]; do
    case "${1}" in
    --rm | --remove) shift && do_remove=true ;;
    -u | --update) shift && do_update=true ;;
    -i | --install) shift && do_install=true ;;
    -l | --link) shift && do_links=true ;;
    --set-git-filters) shift && do_filters=true ;;
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
[[ "${do_filters}" == "true" ]] && configure_git_filters
