#!/usr/bin/env bash

# --- Bash exclusive -----------------------------------------------------------

# prepend to PATH only if missing (bash lacks fish_add_path / typeset -U dedupe)
bash_add_path() {
    case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
    esac
}

export HISTTIMEFORMAT="%F %T "
shopt -s expand_aliases

# --- Basics -------------------------------------------------------------------

source "$HOME/.dotfiles/linux/scripts/profile/exports"
export DOTFILES_SCRIPTS="$DOTFILES/linux/scripts"

bash_add_path "$DOTFILES_SCRIPTS"
bash_add_path "$HOME/.local/bin"
bash_add_path "$HOME/.cargo/bin"
bash_add_path "$HOME/Qt/Tools/QtCreator/bin"
bash_add_path "$HOME/.local/share/pnpm/bin"
bash_add_path "$HOME/go/bin"

alias configreload='source "$HOME/.bashrc"'
source "$DOTFILES_SCRIPTS/profile/aliases"
alias fuuuck='cmd=$(fc -ln -1); gum confirm --default=false "Re-run as SUDO: $cmd" && eval sudo "$cmd"'

# --- Integrations -------------------------------------------------------------
# fzf's key-bindings rebind \C-z (vi-mode switch) -> source BEFORE the \C-z bind below

if [[ $- == *i* ]]; then
    # Tab-completion: case-insensitive; also treat - and _ as interchangeable (fish: built-in)
    bind 'set completion-ignore-case on'
    bind 'set completion-map-case on'
    # Interactive menu: first Tab lists matches (zsh-like), then cycles
    # (Shift-Tab backwards, ESC-? lists all). show-all-if-ambiguous makes
    # rl_menu_complete call display_matches() before cycling.
    bind '"\t": menu-complete'
    bind '"\e[Z": menu-complete-backward'
    bind 'set show-all-if-ambiguous on'
    bind 'set menu-complete-display-prefix on'
    bind 'set page-completions off'
    # Listing cosmetics (colors, trailing / *, no less-paging)
    bind 'set colored-stats on'
    bind 'set colored-completion-prefix on'
    bind 'set visible-stats on'
    bind 'set mark-symlinked-directories on'

    # bash-completion has no double-source guard; /etc/bash.bashrc may load it first
    [[ -z ${BASH_COMPLETION_VERSINFO+x} && -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
    [[ -r /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
    [[ -r /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash

    # atuin AFTER fzf: fzf keeps Ctrl-T/Alt-C, atuin takes Ctrl-R (common TUI, 3 shells)
    if command -v atuin >/dev/null 2>&1; then
        eval "$(atuin init bash)"
        # Ctrl-P: atuin up-style search (cwd-scoped via filter_mode_shell_up_key_binding)
        atuin-bind -m emacs '\C-p' atuin-up-search
    fi

    # Alt-C: cd directly (fzf's macro variant stuffs 'builtin cd -- <dir>' into the line,
    # visible + executed; fish cds directly)
    if declare -F __fzf_defaults >/dev/null; then
        fzf_cd_widget() {
            local dir
            dir=$(FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
            FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) </dev/tty) || return
            [[ -n "$dir" ]] || return
            builtin cd -- "$dir" || return
            READLINE_LINE=""
            READLINE_POINT=0
        }
        bind -m emacs-standard -x '"\ec": fzf_cd_widget'
    fi
fi

# --- Functions ----------------------------------------------------------------

# bash prints the dir stack on pushd/popd, fish doesn't
pushd() { builtin pushd "$@" >/dev/null; }
popd() { builtin popd "$@" >/dev/null; }

# git worktree add + cd
gwa() {
    git_worktree_add "$@"
    local target=$(cat /tmp/git_worktree_add_target 2>/dev/null)
    [[ -n "$target" && -d "$target" ]] && cd "$target"
}
gws() {
    git_worktree_switch "$@"
    local target=$(cat /tmp/git_worktree_switch_target 2>/dev/null)
    [[ -n "$target" && -d "$target" ]] && cd "$target"
}

# mkdir + cd
mkcd() {
    mkdir -p "$1" && pushd "$1"
}

# yazi
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# bring to fg latest job in bg (readline keeps the edited line, bash >= 4.3)
if [[ $- == *i* ]]; then
    bind -x '"\C-z": fg 2>/dev/null'
fi

# --- Tweaks -------------------------------------------------------------------

export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- Prompt -------------------------------------------------------------------

if [[ $- == *i* ]]; then
    eval "$(starship init bash)"
fi

# --- External -----------------------------------------------------------------

bash_add_path "$HOME/omi/scripts"

if [[ $- == *i* ]] && [ -x "/usr/bin/micromamba" ]; then
    export MAMBA_EXE="/usr/bin/micromamba"
    export MAMBA_ROOT_PREFIX="$HOME/.local/share/mamba"
    eval "$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"
fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi

# zoxide last: starship replaces PROMPT_COMMAND, which would drop the zoxide hook
if [[ $- == *i* ]] && command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi
