#!/bin/bash
# log Transports

# Color Include
source $BASH_COLOR_INCL

# Script Settings
_CONFIG_FILE="$HOME/.config/script-settings/logTransports.cfg"
_TA_FOLDER=$(cat $_CONFIG_FILE)
_INIT_DATE=`date +%d.%m.%Y`
_INIT_TIME=`date +%H:%M:%S`

# User Inputs
_EXECUTION_MODE=""
_SELECTED_ITEM_TEXT=""
_SELECTED_ITEM_INDEX=""
_TA_DATE=""
_TA_TIME=""
_TA_DESCRIPTION=""
_README_FILE=""

# Global Variables
declare -a _DIRECTORIES
declare -a _DIRECTORIES_SHORTEND
declare -a _TRANSPORTS
declare -a _TRANSPORTS_DESCRIPTION
declare -a _FILES

dialogGetTargetDirectory() {
    PS3="Archive Ordner wählen: "

    select option in "${_DIRECTORIES_SHORTEND[@]}"; do
        for item in "${_DIRECTORIES_SHORTEND[@]}"; do
            if [[ $item == $option ]]; then
                _SELECTED_ITEM_TEXT=$item
                _SELECTED_ITEM_INDEX=$REPLY
                break 2
            fi
        done
    done

    echo ""
}

getArchiveDirectory() {
    directoryCounter=1
    fileCounter=1

    for entry in "$_TA_FOLDER"/*; do
        if [ -d "$entry" ]; then
            _DIRECTORIES[$directoryCounter]=$entry
            _DIRECTORIES_SHORTEND[$directoryCounter]=${entry##*/}

            directoryCounter=$(($directoryCounter+1))
        fi

        if [ -f "$entry" ]; then
            _FILES[$fileCounter]=$entry
            fileCounter=$(($fileCounter+1))
        fi
    done
}

dialogSetHeaderInformation() {
    read -e -p "Enter custom Date (default: $_INIT_DATE): " taDate
    if [[ $taDate != "" ]]; then
        _TA_DATE=$taDate
    else
        _TA_DATE=$_INIT_DATE
    fi

    read -e -p "Enter custom Time (default: $_INIT_TIME): " taTime
    if [[ $taDate != "" ]]; then
        _TA_TIME=$taTime
    else
        _TA_TIME=$_INIT_TIME
    fi

    read -e -p "Enter Description: " _TA_DESCRIPTION

    echo ""
}

