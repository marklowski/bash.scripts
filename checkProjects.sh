#!/bin/bash
# Check Git Projects

# Color Include
source ~/extSSD/p/projects/bash.scripts/incl.Colors.sh

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
	echo -e "${_FG_WHITE}${_TX_BOLD}Checked Folder:${_TX_RESET} $line"

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
					msg="${_FG_CYAN} No Changes "
					# Check if git status has unstaged changes
				elif [[ $test == *"Changes not staged for commit"* ]]; then
					msg="${_FG_YELLOW} Unstaged changes "
					# Check if git status has uncommitted changes
				elif [[ $test == *"Untracked files"* ]]; then
					msg="${_FG_RED} You forgot to commit some files "
				elif [[ $test == *"Changes to be committed"* ]]; then
					msg="${_FG_PURPLE} Staged Changes but not Commited "
				fi

				echo -e "${directories##*/}:$msg${_TX_RESET}"
				cd ..
			fi
			[ $_NO_DIRECTORIES = true ] && _NO_DIRECTORIES=false
		fi
	done
	[ $_NO_DIRECTORIES = true ] && echo -e "${_FG_WHITE}${_TX_BOLD}INFO:${_TX_RESET}${_FG_BLUE} No Directories Found ${_TX_RESET}" || _NO_DIRECTORIES=true
	echo ""
done

cd $_ORIGIN # Move Origin Directory 
