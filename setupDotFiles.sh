#!/bin/bash
# Setup dotFiles Directory.

#
# Include's
#
_DOTFILES_PATH=$HOME/dotFiles
source $BASH_COLOR_INCL

#
# Global Variables
#
_QUICK_SELECT=false
_SELECTED_ITEM_INDEX=""
_SELECTED_ITEM_TEXT=""
_TARGET_DIRECTORY=./.config

declare -a _DIRECTORIES
declare -a _FILES

#
# set corresponding system directory.
#
setSystemDirectory() {
  PS3="dotFile System Ordner wählen: "

  select option in "${_DIRECTORIES[@]##*/}"; do
    for item in "${_DIRECTORIES[@]##*/}"; do
      if [[ $item == $option ]]; then
        echo -e "Proceeding with ${_FG_BLUE}${item^^}${_TX_RESET}\n"
        _SELECTED_ITEM_TEXT=${item^^}
        _SELECTED_ITEM_INDEX=$REPLY
        break 2
      fi
    done
  done
}

#
# get the configured system directories.
#
getSystemDirectories() {
  systemDirectory=$1
  directoryCounter=1

  # loop over dotFiles directory.
  for entry in "$_DOTFILES_PATH"/*; do
      
    # when directory found add to array.
    if [ -d "$entry" ]; then
      _DIRECTORIES[$directoryCounter]=$entry

      # when quick select active, check if userInput is available & break;
      # otherwise send setSystemDirectory Dialog
      if $_QUICK_SELECT; then
        if [[ ${entry##*/} == $systemDirectory ]]; then 
          echo -e "Proceeding with ${_FG_BLUE}${systemDirectory^^}${_TX_RESET}\n"

          _SELECTED_ITEM_INDEX=directoryCounter; 
          break;
        fi
      fi

      directoryCounter=$(($directoryCounter+1))
    fi
  done

  # when Item was pre selected handle standard dialog
  if [[ $_SELECTED_ITEM_INDEX == "" ]]; then
    if $_QUICK_SELECT; then
      echo -e "${_FG_RED}Error:${_TX_RESET} The Argument ${systemDirectory^^} wasn't found!\n"
    fi
    setSystemDirectory
  fi
}

#
# check or create directories.
#
prepareDirectories() {

  # check for .config directory
  if [ ! -d "$HOME/.config" ]; then
    mkdir -p $HOME/.config
  fi

  # check .local/bin, not relevent for dotFiles but for bash.scripts
  if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p $HOME/.local/bin
  fi

  echo -e "${_FG_BLUE}Info (1/3):${_TX_RESET} Directory prepartions complete!\n"
}

#
# compare '.config' and 'system/.config', because 'system/.config' is the leading directory.
#
checkConfigDirectory() {
  checkDirectory=$1

  # check if system Directory/.config has the corresponding directory
  for subEntry in "${_DIRECTORIES[$_SELECTED_ITEM_INDEX]}"/.config/*; do
    if [[ "${subEntry##*/}" == "${checkDirectory}" ]]; then
      return 1
    fi
  done
}

#
# link dotFiles/.config directories, while checking system directory.
#
linkConfigDirectory() {
  declare -A ignoreDirectories
  
  # loop over dotFiles/.config directory
  for entry in "$_DOTFILES_PATH"/.config/*; do
      
    # when directory found add to array.
    if [ -d "$entry" ]; then
      checkConfigDirectory ${entry##*/}
      returnValue=$?

      if [ $returnValue == 1 ]; then
        #ln -sf $subEntry $_TARGET_DIRECTORY
        ignoreDirectories+=("${subEntry##*/}")
      else
        #ln -sf $entry $_TARGET_DIRECTORY
        ignoreDirectories+=("${entry##*/}")
      fi
    fi
  done

  for entry in "${ignoreDirectories[@]}"; do
    echo $entry
  done

  # loop over systemDirectory/.config directory
  for entry in "${_DIRECTORIES[$_SELECTED_ITEM_INDEX]}"/.config/*; do

    if [[ ! ${ignoreDirectories[*]} =~ $entry ]]; then
      echo "$entry would be handled"
    fi
  done
  echo -e "${_FG_BLUE}Info (2/3):${_TX_RESET} Linkings .config Directory was completed!\n"
}

#
# check if multiple files.
#
checkConfigFiles() {
  checkFile=$1

 echo "$checkFile" 
}

#
# link the different config files.
#
linkConfigFiles() {
  
  # loop over system specific .Files
  for entry in "${_DIRECTORIES[$_SELECTED_ITEM_INDEX]}"/.*; do

    if [ -f "$entry" ]; then
      checkConfigFiles ${entry##*/}
    fi
  done

  echo -e "${_FG_BLUE}Info (3/3):${_TX_RESET} Linking Files within $_SELECTED_ITEM_TEXT was completed!\n"
}

#
# main script execution sequence.
#
main() {
  systemDirectory=$1

  getSystemDirectories $systemDirectory

  prepareDirectories

  linkConfigDirectory

  linkConfigFiles
}

#
# output script description.
#
printHelp() {
  echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
  echo -e "${_SPACE_2}${_FG_WHITE}-e: ${_TX_RESET} Normal Execution Mode (with Dialog)"
  echo -e "${_SPACE_2}${_FG_WHITE}-q: ${_TX_RESET} Quick Execution Mode (Dialog Fallback)"
}

#
# handle script options.
#
while getopts ":heq:" opt; do
	case ${opt} in
		e  ) main ;;
    q  ) _QUICK_SELECT=true; main "$OPTARG" ;;
		h  ) printHelp exit 1;;
		\? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then main; fi
shift $((OPTIND -1))
