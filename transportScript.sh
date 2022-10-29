#!/bin/bash

# ASCII Coloring
_RED="\e[0;31m"
_CYAN="\e[0;36m"
_YELLOW="\e[0;33m"
_BLUE="\e[0;34m"
_PURPLE="\e[0;35m"
_WHITE="\e[0;37m"
_BOLD="\e[1m"
_RESET="\e[0m"

# Global Variables
_CONFIG_FILE_OPTIONS="$HOME/.config/script-settings/transportScriptOptions.cfg"
_CONFIG_FILE_PATH="$HOME/.config/script-settings/transportScriptPath.cfg"

_TRANSPORT_NUMBER="DRPK902330"
_TRANSPORT_SHORTCUT="" # possible values "K" or "R"

_ARRAY_ROWS=3
_ARRAY_COLUMNS=0

_PRP_ENTRY=1
_SELECTED_ENTRY=0
_OUTPUT_ENTRY=0
_REVERSE_OUTPUT='False'

# Read User Configurable Options & add exit option
mapfile -t optionsArray < $_CONFIG_FILE_OPTIONS
_ARRAY_COLUMNS=$(( ${#optionsArray[@]} + $_PRP_ENTRY ))

# Source Possible PATH Settings
mapfile -t -d ";" pathArrayComplete < $_CONFIG_FILE_PATH

declare -A pathArray
rows=0
columns=1
for item in "${pathArrayComplete[@]}"; do
    counter=$((counter+1))
    if [[ $counter == 2 ]]; then
        rows=$((rows+1))

        pathArray[$rows,$columns]=$item

        if [[ $rows == $_ARRAY_ROWS ]]; then
            rows=0
            columns=$((columns+1))
        fi

        counter=0
    fi
done

returnResults() {
    # set cofiles options
    _TRANSPORT_SHORTCUT="K"

    # output cofiles header
    echo -e "${_CYAN} Transports:  ${_BOLD}$_TRANSPORT_SHORTCUT ${_RESET}"

    # output paths's
    returnResult

    # set data options
    _TRANSPORT_SHORTCUT="R"

    # output data header
    echo -e "${_CYAN} Transports:  ${_BOLD}$_TRANSPORT_SHORTCUT ${_RESET}"

    # output paths's
    returnResult
}

returnResult() {
    # split imported TA Number
    sapSystem=${_TRANSPORT_NUMBER::3}
    transportNumber=${_TRANSPORT_NUMBER:4:6}

    # build corresponding TA Strings
    formattedTransport=$_TRANSPORT_SHORTCUT$transportNumber"."$sapSystem

    if [ $_TRANSPORT_SHORTCUT == "R" ]; then
      skipRow=1
    elif [ $_TRANSPORT_SHORTCUT == "K" ]; then
      skipRow=2
    else
      skipRow=9999
    fi

    #loop through prp entrys in corresponding order
    if [ $_REVERSE_OUTPUT == "True" ]; then
      for (( counter=$_ARRAY_ROWS; counter >= 1; counter--)) do
          if [[ $counter -eq $skipRow ]]; then continue; fi
          echo "  "${pathArray[$counter,$_OUTPUT_ENTRY]}$formattedTransport
      done
    else
      for (( counter=1; counter <= $_ARRAY_ROWS; counter++)) do
          if [[ $counter -eq $skipRow ]]; then continue; fi
          echo "  "${pathArray[$counter,$_OUTPUT_ENTRY]}$formattedTransport
      done
    fi

    echo -e ""
}

pathArrayDebug() {
    echo
    f1="%$((${#num_rows}+1))s"
    f2=" %9s"

    printf "$f1" ''
    for ((i=1;i<=num_rows;i++)) do
        printf "$f2" $i
    done

    echo
    for ((j=1;j<=$_ARRAY_COLUMNS;j++)) do
        printf "$f1" $j
        for ((i=1;i<=$_ARRAY_ROWS;i++)) do
            printf "$f2" ${pathArray[$i,$j]}
        done
        echo
    done
}


getTransportPath() {
    PS3="SAP System wählen: "
    select option in "${optionsArray[@]}"; do
        for item in "${optionsArray[@]}"; do
            if [[ $item  == $option ]]; then
                _SELECTED_ENTRY=$(( $REPLY + $_PRP_ENTRY ))
                break 2
            fi
        done
    done

    echo ""
    echo -e "${_BLUE}Displaying Transport Paths for ${_BOLD}$_TRANSPORT_NUMBER${_RESET}"
    
    echo -e ""
    echo -e "${_YELLOW}Local System: ${_BOLD}PRP${_RESET}"
    _OUTPUT_ENTRY=$_PRP_ENTRY
    _REVERSE_OUTPUT="false"
    returnResults

    echo ""
    echo -e "${_YELLOW}Target System: ${_BOLD}$option${_RESET}"
    _OUTPUT_ENTRY=$_SELECTED_ENTRY
    _REVERSE_OUTPUT="True"
    returnResults

}

checkAndDocumentTransports() {
    logTransports.sh -c
    returnValue=$?

    if [ $returnValue == 0 ]; then
        echo ""
        while true
        do
            read -e -p "Document Previous Transport [Y/n]: " input
            echo ""

            case $input in
                [yY][eE][sS]|[yY])
                    logTransports.sh -s
                    echo -e "${_YELLOW}${_BOLD}Finished Sub-Script ${_RESET} \n" 1>&2
                    break
                    ;;
                [nN][oO]|[nN])
                    echo -e "${_BLUE}${_BOLD}Continuing without Sub-Script ${_RESET} \n" 1>&2
                    break
                    ;;
                *)
                    echo -e "${_RED}${_BOLD}Invalid input... ${_RESET} \n" 1>&2
                    ;;
            esac
        done
    fi
}

while getopts ":hg:ad" opt; do
	case ${opt} in
		h )
			echo -e "${_CYAN}${_BOLD}Listing Help: ${_RESET}"
			echo -e " ${_WHITE}${_BOLD}-g: ${_RESET} get Transport Paths"
			echo -e " ${_WHITE}${_BOLD}-a: ${_RESET} add new Transport Path"
			echo -e " ${_WHITE}${_BOLD}-d: ${_RESET} delete a Transport Path"
            exit 1
            ;;
		g )
            checkAndDocumentTransports

            transportNumbers+=("$OPTARG");;
		a )
			echo -e "${_YELLOW}${_BOLD}Option is not Implemented${_RESET} \n" 1>&2
			;;
		d )
			echo -e "${_YELLOW}${_BOLD}Option is not Implemented${_RESET} \n" 1>&2
			;;
		\? )
			echo -e "${_RED}${_BOLD}Invalid Option: ${_RESET} $OPTARG \n" 1>&2
			exit 1
			;;
		: )
			echo -e "${_RED}${_BOLD}Invalid: Option -$OPTARG${_RESET} requires an argument \n" 1>&2
			exit 1
	esac
done
shift $((OPTIND -1))

for transportNumber in "${transportNumbers[@]}"; do
    _TRANSPORT_NUMBER=$transportNumber
    getTransportPath
    echo ""
done

