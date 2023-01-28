#!/bin/bash
# loop through git projects and check for different options

#
# Include's
#
source $BASH_COLOR_INCL

#
# Global Variables
#
_GIT_HOOK_DIR=".git/hooks"
_GIT_HOOK=""

#
# try to get path to standard hook,
# otherwise use user-input to build
# the correct path.
#
getHookPath() {
    hookPath="$_GIT_HOOK_DIR/post-commit"

  # check if different hook was supplied, and replace when needed
  if [ ! -z "$_GIT_HOOK" ]; then
      hookPath="$_GIT_HOOK_DIR/$_GIT_HOOK"
  else
      _GIT_HOOK="post-commit" # otherwise set default value
  fi

  # used for inline return
  eval "$1='$hookPath'"
}

#
# check if the hookPath is plausible.
#
checkExistence() {
    hookPath=$1

    if [ -e "$hookPath" ]; then
        return 0
    else
        echo -e "${_SPACE_2}${_FG_BLUE}Info:${_TX_RESET} Hook ${_FG_YELLOW}'$_GIT_HOOK'${_TX_RESET} does not exist."
        return 1
    fi
} 

#
# try to print the content of the corresponding hook.
#
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

#
# depending on the executionOption,
# execute the script differently.
#
# - IGNORE_NOT_FOUND -> replace only already existing hook's
# - INSERT_OR_REPLACE -> replace or paste hook
#
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

#
# main execution loop, that loop's through
# the current sub-directories and execute's the
# corresponding option.
#
executionMode() {
    option=$1
    argument=$2

    for line in $PWD/; do
        for directories in $line*; do
            if [ -d $directories ]; then
                echo -e "${_FG_BLUE}Checked Folder:${_TX_RESET} ${directories##*/}"
                cd $directories

                case $option in
                    e ) printHook ;;
                    r ) replaceHook "$argument" "IGNORE_NOT_FOUND" ;;
                    i ) replaceHook "$argument" "INSERT_OR_REPLACE" ;;
                    * ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$option" >&2; exit 1;;
                esac
                echo ""
            fi
        done
    done
}
#
# only used to correctly, nest the more command.
#
main() {
    option=$1
    argument=$2

    ( executionMode $option $argument ) | more
}

#
# output script description.
#
printHelp() {
    echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_WHITE}-f:${_TX_RESET} set relevant commit hook"
    echo -e "${_SPACE_2}${_FG_WHITE}-e:${_TX_RESET} check content of hook"
    echo -e "${_SPACE_2}${_FG_WHITE}-r:${_TX_RESET} replace content of hook"
    echo -e "${_SPACE_4}${_FG_YELLOW}arg:${_TX_RESET} path to replacement file"
    echo -e "${_SPACE_2}${_FG_WHITE}-i:${_TX_RESET} insert or replace content of hook"
    echo -e "${_SPACE_4}${_FG_YELLOW}arg:${_TX_RESET} path to replacement file"
    echo ""
    echo -e "${_FG_CYAN}Additional Information: ${_TX_RESET}"
    echo -e "${_SPACE_2}Standard hook that gets checked is ${_FG_RED}post-commit${_TX_RESET},"
    echo -e "${_SPACE_2}when other hook should be tested add ${_FG_WHITE}-f${_TX_RESET} before actual option"
}

#
# handle script options.
#
while getopts ":her:f:i:" opt; do
    case ${opt} in
        e  ) main "e" exit 1 ;;
        r  ) main "r" "$OPTARG" exit 1 ;;
        i  ) main "i" "$OPTARG" exit 1 ;;
        f  ) _GIT_HOOK="$OPTARG" ;;
        h  ) printHelp exit 1 ;;
        \? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        :  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        *  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then main "e"; fi
shift $((OPTIND -1))
exit $PIPESTATUS
