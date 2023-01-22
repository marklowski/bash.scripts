#!/bin/bash
# Build Transport Script Path

#
# Include's
#
_CONFIG_FILE_OPTIONS="$HOME/.config/script-settings/transportScriptOptions.cfg"
_CONFIG_FILE_PATH="$HOME/.config/script-settings/transportScriptPath.cfg"
source $BASH_COLOR_INCL

#
# Global Variables
#
_TRANSPORT_NUMBER="DRPK902330"
_TRANSPORT_SHORTCUT="" # possible values "K" or "R"

_ARRAY_ROWS=3
_ARRAY_COLUMNS=0

_PRP_ENTRY=1
_SELECTED_ENTRY=0
_OUTPUT_ENTRY=0
_REVERSE_OUTPUT='False'

# read User Configurable Options & add exit option
mapfile -t optionsArray < $_CONFIG_FILE_OPTIONS
_ARRAY_COLUMNS=$(( ${#optionsArray[@]} + $_PRP_ENTRY ))

# source Possible PATH Settings
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

#
# return the corresponding results.
#
returnResults() {
    # set cofiles options
    _TRANSPORT_SHORTCUT="K"

    # output cofiles header
    echo -e "${_FG_CYAN}Transports:  $_TRANSPORT_SHORTCUT ${_TX_RESET}"

    # output paths's
    returnResult

    # set data options
    _TRANSPORT_SHORTCUT="R"

    # output data header
    echo -e "${_FG_CYAN}Transports:  $_TRANSPORT_SHORTCUT ${_TX_RESET}"

    # output paths's
    returnResult
}

#
# return the results for one option.
#
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
          echo ${pathArray[$counter,$_OUTPUT_ENTRY]}$formattedTransport
      done
    else
      for (( counter=1; counter <= $_ARRAY_ROWS; counter++)) do
          if [[ $counter -eq $skipRow ]]; then continue; fi
          echo ${pathArray[$counter,$_OUTPUT_ENTRY]}$formattedTransport
      done
    fi

    echo -e ""
}

#
# get the corresponding transport path from config, according to user input.
#
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
    echo -e "${_FG_BLUE}Displaying Transport Paths for $_TRANSPORT_NUMBER${_TX_RESET}"
    
    echo -e ""
    echo -e "${_FG_YELLOW}Local System: PRP${_TX_RESET}"
    _OUTPUT_ENTRY=$_PRP_ENTRY
    _REVERSE_OUTPUT="false"
    returnResults

    echo ""
    echo -e "${_FG_YELLOW}Target System: $option${_TX_RESET}"
    _OUTPUT_ENTRY=$_SELECTED_ENTRY
    _REVERSE_OUTPUT="True"
    returnResults

}

#
# check if there are undocumented transport files available,
# and execute accordingly.
#
checkAndDocumentTransports() {
    logTransports.sh -c
    returnValue=$?

    if [ $returnValue == 0 ]; then
        echo ""
        while true; do
            read -e -p "Document Previous Transport [Y/n]: " input
            echo ""

            case $input in
                [yY][eE][sS]|[yY])
                    logTransports.sh -s
                    echo -e "${_FG_YELLOW}Finished Sub-Script ${_TX_RESET} \n" 1>&2
                    break
                    ;;
                [nN][oO]|[nN])
                    echo -e "${_FG_BLUE}Continuing without Sub-Script ${_TX_RESET} \n" 1>&2
                    break
                    ;;
                *)
                    echo -e "${_FG_RED}Invalid input... ${_TX_RESET} \n" 1>&2
                    ;;
            esac
        done
    fi
}

#
# output script description.
#
printHelp() {
  echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
  echo -e "${_SPACE_2}${_FG_WHITE}-g: ${_TX_RESET} get Transport Paths"
  echo -e "${_SPACE_4}${_FG_YELLOW}args${_TX_RESET} - Transport Number (e.g. DRPK902330)"
  echo -e "${_SPACE_2}${_FG_RED}-a: ${_TX_RESET} add new Transport Path"
  echo -e "${_SPACE_2}${_FG_RED}-d: ${_TX_RESET} delete a Transport Path"
  echo ""
  echo -e "${_FG_CYAN}Additional Information: ${_TX_RESET}"
  echo -e "${_SPACE_2}Option -g can be passed multiple times."
}

#
# handle script options.
#
while getopts ":hg:ad" opt; do
  case ${opt} in
    g ) checkAndDocumentTransports; transportNumbers+=("$OPTARG") ;;
    a ) echo -e "${_FG_YELLOW}Option is not Implemented${_TX_RESET} \n" 1>&2 ;;
    d ) echo -e "${_FG_YELLOW}Option is not Implemented${_TX_RESET} \n" 1>&2 ;;
    h  ) printHelp exit 1;;
    \? ) echo -e "${_FG_YELLOW}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    :  ) echo -e "${_FG_YELLOW}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
    *  ) echo -e "${_FG_RED}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1)); then printHelp; fi
shift $((OPTIND -1))

for transportNumber in "${transportNumbers[@]}"; do
    _TRANSPORT_NUMBER=$transportNumber
    getTransportPath
    echo ""
done

