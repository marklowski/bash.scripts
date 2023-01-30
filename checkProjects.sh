#!/bin/bash
# Check Git Projects

#
# Include's
#
_CONFIG_FILE="$HOME/.config/script-settings/checkProjects.cfg"
source $BASH_COLOR_INCL
source $BASH_ICON_INCL/incl.Icons.checkProjects

#
# Global Variables
#
_PROJECTS=$(cat $_CONFIG_FILE)
_NO_DIRECTORIES=true
_ORIGIN=$(pwd) # Get Origin Directory
_GIT_BASED=".git"
_COMPRESS_OUTPUT=false

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
    ignoreOutput=true
    outputHeader=true

    for line in $_PROJECTS; do

        # Loop all sub-directories
        for directories in $line/*; do
            if [[ -d $directories ]]; then
                cd $directories
                msg="";

                if [ -d "$_GIT_BASED" ]; then
                    test=$(git status);

                    # check git status, and print a corresponding message
                    if [[ $test == *"branch is ahead of"* ]]; then # changes not pushed
                        msg="${_FG_MAGENTA} Commited Changes but not pushed ${i_mdi_flag_outline}"; ignoreOutput=false
                    elif [[ $test == *"nothing to commit"* ]]; then # repository has no changes
                        msg="${_FG_CYAN} No Changes $i_mdi_check"; ignoreOutput=true
                    elif [[ $test == *"Changes not staged for commit"* ]]; then # Check if git status has unstaged changes
                        msg="${_FG_YELLOW} Unstaged changes $i_oct_zap"; ignoreOutput=false
                    elif [[ $test == *"Untracked files"* ]]; then # Check if git status has uncommitted changes
                        msg="${_FG_RED} You forgot to commit some files $i_pom_internal_interruption"; ignoreOutput=false
                    elif [[ $test == *"Changes to be committed"* ]]; then # Check if git status has uncommitted changes
                        msg="${_FG_BLUE} Staged Changes but not Commited $i_pom_external_interruption"; ignoreOutput=false
                    fi

                    if $_COMPRESS_OUTPUT; then
                        if ! $ignoreOutput; then
                            if $outputHeader; then
                                echo -e "${_FG_WHITE}Checked Folder:${_TX_RESET} ${line##*/} ${i_mdi_folder}"
                                outputHeader=false
                            fi

                            echo -e "${directories##*/}:$msg${_TX_RESET}"
                        fi
                    else
                        if $outputHeader; then
                            echo -e "${_FG_WHITE}Checked Folder:${_TX_RESET} ${line##*/} ${i_mdi_folder}"
                            outputHeader=false
                        fi

                        echo -e "${directories##*/}:$msg${_TX_RESET}"
                    fi

                    cd ..
                fi

                [ $_NO_DIRECTORIES = true ] && _NO_DIRECTORIES=false
            fi
        done

        [ $_NO_DIRECTORIES ] && [ ! $_COMPRESS_OUTPUT ] && echo -e "${_FG_BLUE}INFO:${_TX_RESET} No Directories Found" || _NO_DIRECTORIES=true
        [ $outputHeader = false ] && echo ""

        outputHeader=true
    done
}

#
# output script description.
#
printHelp() {
    echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_WHITE}-e: ${_TX_RESET} check Projects"
    echo -e "${_SPACE_2}${_FG_WHITE}-c: ${_TX_RESET} check Projects (compressed)"
}

#
# handle script options.
#
while getopts ":hec" opt; do
    case ${opt} in
        e ) preScript; ( main ) | more; postScript; ;;
        c ) _COMPRESS_OUTPUT=true; preScript; ( main ) | more; postScript; ;;
        h  ) printHelp exit 1;;
        \? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        :  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        *  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then preScript; ( main ) | more; postScript; fi
shift $((OPTIND -1))
exit $PIPESTATUS
