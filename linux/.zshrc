#!/usr/bin/env zsh

# Lovingly typ(o)ed @byBretema

###############################################################################
### OH-MY-ZSH / PLUGINS / MODULES
###############################################################################

export FZF_BASE=/usr/share/fzf
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

export ZSH="/usr/share/oh-my-zsh"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE=true
# ENABLE_CORRECTION="true"
DISABLE_LS_COLORS="true"
HIST_STAMPS="dd.mm.yyyy"
COMPLETION_WAITING_DOTS="true"

plugins=(git fzf extract zsh-interactive-cd)
source $ZSH/oh-my-zsh.sh

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
# zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
# source <(carapace _carapace)
# zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

autoload -U colors && colors


###############################################################################
### OPTIONS
###############################################################################

# Mix
#------------------
setopt interactive_comments     # allow comments please.

# Auto
#------------------
# setopt correct                  # try to correct spelling of commands.
setopt auto_name_dirs           # use exported name of dirs.
setopt auto_remove_slash        # remove slash at the end i.e: my/cool/path/ -> my/cool/path

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
unsetopt clobber                # must use >! or >| to truncate existing files.
unsetopt list_beep              # no bell on ambiguous completion.
unsetopt hist_beep              # no bell on error in history.
unsetopt ignore_eof             # do not exit on end-of-file.
unsetopt rm_star_silent         # confirmation for `rm *' or `rm path/*'.
unsetopt hist_ignore_space      # ignore space prefixed commands.
unsetopt MULTIBYTE              # allow modern stuff


###############################################################################
### ALIASES  (Remember to always define alias between SINGLE quotes, yvm)
###############################################################################

# Shell
#------------------
alias zr='source $HOME/.zshrc'
alias ze='xdg-open $HOME/.zshrc'

# Utils
#------------------
alias h='history'
alias l='eza -a --icons always --git -s type --hyperlink'
alias L='l -1'
alias ll='l -l --no-user'
alias lll='l -T'
alias fff='fzf --preview="bat --color=always {}"'
alias ffc='code $(fzf -m --preview="bat --color=always {}")'
alias aaa='sudo $(fc -ln | tail -1)'
alias wii='which $(fc -ln | tail -1)'
alias trash='rr'

# System
#------------------
## Clipboard
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'
## Kernel info
alias jctl='journalctl'
alias qctl='journalctl -p 3 -xb'

# Arch
#------------------
## Paru
alias pm='paru --bottomup'
alias pmy='paru --bottomup --noconfirm'
alias pmm='paru --bottomup --noconfirm --skipreview'
alias pi='paru'
alias piy='paru --noconfirm -S'
alias pii='paru --noconfirm --skipreview -S'
## Recent installed packages  (from CachyOS default zsh config)
alias pm_rip='expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'
## Cleanup orphaned packages
# alias pm_clean_orphan='sudo pacman -Rsn (pacman -Qtdq)'
## Cleanup cache
alias pm_clean_cache='sudo pacman -Scc'
## Unlock pacman DB
alias pm_unlock='sudo rm /var/lib/pacman/db.lck'
## Remove package recursive and don't save
alias pm_remove='sudo pacman -Rsn'
## Update everything
alias pm_update='paru -Syu'


###############################################################################
### PATHS
###############################################################################

PATH="$PATH:$HOME/.local/bin"


###############################################################################
### EXPORTS
###############################################################################

export LANG=en_US.UTF-8
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
export LC_ALL=en_US.UTF-8


###############################################################################
### DOTFILES
###############################################################################

function dfs {
	pushd $HOME/.dotfiles
	git status -s
	git stash > /dev/null
	git pull --quiet
	git stash pop > /dev/null
	git add -A
	git commit -m "Updates ($(date +%s))" > /dev/null
	git push --quiet
	popd  2> /dev/null || :
}

function dfe {
	code $HOME/.dotfiles
}


###############################################################################
### GIT
###############################################################################

