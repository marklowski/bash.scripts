#!/bin/bash
# Try to Push Commits to Raspi

# Color Include
source $BASH_COLOR_INCL

# Source SSH Settings
source ~/.config/script-settings/sshData.cfg

# Global Variables
_CONFIG_FILE="$HOME/.config/script-settings/pushChangesRaspi.cfg"
_PROJECTS=$(awk '!a[$0]++' $_CONFIG_FILE)
_REMOTE_FILE_WORK="~/changedProject.workLaptop.txt"
_REMOTE_FILE_HOME="~/changedProject.homeDesktop.txt"

pushProjects () {
	counter=1
	clear

	echo -e "${_FG_WHITE}${_TX_BOLD}Cycling through config file ${_TX_RESET} \n"

	for line in $_PROJECTS
	do
		if [ $counter -gt 3 ]; then
			echo -e "${_FG_YELLOW}${_TX_BOLD}Delay of 30 Seconds because Pi not available${_TX_RESET} \n"
			counter=0
			sleep 30
		fi

		GITBASED=.git
		if [[ -d $line ]]; then
			cd $line
			echo -e "${_FG_CYAN}${_TX_BOLD}  Checking Directory: ${_TX_RESET} ${PWD##*/}"
			if [[ -d "$GITBASED" ]]; then
				git push pi
				counter=$[$counter +1]
			fi
		fi
		echo ""
	done
}

clearConfig () {
	echo -e "${_FG_WHITE}${_TX_BOLD}Now clearing config file${_TX_RESET}"
	echo -n "" > $_CONFIG_FILE
}

clearConfigRemote () {
	[[ $remote_opt = 'W' ]] && remote_file=$_REMOTE_FILE_WORK || remote_file=$_REMOTE_FILE_HOME

	echo -e "${_FG_WHITE}${_TX_BOLD}Now clearing Remote file${_TX_RESET} $remote_file"
	test=$(ssh git@$_RASPI_SSH "echo -n "" > $remote_file")
}

listConfig () {
	echo -e "${_FG_CYAN}${_TX_BOLD}Found the Following Projects:${_TX_RESET}"
	for line in $_PROJECTS
	do
		echo -e "${_FG_WHITE} $line ${_TX_RESET}"
	done
	echo ""
}

listConfigRemote() {
	[[ $remote_opt = 'W' ]] && remote_file=$_REMOTE_FILE_WORK || remote_file=$_REMOTE_FILE_HOME

	ssh git@$_RASPI_SSH "cat $remote_file"
}

while getopts ":hcle:r:C:" opt; do
case ${opt} in
		h )
			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
			echo -e "${_FG_WHITE}${_TX_BOLD}-l: ${_TX_RESET} List Local Changes"
			echo -e "${_FG_WHITE}${_TX_BOLD}-r: ${_TX_RESET} List Remote Changes(Work=W, Home=H)"
			echo -e "${_FG_WHITE}${_TX_BOLD}-c: ${_TX_RESET} Clear Local File"
			echo -e "${_FG_WHITE}${_TX_BOLD}-C: ${_TX_RESET} Clear Remote File (Work=W, Home=H)"
			echo -e "${_FG_WHITE}${_TX_BOLD}-e: ${_TX_RESET} Execute Program\n"
			exit 1
			;;
		c )
			clearConfig
			;;
		l )
			listConfig
			;;
		e )
			pushProjects
			remote_opt=$OPTARG
			clearConfigRemote
			;;
		r )
			remote_opt=$OPTARG
			listConfigRemote
			;;
		C )
			remote_opt=$OPTARG
			clearConfigRemote
			;;
		\? ) echo -e "${_FG_YELLOW}${_TX_BOLD}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}${_TX_BOLD}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}${_TX_BOLD}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

if ((OPTIND == 1))
then
echo -e "${_FG_RED}${_TX_BOLD}Error: No Option specified ${_TX_RESET}" >&2;
fi

shift $((OPTIND -1))
