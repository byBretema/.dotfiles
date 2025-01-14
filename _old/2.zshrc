
# Written with <3 @byBretema


###############################################################################
### HISTORY
###############################################################################

SAVEHIST=1024                   # big history
HISTSIZE=1024                   # big history
HISTFILE=~/.zsh/.zsh_history    # where to store zsh history


###############################################################################
### MODULES
###############################################################################

autoload -U colors && colors								# colors
autoload -U zsh-mime-setup && zsh-mime-setup				# run all as executable.
autoload -U select-word-style && select-word-style bash		# ctrl+w del words.


###############################################################################
### KEYBINDINGS
###############################################################################

# bindkey -v
# bindkey '\e[1;5C' forward-word		# C-Right
# bindkey '\e[1;5D' backward-word		# C-Left
# bindkey '^R'      history-incremental-pattern-search-backward


###############################################################################
### OPTIONS
###############################################################################

# Stuff
setopt auto_cd                  # if command is a path, cd into it.
setopt correct                  # try to correct spelling of commands.
setopt glob_dots                # include dotfiles in globbing.
setopt cdablevars               # if cd a var whose value is a valid directory.
setopt chase_links              # resolve symlinks.
setopt extended_glob            # activate complex pattern globbing.
setopt auto_name_dirs           # use exported name of dirs.
setopt auto_remove_slash        # self explicit.
setopt interactive_comments     # allow comments please.

# Pushd
setopt auto_pushd               # make cd push old dir in dir stack.
setopt pushd_silent             # no dir stack after pushd or popd.
setopt pushd_to_home            # `pushd` = `pushd $HOME`.
setopt pushd_ignore_dups        # no duplicates in dir stack.

# History
setopt bang_hist                # !keyword.
setopt hist_verify              # show before executing history commands.
setopt share_history            # share hist between sessions.
setopt append_history           # append.
setopt extended_history         # timestamps on history.
setopt hist_reduce_blanks       # trim blanks.
setopt inc_append_history       # add commands as they are typed.
setopt hist_ignore_all_dups     # no duplicate.

# Completion
setopt correct                  # spelling correction for commands.
setopt hash_list_all            # hash everything before completion.
setopt always_to_end            # go to word-end if cursor its in the middle.
setopt list_ambiguous           # complete until it gets ambiguous.
setopt completealiases          # complete alisases.
setopt complete_in_word         # allow completion from within a word/phrase.

# Unset
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
### PATHs
###############################################################################

# Shortcuts
function dev()  { pushd $dev_dir }
function omis() { pushd "$dev_dir/studio_engine_1" }
function omic() { pushd "$dev_dir/_OmiSetup" }

# Paths
PATH+=";~/.dotfiles/bin"
PATH+=";$dev_dir/_bin/"
PATH+=";$dev_dir/_bin/Odin"

# PATH+=";${env:ProgramFiles}/starship/bin"


###############################################################################
### ALIASes
###############################################################################

# List dir
alias l="eza -a  --icons always --git -s type"
alias ll="eza -la --icons always --git -s type"
alias tree="eza -Ta --icons always --git -s type"

# Clear and list
function k() {
	clear
	ll
}

# Open current dir on explorer
function oo() {
	dolphin $1 &
}

# Shutdown and cancell
# function off { shutdown /hybrid /s /t $($args[0] * 60) }
# function noff { shutdown /a }

# A safe 'rm' alternative
function rr() {
	mv $* ~/.Trash/
}

# Create a folder and enter
function md() {
	mkdir -p $1
	cd $1
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
		brave $ssh
	else
		brave $url
	fi
}

