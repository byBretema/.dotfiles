#!/usr/bin/env bash

# --- Basics -------------------------------------------------------------------

source "$HOME/.dotfiles/linux/scripts/profile/exports"
export DOTFILES_SCRIPTS="$DOTFILES/linux/scripts"

shopt -s expand_aliases # also expand aliases when sourced from a non-interactive shell

# prepend to PATH only if missing (bash lacks fish_add_path / typeset -U dedupe)
_ppath() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

_ppath "$DOTFILES_SCRIPTS"
_ppath "$HOME/.local/bin"
_ppath "$HOME/.cargo/bin"
_ppath "$HOME/Qt/Tools/QtCreator/bin"
_ppath "$HOME/.local/share/pnpm/bin"
_ppath "$HOME/go/bin"

alias configreload='source "$HOME/.bashrc"'
source "$DOTFILES_SCRIPTS/profile/aliases"
alias fuuuck='cmd=$(fc -ln -1); gum confirm --default=false "Re-run as SUDO: $cmd" && eval sudo "$cmd"'

# --- Integrations -------------------------------------------------------------
# fzf's key-bindings rebind \C-z (vi-mode switch) -> source BEFORE the \C-z bind below

if [[ $- == *i* ]]; then
    # bash-completion has no double-source guard; /etc/bash.bashrc may load it first
    [[ -z ${BASH_COMPLETION_VERSINFO+x} && -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
    [[ -r /usr/share/fzf/key-bindings.bash ]] && . /usr/share/fzf/key-bindings.bash
    [[ -r /usr/share/fzf/completion.bash ]] && . /usr/share/fzf/completion.bash
    command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
fi

# --- Functions ----------------------------------------------------------------

# bash prints the dir stack on pushd/popd, fish doesn't (zsh: setopt pushd_silent)
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

_ppath "$HOME/omi/scripts"

if [[ $- == *i* ]] && [ -x "/usr/bin/micromamba" ]; then
    export MAMBA_EXE="/usr/bin/micromamba"
    export MAMBA_ROOT_PREFIX="$HOME/.local/share/mamba"
    eval "$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"
fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
