#!/usr/bin/bash

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# custom vim dir
set -o vi
export EDITOR="vim"
MYVIMRC="$HOME/.dotfiles/vim/vimrc"
export VIMINIT="source $HOME/.dotfiles/vim/vimrc"
[[ :$PATH: != *"$HOME/.dotfiles/scripts"* ]] && PATH="${PATH}:$HOME/.dotfiles/scripts"
export PATH

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
alias tl="tmux list-sessions"
alias tjump="tmuxjump"
alias tj="tmuxjump"

alias :q="echo Vim much?"

alias ls="ls --color=auto"
alias ll="ls -l"
alias la="ls -la"
alias l.="ls -l -Ad .????*"
alias lst="printf 'Most recent first:\n----------------------' && ls -lt -c"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias path="echo -e ${PATH//:/\\\\n}" # Watch out: the \escape is escaped...

alias sinfonf="sinfo -o '%40N %40f'"
alias sinfodiag="sinfo -o '%30N %30f %15G %12O %4c %9z %w'"
alias presll="preserve -llist | grep mao540"
alias cleananalysis='rm -rI !(x.png|z.png|zlatent_mean_std_Z.pkl|z.pkl|model.pth.tar)'
alias modlcupr='module load cuda10.1 prun'
alias displayall='for FILE in *; do display $FILE & done'

# alias sdebug='srun --job-name=realnpv_mnist --output=realnvp.log --time=00:30:00 -N 1 -C TitanX --gres=gpu:1'


# Functions are actions, not tools.
highlight () { grep --color -E "$1|$" $2 ; }

oneoften () {
	if [ -z "$1" ]; then
		echo "use '-z' for leading zeros format."
		exit
	else
		find . -name 'epoch_*' | while read file; do
			if [ $1 == '-z' ]; then
				SUB=$(echo ${file#./epoch_} | sed 's/^0*//')
			else
				SUB=${file#./epoch_}
			fi
			# echo $SUB
			echo -ne "\rEpoch $SUB...\033[0K"
			[ $((${SUB}% 10)) != 0 ] && rm -r "$file";
		done
		echo "done."
		return 0
	fi
}

oneoftenrange() {
	if [ ! -z "$1" ]; then
		echo "Usage: oneoftenrange <regex>"
		echo "Example: oneoften 'epoch_[12][0-9][1-9]"
		find . -name "$1" -exec sh -c 'rm -r $0' {} \;
	fi
}

countext () {
	TIME=$2
	TEXT=$1

	while [ $TIME -gt 0 ]; do
		echo -ne "\r$TEXT $TIME...\033[0K" 
		sleep 1
		((TIME--))
	done
}

prestoproq () {
	preserve -# 1 -s $(date -d '+1 minute' +'%H:%M') -t $((3600*$1)) -q proq
	echo "Showing queue for user mao540 every 10 seconds."
	echo
	for i in {1..200}; do
		preserve -llist | grep mao540; sleep 10 2>/dev/null
	done
}

prestonat () {
	# preserve -# 1 -s $(date -d '+1 minute' +'%H:%M') -t $((3600*$1))
	if [ -z $1 ]; then
		echo "Usage:"
		echo -e "\tprestonat <hours> [GRES] <presll interval>"
		echo -e "\nfor a list of General RESources, see: https://www.cs.vu.nl/das5/special.shtml"
	else
	# echo "All agruments: ${@:1:$(($#))}"

	horus=$1; shift
	ARgs="${@:1:$(($#-1))}"


	sdnoces=$(echo "3600*$horus" | bc)
	intHorus=$(printf "%.0f" "$sdnoces")
	echo "integer seconds to say $horus hours: ${intHorus}"
	echo "native: $ARgs"
	echo "command: preserve -# 1 -s $(date -d '+1 minute' +'%H:%M') -t ${intHorus} -native "-C $ARgs""
	preserve -# 1 -s $(date -d '+1 minute' +'%H:%M') -t ${intHorus} -native "-C $ARgs"

	echo "Showing queue for user mao540 every ${!#} seconds."
	echo
	for i in {1..200}; do
		preserve -llist | grep mao540; sleep ${!#} 2>/dev/null
	done
	fi

	return
}

tmuxjump () {
	if [ $1 ]; then
		echo "provided target: $1"
		targetsesh=$1
		tmux attach -t $targetsesh
	else
		# parse for existing session
		# starts the first found. 
		targetsesh=$(tmux list-sessions | awk '{print $1; exit}')
		# if none is found:
		if [ -z $targetsesh ]; then
			countext "No open sessions found. Starting new instance in" 3
			tmux -f "$HOME/.dotfiles/tmux/tmux.conf"
		else
		countext "Found session $targetsesh. Starting in" 3
		tmux attach -t $targetsesh
	fi
	fi
}


findver () {
	if [ -z "$1" ]; then
		find . -name 'version' -exec sh -c 'echo "$0: $(cat $0)"' {} \;
	else
		FP_VMARKERS=$(find . -name 'version')
		for FP in $FP_VMARKERS; do
			while IFS='' read -r line; do
				if [ "$line" = "$1" ]; then
					echo $FP
					echo "Matched: $line"
				fi
			done < "$FP"
		done
	fi
}

listver () {
	if [ -z "$1" ]; then
		find . -name 'version' -exec sh -c 'echo "$0 : $(cat $0)"; ls --color ${0%/version}' {} \;
	else
		FP_VMARKERS=$(find . -name 'version')
		for FP in $FP_VMARKERS; do

			while IFS='' read -r line; do
				if [ "$line" = "$1" ]; then
					echo "$FP Matched: $line"
					ls --color ${FP%version}
				fi
			done < "$FP"
	done
	fi
}


# export DEBUGNUMMER=1

# sdebug () {
# 	LOGNAME="$HOME/real-nvp/realnvp_$DEBUGNUMMER.log"
# 	printf "\`srun\` called with arguments:\n"
# 	printf "\t\t\t\t--job-name=rnvp --output=$LOGNAME --time=00:30:00 -N 1 -C gpunode --gres=gpu:1 $*\n"
# 	# printf "saving log to \n"
# 	# printf "\t\t\t\t$LOGNAME\n"
# 	srun --job-name=rnvp --time=00:30:00 -N 1 -C TitanX --gres=gpu:1 --pty bash -il $*
# 
# 	if [ -z "$DEBUGNUMMER" ]; then
# 		echo not right equal wrong
# 	else
# 		((DEBUGNUMMER=DEBUGNUMMER+1))
# 		export DEBUGNUMMER
# 	fi
# }
