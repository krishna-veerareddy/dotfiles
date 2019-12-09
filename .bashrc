#!/bin/bash

# Utility functions
set_color() {
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

git_status() {
	local status_porcelain
	if status_porcelain=$(git status --porcelain 2> /dev/null)
	then
		# Get git branch status
		local branch
		printf "${bold}${yellow}"
		if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
		then
			if [[ "$branch" == "HEAD" ]]
			then
				printf "${red} in ↗ detached HEAD state"
			else
				printf " on ⎇  $branch"
			fi
		fi

		printf " ["

		# Check for uncommitted changes
		if ! $(git diff --quiet --ignore-submodules --cached)
		then
			printf "+"
		fi

		# Check for unstaged changes
		if ! $(git diff-files --quiet --ignore-submodules --)
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

if [ -x trash ]
then
	alias rm="trash"
fi

# Command line
set_color
export PROMPT_COMMAND='PS1="${bold}${green}\u${normal}:${bold}${blue}\w${normal}$(git_status)\n$ "'

# Environment variables
export EDITOR="vim"
