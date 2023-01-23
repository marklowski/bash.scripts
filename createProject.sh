#!/bin/bash
# create Project on Local Machine & Remote Machine

#
# Include's
#
_CONFIG_FILE=$HOME/.config/script-settings/sshData.cfg
source $_CONFIG_FILE
source $BASH_COLOR_INCL

#
# Global Variables
#
_C_GITBASED=".git"
_TARGET_SYSTEM=""
_OPTION=""
_REPOSITORY_NAME=""
_REPOSITORY_PATH=""

_REPOSITORY_NAME_SUPPLIED=false
_CREATE_LOCAL=false
_CREATE_RASPBERRY_PI=false
_CREATE_GITHUB=false
_CREATE_GITLAB=false

#
# choose between the possible Visibility.
#
chooseVisibility() {
  echo "Choose between the following options:"
  echo -e "${_SPACE_2}p | Private Repository"
  echo -e "${_SPACE_2}P | Public Repository"

  while true
  do
      echo ""
      read -e -p "Choose between the following [p/P]: " input
      echo ""

      case $input in
          [p]) _OPTION="--private"; break ;;
          [P]) _OPTION="--public"; break ;;
          *)
            echo -e "${_FG_RED}Error:${_TX_RESET}Invalid input...\n" 1>&2
            echo "Choose between the following options:"
            echo -e "${_SPACE_2}p | Private Repository"
            echo -e "${_SPACE_2}P | Public Repository"
            ;;
      esac
  done
}

#
# initialize repository creation.
#
# @param $1 - target system
# @param $2 - display Visibility dialog
#
preRepositoryCreation() {
  targetSystem=$1
  visibilityDialog=$2

  # print header
	echo -e "${_FG_CYAN}Creating ${targetSystem} Repository:${_TX_RESET} $_REPOSITORY_NAME"

  if $visibilityDialog; then
    chooseVisibility
  fi
}

#
# handle the corresponding repository creation.
#
handleRepositoryCreation() {
  if $_CREATE_LOCAL; then
    preRepositoryCreation "Local" false
    createLocalGitRepository
  fi

  if $_CREATE_RASPBERRY_PI; then
    preRepositoryCreation "Raspberry Pi" false
    createRaspberryPiRepository
  fi

  if $_CREATE_GITHUB; then
    preRepositoryCreation "Github" true
    createGithubRepository

    # update git remote path to -> .ssh/config file
    gitAddRemote.sh -g
  fi

  if $_CREATE_GITLAB; then
    preRepositoryCreation "Gitlab" true
    createGitlabRepository

    # update git remote path to -> .ssh/config file
    #gitAddRemote.sh -g
  fi
}

#
# try to create local repository.
#
# 1. check if directory exists,
# 2. check if git is initialized 
#
createLocalGitRepository() {
  # Create Folder when not existent && move into it
  mkdir -p $_REPOSITORY_PATH
  cd $_REPOSITORY_PATH

  # check if repository is git based
  if [ ! -d "$_C_GITBASED" ]; then
    git init
  fi

  # add new line
  echo ""
}

#
# create Repository on Raspberry Pi, with the help of a Sub-Script.
#
createRaspberryPiRepository() {
	# Call Repo Create Script on Raspberry Pi
	ssh $_RASPI_SSH -t ". /etc/profile; . ~/.profile; gitNewRepository $_REPOSITORY_NAME"

  # add Raspberry Remote
  git remote add pi git@$_RASPI_SSH:$_RASPI_PATH$_REPOSITORY.git

  # add new line
  echo ""
}

#
# create Github Repository, with the help of 'gh'.
#
createGithubRepository() {
	# Create GitHub Repo
  projectPath="$(pwd)"
  remoteName="github"

  gh repo create $_REPOSITORY_NAME $_OPTION -r $remoteName -s $projectPath

  # add new line
  echo ""
}

#
# create Gitlab Repository, with the help of 'glab'.
#
createGitlabRepository() {
  # TODO: Not yet implemented

  # add new line
  echo ""
}