# Run git commands in submodules and parent in parallel (supports aliases)
function gs() {  ### [!!] CAREFULL THIS NEED REVIEW : IS JUST A GPT-OUTPUT
    local show_help=false
    local only_submodules=false
    local force_parallel=false
    local start_cwd=$(pwd)
    local cmd=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help=true
                shift
                ;;
            -s|--submodules)
                only_submodules=true
                shift
                ;;
            -p|--parallel)
                force_parallel=true
                shift
                ;;
            *)
                cmd+=("$1")
                shift
                ;;
        esac
    done

    # Print help if needed
    if [[ ${#cmd[@]} -lt 1 || $show_help == true ]]; then
        echo -e "\nRun git commands in submodules"
        echo -e "\nUsage: gs [-s] [-p] cmd..."
        echo "-s : Run only on submodules"
        return
    fi

    # Determine if the command should run in parallel
    local is_parallel=$force_parallel
    if [[ $is_parallel == false ]]; then
        for parallel_cmd in pull push; do
            if [[ " ${cmd[@]} " == *" $parallel_cmd "* ]]; then
                is_parallel=true
                break
            fi
        done
    fi

    # Escape commit messages
    local is_commit=false
    for commit_cmd in commit ac; do
        if [[ " ${cmd[@]} " == *" $commit_cmd "* ]]; then
            is_commit=true
            break
        fi
    done
    if [[ $is_commit == true ]]; then
        cmd[-1]="'${cmd[-1]}'"
    fi

    # Init message
    echo " > Attempting to run command${is_parallel:+ in parallel}"

    # Get the list of submodules
    local submodules=$(git submodule foreach --quiet --recursive 'echo $sm_path')
    if [[ -z $submodules ]]; then
        echo " ! Submodules not found"
        return
    fi

    # Compose the real git command
    local git_cmd="git -c color.ui=always --no-pager ${cmd[*]} 2>&1"

    # Define helper to print output
    print_submodule_output() {
        local char="="
        local name="$1"; shift
        local msg="$*"

        if [[ -z $msg ]]; then
            return
        fi

        echo
        echo "${char:0:60}"
        echo " *  ${name^^}"
        echo "${char:0:60}"
        echo -e "$msg"
    }

    # Process submodules sequentially or in parallel
    if [[ $is_parallel == false ]]; then
        for submodule in $submodules; do
            pushd "$submodule" > /dev/null
            local output=$(eval "$git_cmd")
            print_submodule_output "$submodule" "$output"
            popd > /dev/null
        done
    else
        # Parallel execution
        local jobs=()
        for submodule in $submodules; do
            (
                pushd "$submodule" > /dev/null
                eval "$git_cmd"
                popd > /dev/null
            ) & jobs+=($!)
        done

        # Wait for all jobs to complete
        for job in "${jobs[@]}"; do
            wait $job
        done
    fi

    # Run also on parent repository
    if [[ $only_submodules == false ]]; then
        cd "$start_cwd"
        local output=$(eval "$git_cmd")
        print_submodule_output "parent" "$output"
    fi

    # Return to the start directory
    cd "$start_cwd"
}


###############################################################################
### UTILITIES
###############################################################################

# Quick info and check of your net status
function net {
	public=$(curl -s icanhazip.com)
	echo "$fg[blue]Public$fg[white]: $fg[cyan]$public"
	private=$(ifconfig en0 | grep 'inet ' | awk '{print $2}')
	echo "$fg[blue]Private$fg[white]: $fg[cyan]$private"
	avg8888=$(ping -qc 5 8.8.8.8 | sed -n 5p | awk -F"/" '{print $5" ms"}')
	echo "$fg[blue]8.8.8.8 $fg[white]=> $fg[cyan]$avg8888"
	avgDotES=$(ping -qc 5 google.es | sed -n 5p | awk -F"/" '{print $5" ms"}')
	echo "$fg[blue]Google.es $fg[white]=> $fg[cyan]$avgDotES"
}

# # Is ip alive?
# function is_ip_alive {
# 	Param
# 	(
# 		[Parameter(Mandatory = $true)] [string]$ip,
# 		[Parameter(Mandatory = $false)] [Int32]$timeout_ms = 40
# 	)
# 	$(ping $ip -n 1 -w $timeout_ms -f -4 | Out-Null)
# 	return ("", $ip)[$LASTEXITCODE -eq 0]
# }

# Download to temp file
function download_to_temp() {
    local url="$1"
    local name="$2"

    # If name is not provided, extract it from the URL
    if [[ -z "$name" ]]; then
        name="${url##*/}"  # Extract the last part of the URL
    fi

    echo ">> Downloading: $name" >&2

    # Define the temporary file path
    local tmp_file="/tmp/$name"

    # Use curl or wget to download the file
    if command -v curl &>/dev/null; then
        curl -A "Wget" -o "$tmp_file" "$url"
    elif command -v wget &>/dev/null; then
        wget --user-agent="Wget" -O "$tmp_file" "$url"
    else
        echo "Error: Neither curl nor wget is installed." >&2
        return 1
    fi

    echo ">> Downloaded to: $tmp_file" >&2
    echo "$tmp_file"
}

# Unzip
function unzip($path) {
	# & "${env:ProgramFiles}\7-Zip\7zG.exe" x "$path" -o* -aou
}

# # Everything Search CLI
# function ev {
# 	Param
# 	(
# 		[Parameter(Mandatory = $true)]  [string] $query,
# 		[Parameter(Mandatory = $false)] [string] $ext
# 	)
# 	es -size -dm -sizecolor 4 -dmcolor 2 -sort path "*$query*$ext*"
# }


# Search on Google
function s {
	brave "https://www.google.com/search?q=$($* -join '+')"
}

# Translatation CLI
function tr () {
	local to="$1"
    local text="$2"

	uri="https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($to)&dt=t&q=$text"
	response=$(curl -A "Wget" -o "$uri")
	# ??? translation = $Response[0].SyncRoot | ForEach-Object { $_[0] }
	echo "$translation"
}


###############################################################################
### PROMPT
###############################################################################

export STARSHIP_CONFIG="~/.dotfiles/starship.toml";
eval "$(starship init zsh)"
