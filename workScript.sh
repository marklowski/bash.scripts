#!/bin/bash
#workScript

#
# Include's
#
_CONFIG_FILE=$HOME/.config/script-settings/workScript.cfg
source $BASH_COLOR_INCL

#
# Global Variables
#
_REMINDER_FOLDER="$HOME/.local/share/script-settings"
_REMINDER_FILE="$HOME/.local/share/script-settings/reminder.cfg"
_DIRECTORIES=$(cat $_CONFIG_FILE)
_CURRENT_DATE=`date +"%Y-%m-%d"`

prepareReminder() {
    # check if directory exists
    if [ ! -d "$_REMINDER_FOLDER" ]; then
        mkdir $_REMINDER_FOLDER 
    fi

    # check if file exists
    if [ ! -e "$_REMINDER_FILE" ]; then
        touch $_REMINDER_FILE
    fi
}

#
# try list contents of reminder file.
#
listReminders() {
    prepareReminder

    cat $_REMINDER_FILE
}

#
# clear reminder file.
#
clearReminders() {
    prepareReminder

    echo "" > $_REMINDER_FILE
}

#
# add a reminder to the config file.
#
addReminder() {
    reminderMsg=$1
    prepareReminder

    echo "$reminderMsg" >> $_REMINDER_FILE
}

#
# pull the latest git version.
#
pullDirectories() {
    gitRemote=$1

    for directory in $_DIRECTORIES; do
        if [ -d "$directory" ]; then
            cd $directory

            git pull $gitRemote master 
        fi                      
    done                        
}                               

#
# commit the changes with standard message.
#
pushDirectories() {
    for directory in $_DIRECTORIES; do
        if [ -d "$directory" ]; then
            cd $directory

            if [[ $directory == "H" ]]; then
                commitMsg="${_CURRENT_DATE}: From HomeOffice"
            else
                commitMsg="${_CURRENT_DATE}: From Office"
            fi

            git add .
            git commit -m "$commitMsg"
            git push 
        fi
    done
}

#
# output script description.
#
printHelp() {
    echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_WHITE}-l:${_TX_RESET} List Reminders"
    echo -e "${_SPACE_2}${_FG_WHITE}-c:${_TX_RESET} Clear Reminders"
    echo -e "${_SPACE_2}${_FG_WHITE}-a:${_TX_RESET} Add Reminder"
    echo -e "${_SPACE_2}${_FG_WHITE}-g:${_TX_RESET} Pull Work Directories"
    echo -e "${_SPACE_2}${_FG_WHITE}-s:${_TX_RESET} Push Work Directories"
    echo -e "${_SPACE_4}${_FG_YELLOW}args${_TX_RESET} - Available Options:"
    echo -e "${_SPACE_6}${_FG_BLUE}'H'${_TX_RESET} - Home Office"
    echo -e "${_SPACE_6}${_FG_BLUE}'O'${_TX_RESET} - Office"
}

#
# handle script options.
#
while getopts ":hlcg:a:s:" opt; do
    case ${opt} in
        l  ) listReminders ;;
        c  ) clearReminders ;;
        a  ) addReminder "$OPTARG" ;;
        g  ) pullDirectories "$OPTARG" ;;
        s  ) pushDirectories "$OPTARG" ;;
        h  ) printHelp exit 1;;
        \? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        :  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
        *  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then printHelp; fi
shift $((OPTIND -1))
