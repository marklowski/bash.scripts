#!/bin/bash
# Try to Push Commits to Raspi

#
# Include's
#
_CONFIG_FILE=$HOME/.local/share/script-settings/pushProjects.cfg
source ~/.config/script-settings/sshData.cfg
source $BASH_COLOR_INCL

#
# Global Variables
#
_PROJECTS=$(awk '!a[$0]++' $_CONFIG_FILE)
_REMOTE_FILE_WORK="~/changedProject.workLaptop.txt"
_REMOTE_FILE_HOME="~/changedProject.homeDesktop.txt"
_C_GITBASED=".git"

#
# push listed projects to raspberr pi,
# after a 3 projects, paus for a interval of 30 seconds.
#
pushProjects () {
	counter=1
	clear

	echo -e "${_FG_BLUE}INFO:${_TX_RESET} Cycling through config file\n"

	for line in $_PROJECTS; do
		if [ $counter -gt 3 ]; then
	    echo -e "${_FG_YELLOW}INFO:${_TX_RESET} Delay of 30 Seconds because Pi not available\n"
			counter=0
			sleep 30
		fi

		if [[ -d $line ]]; then
			cd $line
			echo -e "${_SPACE_2}${_FG_CYAN}Checking Directory: ${_TX_RESET} ${PWD##*/}"

			if [[ -d "$_C_GITBASED" ]]; then
				git push pi
				counter=$[$counter +1]
			fi
		fi

		echo ""
	done
}

#
# clear config file.
#
clearConfig () {
	echo -e "${_FG_BLUE}INFO:${_TX_RESET} Now clearing config file"
	echo -n "" > $_CONFIG_FILE
}

#
# clear specified remote config file.
#
clearConfigRemote () {
	[[ $remote_opt = 'W' ]] && remote_file=$_REMOTE_FILE_WORK || remote_file=$_REMOTE_FILE_HOME

	echo -e "${_FG_WHITE}Now clearing Remote file${_TX_RESET} $remote_file"
	test=$(ssh git@$_RASPI_SSH "echo -n "" > $remote_file")
}

#
# list local config file.
#
listConfig () {
	echo -e "${_FG_CYAN}Found the Following Projects:${_TX_RESET}"
	for line in $_PROJECTS; do
		echo -e "${_FG_WHITE} $line ${_TX_RESET}"
	done
	echo ""
}

#
# list specifified remote file.
#
listConfigRemote() {
	[[ $remote_opt = 'W' ]] && remote_file=$_REMOTE_FILE_WORK || remote_file=$_REMOTE_FILE_HOME

	ssh git@$_RASPI_SSH "cat $remote_file"
}

#
# output script description.
#
printHelp() {
  echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
  echo -e "${_SPACE_2}${_FG_WHITE}-g: ${_TX_RESET} get Transport Paths"
  echo -e "${_SPACE_2}${_FG_WHITE}-l: ${_TX_RESET} List Local Changes"
  echo -e "${_SPACE_2}${_FG_WHITE}-r: ${_TX_RESET} List Remote Changes"
  echo -e "${_SPACE_4}${_FG_YELLOW}args${_TX_RESET} - Available Options:"
  echo -e "${_SPACE_6}${_FG_BLUE}'H'${_TX_RESET} - Home Office"
  echo -e "${_SPACE_6}${_FG_BLUE}'W'${_TX_RESET} - Office"
  echo -e "${_SPACE_2}${_FG_WHITE}-c: ${_TX_RESET} Clear Local File"
  echo -e "${_SPACE_2}${_FG_WHITE}-C: ${_TX_RESET} Clear Remote File"
  echo -e "${_SPACE_4}${_FG_YELLOW}args${_TX_RESET} - Available Options:"
  echo -e "${_SPACE_6}${_FG_BLUE}'H'${_TX_RESET} - Home Office"
  echo -e "${_SPACE_6}${_FG_BLUE}'W'${_TX_RESET} - Office"
  echo -e "${_SPACE_2}${_FG_WHITE}-e: ${_TX_RESET} Execute Program\n"
}

#
# handle script options.
#
while getopts ":hcle:r:C:" opt; do
  case ${opt} in
    c ) clearConfig ;;
		l ) listConfig ;;
		e ) pushProjects; remote_opt=$OPTARG; clearConfigRemote ;;
		r ) remote_opt=$OPTARG; listConfigRemote ;;
		C ) remote_opt=$OPTARG; clearConfigRemote ;;
		h  ) printHelp exit 1;;
		\? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then listConfig; fi
shift $((OPTIND -1))