convertFilesToTransports() {
    transportCounter=1

    for entry in "${_FILES[@]}"; do
        entryShortend=${entry##*/}
        transportShortcut=${entryShortend::1}
        transportNumber=${entryShortend:1:6}
        sapSystem=${entryShortend:8:10}

        if [ $transportShortcut == "K" ]; then
            _TRANSPORTS[$transportCounter]=$sapSystem$transportShortcut$transportNumber
            transportCounter=$(($transportCounter+1))
        fi
    done
}

dialogSetTransportInformation() {
    transportCounter=1

    for entry in "${_TRANSPORTS[@]}"; do
        read -e -p "Enter Description ($entry): " _TRANSPORTS_DESCRIPTION[$transportCounter]
        transportCounter=$(($transportCounter+1))
    done
    echo ""
}

checkREADME() {
    _README_FILE="${_DIRECTORIES[$_SELECTED_ITEM_INDEX]}/README.md"
    if [ ! -e "$_README_FILE" ]; then
        touch $_README_FILE
        echo "# Changelog / Grouping Information" > $_README_FILE
    fi
}

writeHeader() {
    exectuionMode="$1"

    if [ "$exectuionMode" == "PREVIEW" ]; then
        echo ""
        echo -e "${_FG_YELLOW}## ${_TA_DATE} - ${_TA_TIME} ${_TX_RESET}"
        echo ""
        echo -e "${_FG_WHITE}${_TA_DESCRIPTION}${_TX_RESET}"
    else
        echo "" >> $_README_FILE
        echo "## ${_TA_DATE} - ${_TA_TIME}" >> $_README_FILE
        echo "" >> $_README_FILE
        echo "${_TA_DESCRIPTION}" >> $_README_FILE
    fi
}

writeTransports() {
    exectuionMode="$1"

    if [ "$exectuionMode" == "PREVIEW" ]; then
        echo ""
        echo -e "${_FG_YELLOW}**Corresponding Transports:**${_TX_RESET}"
        echo ""

        for i in ${!_TRANSPORTS[@]}; do
            echo "- ${_TRANSPORTS[$i]} - ${_TRANSPORTS_DESCRIPTION[$i]}"
        done
    else
        echo "" >> $_README_FILE
        echo "**Corresponding Transports:**" >> $_README_FILE
        echo "" >> $_README_FILE

        for i in ${!_TRANSPORTS[@]}; do
            echo "- ${_TRANSPORTS[$i]} - ${_TRANSPORTS_DESCRIPTION[$i]}" >> $_README_FILE
        done
    fi
}

writeLog() {
    exectuionMode="$1"
    checkREADME

    if [ "$exectuionMode" == "PREVIEW" ]; then
		echo -e "${_FG_BLUE}Log Preview: ${_TX_RESET}"
        echo ""
        echo -e "${_FG_BLUE}---${_TX_RESET}"
    fi

    writeHeader "$exectuionMode"
    writeTransports "$exectuionMode"

    if [ "$exectuionMode" == "PREVIEW" ]; then
        echo ""
        echo -e "${_FG_BLUE}---${_TX_RESET}"
        echo ""
    fi
}

moveFiles() {
    for entry in "${_FILES[@]}"; do
        mv "$entry" "${_DIRECTORIES[$_SELECTED_ITEM_INDEX]}"
    done
}

dialogWriteLog() {
    writeLog "PREVIEW"

    while true
    do
        read -e -p "Write Log to README.md [Y/n]: " input
        echo ""

        case $input in
            [yY][eE][sS]|[yY])
                writeLog
                moveFiles

                if [ "$_EXECUTION_MODE" != "SILENT" ]; then
	                echo -e "${_FG_YELLOW}Finished Script ${_TX_RESET}"
                fi
                break
                ;;
            [nN][oO]|[nN])
                if [ "$_EXECUTION_MODE" != "SILENT" ]; then
			        echo -e "${_FG_BLUE}Aborting Script ${_TX_RESET}"
                fi
                break
                ;;
            *)
			    echo -e "${_FG_RED}Invalid input... ${_TX_RESET}"
                echo ""
                ;;
        esac
    done
}

checkFiles() {
    getArchiveDirectory

    if [ "$_EXECUTION_MODE" == "EXTERNAL" ]; then
        if [ ${#_FILES[@]} == 0 ]; then
            exit 1 # Initial
        else
            exit 0 # Not Initial
        fi
    else
        if [ ${#_FILES[@]} == 0 ]; then
            return 1 # Initial
        else
            return 0 # Not Initial
        fi
    fi
}

main() {
    checkFiles
    returnValue=$?

    if [ $returnValue != 0 ]; then
        echo ""
        echo -e "${_FG_BLUE}${_TX_BOLD}Aborting Script. ${_TX_RESET}"
        echo -e "${_FG_RED}${_TX_BOLD}No Files were found!${_TX_RESET}"
        return 1
    fi

    getArchiveDirectory

    dialogGetTargetDirectory

    dialogSetHeaderInformation

    convertFilesToTransports

    dialogSetTransportInformation

    dialogWriteLog
}

# -h : is used for help menu
# -e : default script execution
# -c : Sub-Script Functionality(SSF), Check if undocumented Files exist
# -s : SSF, Silent default Script execution
#
while getopts ":hecs" opt; do
	case ${opt} in
        h )
			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
			echo -e "${_FG_WHITE}${_TX_BOLD}-e: ${_TX_RESET} Execute Program"
            exit 1;;
        e )
            main
			;;
        c )
            _EXECUTION_MODE="EXTERNAL"
            checkFiles
            ;;
        s )
            _EXECUTION_MODE="SILENT"
            main
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

shift $((OPTIND - 1))
