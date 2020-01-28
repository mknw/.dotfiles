# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# custom vim dir
set -o vi
EDITOR="vim"
MYVIMRC="$HOME/.dotfiles/vim/vimrc"
export VIMINIT="source $HOME/.dotfiles/vim/vimrc"

# custom bash prompt.
BASH_PLUGINS="$HOME/.dotfiles/bash_plugins"
source "$BASH_PLUGINS/bash_prompt"

# 
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=1000
shopt -s checkwinsize
[ -x /usr/bin/lesspip ] && eval "$(SHELL=bin/sh lesspipe)"

# User specific aliases and functions
module load gcc
module load slurm 
# alternative coloured prompt
# PS1="\[\033[38;5;51m\]\u\[\033[38;5;155m\] @\[\033[38;5;15m\] \[\033[38;5;220m\]\w\[\033[38;5;15m\] \\$\[$(tput sgr0)\] "

# Aliases are memos, not commands.
alias reload="source $HOME/.bashrc && echo '$HOME/.bashrc sourced'"
alias tmux="tmux -f $HOME/.dotfiles/tmux/tmux.conf"
alias ta="tmux attach -t"
alias tl="tmux list-sessions"
alias :q="echo You\'re not in vim."

alias ls="ls --color=auto"
alias ll="ls -l"
alias la="ls -la"
alias l.="ls -l -Ad .????*"
alias lst="printf 'Most recent on top:\n---------------------- && ls -lt -c"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias path="echo -e ${PATH//:/\\n}"

alias sinfonf="sinfo -o '%40N %40f'"

# Functions are actions, not tools.
highlight () { grep --color -E "$1|$" $2 ; }
