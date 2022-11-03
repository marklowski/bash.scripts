#! /bin/bash

# Color Include
source ~/extSSD/p/projects/bash.scripts/incl.Colors.sh

# Source SSH Settings
source ~/.config/script-settings/sshData.cfg

# Get List of Repositories
_REPOS="$(ssh git@$_RASPI_SSH "ls $_RASPI_PATH")"

echo "$_REPOS" >> test.txt
#while getopts ":hcle:r:C:" opt; do
#case ${opt} in
#		h )
#			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
#			echo -e "${_FG_WHITE}${_TX_BOLD}-l: ${_TX_RESET} List Local Changes"
#			echo -e "${_FG_WHITE}${_TX_BOLD}-r: ${_TX_RESET} List Remote Changes(Work=W, Home=H)"
#			echo -e "${_FG_WHITE}${_TX_BOLD}-c: ${_TX_RESET} Clear Local File"
#			echo -e "${_FG_WHITE}${_TX_BOLD}-C: ${_TX_RESET} Clear Remote File (Work=W, Home=H)"
#			echo -e "${_FG_WHITE}${_TX_BOLD}-e: ${_TX_RESET} Execute Program\n"
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
#			echo -e "${_FG_YELLOW}${_TX_BOLD}Invalid Option: ${_TX_RESET} $OPTARG" 1>&2
#			exit 1
#			;;
#		: )
#            echo -e "${_FG_YELLOW}${_TX_BOLD}Invalid Option: ${_TX_RESET} -$OPTARG requires an argument \n" 1>&2
#            exit 1
#            ;;
#	esac
#done
#shift $((OPTIND -1))
