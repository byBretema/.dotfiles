#!/usr/bin/env zsh

# Lovingly typ(o)ed @byBretema

###############################################################################
### OH-MY-ZSH / PLUGINS / MODULES
###############################################################################

export ZSH="/usr/share/oh-my-zsh"
export FZF_BASE=/usr/share/fzf

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

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
alias zr='source $HOME/.zshrc && source $HOME/.zshenv'
alias ze='xdg-open $HOME/.zshrc'

# Utils
#------------------
alias l='eza -a  --icons always --git -s type'
alias ll='eza -la --icons always --git -s type'
alias lll='eza -Ta --icons always --git -s type'
alias fff='fzf --preview="bat --color=always {}"'
alias ffc='code $(fzf -m --preview="bat --color=always {}")'
alias aaa='sudo !!'
alias wii='which !!'
alias trash='rr'

# System
#------------------
## Clipboard
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
## Kernel info
alias jctl='journalctl'
alias qctl='journalctl -p 3 -xb'

# Arch
#------------------
## Paru
alias pm='paru --bottomup'
alias pmy='paru --bottomup --noconfirm'
## Recent installed packages  (from CachyOS default zsh config)
alias pm_rip='expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'
## Cleanup orphaned packages
alias pm_clean_orphan='sudo pacman -Rsn (pacman -Qtdq)'
## Cleanup cache
alias pm_clean_cache='sudo pacman -Scc'
## Unlock pacman DB
alias pm_unlock='sudo rm /var/lib/pacman/db.lck'
## Remove package recursive and don't save
alias pm_remove='sudo pacman -Rsn'
## Update everything
alias pm_update='sudo pacman -Syu'


###############################################################################
### PATH && EXPORTS
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
	if [ ! -d "./.git" ]; then
		echo "fatal: not a git repository"
		return
	fi

	url=$(git remote -v | head -n 1 | awk '{print $2}')
	if [[ $url == *@* ]]; then
		ssh=$(echo $url | awk -F'@' '{print $2}' | sed 's/:/\//')
		xdg-open $ssh
	else
		xdg-open $url
	fi
}

# Run commands on submodules
## Depends on '__gs_output_format' to be defined in .zshenv
function gs() {
    local show_help=0
    local only_in_submodules=0
    local only_if_changes=0
    local force_parallel=0
    local cmd=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h) show_help=1; shift;;
            -s) only_in_submodules=1; shift;;
            -c) only_if_changes=1; shift;;
            -p) force_parallel=1; shift;;
            *)  cmd+=("$1"); shift;;
        esac
    done

    # Print help if needed
    if [[ ${#cmd[@]} -lt 1 || $show_help == 1 ]]; then
        echo -e "\nRun git commands in submodules"
        echo -e "\nUsage: gs [-p] cmd..."
        echo "-s : Run only in submodules"
        echo "-p : Force to run in parallel"
        echo "-c : Only if a changes are present"
        return
    fi

	# Determine if the command should run in parallel
    local is_parallel=$force_parallel
	[[ " ${cmd[1]} " == *" pull "* ]] && is_parallel=1
	[[ " ${cmd[1]} " == *" push "* ]] && is_parallel=1

	# Escape message
	local cmd_not_escaped=(${cmd[@]})
    local escape_last=0
	[[ " ${cmd[1]}  " == *" ac "* ]] && escape_last=1
	[[ " ${cmd[-2]} " == *" -m "* ]] && escape_last=1
    if [[ $escape_last == 1 ]]; then
        cmd[-1]=${(qq)cmd[-1]}
    fi

	# Generate command list
	cmd_list=""
	for i in */ ; do
		i=$(echo $i | tr -d '/')
		if [[ -e "$i/.git" ]] && { [[ $only_if_changes -ne 1 || $(git -C "$i" status --porcelain=1 | wc -l) -gt 0 ]] }; then
			cmd_list+="git -C $i -c color.ui=always --no-pager $cmd 2>&1 | __gs_output_format $i\n"
		fi
	done

	# Execute command list
	if [[ $is_parallel == 1 ]]; then
		printf "$cmd_list" | parallel -j$(nproc) {1}
	else
		eval "$(printf "$cmd_list")"
	fi

	# Run on super-repo too
	if [[ $only_in_submodules == 0 ]] && [[ -e ".git" ]]; then
		git -c color.ui=always --no-pager $cmd_not_escaped 2>&1 | __gs_output_format "Super :: $(basename $PWD)"
	fi

	# # Debug
	# echo "\n\n============================================="
	# echo "show_help       = $show_help"
	# echo "only_submodules = $only_submodules"
	# echo "force_parallel  = $force_parallel"
	# echo "is_parallel     = $is_parallel"
	# echo "escape_last     = $escape_last"
	# echo "cmd             = $cmd"
}
alias gsdiff="gs diff | ov -F --section-delimiter '^diff' --section-header"


###############################################################################
### OTHER UTILITIES
###############################################################################

function k { clear; ll; }  # Clear and list

function oo { xdg-open $1; }  # Open with default application

function mkcd { mkdir -p $1; cd $1; }  # Create a folder and enter

function rr { gio trash $*; }  # Send to trash / A safe 'rm' alternative

function s { oo "https://www.google.com/search?q=$($* -join '+')"; }  # Search on Google w/ default browser

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
    if [[ ! -e $dir ]]; then echo "-- Bad dir"; return; fi
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

function gpu_toggle_discrete_only()  # FIXME : Toggle is not working yet
{
	lines=(
		"__NV_PRIME_RENDER_OFFLOAD=1"
		"__GLX_VENDOR_LIBRARY_NAME=nvidia"
		"__VK_LAYER_NV_optimus=NVIDIA_only"
		"VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json"
	)

	env_file="/etc/environment"
	temp_file=$(mktemp)

	# Toggle
	while IFS= read -r line; do
		if [[ " ${lines[@]} " =~ " ${line} " ]] || [[ " ${lines[@]} " =~ " ${line:1} " ]]; then
			if [[ ! $line =~ ^# ]]; then
				line="#$line"
			else
				line="${line:1}"
			fi
			echo "$line"
		fi
		echo "$line" >> "$temp_file"
	done < "$env_file"

	sudo mv "$temp_file" "$env_file"
	echo "\n[ Remeber to re-login to apply the changes ! ]"
}
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
### HAPPY COPY PASTE
###############################################################################

# Only on Ghostty, change interruption signal from Ctrl+C to Ctrl+X
# So you can bind Ctrl+C to normal copy
if [[ ${GHOSTTY_RESOURCES_DIR+x} ]]; then stty intr '^X'; fi


###############################################################################
### SOURCE PRIVATE STUFF
###############################################################################

source $HOME/dev/.private.zsh
