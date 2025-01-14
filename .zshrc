# Lovingly typ(o)ed @byBretema


###############################################################################
### P10K
###############################################################################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


###############################################################################
### MODULES
###############################################################################

autoload -U colors && colors								# colors
autoload -U zsh-mime-setup && zsh-mime-setup				# run all as executable.
# autoload -U select-word-style && select-word-style bash		# ctrl+w del words.


###############################################################################
### SETTINGS
###############################################################################

# Plugins
#------------------
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
plugins=(git fzf extract)
export FZF_BASE=/usr/share/fzf

# History
#------------------
## Sync history between shells
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"  
## Don't add certain commands to the history file.
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
## Ignore commands that start with spaces and duplicates.
export HISTCONTROL=ignoreboth

# Less (colorize)
#------------------
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"


###############################################################################
### OPTIONS
###############################################################################

# Mix
#------------------
setopt interactive_comments     # allow comments please.

# Auto
#------------------
setopt correct                  # try to correct spelling of commands.
setopt auto_name_dirs           # use exported name of dirs.
setopt auto_remove_slash        # self explicit.

# Cd
#------------------
setopt auto_cd                  # if command is a path, cd into it.
setopt cdablevars               # if cd a var whose value is a valid directory.
setopt chase_links              # resolve symlinks.
setopt glob_dots                # include dotfiles in globbing.
setopt extended_glob            # activate complex pattern globbing.

# Pushd
#------------------
setopt auto_pushd               # make cd push old dir in dir stack.
setopt pushd_silent             # no dir stack after pushd or popd.
setopt pushd_to_home            # `pushd` = `pushd $HOME`.
setopt pushd_ignore_dups        # no duplicates in dir stack.

# History
#------------------
setopt bang_hist                # !keyword.
setopt hist_verify              # show before executing history commands.
setopt share_history            # share hist between sessions.
setopt append_history           # append.
setopt extended_history         # timestamps on history.
setopt hist_reduce_blanks       # trim blanks.
setopt inc_append_history       # add commands as they are typed.
setopt hist_ignore_all_dups     # no duplicate.

# Completion
#------------------
setopt correct                  # spelling correction for commands.
setopt hash_list_all            # hash everything before completion.
setopt always_to_end            # go to word-end if cursor its in the middle.
setopt list_ambiguous           # complete until it gets ambiguous.
setopt completealiases          # complete alisases.
setopt complete_in_word         # allow completion from within a word/phrase.

# Unset
#------------------
unsetopt hup                    # no hup signal at shell exit.
unsetopt beep                   # no bell on error.
unsetopt bg_nice                # no lower prio for background jobs.
unsetopt clobber                # must use >| to truncate existing files.
unsetopt list_beep              # no bell on ambiguous completion.
unsetopt hist_beep              # no bell on error in history.
unsetopt ignore_eof             # do not exit on end-of-file.
unsetopt rm_star_silent         # confirmation for `rm *' or `rm path/*'.
unsetopt hist_ignore_space      # ignore space prefixed commands.


###############################################################################
### AUTO COMPLETE
###############################################################################

autoload -U compinit -d && compinit

## Basics
zstyle ':completion:*' menu select=2                       # menu if items > 2
zstyle ':completion::complete:*' use-cache on              # use cache
zstyle ':completion:*' cache-path ~/.zsh/cache             # cache path
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}      # colorz !
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # ignore case
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

## Sections
# zstyle ':completion:*:messages' format $'\e[37m%d'
zstyle ':completion:*:manuals' separate-sections true
# zstyle ':completion:*:descriptions' format $'\e[37m%d'


###############################################################################
### GLOBAL VARS
###############################################################################

export dev_dir="~/dev"
export dot_dir="~/.dotfiles"


###############################################################################
### PATH
###############################################################################

PATH="$PATH:~/dev/omi/_bin/tp_tools/scripts"


###############################################################################
### ALIASES
###############################################################################

# Utils
#------------------
alias aaa="sudo !!"
alias fff="fzf"
alias l="eza -a  --icons always --git -s type"
alias ll="eza -la --icons always --git -s type"
alias tree="eza -Ta --icons always --git -s type"

# Apps
#------------------
alias code="vscodium"

# System
#------------------
## Kernel info
alias jctl="journalctl"
alias qctl="journalctl -p 3 -xb"

# Arch
#------------------
## Paru
alias paru="paru --bottomup"
## Recent installed packages
alias pm_rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
## Cleanup orphaned packages
alias pm_clean_orphan="sudo pacman -Rsn (pacman -Qtdq)"
## Cleanup cache
alias pm_clean_cache="sudo pacman -Scc"
## Unlock pacman DB
alias pm_unlock="sudo rm /var/lib/pacman/db.lck"
## Remove package recursive and don't save
alias pm_remove="sudo pacman -Rsn"
## Update everything
alias pm_update="sudo pacman -Syu"


###############################################################################
### DOTFILES
###############################################################################

function dotfiles_sync() {
	source "$dot_dir/.zshrc"
	pushd $dot_dir
	git status -s
	git stash > /dev/null
	git pull --quiet
	git stash pop > /dev/null
	git add -A
	git commit -m "Updates ($(date +%s))" > /dev/null
	git push --quiet
	popd
}

function dotfiles_edit() {
	code $dot_dir
}


###############################################################################
### GIT
###############################################################################

# Open git repo on the browser
# function gitit {
# 	if [ ! -d "./.git" ]; then
# 		echo "fatal: not a git repository"
# 		return
# 	fi

# 	url=$(git remote -v | head -n 1 | awk '{print $2}')
# 	if [[ $url == *@* ]]; then
# 		ssh=$(echo $url | awk -F'@' '{print $2}' | sed 's/:/\//')
# 		brave $ssh   ## mime_open ??
# 	else
# 		brave $url
# 	fi
# }


###############################################################################
### OTHER UTILITIES
###############################################################################

# Clear and list
function k() {
	clear
	ll
}

# Open current dir on explorer
function oo() {
	dolphin $1 &
}

# A safe 'rm' alternative
# function rr() {
# 	mv $* ~/.Trash/
# }

# Create a folder and enter
function md() {
	mkdir -p $1
	cd $1
}

# Quick info and check of your net status
function net {
	public=$(curl -s icanhazip.com)
	echo "$fg[blue]Public$fg[white]: $fg[cyan]$public"
	private=$(ip addr | grep 'inet ' | awk '{print $2}' | tail -1)
	echo "$fg[blue]Private$fg[white]: $fg[cyan]$private"
	avg8888=$(ping -qc 5 8.8.8.8 | sed -n 5p | awk -F"/" '{print $5" ms"}')
	echo "$fg[blue]8.8.8.8 $fg[white]=> $fg[cyan]$avg8888"
	avgDotES=$(ping -qc 5 google.es | sed -n 5p | awk -F"/" '{print $5" ms"}')
	echo "$fg[blue]Google.es $fg[white]=> $fg[cyan]$avgDotES"
}


###############################################################################
### REMOTE WORK UTILITIES
###############################################################################

function omi_set_online {
	nohup slack </dev/null >/dev/null 2>&1 &; disown
	nohup tandem </dev/null >/dev/null 2>&1 &; disown
	nohup tailscale-systray </dev/null >/dev/null 2>&1 &; disown
}