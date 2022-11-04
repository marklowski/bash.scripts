#!/bin/bash
# Build Transport Script Path

# Color Include
source $BASH_COLOR_INCL

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
    echo -e "${_FG_CYAN} Transports:  ${_TX_BOLD}$_TRANSPORT_SHORTCUT ${_TX_RESET}"

    # output paths's
    returnResult

    # set data options
    _TRANSPORT_SHORTCUT="R"

    # output data header
    echo -e "${_FG_CYAN} Transports:  ${_TX_BOLD}$_TRANSPORT_SHORTCUT ${_TX_RESET}"

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
    echo -e "${_FG_BLUE}Displaying Transport Paths for ${_TX_BOLD}$_TRANSPORT_NUMBER${_TX_RESET}"
    
    echo -e ""
    echo -e "${_FG_YELLOW}Local System: ${_TX_BOLD}PRP${_TX_RESET}"
    _OUTPUT_ENTRY=$_PRP_ENTRY
    _REVERSE_OUTPUT="false"
    returnResults

    echo ""
    echo -e "${_FG_YELLOW}Target System: ${_TX_BOLD}$option${_TX_RESET}"
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
                    echo -e "${_FG_YELLOW}${_TX_BOLD}Finished Sub-Script ${_TX_RESET} \n" 1>&2
                    break
                    ;;
                [nN][oO]|[nN])
                    echo -e "${_FG_BLUE}${_TX_BOLD}Continuing without Sub-Script ${_TX_RESET} \n" 1>&2
                    break
                    ;;
                *)
                    echo -e "${_FG_RED}${_TX_BOLD}Invalid input... ${_TX_RESET} \n" 1>&2
                    ;;
            esac
        done
    fi
}

while getopts ":hg:ad" opt; do
	case ${opt} in
		h )
			echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
			echo -e " ${_FG_WHITE}${_TX_BOLD}-g: ${_TX_RESET} get Transport Paths"
			echo -e " ${_FG_WHITE}${_TX_BOLD}-a: ${_TX_RESET} add new Transport Path"
			echo -e " ${_FG_WHITE}${_TX_BOLD}-d: ${_TX_RESET} delete a Transport Path"
            exit 1
            ;;
		g )
            checkAndDocumentTransports

            transportNumbers+=("$OPTARG");;
		a )
			echo -e "${_FG_YELLOW}${_TX_BOLD}Option is not Implemented${_TX_RESET} \n" 1>&2
			;;
		d )
			echo -e "${_FG_YELLOW}${_TX_BOLD}Option is not Implemented${_TX_RESET} \n" 1>&2
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

for transportNumber in "${transportNumbers[@]}"; do
    _TRANSPORT_NUMBER=$transportNumber
    getTransportPath
    echo ""
done

