#!/bin/bash
# Check for Commits

# ASCII Coloring
_RED="\e[0;31m"
_CYAN="\e[0;36m"
_YELLOW="\e[0;33m"
_BLUE="\e[0;34m"
_PURPLE="\e[0;35m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

# Global Variables
_CONFIG_FILE="$HOME/.config/script-settings/chkProjects.cfg"
_PROJECTS=$(cat $_CONFIG_FILE)
_NO_DIRECTORIES=true

# Initialize Program

_ORIGIN=$(pwd) # Get Origin Directory 
cd # GoTo Root Directory
clear # Clear Screen

for line in $_PROJECTS
do
	GITBASED=.git
	echo -e "${_WHITE}${_BOLD}Checked Folder:${_RESET} $line"

	# Loop all sub-directories
	for directories in $line*
	do
		if [[ -d $directories ]]; then
			cd $directories
			msg="";

			if [ -d "$GITBASED" ]; then
				test=$(git status);
				# Check Local Repository for changes
				if [[ $test == *"nothing to commit"* ]]; then
					msg="${_CYAN} No Changes "
					# Check if git status has unstaged changes
				elif [[ $test == *"Changes not staged for commit"* ]]; then
					msg="${_YELLOW} Unstaged changes "
					# Check if git status has uncommitted changes
				elif [[ $test == *"Untracked files"* ]]; then
					msg="${_RED} You forgot to commit some files "
				elif [[ $test == *"Changes to be committed"* ]]; then
					msg="${_PURPLE} Staged Changes but not Commited "
				fi

				echo -e "${directories##*/}:$msg${_RESET}"
				cd ..
			fi
			[ $_NO_DIRECTORIES = true ] && _NO_DIRECTORIES=false
		fi
	done
	[ $_NO_DIRECTORIES = true ] && echo -e "${_WHITE}${_BOLD}INFO:${_RESET}${_BLUE} No Directories Found ${_RESET}" || _NO_DIRECTORIES=true
	echo ""
done

cd $_ORIGIN # Move Origin Directory 
