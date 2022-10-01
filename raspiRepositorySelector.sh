#! /bin/bash

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

# Get List of Repositories
_REPOS="$(ssh git@$_RASPI_SSH "ls $_RASPI_PATH")"

echo "$_REPOS" >> test.txt
#while getopts ":hcle:r:C:" opt; do
#case ${opt} in
#		h )
#			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
#			echo -e "${_WHITE}${_BOLD}-l: ${_RESET} List Local Changes"
#			echo -e "${_WHITE}${_BOLD}-r: ${_RESET} List Remote Changes(Work=W, Home=H)"
#			echo -e "${_WHITE}${_BOLD}-c: ${_RESET} Clear Local File"
#			echo -e "${_WHITE}${_BOLD}-C: ${_RESET} Clear Remote File (Work=W, Home=H)"
#			echo -e "${_WHITE}${_BOLD}-e: ${_RESET} Execute Program\n"
#			exit 1
#			;;
#		c )
#			clearConfig
#			;;
#		l )
#			listConfig
#			;;
#		e )
#			pushProjects
#			remote_opt=$OPTARG
#			clearConfigRemote
#			;;
#		r )
#			remote_opt=$OPTARG
#			listConfigRemote
#			;;
#		C )
#			remote_opt=$OPTARG
#			clearConfigRemote
#			;;
#		\? )
#			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} $OPTARG" 1>&2
#			exit 1
#			;;
#		: )
#            echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} -$OPTARG requires an argument \n" 1>&2
#            exit 1
#            ;;
#	esac
#done
#shift $((OPTIND -1))
