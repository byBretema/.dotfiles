#!/usr/bin/env zsh

################################################################################
### Common setup "Shell-Agnostic"  (Part 1)
################################################################################

DOTFILES_SCRIPTS="$HOME/.dotfiles/linux/scripts"
PATH="$DOTFILES_SCRIPTS/bash:$PATH"

source "$DOTFILES_SCRIPTS/.profile/_exports_"

PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/Qt/Tools/QtCreator/bin:$PATH"


################################################################################
### Functions
################################################################################

mkcd(){
  mkdir -p "${1}"
  pushd "${1}"
}


################################################################################
### Plugins
################################################################################

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


################################################################################
### Common setup "Shell-Agnostic"  (Part 2)
################################################################################

# Prompt
eval "$(starship init zsh)"

# Aliases
alias configreload='source $HOME/.zshrc'
source "$DOTFILES_SCRIPTS/.profile/_aliases_"

# External Profile / Binaries

OMI_SCRIPTS="$HOME/omi/scripts"
PATH="$OMI_SCRIPTS/bash:$PATH"

OMI_PROFILE="$OMI_SCRIPTS/_exports_"
if [[ -f "$OMI_PROFILE" ]]; then source "$OMI_PROFILE"; fi
if [[ -f "$OMI_SCRIPTS/bash/omi" ]]; then omi -u; fi
