#!/bin/bash
# Try to Push Commits to Raspi

# ASCII Coloring
_YELLOW="\e[0;33m"
_CYAN="\e[0;36m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

# Global Variables
_PROJECTS="$(pwd)/"

listProjects() {
	echo -e "${_WHITE}${_BOLD}Checked Folder:${_RESET} $_PROJECTS"
	
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
	echo -e "${_WHITE}${_BOLD}Checked Folder:${_RESET} $_PROJECTS"
	
	for directories in $_PROJECTS*
	do
		echo -e "${_WHITE}${_BOLD}Checked Project:${_RESET} ${directories##*/}"
		NODEBASED=node_modules
		FILEBASED=package.json

		if [[ -d $directories ]]; then
			cd $directories

			if [[ -d "$NODEBASED" || -f "$FILEBASED" ]]; then
				npm audit
				npm outdated
			fi
			echo ""
		fi
	done
}



while getopts ":hlcDiu" opt; do
case ${opt} in
		h )
			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
			echo -e "${_WHITE}${_BOLD}-l: ${_RESET} List would be Checked Projects"
			echo -e "${_WHITE}${_BOLD}-c: ${_RESET} Check for Vulnerabilities && Updates"
			echo -e "${_WHITE}${_BOLD}-D: ${_RESET} Delete node_modules Folder && package-lock-json"
            echo -e "${_WHITE}${_BOLD}-i: ${_RESET} Install NPM Packages"
            echo -e "${_WHITE}${_BOLD}-u: ${_RESET} Upgrade All NPM Packages\n"
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
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} $OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))
