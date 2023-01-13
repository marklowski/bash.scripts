#!/bin/bash
# loop through git projects and check for different options

# Color Include
source $BASH_COLOR_INCL

# Constants
_GIT_HOOK_DIR=".git/hooks"

# User Inputs
_GIT_HOOK=""

getHookPath() {
  hookPath="$_GIT_HOOK_DIR/post-commit"

  # check if different hook was supplied, and replace when needed
  if [ ! -z "$_GIT_HOOK" ]; then
    hookPath="$_GIT_HOOK_DIR/$_GIT_HOOK"
  else
    _GIT_HOOK="post-commit" # otherwise set default value
  fi

  eval "$1='$hookPath'"
}

checkExistence() {
  hookPath=$1

  if [ -e "$hookPath" ]; then
    return 0
  else
    echo -e "${_SPACE_2}${_FG_BLUE}Info:${_TX_RESET} Hook '$_GIT_HOOK' does not exist."
    return 1
  fi
} 

printHook() {
  # getHookPath && check existence 
  hookPath=""
  getHookPath hookPath

  checkExistence $hookPath
  returnValue=$?

  if [ $returnValue == 0 ]; then
    cat ${hookPath}
  fi
}

replaceHook() {
  # get args
  replacementPath=$1
  executionOption=$2

  hookPath=""
  getHookPath hookPath 

  # handle different Execution Options
  if [ "$executionOption" == "IGNORE_NOT_FOUND" ]; then
    checkExistence $hookPath
    returnValue=$?
  elif [ "$executionOption" == "INSERT_OR_REPLACE" ]; then
    hookPath="$_GIT_HOOK_DIR/"
    returnValue=0
  fi

  if [ $returnValue == 0 ]; then
    cp "$replacementPath" "$hookPath"
    echo -e "${_SPACE_2}${_FG_GREEN}Success:${_TX_RESET} Hook '$_GIT_HOOK' was changed."
  else
    echo -e "${_SPACE_8}No Action was taken. Execute with option ${_FG_WHITE}-i${_TX_RESET},"
    echo -e "${_SPACE_8}when Hook should be inserted regardless"
  fi
}

main() {
  OPTION=$1
  ARGUMENT=$2

  for line in $PWD/
  do
    for directories in $line*
    do
      echo -e "${_FG_YELLOW}${directories##*/}: ${_TX_RESET}"
      cd $directories

      case $OPTION in
        e )
          printHook
          ;;
        r )
          replaceHook "$ARGUMENT" "IGNORE_NOT_FOUND"
          ;;
        i )
          replaceHook "$ARGUMENT" "INSERT_OR_REPLACE"
          ;;
		    * ) echo -e "${_FG_RED}${_TX_BOLD}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
      esac
      echo ""
    done
  done
}

printHelp() {
  echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
  echo -e "${_SPACE_2}${_FG_WHITE}-f:${_TX_RESET} set relevant commit hook"
  echo -e "${_SPACE_2}${_FG_WHITE}-e:${_TX_RESET} check content of hook"
  echo -e "${_SPACE_2}${_FG_WHITE}-r:${_TX_RESET} replace content of hook"
  echo -e "${_SPACE_4}${_FG_YELLOW}-arg:${_TX_RESET} path to replacement file"
  echo -e "${_SPACE_2}${_FG_WHITE}-i:${_TX_RESET} insert or replace content of hook"
  echo -e "${_SPACE_4}${_FG_YELLOW}-arg:${_TX_RESET} path to replacement file"
  echo ""
  echo -e "${_FG_CYAN}Additional Information: ${_TX_RESET}"
  echo -e "${_SPACE_2}Standard hook that gets checked is ${_FG_RED}post-commit${_TX_RESET},"
  echo -e "${_SPACE_2}when other hook should be tested add ${_FG_WHITE}-f${_TX_RESET} before actual option"
}

while getopts ":her:f:i:" opt; do
case ${opt} in
		h )
      printHelp
			exit 1
			;;
		e )
      main "e"
			exit 1
			;;
    r )
      main "r" "$OPTARG"
		 	exit 1
		 	;;
    i )
      main "i" "$OPTARG"
		 	exit 1
		 	;;
    f )
      _GIT_HOOK="$OPTARG"
      ;;
		\? ) echo -e "${_FG_YELLOW}${_TX_BOLD}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}${_TX_BOLD}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}${_TX_BOLD}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

if ((OPTIND == 1)); then
  main "e"
fi

shift $((OPTIND -1))
