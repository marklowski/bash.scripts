#!/bin/bash
# create Project on Local Machine & Remote Machine

# Color Include
source $BASH_COLOR_INCL

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
			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
			echo -e "${_FG_WHITE}${_TX_BOLD}-l: ${_TX_RESET} Create Local Repository & Repository on RaspberryPi"
			echo -e "${_FG_WHITE}${_TX_BOLD}-p: ${_TX_RESET} Create ${_TX_BOLD}Public${_TX_RESET} Github Repository"
			echo -e "${_FG_WHITE}${_TX_BOLD}-i: ${_TX_RESET} Create ${_TX_BOLD}Private${_TX_RESET} Github Repository"
			exit 1
			;;
		l )
			echo -e "${_FG_CYAN}${_TX_BOLD}Creating Raspberry Pi Repository:${_TX_RESET} $OPTARG\n"
			_REPOSITORY=$OPTARG

			create_Git_Repository
			create_Git_Remote
			;;
		p )
			echo -e "${_FG_CYAN}${_TX_BOLD}Creating Public Github Repository:${_TX_RESET} $OPTARG \n"
			_REPOSITORY=$OPTARG
			_OPTION="--public"

			create_Git_Repository
			create_Git_Remote
			create_Github_Repository

			;;
		i )
			echo -e "${_FG_CYAN}${_TX_BOLD}Creating Private Github Repository:${_TX_RESET} $OPTARG \n"
			_REPOSITORY=$OPTARG
            _OPTION="--private"

			create_Git_Repository
			create_Git_Remote
			create_Github_Repository
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