#
# check Mandatory Fields, for execution.
#
checkMandatory() {
  # ignore when create local repository is set
  if ! $_CREATE_LOCAL; then
    # check repository exists localy.
    if [ ! -d $_REPOSITORY_PATH ]; then
      echo ""
      echo -e "${_FG_RED}Error:${_TX_RESET} Local Repository not found, to fix add the following Option" >&2;
      echo -e "${_SPACE_2}${_FG_WHITE}-l:${_TX_RESET} Create ${_FG_YELLOW}Local${_TX_RESET} Repository" >&2;
      return 1
    else
      cd $_REPOSITORY_PATH
    fi

	  if [ ! -d "$_C_GITBASED" ]; then
      echo -e "${_FG_RED}Error:${_TX_RESET} Local Repository is not initialized as a git repository" >&2;
    fi
  fi

  # check if a create flag was supplied.
  if ( ! $_CREATE_LOCAL && ! $_CREATE_RASPBERRY_PI && ! $_CREATE_GITHUB && ! $_CREATE_GITLAB ); then
    echo -e "${_FG_RED}Error:${_TX_RESET} For Project Creation Option one of the following options needs to be supplied:" >&2;
	  echo -e "${_SPACE_2}${_FG_WHITE}-l:${_TX_RESET} Create ${_FG_YELLOW}Local${_TX_RESET} Repository" >&2;
	  echo -e "${_SPACE_2}${_FG_WHITE}-r:${_TX_RESET} Create ${_FG_YELLOW}RaspberryPi${_TX_RESET} Repository" >&2;
	  echo -e "${_SPACE_2}${_FG_WHITE}-g:${_TX_RESET} Create ${_FG_YELLOW}Github${_TX_RESET} Repository" >&2;
	  echo -e "${_SPACE_2}${_FG_RED}-G:${_TX_RESET} Create ${_FG_YELLOW}Gitlab${_TX_RESET} Repository" >&2;
    return 1
  fi

  # all mandatory requirements were supplied
  return 0
}

#
# output script description.
#
printHelp() {
  echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
	echo -e "${_SPACE_2}${_FG_WHITE}-l:${_TX_RESET} Create ${_FG_YELLOW}Local${_TX_RESET} Repository"
	echo -e "${_SPACE_2}${_FG_WHITE}-r:${_TX_RESET} Create ${_FG_YELLOW}RaspberryPi${_TX_RESET} Repository"
	echo -e "${_SPACE_2}${_FG_WHITE}-g:${_TX_RESET} Create ${_FG_YELLOW}Github${_TX_RESET} Repository"
	echo -e "${_SPACE_2}${_FG_RED}-G:${_TX_RESET} Create ${_FG_YELLOW}Gitlab${_TX_RESET} Repository"
	echo -e "${_SPACE_2}${_FG_WHITE}-n:${_TX_RESET} This Option is ${_FG_RED}mandatory${_TX_RESET} to supply the Repository Name"
	echo -e "${_SPACE_6}${_FG_YELLOW}arg:${_TX_RESET} Repository Name"
  echo ""
  echo -e "${_FG_MAGENTA}Examples: ${_TX_RESET}"
	echo -e "${_SPACE_2}createProject.sh -lrn ${_FG_BLUE}<Repository Name>${_TX_RESET}"
	echo -e "${_SPACE_4}-l | create Local Repository"
	echo -e "${_SPACE_4}-r | create RaspberryPi Repository"
	echo -e "${_SPACE_4}-n | set Repository Name"
  echo ""
  echo -e "${_SPACE_2}createProject.sh -lgn ${_FG_BLUE}<Repository Name>${_TX_RESET}"
	echo -e "${_SPACE_4}-l | create Local Repository"
	echo -e "${_SPACE_4}-g | create Github Repository"
	echo -e "${_SPACE_4}-n | set Repository Name"
  echo ""
  echo -e "${_SPACE_2}createProject.sh -rgn ${_FG_BLUE}<Repository Name>${_TX_RESET}"
	echo -e "${_SPACE_4}-r | create RaspberryPi Repository"
	echo -e "${_SPACE_4}-g | create Github Repository"
	echo -e "${_SPACE_4}-n | set Repository Name"
  echo ""
}

#
# handle script options.
#
while getopts ":hlrgn:" opt; do
	case ${opt} in
    l  ) _REPOSITORY_NAME_SUPPLIED=false; _CREATE_LOCAL=true ;;
		r  ) _REPOSITORY_NAME_SUPPLIED=false; _CREATE_RASPBERRY_PI=true ;;
		g  ) _REPOSITORY_NAME_SUPPLIED=false; _CREATE_GITHUB=true ;;
		G  ) _REPOSITORY_NAME_SUPPLIED=false; _CREATE_GITLAB=true ;;
		n  )
      _REPOSITORY_NAME_SUPPLIED=true
      _REPOSITORY_NAME="$OPTARG"
      _REPOSITORY_PATH="$(pwd)/$_REPOSITORY_NAME"

      checkMandatory
      returnValue=$?

      if [ $returnValue == 0 ]; then
        handleRepositoryCreation
      fi

      exit 1
      ;;
		h  ) printHelp exit 1;;
		\? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then
  echo -e "${_FG_RED}Error:${_TX_RESET} No Option specified" >&2;
  exit 1
fi

shift $((OPTIND -1))

# check when a create flag was set, that the repository name was also supplied
if ( $_CREATE_LOCAL || $_CREATE_RASPBERRY_PI || $_CREATE_GITHUB || $_CREATE_GITLAB ); then
  if ! $_REPOSITORY_NAME_SUPPLIED; then
    echo -e "${_FG_RED}Error:${_TX_RESET} For Project Creation Option -n needs to supplied with a ${_FG_BLUE}<Repository Name>  ${_TX_RESET}" >&2;
  fi
fi
