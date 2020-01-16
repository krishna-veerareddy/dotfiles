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
	local repo_info exit_code branch inside_worktree

	repo_info="$(git rev-parse --is-inside-work-tree --abbrev-ref HEAD 2>/dev/null)"
	exit_code="$?"

	if [ -z "$repo_info" ] || [ $exit_code -ne 0 ]
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
		if ! $(git diff-files --quiet --ignore-submodules --no-ext-diff --)
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

		printf "]${normal}"
	fi
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

# Miscellaneous
bind -f "$(dirname ${BASH_SOURCE[0]})/.inputrc"
