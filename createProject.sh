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
# initialize repository creation.
#
preRepositoryCreation() {
  targetSystem=$1
  visibilityDialog=$2

  # print header
	echo -e "${_FG_CYAN}Creating ${targetSystem} Repository:${_TX_RESET} $_REPOSITORY_NAME\n"

  if $visibilityDialog; then
    echo "Repository visibility dialog would be shown."
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
  fi

  if $_CREATE_GITLAB; then
    preRepositoryCreation "Gitlab" true
  fi
}

#
# try to create local repository.
#
# 1. check if directory exists,
# 2. check if git is initialized 
#
createLocalGitRepository() {
  gitBased=".git"
	# Create Folder when not existent && move into it
	mkdir -p $_REPOSITORY_PATH
	cd $_REPOSITORY_PATH

  # check if repository is git based
	if [ ! -d "$gitBased" ]; then
	  git init
	fi
}

#
# create Repository on Raspberry Pi, with the help of a Sub-Script.
#
createRaspberryPiRepository() {
	# Call Repo Create Script on Raspberry Pi
	ssh $_RASPI_SSH -t ". /etc/profile; . ~/.profile; gitNewRepository $_REPOSITORY_NAME"
}

createGithubRepository() {
	# Create GitHub Repo
  projectPath="$(pwd)"
  remoteName="github"

  gh repo create $_REPOSITORY_NAME $_OPTION -r $remoteName -s $projectPath
}

#
# create Gitlab Repository, with the help of 'glab'.
#
createGitlabRepository() {
  # TODO: Not yet implemented
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
	echo -e "${_SPACE_6}${_FG_YELLOW}-arg:${_TX_RESET} Repository Name"
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
		n  ) _REPOSITORY_NAME_SUPPLIED=true; handleRepositoryCreation exit 1;;
		h  ) printHelp exit 1;;
		\? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1))
then
  echo -e "${_FG_RED}Error: No Option specified ${_TX_RESET}" >&2;
  exit 1
fi

shift $((OPTIND -1))

# check when a create flag was set, that the repository name was also supplied
if ( $_CREATE_LOCAL || $_CREATE_RASPBERRY_PI || $_CREATE_GITHUB || $_CREATE_GITLAB ); then
  if ! $_REPOSITORY_NAME_SUPPLIED; then
    echo -e "${_FG_RED}Error:${_TX_RESET} For Project Creation Option -n needs to supplied with a ${_FG_BLUE}<Repository Name>  ${_TX_RESET}" >&2;
  fi
fi

# check if a repository name was set, that create flag was also supplied
if $_REPOSITORY_NAME_SUPPLIED; then
  if ( ! $_CREATE_LOCAL && ! $_CREATE_RASPBERRY_PI && ! $_CREATE_GITHUB && ! $_CREATE_GITLAB ); then
    echo -e "${_FG_RED}Error:${_TX_RESET} For Project Creation Option one of the following options needs to be supplied:" >&2;
	  echo -e "${_SPACE_2}${_FG_WHITE}-l:${_TX_RESET} Create ${_FG_YELLOW}Local${_TX_RESET} Repository" >&2;
	  echo -e "${_SPACE_2}${_FG_WHITE}-r:${_TX_RESET} Create ${_FG_YELLOW}RaspberryPi${_TX_RESET} Repository" >&2;
	  echo -e "${_SPACE_2}${_FG_WHITE}-g:${_TX_RESET} Create ${_FG_YELLOW}Github${_TX_RESET} Repository" >&2;
	  echo -e "${_SPACE_2}${_FG_RED}-G:${_TX_RESET} Create ${_FG_YELLOW}Gitlab${_TX_RESET} Repository" >&2;
  fi
fi
