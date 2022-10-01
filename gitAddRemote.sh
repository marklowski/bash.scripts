#!/bin/bash
# remove old Git-Remote 
# add new Git-Remote

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
_GIT_SUFFIX=".git"
_DIRECTORY_PREFIX=$_RASPI_PATH
_CURRENT_REPOSITORY=${PWD##*/}
_DIRECTORY_PATH="$_DIRECTORY_PREFIX$_CURRENT_REPOSITORY$_GIT_SUFFIX"
_REMOTE_ARG=""
_REMOTE_SSH=""

changeRemote() {

    if [ $_REMOTE_ARG != "pi" ]; then
 
        # Get current Remote Url & Split for Releveant Part
        remote_url=$(git config --get remote.$_REMOTE_ARG.url) 
        split_url="$(echo $remote_url | cut -d ':' -f2)"
 
        [[ -z $split_url ]] && echo "Remote not found" && exit 1
        _DIRECTORY_PATH="$split_url"
    else
        # set gen. prefix when nothing was found
        if [[ "$_CURRENT_REPOSITORY" != *"."* ]]; then
            _CURRENT_REPOSITORY="gen.$_CURRENT_REPOSITORY"
            _DIRECTORY_PATH="$_DIRECTORY_PREFIX$_CURRENT_REPOSITORY$_GIT_SUFFIX"
        fi
    fi

    git remote remove $_REMOTE_ARG

    git remote add $_REMOTE_ARG git@$_REMOTE_SSH:$_DIRECTORY_PATH

    git remote -v
}

while getopts ":hbgr" opt; do
	case ${opt} in
		h )
			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
            echo -e "${_WHITE}${_BOLD}-b: ${_RESET} Update Bitbucket Remote"
			echo -e "${_WHITE}${_BOLD}-g: ${_RESET} Update Github Remote"
			echo -e "${_WHITE}${_BOLD}-r: ${_RESET} Update Raspberry Remote"
            exit 1
            ;;
		b )
            _REMOTE_ARG="bitbucket"
            _REMOTE_SSH=$_BITBUCKET_SSH
			changeRemote
			;;
		g )
            _REMOTE_ARG="github"
            _REMOTE_SSH=$_GITHUB_SSH
			changeRemote
			;;
		r )
            _REMOTE_ARG="pi"
            _REMOTE_SSH=$_RASPI_SSH
			changeRemote
			;;
		\? )
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} $OPTARG \n" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))