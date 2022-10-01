#!/bin/bash
#PRP WorkScript

# ASCII Coloring
_RED="\e[0;31m"
_CYAN="\e[0;36m"
_YELLOW="\e[0;33m"
_BLUE="\e[0;34m"
_PURPLE="\e[0;35m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

_CONFIG_FILE="$HOME/.config/script-settings/prpScript.cfg"
_REMINDER_FOLDER="$HOME/.config/script-settings"
_REMINDER_FILE="$HOME/.config/script-settings/reminder.cfg"
_PRP_FOLDER=$(cat $_CONFIG_FILE)
_CURRENT_DATE=`date +"%Y-%m-%d"`

List_Reminder() {

    ( [ -d "$_REMINDER_FOLDER" ] || mkdir $_REMINDER_FOLDER ) &&
    ( [ -e "$_REMINDER_FILE" ] || touch $_REMINDER_FILE ) &&
    cat $_REMINDER_FILE
}

Clear_Reminder() {

    ( [ -d "$_REMINDER_FOLDER" ] || mkdir $_REMINDER_FOLDER ) &&
    ( [ -e "$_REMINDER_FILE" ] || touch $_REMINDER_FILE ) &&
    > $_REMINDER_FILE
}

Add_Reminder() {

    ( [ -d "$_REMINDER_FOLDER" ] || mkdir $_REMINDER_FOLDER ) &&
    ( [ -e "$_REMINDER_FILE" ] || touch $_REMINDER_FILE ) &&
    echo "$1" >> $_REMINDER_FILE
}

Git_Pull() {

    ( [ -d "$_PRP_FOLDER" ] ) &&
    cd $_PRP_FOLDER &&
    git pull pi master
}

Git_Push() {

    ( [ -d "$_PRP_FOLDER" ] ) &&
    cd $_PRP_FOLDER &&
    git push pi master
}

Git_Commit() {

    ( [ -d "$_PRP_FOLDER" ] ) && cd $_PRP_FOLDER &&
    [[ $1 == "H" ]] && PRP_Commit="${_CURRENT_DATE}: From HomeOffice" ||
    PRP_Commit="${_CURRENT_DATE}: From Office"
    git add . &&
    git commit -m "$PRP_Commit"
}

while getopts ":hlcga:s:" opt; do
	case ${opt} in
		h )
 			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
            echo -e "${_WHITE}${_BOLD}-l: ${_RESET} List Reminders"
			echo -e "${_WHITE}${_BOLD}-c: ${_RESET} Clear Reminders"
			echo -e "${_WHITE}${_BOLD}-a: ${_RESET} Add Reminder"
			echo -e "${_WHITE}${_BOLD}-g: ${_RESET} Pull PRP-Folder Changes"
            echo -e "${_WHITE}${_BOLD}-s: ${_RESET} Commit Changes to PRP-Folder"
            echo -e "	Options 'H' = ${_BOLD}Home Office${_RESET}"
			echo -e "	Options 'O' = ${_BOLD}Office${_RESET}"
            exit 1
            ;;
		l )
			List_Reminder
			;;
		c )
			Clear_Reminder
			;;
		g )
			Git_Pull
			;;
		a )
			Add_Reminder "$OPTARG"
			shift
			;;
		s )
		    Git_Commit "$OPTARG"
		    Git_Push
			shift
			;;
		\? )
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} $OPTARG \n" 1>&2
			exit 1
			;;

		: )
			echo -e "${_YELLOW}${_BOLD}Invalid Option: ${_RESET} -$OPTARG requires an argument \n" 1>&2
            exit 1
            ;;
	esac
done
shift $((OPTIND -1))