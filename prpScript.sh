#!/bin/bash
#PRP WorkScript

# Color Include
source $BASH_COLOR_INCL

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
            echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
            echo -e "${_FG_WHITE}${_TX_BOLD}-l: ${_TX_RESET} List Reminders"
			echo -e "${_FG_WHITE}${_TX_BOLD}-c: ${_TX_RESET} Clear Reminders"
			echo -e "${_FG_WHITE}${_TX_BOLD}-a: ${_TX_RESET} Add Reminder"
			echo -e "${_FG_WHITE}${_TX_BOLD}-g: ${_TX_RESET} Pull PRP-Folder Changes"
            echo -e "${_FG_WHITE}${_TX_BOLD}-s: ${_TX_RESET} Commit Changes to PRP-Folder"
            echo -e "	Options 'H' = ${_TX_BOLD}Home Office${_TX_RESET}"
			echo -e "	Options 'O' = ${_TX_BOLD}Office${_TX_RESET}"
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
		\? ) echo -e "${_FG_YELLOW}${_TX_BOLD}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}${_TX_BOLD}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}${_TX_BOLD}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

if ((OPTIND == 1))
then
echo -e "${_FG_RED}${_TX_BOLD}Error: No Option specified ${_TX_RESET}" >&2;
fi

shift $((OPTIND -1))
