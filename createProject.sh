#!/bin/bash
# create Project on Local Machine & Remote Machine

# ASCII Coloring
_RED="\e[0;31m"
_CYAN="\e[0;36m"
_YELLOW="\e[0;33m"
_BLUE="\e[0;34m"
_PURPLE="\e[0;35m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

# Source SSH Settings
source ~/.config/script-settings/sshData.cfg

# Global Variables
_OPTION=""
_REPOSITORY=""

create_Git_Repository() {
	# Create Folder when not existent && move into it
	mkdir -p ./$_REPOSITORY
	cd ./$_REPOSITORY
	if [ ! -d ".git" ]; then
	  git init
	  git remote add pi git@$_RASPI_SSH:$_RASPI_PATH$_REPOSITORY.git
	fi
}

create_Github_Repository() {
	# Create GitHub Repo
	gh repo create $_REPOSITORY --confirm $_OPTION
	git remote rename origin github
}

create_Git_Remote() {
	# Call Repo Create Script on Raspberry Pi
	ssh git@$_RASPI_SSH -t ". /etc/profile; . ~/.profile; gitNewRepository $_REPOSITORY"
}


while getopts ":hl:p:i:" opt; do
	case ${opt} in
		h )
			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
			echo -e "${_WHITE}${_BOLD}-l: ${_RESET} Create Local Repository & Repository on RaspberryPi"
			echo -e "${_WHITE}${_BOLD}-p: ${_RESET} Create ${_BOLD}Public${_RESET} Github Repository"
			echo -e "${_WHITE}${_BOLD}-i: ${_RESET} Create ${_BOLD}Private${_RESET} Github Repository"
			exit 1
			;;
		l )
			echo -e "${_CYAN}${_BOLD}Creating Raspberry Pi Repository:${_RESET} $OPTARG\n"
			_REPOSITORY=$OPTARG

			create_Git_Repository
			create_Git_Remote
			;;
		p )
			echo -e "${_CYAN}${_BOLD}Creating Public Github Repository:${_RESET} $OPTARG \n"
			_REPOSITORY=$OPTARG
			_OPTION="--public"

			create_Git_Repository
			create_Git_Remote
			create_Github_Repository

			;;
		i )
			echo -e "${_CYAN}${_BOLD}Creating Private Github Repository:${_RESET} $OPTARG \n"
			_REPOSITORY=$OPTARG
            _OPTION="--private"

			create_Git_Repository
			create_Git_Remote
			create_Github_Repository
			;;
		\? )
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} $OPTARG \n" 1>&2
			exit 1
			;;
		: )
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} -$OPTARG requires an argument \n" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))
