#!/bin/bash
# remove old Git-Remote 
# add new Git-Remote

# Color Include
source $BASH_COLOR_INCL

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
			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
            echo -e "${_FG_WHITE}${_TX_BOLD}-b: ${_TX_RESET} Update Bitbucket Remote"
			echo -e "${_FG_WHITE}${_TX_BOLD}-g: ${_TX_RESET} Update Github Remote"
			echo -e "${_FG_WHITE}${_TX_BOLD}-r: ${_TX_RESET} Update Raspberry Remote"
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
