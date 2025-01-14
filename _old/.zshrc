# ... Highly influenced by (https://dustri.org/b/my-zsh-configuration.html)

### CONFIG::BASICS
# Notify logins
watch=all
logcheck=30
WATCHFMT="%n from %M has %a tty%l at %T %W"
# History size and place
SAVEHIST=1024                   # big history
HISTSIZE=1024                   # big history
HISTFILE=~/.zsh/.zsh_history    # where to store zsh history
# Basic cool modules
autoload -U colors && colors								# colors
autoload -U zsh-mime-setup && zsh-mime-setup				# run all as executable.
autoload -U select-word-style && select-word-style bash		# ctrl+w del words.
# Vim mode keybinds
bindkey -v
bindkey '\e[1;5C' forward-word		# C-Right
bindkey '\e[1;5D' backward-word		# C-Left
bindkey '^R'      history-incremental-pattern-search-backward

### CONFIG::PROMPT
setopt prompt_subst		# allow funky stuff in prompt.
## Vcs
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats " %b %%% %u%c "
function vcsinfo {
	vcs_info
	if [ -z $vcs_info_msg_0_ ]; then
		vcs_info_msg_0_=' %% '
	fi
}
## Prompt
sepL='•'
precmd() { vcsinfo; echo; }
PROMPT='%B%{%F{magenta}%}%(?,:%),:() \
%b%{%F{white}%}$sepL \
%B%{%F{yellow}%}%2~ \
%b%{%F{white}%}$sepL\
%B%{%F{cyan}%}${vcs_info_msg_0_}\
%b%{%F{white}%}$sepL
⇒  '
preexec() { echo }
# Visual alert of vim normal mode.
function zle-line-init zle-keymap-select {
	RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
	zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

### CONFIG::OPTIONS
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
# Bullshit
unsetopt hup                    # no hup signal at shell exit.
unsetopt beep                   # no bell on error.
unsetopt bg_nice                # no lower prio for background jobs.
unsetopt clobber                # must use >| to truncate existing files.
unsetopt list_beep              # no bell on ambiguous completion.
unsetopt hist_beep              # no bell on error in history.
unsetopt ignore_eof             # do not exit on end-of-file.
unsetopt rm_star_silent         # confirmation for `rm *' or `rm path/*'.
unsetopt hist_ignore_space      # ignore space prefixed commands.

### CONFIG::COMPLETION
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

### CONFIG::FUNCTIONS
# A safe 'rm' alternative
function rr { mv $* ~/.Trash/ }
# Create a folder and enter
function md { mkdir -p $1 && cd $1 }
# Copy a file to dropbox folder
function db { cp -vi $* ~/Dropbox/temp }
# Quick push
function qgp { git add -A; git commit -m "$*"; git push }
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


### ALIASES
# Move
alias rm=' rm -vi '
alias mv=' mv -vi '
alias cp=' cp -vi '
alias bk=' cd $OLDPWD '
alias gd=' cd $GODEV '
# Info
alias d='docker'
alias ck=' c && k '
alias c=' clear '
alias k=' k -h '
alias h=' history '
alias l=' ls -Ga '
alias ll=' ls -Gla '
alias lll=' tree -LC 2 '
alias grep=' grep --color=auto '
alias getweb=' wget -m -k -K -E -e robots=off '
alias le=' vim -u $(locate less.vim | grep "/usr/share/.*/macros/less.vim") '
# Tools
alias t=' tmux '
alias e='$EDITOR'
alias py=' python '
alias py3=' python3 '
alias tks=' tmux kill-server'
# Manage
alias lz=' source ~/.zshrc '
alias ev=' $EDITOR ~/.vimrc '
alias et=' $EDITOR ~/.tmux.conf '
alias ez=' $EDITOR ~/.zshrc && source ~/.zshrc '


### EXPORTS
# FullPath
PATH="/usr/local/sbin:$PATH:$GOPATH/bin"
# Basics
export ZGEN_DIR=~/.zsh/zgen
export TERM='xterm-256color'
export EDITOR="gvim"
# Paths
export DEVPATH=~/Documentos/code
export CLASSPATH=~/Documentos/college
# GoExports ...
export GOPATH=$DEVPATH/go
export GOBIN=$GOPATH/bin
export GODEV=$GOPATH/src/github.com/cambalamas
# Less colors, for colorized man pages :)
export LESS_TERMCAP_mb=$(printf '\e[01;36m') # blink = cyan.
export LESS_TERMCAP_so=$(printf '\e[01;31m') # standout = green.
export LESS_TERMCAP_us=$(printf '\e[04;33m') # underline = yellow.
export LESS_TERMCAP_md=$(printf '\e[01;35m') # double-bright = bold+magenta.
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode.
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode.
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearances.
