#!/bin/bash
# log Transports

# ASCII Coloring
_RED="\e[0;31m"
_CYAN="\e[0;36m"
_YELLOW="\e[0;33m"
_BLUE="\e[0;34m"
_PURPLE="\e[0;35m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

# Script Settings
_CONFIG_FILE="$HOME/.config/script-settings/logTransports.cfg"
_TA_FOLDER=$(cat $_CONFIG_FILE)
_INIT_DATE=`date +%d.%m.%Y`
_INIT_TIME=`date +%H:%M:%S`

# User Inputs
_SELECTED_ITEM=""
_TA_DATE=""
_TA_TIME=""
_TA_DESCRIPTION=""

getTargetDirectory() {
    PS3="Archive Ordner wählen: "
    directoryTargets=($@)

    select option in "${directoryTargets[@]}"; do
        for item in "${directoryTargets[@]}"; do
            if [[ $item == $option ]]; then
                _SELECTED_ITEM=$item
                break 2
            fi
        done
    done

    return $REPLY
}

setDocumentation() {
    read -e -p "Enter custom Date (otherwise: $_INIT_DATE): " taDate
    if [[ $taDate != "" ]]; then
        _TA_DATE=$taDate
    else
        _TA_DATE=$_INIT_DATE
    fi

    read -e -p "Enter custom Time (otherwise: $_INIT_TIME): " taTime
    if [[ $taDate != "" ]]; then
        _TA_TIME=$taTime
    else
        _TA_TIME=$_TA_TIME
    fi

    read -e -p "Enter Description: " _TA_DESCRIPTION
}

handleLogging() {
    
    fileOptions=$1

}

getArchiveDirectory() {
    directoryCounter=0
    fileCounter=0

    for entry in "$_TA_FOLDER"/*
    do
        if [ -d "$entry" ]; then
            directoryOptions[$directoryCounter]=$entry
            directoryOptionsShortend[$directoryCounter]=${entry##*/}

            directoryCounter=$(($directoryCounter+1))
        fi

        if [ -f "$entry" ]; then
            fileOptions[$fileCounter]=$entry
            fileCounter=$(($fileCounter+1))
        fi
    done
    
   getTargetDirectory ${directoryOptionsShortend[@]}
   rvTargetDirectory=$?

   setDocumentation ${fileOptions}

   handleLogging $fileOptions
}

main() {
    getArchiveDirectory
}

while getopts ":he" opt; do
	case ${opt} in
        h  ) echo "Listing Help:"; echo "-e: execute program (expects Parameter: (APT, DNF, ZYPPER, PACMAN))"; exit 1;;
        e  )
            main
			;;
		\? ) echo "Unknown Option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$opt"
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
fi

shift $((OPTIND - 1))
