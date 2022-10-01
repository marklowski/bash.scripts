#!/bin/bash
# Try to Push Commits to Raspi

# ASCII Coloring
_YELLOW="\e[0;33m"
_CYAN="\e[0;36m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

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

	echo -e "${_WHITE}${_BOLD}Cycling through config file ${_RESET} \n"

	for line in $_PROJECTS
	do
		if [ $counter -gt 3 ]; then
			echo -e "${_YELLOW}${_BOLD}Delay of 30 Seconds because Pi not available${_RESET} \n"
			counter=0
			sleep 30
		fi

		GITBASED=.git
		if [[ -d $line ]]; then
			cd $line
			echo -e "${_CYAN}${_BOLD}  Checking Directory: ${_RESET} ${PWD##*/}"
			if [[ -d "$GITBASED" ]]; then
				git push pi
				counter=$[$counter +1]
			fi
		fi
		echo ""
	done
}

clearConfig () {
	echo -e "${_WHITE}${_BOLD}Now clearing config file${_RESET}"
	echo -n "" > $_CONFIG_FILE
}

clearConfigRemote () {
	[[ $remote_opt = 'W' ]] && remote_file=$_REMOTE_FILE_WORK || remote_file=$_REMOTE_FILE_HOME

	echo -e "${_WHITE}${_BOLD}Now clearing Remote file${_RESET} $remote_file"
	test=$(ssh git@$_RASPI_SSH "echo -n "" > $remote_file")
}

listConfig () {
	echo -e "${_CYAN}${_BOLD}Found the Following Projects:${_RESET}"
	for line in $_PROJECTS
	do
		echo -e "${_WHITE} $line ${_RESET}"
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
			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
			echo -e "${_WHITE}${_BOLD}-l: ${_RESET} List Local Changes"
			echo -e "${_WHITE}${_BOLD}-r: ${_RESET} List Remote Changes(Work=W, Home=H)"
			echo -e "${_WHITE}${_BOLD}-c: ${_RESET} Clear Local File"
			echo -e "${_WHITE}${_BOLD}-C: ${_RESET} Clear Remote File (Work=W, Home=H)"
			echo -e "${_WHITE}${_BOLD}-e: ${_RESET} Execute Program\n"
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
		\? )
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} $OPTARG" 1>&2
			exit 1
			;;
		: )
            echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} -$OPTARG requires an argument \n" 1>&2
            exit 1
            ;;
	esac
done
shift $((OPTIND -1))