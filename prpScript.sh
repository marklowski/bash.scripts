#!/bin/bash
#PRP WorkScript

#
# Include's
#
_CONFIG_FILE=$HOME/.config/script-settings/prpScript.cfg
source $BASH_COLOR_INCL

#
# Global Variables
#
_REMINDER_FOLDER="$HOME/.local/share/script-settings"
_REMINDER_FILE="$HOME/.local/share/script-settings/reminder.cfg"
_PRP_FOLDER=$(cat $_CONFIG_FILE)
_CURRENT_DATE=`date +"%Y-%m-%d"`

#
# try list contents of reminder file.
#
listReminders() {

    # check if directory / file exists
    ( [ -d "$_REMINDER_FOLDER" ] || mkdir $_REMINDER_FOLDER ) &&
    ( [ -e "$_REMINDER_FILE" ] || touch $_REMINDER_FILE ) &&
    cat $_REMINDER_FILE
}

#
# clear reminder file.
#
clearReminders() {

    ( [ -d "$_REMINDER_FOLDER" ] || mkdir $_REMINDER_FOLDER ) &&
    ( [ -e "$_REMINDER_FILE" ] || touch $_REMINDER_FILE ) &&
    > $_REMINDER_FILE
}

#
# add a reminder to the config file.
#
addReminder() {

    ( [ -d "$_REMINDER_FOLDER" ] || mkdir $_REMINDER_FOLDER ) &&
    ( [ -e "$_REMINDER_FILE" ] || touch $_REMINDER_FILE ) &&
    echo "$1" >> $_REMINDER_FILE
}

#
# pull the latest git version.
#
gitPull() {

    ( [ -d "$_PRP_FOLDER" ] ) &&
    cd $_PRP_FOLDER &&
    git pull pi master
}

#
# push the latest changes to raspberry pi.
#
gitPush() {

    ( [ -d "$_PRP_FOLDER" ] ) &&
    cd $_PRP_FOLDER &&
    git push pi master
}

#
# commit the changes with standard message.
#
gitCommit() {

    ( [ -d "$_PRP_FOLDER" ] ) && cd $_PRP_FOLDER &&
    [[ $1 == "H" ]] && PRP_Commit="${_CURRENT_DATE}: From HomeOffice" ||
    PRP_Commit="${_CURRENT_DATE}: From Office"
    git add . &&
    git commit -m "$PRP_Commit"
}

#
# output script description.
#
printHelp() {
  echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
  echo -e "${_SPACE_2}${_FG_WHITE}-l: ${_TX_RESET} List Reminders"
  echo -e "${_SPACE_2}${_FG_WHITE}-c: ${_TX_RESET} Clear Reminders"
  echo -e "${_SPACE_2}${_FG_WHITE}-a: ${_TX_RESET} Add Reminder"
  echo -e "${_SPACE_2}${_FG_WHITE}-g: ${_TX_RESET} Pull PRP-Folder Changes"
  echo -e "${_SPACE_2}${_FG_WHITE}-s: ${_TX_RESET} Commit Changes to PRP-Folder"
  echo -e "${_SPACE_4}${_FG_YELLOW}args${_TX_RESET} - Available Options:"
  echo -e "${_SPACE_6}${_FG_BLUE}'H'${_TX_RESET} - Home Office"
  echo -e "${_SPACE_6}${_FG_BLUE}'O'${_TX_RESET} - Office"
}

#
# handle script options.
#
while getopts ":hlcga:s:" opt; do
	case ${opt} in
		g  ) gitPull ;;
		l  ) listReminders ;;
		c  ) clearReminders ;;
		a  ) addReminder "$OPTARG"; shift ;;
		s  ) gitCommit "$OPTARG"; gitPush; shift ;;
		h  ) printHelp exit 1;;
		\? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then
  printHelp
fi

shift $((OPTIND -1))
