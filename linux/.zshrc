#!/usr/bin/env zsh

# --- Basics -------------------------------------------------------------------

source "$HOME/.dotfiles/linux/scripts/profile/exports"
export DOTFILES_SCRIPTS="$DOTFILES/linux/scripts"

typeset -U PATH
export PATH="$DOTFILES_SCRIPTS:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/Qt/Tools/QtCreator/bin:$PATH"

alias configreload='source $HOME/.zshrc'
source "$DOTFILES_SCRIPTS/profile/aliases"

# --- Functions ----------------------------------------------------------------

# mkdir + cd
mkcd() {
    mkdir -p "$1" && pushd "$1"
}

# yazi
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# bring to fg latest job in bg
fancy-ctrl-z() {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg 2>/dev/null"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# --- Tweaks -------------------------------------------------------------------

export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- Prompt -------------------------------------------------------------------

eval "$(starship init zsh)"

# --- External -----------------------------------------------------------------

export PATH="$HOME/omi/scripts/bash:$PATH"

if [ -x "/usr/bin/micromamba" ]; then
    export MAMBA_EXE="/usr/bin/micromamba"
    export MAMBA_ROOT_PREFIX="$HOME/.local/share/mamba"
    eval "$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX")"
fi
