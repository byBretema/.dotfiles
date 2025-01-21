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
ENABLE_CORRECTION="true"
DISABLE_LS_COLORS="true"
HIST_STAMPS="dd.mm.yyyy"
COMPLETION_WAITING_DOTS="true"

plugins=(git fzf extract)
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
# setopt pushd_ignore_dups        # [this breaks some scripts] no duplicates in dir stack.

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
### ALIASES
###############################################################################

# Shell
#------------------
alias zr="source $HOME/.zshrc && source $HOME/.zshenv"
alias ze="xdg-open $HOME/.zshrc"

# Utils
#------------------
alias l="eza -a  --icons always --git -s type"
alias ll="eza -la --icons always --git -s type"
alias lll="eza -Ta --icons always --git -s type"
alias fff="fzf"
alias trash="rr"

# System
#------------------
## Clipboard
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"
## Kernel info
alias jctl="journalctl"
alias qctl="journalctl -p 3 -xb"

# Arch
#------------------
## Paru
alias pm="paru --bottomup"
alias pmy="paru --bottomup --noconfirm"
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

function dotfiles_sync {
	zr
	pushd $HOME/.dotfiles
	git status -s
	git stash > /dev/null
	git pull --quiet
	git stash pop > /dev/null
	git add -A
	git commit -m "Updates ($(date +%s))" > /dev/null
	git push --quiet
	popd  2> /dev/null
}

function dotfiles_edit {
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

function gs() {
    local show_help=0
    local only_submodules=0
    local force_parallel=0
    local cmd=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
				show_help=1
				shift;;
            -s|--submodules)
				only_submodules=1
				shift;;
            -p|--parallel)
				force_parallel=1
				shift;;
            -sp|-ps)
				only_submodules=1
				force_parallel=1
				shift;;
            *)
				cmd+=("$1");
				shift;;
        esac
    done

    # Print help if needed
    if [[ ${#cmd[@]} -lt 1 || $show_help == 1 ]]; then
        echo -e "\nRun git commands in submodules"
        echo -e "\nUsage: gs [-s] [-p] cmd..."
        echo "-s, --submodules : Run only on submodules"
        echo "-p, --parallel   : Force to run in parallel"
        return
    fi

	# Determine if the command should run in parallel
    local is_parallel=$force_parallel
    if [[ $is_parallel == 0 ]]; then
        for parallel_cmd in pull push; do
            if [[ " ${cmd[1]} " == *" $parallel_cmd "* ]]; then
                is_parallel=1
                break
            fi
        done
    fi

	# Escape commit messages
    local is_commit=0
    for commit_cmd in commit ac; do
        if [[ " ${cmd[1]} " == *" $commit_cmd "* ]]; then
            is_commit=1
            break
        fi
    done
    if [[ $is_commit == 1 ]]; then
        cmd[-1]="\"${cmd[-1]}\""
    fi

	# Recover quotes
	cmd="git -c color.ui=always --no-pager $cmd 2>&1"

	line_sep="; "
	[[ $is_parallel == 1 ]] && line_sep="\n"

	dir_cmd=""
	for i in */ ; do
		if [[ -e "$i/.git" ]]; then
			dir=$(basename $i)
			dir=${(qq)dir}
			dir_cmd+="pushd ${dir}; $cmd | __gs_output_format $dir; popd$line_sep"
		fi
	done

	if [[ $is_parallel == 1 ]]; then
		echo "$dir_cmd" | parallel -j`nproc` {1}
	else
		eval "$dir_cmd"
	fi

	# # Debug
	# echo "\n\n============================================="
	# echo "show_help       = $show_help"
	# echo "only_submodules = $only_submodules"
	# echo "force_parallel  = $force_parallel"
	# echo "is_parallel     = $is_parallel"
	# echo "is_commit       = $is_commit"
	# echo "cmd             = $cmd"
}


###############################################################################
### OTHER UTILITIES
###############################################################################

function k { clear; ll; }  # Clear and list

function oo { xdg-open $1; }  # Open with default application

function md { mkdir -p $1; cd $1; }  # Create a folder and enter

function s { oo "https://www.google.com/search?q=$($* -join '+')"; }  # Search on Google w/ default browser

function rr { gio trash $*; }  # Send to trash / A safe 'rm' alternative

function nvidia_status { bat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status; }

function net {   # Quick info and check of your net status
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
