#!/bin/bash
# Check Git Projects

#
# Include's
#
_CONFIG_FILE="$HOME/.config/script-settings/chkProjects.cfg"
source $BASH_COLOR_INCL

#
# Global Variables
#
_PROJECTS=$(cat $_CONFIG_FILE)
_NO_DIRECTORIES=true
_ORIGIN=$(pwd) # Get Origin Directory
_GIT_BASED=".git"

#
# handle pre script execution.
#
preScript() {
  cd ~ # GoTo Home Directory, otherwise directory could get ignroed
  clear # Clear Screen
}

#
# handle post script execution.
#
postScript() {
  cd $_ORIGIN # Move Origin Directory
}

#
# main script execution.
#
main() {
  for line in $_PROJECTS; do
    echo -e "${_FG_WHITE}Checked Folder:${_TX_RESET} ${line##*/}"

    # Loop all sub-directories
    for directories in $line/*; do
      if [[ -d $directories ]]; then
        cd $directories
        msg="";

        if [ -d "$_GIT_BASED" ]; then
          test=$(git status);

          # Check Local Repository for changes
          if [[ $test == *"nothing to commit"* ]]; then
            msg="${_FG_CYAN} No Changes "
            # Check if git status has unstaged changes
          elif [[ $test == *"Changes not staged for commit"* ]]; then
            msg="${_FG_YELLOW} Unstaged changes "
            # Check if git status has uncommitted changes
          elif [[ $test == *"Untracked files"* ]]; then
            msg="${_FG_RED} You forgot to commit some files "
          elif [[ $test == *"Changes to be committed"* ]]; then
					  msg="${_FG_PURPLE} Staged Changes but not Commited "
				  fi

          echo -e "${directories##*/}:$msg${_TX_RESET}"
          cd ..
        fi

        [ $_NO_DIRECTORIES = true ] && _NO_DIRECTORIES=false
      fi
    done

    [ $_NO_DIRECTORIES = true ] && echo -e "${_FG_BLUE}INFO:${_TX_RESET} No Directories Found" || _NO_DIRECTORIES=true
    echo ""
  done
}

#
# sets script execution sequence.
#
preScript
( main ) | more # pipe output to more, so output is scrollable
postScript

exit $PIPESTATUS
