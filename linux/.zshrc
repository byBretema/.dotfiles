#!/usr/bin/env zsh

#-------------------------------------------------------------------------------
# Common setup "Shell-Agnostic"  (Part 1)

PATH="$HOME/.local/bin:$PATH"

DOTFILES_SCRIPTS="$HOME/.dotfiles/linux/scripts"
PATH="$DOTFILES_SCRIPTS:$PATH"
source "$DOTFILES_SCRIPTS/_exports_"


#-------------------------------------------------------------------------------
# Plugins

export FZF_BASE=/usr/share/fzf
export ZSH="/usr/share/oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE=true
DISABLE_LS_COLORS="true"
HIST_STAMPS="dd.mm.yyyy"
COMPLETION_WAITING_DOTS="true"

plugins=(git fzf extract zsh-interactive-cd)
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

autoload -U colors && colors


#-------------------------------------------------------------------------------
# Common setup "Shell-Agnostic"  (Part 2)

eval "$(starship init zsh)"
source "$DOTFILES_SCRIPTS/_aliases_"
alias configreload='source $HOME/.zshrc'
