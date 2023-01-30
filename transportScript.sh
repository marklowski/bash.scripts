#!/bin/bash
# Build Transport Script Path

#
# Include's
#
_CONFIG_FILE_OPTIONS="$HOME/.config/script-settings/transportScriptOptions.cfg"
_CONFIG_FILE_PATH="$HOME/.config/script-settings/transportScriptPath.cfg"
source $BASH_COLOR_INCL
source $BASH_ICON_INCL/incl.Icons.transportScript

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
    echo -e "${_FG_CYAN}${i_mdi_truck} Transports: $_TRANSPORT_SHORTCUT ${_TX_RESET}"

    # output paths's
    returnResult

    # set data options
    _TRANSPORT_SHORTCUT="R"

    # output data header
    echo -e "${_FG_CYAN}${i_mdi_truck} Transports: $_TRANSPORT_SHORTCUT ${_TX_RESET}"

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
    PS3="${_FG_BLUE}SAP System${_TX_RESET} wählen: "
    select option in "${optionsArray[@]}"; do
        for item in "${optionsArray[@]}"; do
            if [[ $item  == $option ]]; then
                _SELECTED_ENTRY=$(( $REPLY + $_PRP_ENTRY ))
                break 2
            fi
        done
    done

    echo ""
    echo -e "Displaying Transport Paths for ${_FG_BLUE}$_TRANSPORT_NUMBER${_TX_RESET}"

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

addNewConfig() {
    identifier="$1"
    cofilesPath="$2"
    dataPath="$3"
    localPath="$4"

  # Add Identifier
  echo "$identifier" >> $_CONFIG_FILE_OPTIONS

  # Add Path's
  echo "_${identifier}_COFILES;${cofilesPath};" >> $_CONFIG_FILE_PATH
  echo "_${identifier}_DATA;${dataPath};"    >> $_CONFIG_FILE_PATH
  echo "_${identifier}_LOCAL;${localPath};"   >> $_CONFIG_FILE_PATH
}

confirmConfigInput() {
    identifier="$1"
    cofilesPath="$2"
    dataPath="$3"
    localPath="$4"

    echo -e "${_FG_WHITE}Identifier:${_TX_RESET} $identifier"
    echo -e "${_SPACE_2}${_FG_BLUE}cofiles path:${_TX_RESET} $cofilesPath"
    echo -e "${_SPACE_2}${_FG_BLUE}data path:${_TX_RESET} $dataPath"
    echo -e "${_SPACE_2}${_FG_BLUE}local path:${_TX_RESET} $localPath"

    echo ""
    while true; do
        read -e -p "Are the inputs correct[Y/n/R]: " input
        echo ""

        case $input in
            [yY][eE][sS]|[yY])
                addNewConfig "$identifier" "$cofilesPath" "$dataPath" "$localPath"
                echo -e "${_FG_GREEN}Success ${i_mdi_check}:${_TX_RESET} Config '$identifier' was added.\n" 1>&2
                break
                ;;
            [nN][oO]|[nN])
                echo -e "${_FG_BLUE}${i_mdi_information_variant} INFO:${_TX_RESET} Aborting Script...\n" 1>&2
                break
                ;;
            [rR][eE][tT][rR][yY]|[rR]) handleConfig;;
            *)
                echo -e "${_FG_RED}Invalid input... ${_TX_RESET} \n" 1>&2
                echo -e "${_FG_WHITE}Y - Yes${_TX_RESET}"
                echo -e "${_FG_WHITE}N - No${_TX_RESET}"
                echo -e "${_FG_WHITE}R - Retry${_TX_RESET}"
                ;;
        esac
    done
}

handleConfig() {
    checkIdentifier=false

    if [[ ${#optionsArray[@]} != 0 ]]; then
        echo -e "${_FG_BLUE}${i_mdi_information_variant} INFO:${_TX_RESET} The following Identifier's are already used:"
        for item in "${optionsArray[@]}"; do
            echo "- $item"
        done

        echo ""
        checkIdentifier=true
    else
        echo -e "${_FG_BLUE}${i_mdi_information_variant} INFO:${_TX_RESET} No Identifiers were found"
    fi

    read -e -p "Enter a unique System Identifier (e.g. '${_FG_YELLOW}sap1${_TX_RESET}'): " identifier

    identifier=${identifier^^}

    if $checkIdentifier; then
        for item in "${optionsArray[@]}"; do
            if [[ $item  == $identifier ]]; then
                echo -e "${_FG_RED}Error:${_TX_RESET} Identifier '$identifier' already used."
                exit 1
            fi
        done
    fi

    echo -e "${_FG_BLUE}${i_mdi_information_variant} INFO:${_TX_RESET} With the help of TCODE 'AL11', you can find the corresponding path's."

  # adds '/' when not found, at last position.
  read -e -p "Enter the ${_FG_BLUE}cofiles${_TX_RESET} directory: " cofilesPath
  [[ "$cofilesPath" != */ ]] && cofilesPath+="/"

  read -e -p "Enter the ${_FG_BLUE}data${_TX_RESET} directory: " dataPath
  [[ "$dataPath" != */ ]] && dataPath+="/"
  read -e -p "Enter the ${_FG_BLUE}local${_TX_RESET} directory(default: 'C:/TEMP/TA/'): " localPath
  [[ "$localPath" != */ ]] && localPath+="/"

  if [[ $localPath == "" || $localPath == "/" ]]; then
      localPath="C:/TEMP/TA/"
      echo "$localPath"
  fi

  confirmConfigInput "$identifier" "$cofilesPath" "$dataPath" "$localPath"
}

deleteConfig() {
    identifier=""

    PS3="${_FG_BLUE}Config${_TX_RESET} wählen: "
    select option in "${optionsArray[@]}"; do
        for item in "${optionsArray[@]}"; do
            if [[ $item  == $option ]]; then
                identifier=$item
                break 2
            fi
        done
    done

    read -e -p "Delete the following Config '${_FG_YELLOW}$identifier${_TX_RESET}' [Y/n]:" input

    if [[ "$input" == "Y" || "$input" == "y" ]]; then
        sed -i "/${identifier}/d" $_CONFIG_FILE_OPTIONS
        sed -i "/_${identifier}_/d" $_CONFIG_FILE_PATH
        echo -e "${_FG_GREEN}Success:${_TX_RESET} Config '$identifier' was deleted."
    else
        echo -e "${_FG_RED}${i_mdi_information_variant} INFO:${_TX_RESET} Config delete for '$identifier' was aborted."
    fi
}

#
# output script description.
#
printHelp() {
    echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
    echo -e "${_SPACE_2}${_FG_WHITE}-g: ${_TX_RESET} get Transport Paths"
    echo -e "${_SPACE_4}${_FG_YELLOW}args${_TX_RESET} - Transport Number (e.g. DRPK902330)"
    echo -e "${_SPACE_2}${_FG_WHITE}-a: ${_TX_RESET} add new Transport Path"
    echo -e "${_SPACE_2}${_FG_WHITE}-d: ${_TX_RESET} delete a Transport Path"
    echo ""
    echo -e "${_FG_CYAN}Additional Information: ${_TX_RESET}"
    echo -e "${_SPACE_2}Option -g can be passed multiple times."
}

#
# handle script options.
#
while getopts ":hg:ad" opt; do
    case ${opt} in
        g  ) checkAndDocumentTransports; transportNumbers+=("$OPTARG") ;;
        a  ) handleConfig ;;
        d  ) deleteConfig ;;
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
    ( getTransportPath ) | more
    echo ""
done

exit $PIPESTATUS
