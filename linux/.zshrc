#!/usr/bin/env zsh

# Lovingly typ(o)ed @byBretema

###############################################################################
### OH-MY-ZSH / PLUGINS / MODULES
###############################################################################

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


# ###############################################################################
# ### OPTIONS
# ###############################################################################

# # Mix
# #------------------
# setopt interactive_comments     # allow comments please.

# # Auto
# #------------------
# # setopt correct                  # try to correct spelling of commands.
# setopt auto_name_dirs           # use exported name of dirs.
# setopt auto_remove_slash        # remove slash at the end i.e: my/cool/path/ -> my/cool/path

# # Cd
# #------------------
# setopt auto_cd                  # if command is a path, cd into it.
# setopt cdablevars               # if cd a var whose value is a valid directory.
# setopt chase_links              # resolve symlinks.
# setopt glob_dots                # include dotfiles in globbing.
# setopt extended_glob            # activate complex pattern globbing.

# # Pushd
# #------------------
# setopt auto_pushd               # make cd push old dir in dir stack.
# setopt pushd_silent             # no dir stack after pushd or popd.
# setopt pushd_to_home            # `pushd` = `pushd $HOME`.
# setopt pushd_ignore_dups        # no duplicates in dir stack.

# # History
# #------------------
# setopt bang_hist                # !keyword.
# setopt hist_verify              # show before executing history commands.
# setopt share_history            # share hist between sessions.
# setopt append_history           # append.
# setopt extended_history         # timestamps on history.
# setopt hist_reduce_blanks       # trim blanks.
# setopt inc_append_history       # add commands as they are typed.
# setopt hist_ignore_all_dups     # no duplicate.

# # Completion
# #------------------
# setopt correct                  # spelling correction for commands.
# setopt hash_list_all            # hash everything before completion.
# setopt always_to_end            # go to word-end if cursor its in the middle.
# setopt list_ambiguous           # complete until it gets ambiguous.
# setopt completealiases          # complete alisases.
# setopt complete_in_word         # allow completion from within a word/phrase.

# # Unset
# #------------------
# unsetopt hup                    # no hup signal at shell exit.
# unsetopt beep                   # no bell on error.
# unsetopt bg_nice                # no lower prio for background jobs.
# unsetopt clobber                # must use >! or >| to truncate existing files.
# unsetopt list_beep              # no bell on ambiguous completion.
# unsetopt hist_beep              # no bell on error in history.
# unsetopt ignore_eof             # do not exit on end-of-file.
# unsetopt rm_star_silent         # confirmation for `rm *' or `rm path/*'.
# unsetopt hist_ignore_space      # ignore space prefixed commands.
# unsetopt MULTIBYTE              # allow modern stuff


###############################################################################
### ALIASES  (Remember to define alias between SINGLE quotes)
###############################################################################

# Shell
#------------------
alias zr='source $HOME/.zshrc'
alias ze='xdg-open $HOME/.zshrc'

# Langs
#------------------
alias py="python"
alias py3="python3"
alias py310="python310"

# Utils
#------------------
alias h='history'
alias l='eza -a --icons always --git -s type --hyperlink'
alias L='eza -a --git -s type --hyperlink'
alias l1='l -1'
alias ll='l -l --no-user'
alias lt='l -T'
alias lt1='l -T --level=1'
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
## Systemctl
alias ssctl='sudo systemctl'
alias ssctl_off='ssctl disable'
alias ssctl_on='ssctl enable'
alias ssctl_start='ssctl start'
alias ssctl_stop='ssctl start'

# Arch
#------------------
## Paru
alias pm='paru --bottomup'
alias pmy='pm --noconfirm'
alias pmm='pm --noconfirm --skipreview'
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

# Tools
#------------------
alias hx='helix'
qc() { qtcreator $* >/dev/null 2>&1 & }
alias yyy='yazi'


###############################################################################
### PATHS
###############################################################################

PATH="$HOME/.local/bin:$PATH"

DOTFILES="$HOME/.dotfiles"

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

export MICRO_TRUECOLOR=1


###############################################################################
### DOTFILES
###############################################################################

dfs() {
	pushd "$DOTFILES"
	git status -s
	git stash > /dev/null
	git pull --quiet
	git stash pop > /dev/null
	git add -A
	git commit -m "Updates ($(date +%s))" > /dev/null
	git push --quiet
	popd  2> /dev/null || :
}
dfce() { python3 $DOTFILES/common/vscode/extensions.py $@; }
dfe() { code $DOTFILES; }
dfi() { $DOTFILES/linux/install.sh $@; }
dff() { cd $DOTFILES; }


###############################################################################
### GIT
###############################################################################

