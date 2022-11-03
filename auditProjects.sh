#!/bin/bash
# Audit PNPM Packages of multiple Projects

# Color Include
source ~/extSSD/p/projects/bash.scripts/incl.Colors.sh

# Global Variables
_PROJECTS="$(pwd)/"

listProjects() {
	echo -e "${_FG_WHITE}${_TX_BOLD}Checked Folder:${_TX_RESET} $_PROJECTS"
	
	for directories in $_PROJECTS*
	do
		NODEBASED=node_modules
		FILEBASED=package.json

		if [[ -d $directories ]]; then
			cd $directories

			if [[ -d "$NODEBASED" || -f "$FILEBASED" ]]; then
				echo "This Directory wourld be checked: ${directories##*/}"
			fi
		fi
	done
}

checkProjects() {
	echo -e "${_FG_WHITE}${_TX_BOLD}Checked Folder:${_TX_RESET} $_PROJECTS"
	
	for directories in $_PROJECTS*
	do
		echo -e "${_FG_WHITE}${_TX_BOLD}Checked Project:${_TX_RESET} ${directories##*/}"
		NODEBASED=node_modules
		FILEBASED=package.json

		if [[ -d $directories ]]; then
			cd $directories

			if [[ -d "$NODEBASED" || -f "$FILEBASED" ]]; then
				pnpm audit
				pnpm outdated
			fi
			echo ""
		fi
	done
}



while getopts ":hlcDiu" opt; do
case ${opt} in
		h )
			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
			echo -e "${_FG_WHITE}${_TX_BOLD}-l: ${_TX_RESET} List would be Checked Projects"
			echo -e "${_FG_WHITE}${_TX_BOLD}-c: ${_TX_RESET} Check for Vulnerabilities && Updates"
			echo -e "${_FG_WHITE}${_TX_BOLD}-D: ${_TX_RESET} Delete node_modules Folder && package-lock-json"
            echo -e "${_FG_WHITE}${_TX_BOLD}-i: ${_TX_RESET} Install NPM Packages"
            echo -e "${_FG_WHITE}${_TX_BOLD}-u: ${_TX_RESET} Upgrade All NPM Packages\n"
			exit 1
			;;
		c )
			checkProjects
			exit 1
			;;
		l )
			listProjects
			exit 1
			;;
		e )
			# pushProjects
			exit 1
			;;
		\? )
			echo -e "${_FG_YELLOW}${_TX_BOLD}Invalid Option: ${_TX_RESET} $OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))
