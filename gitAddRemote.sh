#!/bin/bash
# remove old Git-Remote
# add new Git-Remote

#
# Include's
#
_CONFIG_FILE=$HOME/.config/script-settings/sshData.cfg
source $_CONFIG_FILE
source $BASH_COLOR_INCL

#
# Global Variables
#
_CONFIG_FOLDER="$HOME/.config/script-settings"
_C_GIT_SUFFIX=".git"
_DIRECTORY_PREFIX=$_RASPI_PATH
_CURRENT_REPOSITORY=${PWD##*/}
_DIRECTORY_PATH="$_DIRECTORY_PREFIX$_CURRENT_REPOSITORY$_C_GIT_SUFFIX"
_REMOTE_ARG=""
_REMOTE_SSH=""

# create options array, for custom selection
mapfile -t optionsArray < $_CONFIG_FILE

#
# main script execution.
#
changeRemote() {

    # add special handling for raspberry pi
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
            _DIRECTORY_PATH="$_DIRECTORY_PREFIX$_CURRENT_REPOSITORY$_C_GIT_SUFFIX"
        fi
    fi

    # change git remotes
    git remote remove $_REMOTE_ARG

    git remote add $_REMOTE_ARG $_REMOTE_SSH:$_DIRECTORY_PATH

    echo ""
    echo -e "${_FG_GREEN}Remote '$_REMOTE_ARG' was successfully changed to:${_TX_RESET}"
    echo -e "${_SPACE_2}$_REMOTE_ARG $_REMOTE_SSH:$_DIRECTORY_PATH"
}

#
# decide between the configured ssh connections.
#
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

    # get relevent information
    _REMOTE_SSH="${selectedEntry##*=}"
}

#
# create config file.
#
initializeScript() {
    [ -e "$_CONFIG_FILE" ] && echo "sshData.cfg File exists already, delete before execution is possible" && exit 1

    # check and or create directory / config file
    ( [ -d "$_CONFIG_FOLDER" ] || mkdir -p $_CONFIG_FOLDER ) &&
        ( [ -e "$_CONFIG_FILE" ] || touch $_CONFIG_FILE ) &&

    # add standard functionality, can be deleted wihtin the file
    echo "_GITHUB_SSH=" > $_CONFIG_FILE
    echo "_GITLAB_SSH=" >> $_CONFIG_FILE
    echo "_BITBUCKET_SSH=" >> $_CONFIG_FILE
    echo "_RASPI_SSH=" >> $_CONFIG_FILE
    echo "_RASPI_PATH=" >> $_CONFIG_FILE


    echo -e "${_FG_GREEN}Success:${_TX_RESET} sshData.cfg was create at ~/.config/script-settings."
    echo -e "${_SPACE_2}Configure the corresponding ssh files"
}

#
# output script description.
#
printHelp() {
    echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_WHITE}-c: ${_TX_RESET} create Config File"
    echo -e "${_SPACE_2}${_FG_WHITE}-b: ${_TX_RESET} Update Bitbucket Remote"
    echo -e "${_SPACE_2}${_FG_WHITE}-g: ${_TX_RESET} Update Github Remote"
    echo -e "${_SPACE_2}${_FG_WHITE}-r: ${_TX_RESET} Update Raspberry Remote"
    echo -e "${_SPACE_2}${_FG_WHITE}-i: ${_TX_RESET} Interactive Update"
    echo -e "${_SPACE_4}${_FG_YELLOW}arg: ${_TX_RESET} git remote name"
}

#
# handle script options.
#
while getopts ":hbgri:c" opt; do
    case ${opt} in
        c  ) initializeScript ;;
        b  ) _REMOTE_ARG="bitbucket"; _REMOTE_SSH=$_BITBUCKET_SSH; changeRemote ;;
        g  ) _REMOTE_ARG="github"; _REMOTE_SSH=$_GITHUB_SSH; changeRemote ;;
        r  ) _REMOTE_ARG="pi"; _REMOTE_SSH=$_RASPI_SSH; changeRemote ;;
        i  ) _REMOTE_ARG="$OPTARG"; selectRemoteSSH; changeRemote ;;
        h  ) printHelp exit 1;;
        \? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        :  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        *  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then printHelp; fi
shift $((OPTIND -1))