# Open git repo on the browser
function gitit {

	if ! git remote -v > /dev/null 2>&1; then echo "-- Not a repo."; return; fi

	local url=$(git remote -v | head -n 1 | awk '{print $2}')
	if [[ $url == *@* ]]; then
		local ssh=$(echo $url | awk -F'@' '{print $2}' | sed 's/:/\//')
		xdg-open "https://$ssh"
	else
		xdg-open $url
	fi
}

git_remove_branch_local_and_remote() {

	local local_delete_flag="-d"
	if [[ $# -gt 1 && $1 -eq "-f" ]]; then local_delete_flag="-D"; fi

	local branch=$(git --no-pager branch | grep -P '^(?!.*(main|master|release))' | fzf)
	local branch=$(echo $branch | sed -E 's/^\*?[ ]*//; s/[ ]*$//')

	if [[ ! -n "$branch" ]]; then echo "-- No branch selected."; return; fi

	read -k 1 -r "?@ Deleting local, sure? [y/N] "; echo
	if [[ ! $REPLY =~ ^[Yy]$ ]] then return; fi
	git branch $local_delete_flag $branch

	read -k 1 -r "?@ Deleting remote, sure? [y/N] "; echo
	if [[ ! $REPLY =~ ^[Yy]$ ]] then return; fi
	git push origin --delete $branch
}

gitsw() {
	echo $(git branch -a | fzf) | sed -E 's/^remotes\/origin\///; s/^\*?[ ]*//' | xargs git switch
}


###############################################################################
### OTHER UTILITIES
###############################################################################

function k { clear; ll; }  # Clear and list

function o { xdg-open $1 &; }  # Open with default application
function oo { xdg-open . &; }  # Open with default application

function dev() { cd $HOME/dev; }
function lab() { cd $HOME/dev/_lab; }

function mkcd { mkdir -p $1; cd $1; }  # Create a folder and enter

function rr { gio trash $*; }  # Send to trash / A safe 'rm' alternative

function s { o "https://www.google.com/search?q=$($* -join '+')"; }  # Search on Google w/ default browser

# Quick info and check of your net status
function net {
	local public=$(curl -s icanhazip.com)
	echo "$fg[blue]Public$fg[white]: $fg[cyan]$public"
	local private=$(ip addr | grep 'inet ' | awk '{print $2}' | tail -1)
	echo "$fg[blue]Private$fg[white]: $fg[cyan]$private"
	local avg8888=$(ping -qc 5 8.8.8.8 | sed -n 5p | awk -F"/" '{print $5" ms"}')
	echo "$fg[blue]8.8.8.8 $fg[white]=> $fg[cyan]$avg8888"
	local avgDotES=$(ping -qc 5 google.es | sed -n 5p | awk -F"/" '{print $5" ms"}')
	echo "$fg[blue]Google.es $fg[white]=> $fg[cyan]$avgDotES"
}


###############################################################################
### CPP
###############################################################################

cpprun() {
	if [[ $# -lt 4 ]]; then 
		echo "usage: cpprun <compiler> <usage_msg> <std_version> <filepath>"
		return
	fi

    local compiler=$1; shift
    local usage_msg=$1; shift
    local stdver=$1; shift
    local filepath=$(realpath $1); shift

	if [[ ! -f "$filepath" ]]; then
		echo $usage_msg
		echo "\n- error: <filepath> was not found."
		return
	fi

	local bin_path="/tmp/cpprun/"
	mkdir -p $bin_path
	local bin_name=$(mktemp -u "$bin_path/XXXXXXXXXX")

	"$compiler" --std="c++$stdver" $filepath -o $bin_name && "$bin_name"

	if [[ -f "$bin_name" ]]; then
		rm "$bin_name"
	fi
}

g++run() {
	cpprun "g++" "usage: g++run <std_version> <filepath>" $*
}


###############################################################################
### HARDWARE UTILITIES
###############################################################################

nvstatus() { bat "/sys/bus/pci/devices/0000:01:00.0/power/runtime_status"; }

GOVERNOR_PATH="/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
gov_info() { cat "$GOVERNOR_PATH"; }
gov_performance() {echo performance | sudo tee "$GOVERNOR_PATH"; }
gov_powersave() { echo powersave | sudo tee "$GOVERNOR_PATH"; }

gpu_toggle() { python "$DOTFILES/linux/scripts/gpu_toggle.py"; }
gpu_get_default() { glxinfo | grep "OpenGL renderer"; }


###############################################################################
### PROMPT
###############################################################################

export STARSHIP_CONFIG=$DOTFILES/configs/starship.toml
eval "$(starship init zsh)"


###############################################################################
### SOURCE PRIVATE STUFF
###############################################################################

if [[ -f $HOME/dev/.private.zsh ]]; then
	source $HOME/dev/.private.zsh
else
	echo "-- Remember to get your .private.zsh file"
fi