# Open git repo on the browser
function gitit {

	if ! git remote -v > /dev/null 2>&1; then echo "-- Not a repo."; return; fi

	url=$(git remote -v | head -n 1 | awk '{print $2}')
	if [[ $url == *@* ]]; then
		ssh=$(echo $url | awk -F'@' '{print $2}' | sed 's/:/\//')
		xdg-open "https://$ssh"
	else
		xdg-open $url
	fi
}

git_remove_branch_local_and_remote() {

	local_delete_flag="-d"
    if [[ $# -gt 1 && $1 -eq "-f" ]]; then local_delete_flag="-D"; fi

    if [[ $# -lt 1 ]]; then echo "'branch_name' is mandatory"; return; fi
    local branch_name=$1; shift

	git branch $local_delete_flag $branch_name
	git push origin --delete $branch_name
}

gitsw() {
	echo $(git branch -a | fzf) | sed -E 's/^remotes\/origin\///; s/^\*\ //' | xargs git switch
}

###############################################################################
### OTHER UTILITIES
###############################################################################

function k { clear; ll; }  # Clear and list

function o { xdg-open $1 &; }  # Open with default application
function oo { xdg-open . &; }  # Open with default application

function mkcd { mkdir -p $1; cd $1; }  # Create a folder and enter

function rr { gio trash $*; }  # Send to trash / A safe 'rm' alternative

function s { o "https://www.google.com/search?q=$($* -join '+')"; }  # Search on Google w/ default browser

function dev() { cd $HOME/dev; }

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

# Util for grep + find
function __frep() {
	show_usage() {
        echo -e "\nRun grep over files in given path"
        echo -e "\n  Usage: frep dir searh-term"
	}
	# Get type
    if [[ $# -lt 1 ]]; then echo "-- Bad type"; return; fi
    local type=$1; shift
	# Get dir
    if [[ $# -lt 1 ]]; then show_usage; return; fi
    local dir=$1; shift
    if [[ ! -d $dir ]]; then echo "-- Bad dir"; return; fi
	# Get search term
    if [[ $# -lt 1 ]]; then show_usage; return; fi
    local search_term=$*;

	find $dir -type $type -exec grep -H --color=always "$*" {} ';'
}
alias frepf='__frep f'
alias frepd='__frep d'


###############################################################################
### HARDWARE UTILITIES
###############################################################################

function nvstatus { bat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status; }

function gov_info() {
	cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}
function gov_performance() {
	echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}
function gov_powersave() {
	echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}

# function gpu_toggle_discrete_only()  # FIXME : Toggle is not working yet
# {
# 	lines=(
# 		"__NV_PRIME_RENDER_OFFLOAD=1"
# 		"__GLX_VENDOR_LIBRARY_NAME=nvidia"
# 		"__VK_LAYER_NV_optimus=NVIDIA_only"
# 		"VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json"
# 	)

# 	env_file="/etc/environment"
# 	temp_file=$(mktemp)

# 	# Toggle
# 	while IFS= read -r line; do
# 		if [[ " ${lines[@]} " =~ " ${line} " ]] || [[ " ${lines[@]} " =~ " ${line:1} " ]]; then
# 			if [[ ! $line =~ ^# ]]; then
# 				line="#$line"
# 			else
# 				line="${line:1}"
# 			fi
# 			echo "$line"
# 		fi
# 		echo "$line" >> "$temp_file"
# 	done < "$env_file"

# 	sudo mv "$temp_file" "$env_file"
# 	echo "\n[ Remeber to re-login to apply the changes ! ]"
# }
function gpu_get_default()
{
	glxinfo | grep "OpenGL renderer"
}


###############################################################################
### PROMPT
###############################################################################

export STARSHIP_CONFIG=$HOME/.dotfiles/common/starship.toml
eval "$(starship init zsh)"


###############################################################################
### SOURCE PRIVATE STUFF
###############################################################################

if [[ -f $HOME/dev/.private.zsh ]]; then
	source $HOME/dev/.private.zsh
else
	echo "-- Remember to get your .private.zsh file"
fi
