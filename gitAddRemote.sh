#!/bin/bash
# remove old Git-Remote
# add new Git-Remote

_CONFIG_FILE="$HOME/.config/script-settings/sshData.cfg"

# Color Include
source $BASH_COLOR_INCL

# Source SSH Settings
source $_CONFIG_FILE

# Global Variables
_CONFIG_FOLDER="$HOME/.config/script-settings"
_CONFIG_FILE="$HOME/.config/script-settings/sshData.cfg"
_GIT_SUFFIX=".git"
_DIRECTORY_PREFIX=$_RASPI_PATH
_CURRENT_REPOSITORY=${PWD##*/}
_DIRECTORY_PATH="$_DIRECTORY_PREFIX$_CURRENT_REPOSITORY$_GIT_SUFFIX"
_REMOTE_ARG=""
_REMOTE_SSH=""

mapfile -t optionsArray < $_CONFIG_FILE

changeRemote() {

    if [ $_REMOTE_ARG != "pi" ]; then

        # Get current Remote Url & Split for Releveant Part
        remoteUrl=$(git config --get remote.$_REMOTE_ARG.url)
        splitUrl="${remoteUrl##*:}"

        [[ -z $splitUrl ]] && echo "Remote not found" && exit 1
        _DIRECTORY_PATH="$splitUrl"
    else
        # set gen. prefix when nothing was found
        if [[ "$_CURRENT_REPOSITORY" != *"."* ]]; then
            _CURRENT_REPOSITORY="gen.$_CURRENT_REPOSITORY"
            _DIRECTORY_PATH="$_DIRECTORY_PREFIX$_CURRENT_REPOSITORY$_GIT_SUFFIX"
        fi
    fi

    git remote remove $_REMOTE_ARG

    git remote add $_REMOTE_ARG $_REMOTE_SSH:$_DIRECTORY_PATH

    echo ""
		echo -e "${_FG_GREEN}Remote '$_REMOTE_ARG' was successfully changed to:${_TX_RESET}"
		echo -e "${_SPACE_2}$_REMOTE_ARG $_REMOTE_SSH:$_DIRECTORY_PATH"
}

printHelp() {
			echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
			echo -e "${_SPACE_2}${_FG_WHITE}-c: ${_TX_RESET} create Config File"
      echo -e "${_SPACE_2}${_FG_WHITE}-b: ${_TX_RESET} Update Bitbucket Remote"
			echo -e "${_SPACE_2}${_FG_WHITE}-g: ${_TX_RESET} Update Github Remote"
			echo -e "${_SPACE_2}${_FG_WHITE}-r: ${_TX_RESET} Update Raspberry Remote"
			echo -e "${_SPACE_2}${_FG_WHITE}-i: ${_TX_RESET} Interactive Update"
			echo -e "${_SPACE_4}${_FG_YELLOW}arg: ${_TX_RESET} git remote name"
}

selectRemoteSSH() {
    PS3="SSH Verbindung wählen: "
    select option in "${optionsArray[@]}"; do
        for item in "${optionsArray[@]}"; do
            if [[ $item  == $option ]]; then
              selectedEntry=$option
              break 2
            fi
        done
    done

    _REMOTE_SSH="${selectedEntry##*=}"
}

initializeScript() {
  [ -e "$_CONFIG_FILE" ] && echo "sshData.cfg File exists already, delete before execution is possible" && exit 1

    ( [ -d "$_CONFIG_FOLDER" ] || mkdir -p $_CONFIG_FOLDER ) &&
    ( [ -e "$_CONFIG_FILE" ] || touch $_CONFIG_FILE ) &&

    echo "_GITHUB_SSH=" > $_CONFIG_FILE
    echo "_GITLAB_SSH=" >> $_CONFIG_FILE
    echo "_BITBUCKET_SSH=" >> $_CONFIG_FILE
    echo "_RASPI_SSH=" >> $_CONFIG_FILE
    echo "_RASPI_PATH=" >> $_CONFIG_FILE
}

while getopts ":hbgri:c" opt; do
	case ${opt} in
		h )
      printHelp
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
    i )
      _REMOTE_ARG="$OPTARG"
      selectRemoteSSH
      changeRemote
      ;;
    c )
      initializeScript
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
