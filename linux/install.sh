#!/usr/bin/env bash

script_path=$(cd -- "$(dirname -- "${BASH_SOURCE[-1]}")" &>/dev/null && pwd)
source "${script_path}/scripts/.bash_common"

# --- Consts -------------------------------------------------------------------

DOT_ROOT=$(cd -- "${script_path}/.." && pwd)
DOT_CONFIGS="${DOT_ROOT}/configs"
DOT_ASSETS="${script_path}/../assets"
DOT_LINUX_ASSETS="${script_path}/assets"

HOME_CONFIG="$HOME/.config"
mkdir -p "${HOME_CONFIG}"

git_dir=$(git -C "$script_path" rev-parse --absolute-git-dir 2>/dev/null)
attributes_file="${git_dir:+${git_dir}/info/attributes}"

# --- Actions ------------------------------------------------------------------

# Copy into a system path; skips when unchanged, keeps a numbered backup (file.~1~) otherwise
sys_copy() {
    cmp -s "$1" "$2" && return 0
    sudo cp --backup=numbered "$1" "$2"
}

# Symlink $1 -> $2, creating parent dirs. -n replaces an existing dir link instead of nesting into it.
link() {
    mkdir -p "$(dirname "$2")" && ln -srfn "$1" "$2"
}

# Reads "src dst" lines from stdin: src relative to the repo, dst relative to $HOME.
link_table() {
    local src dst
    while read -r src dst; do
        [[ -z "${src}" || "${src}" == \#* ]] && continue
        link "${DOT_ROOT}/${src}" "$HOME/${dst}"
    done
}

link_config_files() {

    log_header "Linking - Configs"

    #... a real dir here would make ln nest the link inside it
    if [[ -d "$HOME/.claude/bin" && ! -L "$HOME/.claude/bin" ]]; then
        claude_bin_backup="$HOME/.claude/bin.bak.$(date +%Y%m%d%H%M%S)"
        mv "$HOME/.claude/bin" "${claude_bin_backup}" && log_warn "Existing ~/.claude/bin moved to ${claude_bin_backup}"
    fi

    link_table <<'TABLE'

# Shell
linux/.fishrc                                        .config/fish/config.fish
linux/.bashrc                                        .bashrc
linux/.bash_profile                                  .bash_profile
linux/.zshrc                                         .zshrc
configs/ghostty.conf                                 .config/ghostty/config
configs/alacritty.toml                               .config/alacritty/alacritty.toml
configs/tmux/tmux.conf                               .config/tmux/tmux.conf
configs/atuin/config.toml                            .config/atuin/config.toml
configs/atuin/themes/catppuccin-mocha-mauve.toml     .config/atuin/themes/catppuccin-mocha-mauve.toml

# Dev env
configs/helix/config.toml                            .config/helix/config.toml
configs/helix/languages.toml                         .config/helix/languages.toml
configs/helix/theme.toml                             .config/helix/themes/bretema.toml
configs/.gitconfig                                   .gitconfig
configs/.gitignore                                   .gitignore
configs/.gdbinit                                     .gdbinit
configs/worktrunk.toml                               .config/worktrunk/config.toml

# Apps
configs/flameshot.ini                                .config/flameshot/flameshot.ini
configs/copyq/copyq.conf                             .config/copyq/copyq.conf
configs/copyq/copyq-commands.ini                     .config/copyq/copyq-commands.ini
configs/copyq/themes/catppuccin-mocha.ini            .config/copyq/themes/catppuccin-mocha.ini
linux/assets/autostart/copyq.desktop                 .config/autostart/copyq.desktop
configs/lazygit/config.yml                           .config/lazygit/config.yml
configs/glow/themes/catppuccin-mocha.json            .config/glow/themes/catppuccin-mocha.json
configs/hunk/config.toml                             .config/hunk/config.toml
configs/mpv/mpv.conf                                 .config/mpv/mpv.conf
configs/obs-studio/global.ini                        .config/obs-studio/global.ini
configs/obs-studio/user.ini                          .config/obs-studio/user.ini
configs/obs-studio/basic/profiles/Untitled/basic.ini .config/obs-studio/basic/profiles/Untitled/basic.ini
configs/obs-studio/basic/scenes/Untitled.json        .config/obs-studio/basic/scenes/Untitled.json
configs/yazi/yazi.toml                               .config/yazi/yazi.toml
configs/yazi/keymap.toml                             .config/yazi/keymap.toml
configs/yazi/themes/theme.toml                       .config/yazi/theme.toml
configs/qtcreator/themes/monokai_dark.xml            .config/QtProject/qtcreator/styles/monokai_dark_t.xml
configs/qtcreator/themes/gruvbox_dark.xml            .config/QtProject/qtcreator/styles/gruvbox_dark_t.xml
configs/qtcreator/themes/catppuccin_latte.xml        .config/QtProject/qtcreator/styles/catppuccin_latte_t.xml

# Claude Code
configs/claude/CLAUDE.md                             .claude/CLAUDE.md
configs/claude/settings.json                         .claude/settings.json
configs/claude/keybindings.json                      .claude/keybindings.json
configs/claude/bin                                   .claude/bin

# Open Code
configs/opencode/AGENTS.md                           .config/opencode/AGENTS.md
configs/opencode/opencode.jsonc                      .config/opencode/opencode.jsonc
configs/opencode/cli.json                            .config/opencode/cli.json
configs/opencode/tui.json                            .config/opencode/tui.json
configs/opencode/themes/catppuccin-transparent.json  .config/opencode/themes/catppuccin-transparent.json
configs/opencode/commands                            .config/opencode/commands
configs/opencode/agents                              .config/opencode/agents
configs/opencode/skills                              .config/opencode/skills
configs/opencode/plugins                             .config/opencode/plugins

# Env vars
linux/assets/env/10-shell.conf                       .config/environment.d/10-shell.conf
linux/assets/env/10-qt.conf                          .config/environment.d/10-qt.conf
linux/assets/env/10-ssh.conf                         .config/environment.d/10-ssh.conf

# Desktop
linux/assets/autostart/gnome-keyring-secrets.desktop .config/autostart/gnome-keyring-secrets.desktop
linux/assets/autostart/gnome-keyring-pkcs11.desktop  .config/autostart/gnome-keyring-pkcs11.desktop
linux/assets/xdg-desktop-portal/portals.conf         .config/xdg-desktop-portal/portals.conf
linux/assets/gtk/gtk-3.0/settings.ini                .config/gtk-3.0/settings.ini
linux/assets/gtk/gtk-4.0/settings.ini                .config/gtk-4.0/settings.ini

# Input
linux/assets/solaar/rules.yaml                       .config/solaar/rules.yaml
linux/assets/solaar/config.yaml                      .config/solaar/config.yaml
linux/assets/solaar/solaar.desktop                   .config/autostart/solaar.desktop
TABLE

    #... per-file so themes/queries installed by other means are kept
    for theme_file in "${DOT_CONFIGS}/helix/themes/"*.toml; do
        link "${theme_file}" "${HOME_CONFIG}/helix/themes/$(basename "${theme_file}")"
    done
    for queries_dir in "${DOT_CONFIGS}/helix/runtime/queries/"*/; do
        link "${queries_dir}" "${HOME_CONFIG}/helix/runtime/queries/$(basename "${queries_dir}")"
    done

    # --- Extras ---
    log_header "Setup - Extras"

    log_info "Tmux plugins"
    [[ ! -d "${HOME_CONFIG}/tmux/plugins/tpm" ]] && { git clone "https://github.com/tmux-plugins/tpm" "${HOME_CONFIG}/tmux/plugins/tpm"; }

    log_info "GDB dashboard"
    [[ ! -d "$HOME/.local/share/gdb-dashboard" ]] && { git clone "https://github.com/cyrus-and/gdb-dashboard" "$HOME/.local/share/gdb-dashboard"; }

    log_info "Glow"
    echo "style: \"${HOME_CONFIG}/glow/themes/catppuccin-mocha.json\"" >"${HOME_CONFIG}/glow/glow.yml"

    log_info "Yazi packages"
    mkdir -p "${HOME_CONFIG}/yazi/flavors"
    for pkg in flavors:catppuccin-mocha plugins:piper plugins:toggle-pane; do
        ya pkg add "yazi-rs/${pkg}" &>/dev/null && ya pkg install || true
    done

    log_info "Atuin"
    if is_cmd "atuin"; then
        #... seed the DB once from bash/zsh/fish history files (import is idempotent, empty DB = first run)
        atuin_db="${XDG_DATA_HOME:-$HOME/.local/share}/atuin/history.db"
        if [[ ! -f "${atuin_db}" ]]; then
            atuin import auto && log_info "History imported into ${atuin_db}"
        fi
        #... sync needs credentials -> stays manual
        log_info "Sync: run 'atuin register' (first machine) or 'atuin login' (others)"
    else
        log_warn "atuin not installed yet (run -i) — config linked, import skipped"
    fi

    # --- Environment ---
    log_header "Copying - System env"
    sys_copy "$DOT_LINUX_ASSETS/etc/environment" "/etc/environment"

    # --- GNOME ---
    log_header "Setup - Gnome fixes"

    #... Unmask socket (was masked to /dev/null when using gcr-ssh-agent only)
    if [[ -L "${HOME}/.config/systemd/user/gnome-keyring-daemon.socket" ]]; then
        rm "${HOME}/.config/systemd/user/gnome-keyring-daemon.socket"
        systemctl --user daemon-reload 2>/dev/null || true
        systemctl --user enable gnome-keyring-daemon.socket 2>/dev/null || true
    fi

    #... PAM unlock: login service holds user session via greetd (Service=login)
    if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/login 2>/dev/null; then
        sys_copy "$DOT_LINUX_ASSETS/pam/login" /etc/pam.d/login
        log_warn "/etc/pam.d/login replaced (backup: /etc/pam.d/login.~N~). Test a TTY login before logging out."
    fi

    # --- Input Management ---
    log_header "Setup - Input management"

    # Caps 2 Esc
    # ! Symlinks could fail at boot-time so copy the files is the best approach here
    log_info "Caps-2-Esc"

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
    log_info "Available at: $wallpapers_dir"

    # --- Cosmic ---
    log_header "Linking Cosmic Settings"

    cosmic_dir="${HOME_CONFIG}/cosmic"
    if [[ -d "${cosmic_dir}" && ! -L "${cosmic_dir}" ]]; then
        cosmic_backup="${cosmic_dir}.bak.$(date +%Y%m%d%H%M%S)"
        mv "${cosmic_dir}" "${cosmic_backup}" || {
            log_error "Could not back up ${cosmic_dir}"
            return 1
        }
        log_warn "Existing cosmic config moved to ${cosmic_backup}"
    fi
    ln -srfn "$DOT_LINUX_ASSETS/cosmic" "${cosmic_dir}"
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
        [[ $((status ^ invert)) -eq 1 ]] && result+=("$pkg")
    done <"$list_file"

    echo "${result[@]}"
}

pnpm_installed() {
    # 'pnpm list -g' exits 0 even when the package is missing, so match the name@version line
    pnpm list -g "$1" 2>/dev/null | grep -qF "$1@"
}

install_packages() {
    log_header "Installing packages"

    log_header "-- Pacman"
    _pkgs=($(collect_packages "$script_path/pacman_install.conf" "paru -Q" "[^a-zA-Z0-9_-]"))
    [[ ${#_pkgs[@]} -gt 0 ]] && paru -S $paru_confirm --skipreview "${_pkgs[@]}"

    log_header "-- Flatpak"
    _pkgs=($(collect_packages "$script_path/flatpak_install.conf" "flatpak info" "[^a-zA-Z0-9.]"))
    [[ ${#_pkgs[@]} -gt 0 ]] && flatpak -y install "${_pkgs[@]}"

    log_header "-- Pnpm"
    _pkgs=($(collect_packages "$script_path/pnpm_install.conf" "pnpm_installed" "[^a-zA-Z0-9@\/._-]"))
    [[ ${#_pkgs[@]} -gt 0 ]] && pnpm add -g "${_pkgs[@]}"
}

remove_packages() {
    log_header "Removing packages"

    _pkgs=($(collect_packages "$script_path/pacman_remove.conf" "paru -Q" "[^a-zA-Z0-9_-]" 1))
    [[ ${#_pkgs[@]} -gt 0 ]] && paru -Rns $paru_confirm "${_pkgs[@]}"

    _pkgs=($(collect_packages "$script_path/flatpak_remove.conf" "flatpak info" "[^a-zA-Z0-9.]" 1))
    [[ ${#_pkgs[@]} -gt 0 ]] && flatpak -y uninstall "${_pkgs[@]}"
    flatpak uninstall --unused -y

    _pkgs=($(collect_packages "$script_path/pnpm_remove.conf" "pnpm_installed" "[^a-zA-Z0-9@\/._-]" 1))
    [[ ${#_pkgs[@]} -gt 0 ]] && pnpm remove -g "${_pkgs[@]}"
}

system_update() {
    log_header "Updating system"
    paru $paru_confirm -Syu
    flatpak update -y
}

configure_git_filters() {
    log_header "Configuring Git filters"

    (
        cd "$script_path"

        is_git || {
            log_warn "Not inside a Git repository"
            exit 1
        }

        # Attributes file
        mkdir -p "$(dirname "$attributes_file")"
        touch "$attributes_file"

        # Solaar
        (
            attribute="linux/assets/solaar/config.yaml filter=solaar-cookie"

            grep -Fqx -- "$attribute" "$attributes_file" || printf '%s\n' "$attribute" >>"$attributes_file"

            git config --local filter.solaar-cookie.clean "sed '/^[[:space:]]*_config_cookie:/d'"
            git config --local filter.solaar-cookie.required true
        )

        # Screenshot
        (
            attribute="linux/assets/cosmic/com.system76.CosmicPortal/v1/screenshot filter=cosmic-rectangle"

            grep -Fqx -- "$attribute" "$attributes_file" || printf '%s\n' "$attribute" >>"$attributes_file"

            helper="${DOT_LINUX_ASSETS}/git_filters/cosmic_rectangle_clean.py"
            printf -v rectangle_command 'python3 %q %%f' "$helper"

            git config --local filter.cosmic-rectangle.clean "$rectangle_command"
            git config --local filter.cosmic-rectangle.required true
        )

        log_info "Git filters config done."
    )
}

macbook_keyboard_setup() {
    local action="$1"
    case "$action" in
    enable | disable) ;;
    *)
        log_error "Unknown action '${action}' (enable|disable)"
        return 1
        ;;
    esac
    log_header "MacBook keyboard - ${action}"

    local hw_model=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
    local xkb_file="${DOT_LINUX_ASSETS}/cosmic/com.system76.CosmicComp/v1/xkb_config"
    local attribute="linux/assets/cosmic/com.system76.CosmicComp/v1/xkb_config filter=xkb-macbook"
    local fn_param="/sys/module/hid_apple/parameters/swap_fn_leftctrl"

    if [[ "$action" == "enable" && "$hw_model" != *MacBook* && "$hw_model" != *Apple* ]]; then
        log_warn "Not a MacBook/Apple machine (${hw_model:-unknown}) - skipped"
        return 1
    fi

    if [[ "$action" == "enable" ]]; then

        #... Fn <-> Left Ctrl (hid-apple: runtime now, persistent on boot)

        if [[ -e "$fn_param" ]]; then
            echo 1 | sudo tee "$fn_param" >/dev/null
            sudo cp "$DOT_LINUX_ASSETS/modprobe/90-macbook-keyboard.conf" "/etc/modprobe.d/90-macbook-keyboard.conf"
            log_info "Fn/Ctrl swap enabled (hid_apple.swap_fn_leftctrl=1)"
        else
            log_warn "hid_apple.swap_fn_leftctrl not available - Fn/Ctrl swap skipped"
        fi

        #... Alt/Win swap + AltGr on right cmd (COSMIC xkb, needs relogin)

        sed -i -E 's|^[[:space:]]*options:.*|    options: Some("altwin:swap_alt_win,lv3:rwin_switch"),|' "$xkb_file"
        log_info "XKB Alt/Win swap enabled"

        #... Git filter : keep machine-local options out of commits

        if git -C "$script_path" rev-parse --is-inside-work-tree &>/dev/null; then
            mkdir -p "$(dirname "$attributes_file")"
            touch "$attributes_file"
            grep -Fqx -- "$attribute" "$attributes_file" || printf '%s\n' "$attribute" >>"$attributes_file"
            git -C "$script_path" config --local filter.xkb-macbook.clean "sed -E 's|^[[:space:]]*options:.*|    options: None,|'"
            git -C "$script_path" config --local filter.xkb-macbook.required true
            log_info "Git filter xkb-macbook registered"
        else
            log_warn "Not a git repository - xkb-macbook filter NOT registered"
        fi

        log_info "Done. Relogin to load new xkb options."

    else

        #... Fn <-> Left Ctrl revert

        [[ -e "$fn_param" ]] && echo 0 | sudo tee "$fn_param" >/dev/null
        sudo rm -f "/etc/modprobe.d/90-macbook-keyboard.conf"
        log_info "Fn/Ctrl swap reverted"

        #... Xkb options revert

        sed -i -E 's|^[[:space:]]*options:.*|    options: None,|' "$xkb_file"
        log_info "XKB options reverted"

        #... Git filter removal

        if [[ -f "$attributes_file" ]] && grep -qxF -- "$attribute" "$attributes_file"; then
            grep -vxF -- "$attribute" "$attributes_file" >"${attributes_file}.tmp"
            mv "${attributes_file}.tmp" "$attributes_file"
        fi
        git -C "$script_path" config --local --unset filter.xkb-macbook.clean 2>/dev/null || true
        git -C "$script_path" config --local --unset filter.xkb-macbook.required 2>/dev/null || true
        log_info "Git filter xkb-macbook removed"

        log_info "Done. Relogin to load reverted xkb options."
    fi
}

# --- Parse Args ---------------------------------------------------------------

#! Help

usage() {
    show_help <<EOF
Usage: ${script_name} [options]

Manage configs and system apps, themes...

Options:
  -d | --remove            Remove discarded packages
  -u | --update            System update
  -i | --install           Install packages / apps
  -l | --links             Link configs / themes
       --all               Run -d, -u, -i, and -l in sequence

  --set-git-filters        Configure local Git filters *1

  --mbkb-enable            MacBook keyboard : fn/ctrl swap, alt/win xkb, git filter *2
  --mbkb-disable           Revert MacBook keyboard setup

  --confirm-pacman         Prompt before each package action (removes --noconfirm)

  -h | --help              Show this message

 [*1]
      - Solaar     : Do not sync config_cookie.
      - Screenshot : Do not sync last_rectangle.

 [*2]
      - Swaps physical Fn with Left Ctrl (hid_apple.swap_fn_leftctrl).
      - Enables altwin:swap_alt_win,lv3:rwin_switch on COSMIC (es layout).
      - Registers xkb-macbook Git filter (commits options: None).
EOF
}

#! Defaults

do_remove=false
do_update=false
do_install=false
do_links=false
do_filters=false
do_mbkb=""
confirm_pacman=false

#! Process options

while [[ "${#}" > 0 ]]; do
    case "${1}" in

    -d | --remove) shift && do_remove=true ;;
    -u | --update) shift && do_update=true ;;
    -i | --install) shift && do_install=true ;;
    -l | --links) shift && do_links=true ;;
    --all) shift && do_remove=true && do_update=true && do_install=true && do_links=true ;;

    --set-git-filters) shift && do_filters=true ;;

    --mbkb-enable) shift && do_mbkb="enable" ;;
    --mbkb-disable) shift && do_mbkb="disable" ;;

    --confirm-pacman) shift && confirm_pacman=true ;;

    -h | --help) usage && exit 0 ;;
    --) shift && break ;;

    *) break ;;

    esac
done

# --- Execution ----------------------------------------------------------------

paru_confirm="--noconfirm"
[[ $confirm_pacman == true ]] && paru_confirm=""

exit_code=0

is_cmd "paru" || sudo pacman -S paru
is_cmd "flatpak" || sudo pacman -S flatpak

[[ "${do_remove}" == "true" ]] && { remove_packages || exit_code=1; }
[[ "${do_update}" == "true" ]] && { system_update || exit_code=1; }
[[ "${do_install}" == "true" ]] && { install_packages || exit_code=1; }
[[ "${do_links}" == "true" ]] && { link_config_files || exit_code=1; }
[[ "${do_filters}" == "true" ]] && { configure_git_filters || exit_code=1; }
[[ -n "${do_mbkb}" ]] && { macbook_keyboard_setup "${do_mbkb}" || exit_code=1; }

exit "${exit_code}"
