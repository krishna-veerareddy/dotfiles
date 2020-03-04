#!/bin/bash

# Utility functions
__set_color() {
	# Colorize output if and only if output is connected to a tty and the tty supports colors
	if [ -t 1 ]
	then
		ncolors=$(tput colors 2> /dev/null)
		if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]
		then
			normal="$(tput sgr0)"
			bold="$(tput bold)"
			red="$(tput setaf 9)"
			green="$(tput setaf 2)"
			yellow="$(tput setaf 3)"
			blue="$(tput setaf 4)"
		fi
	fi
}

__git_status() {
	local repo_info branch inside_worktree

	repo_info="$(git rev-parse --is-inside-work-tree --abbrev-ref HEAD 2>/dev/null)"

	if [ $? -ne 0 ] || [ -z "$repo_info" ]
	then
		return 0
	fi

	# Get branch name
	branch="${repo_info##*$'\n'}"
	repo_info="${repo_info%$'\n'*}"

	# Check whether we are inside the worktree
	inside_worktree="${repo_info##*$'\n'}"
	repo_info="${repo_info%$'\n'*}"

	if [[ "$inside_worktree" == "true" ]]
	then
		printf "${bold}"

		if [[ "$branch" == "HEAD" ]]
		then
			printf "${red} in ↗ detached HEAD state"
		else
			printf "${yellow} on ⎇  $branch"
		fi

		printf " ["

		# Check for uncommitted changes
		if ! $(git diff-index --quiet --ignore-submodules --no-ext-diff --cached HEAD)
		then
			printf "+"
		fi

		# Check for unstaged changes
		if ! $(git diff --quiet --ignore-submodules --no-ext-diff)
		then
			printf "!"
		fi

		# Check for untracked changes
		if [ -n "$(git ls-files --others --exclude-standard)" ]
		then
			printf "?"
		fi

		# Check for stashed changes
		if $(git rev-parse --verify refs/stash &>/dev/null)
		then
			printf "$"
		fi

        case "$(git rev-list --count --left-right "@{upstream}"...HEAD 2> /dev/null)" in
			# No upstream or local branch is in-sync with remote
			"" | "0	0") printf "" ;;
			# Local branch is ahead of remote
			"0	"*) printf "↑" ;;
			# Local branch is behind remote
			*"	0") printf "↓" ;;
			# Local branch diverges from remote
			*) printf "Y" ;;
        esac

		printf "]${normal}"
	fi
}

mkcd() {
	mkdir -p $1
	cd $1
}

# Aliases
alias hgrep="history | grep"
alias gti="git"
alias sl="ls"
alias ..="cd .."
alias ...="cd ../.."
alias .4="cd ../../.."
alias .5="cd ../../../.."

if trash_path=$(type -P "trash") && [ -x $trash_path ]
then
	alias rm="trash"
fi

# Command line
__set_color
export PROMPT_COMMAND='PS1="${bold}${green}\u${normal}:${bold}${blue}\w${normal}$(__git_status)\n$ "'

# History
shopt -s cmdhist
shopt -s histappend

# Environment variables
export EDITOR="vim"
export HISTCONTROL=ignorespace:ignoredups:erasedups
export HISTIGNORE=ls:exit:pwd:clear
export HISTSIZE=10000
export HISTFILESIZE=20000
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32"

# Miscellaneous
bind -f "$(dirname ${BASH_SOURCE[0]})/.inputrc"
