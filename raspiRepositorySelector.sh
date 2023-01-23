#! /bin/bash

# Color Include
source $BASH_COLOR_INCL

# Source SSH Settings
source ~/.config/script-settings/sshData.cfg

# Get List of Repositories
_REPOS="$(ssh git@$_RASPI_SSH "ls $_RASPI_PATH")"

echo "$_REPOS" >> test.txt
#while getopts ":hcle:r:C:" opt; do
#case ${opt} in
#		h )
#			echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
#			echo -e "${_FG_WHITE}-l: ${_TX_RESET} List Local Changes"
#			echo -e "${_FG_WHITE}-r: ${_TX_RESET} List Remote Changes(Work=W, Home=H)"
#			echo -e "${_FG_WHITE}-c: ${_TX_RESET} Clear Local File"
#			echo -e "${_FG_WHITE}-C: ${_TX_RESET} Clear Remote File (Work=W, Home=H)"
#			echo -e "${_FG_WHITE}-e: ${_TX_RESET} Execute Program\n"
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
#			echo -e "${_FG_YELLOW}Invalid Option: ${_TX_RESET} $OPTARG" 1>&2
#			exit 1
#			;;
#		: )
#            echo -e "${_FG_YELLOW}Invalid Option: ${_TX_RESET} -$OPTARG requires an argument \n" 1>&2
#            exit 1
#            ;;
#	esac
#done
#shift $((OPTIND -1))
