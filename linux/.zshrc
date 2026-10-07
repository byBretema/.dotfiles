#!/usr/bin/env zsh

# --- Basics -------------------------------------------------------------------

source "$HOME/.dotfiles/linux/scripts/profile/exports"
export DOTFILES_SCRIPTS="$DOTFILES/linux/scripts"

typeset -U PATH
setopt pushd_silent # dir stack on pushd/popd stays quiet, like fish
export PATH="$DOTFILES_SCRIPTS:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/Qt/Tools/QtCreator/bin:$PATH"
export PATH="$HOME/.local/share/pnpm/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

alias configreload='source $HOME/.zshrc'
source "$DOTFILES_SCRIPTS/profile/aliases"
alias fuuuck='cmd=$(fc -ln -1); gum confirm --default=false "Re-run as SUDO: $cmd" && eval sudo "$cmd"'

# --- Functions ----------------------------------------------------------------

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

export HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- Prompt -------------------------------------------------------------------

[[ -o interactive ]] && eval "$(starship init zsh)"

# --- External -----------------------------------------------------------------

export PATH="$HOME/omi/scripts:$PATH"

if [[ -o interactive ]] && [ -x "/usr/bin/micromamba" ]; then
    export MAMBA_EXE="/usr/bin/micromamba"
    export MAMBA_ROOT_PREFIX="$HOME/.local/share/mamba"
    eval "$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX")"
fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# --- Shell integrations -------------------------------------------------------

# completion system first (zsh-completions ships into site-functions, on fpath by default)
[[ -o interactive ]] && { autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"; }

[[ -o interactive ]] && command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# Alt-C: cd directly (fzf's default widget stuffs 'builtin cd -- <dir>' into BUFFER ->
# visible command text + history pollution; fish cds directly)
if (( $+functions[__fzf_defaults] )); then
    fzf-cd-widget() {
        setopt localoptions pipefail no_aliases 2>/dev/null
        local dir
        dir=$(FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
            FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty) || { zle redisplay; return 1 }
        [[ -z "$dir" ]] && { zle redisplay; return 0 }
        builtin cd -- "$dir" || return
        zle reset-prompt
    }
    zle -N fzf-cd-widget
    bindkey -M emacs '\ec' fzf-cd-widget
    bindkey -M vicmd '\ec' fzf-cd-widget
    bindkey -M viins '\ec' fzf-cd-widget
fi

[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6C7086" # catppuccin overlay0, fish-grey

[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# history-substring-search is the sanctioned exception: sourced after syntax-highlighting
[[ -r /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && {
    source /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
}
