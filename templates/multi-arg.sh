#!/bin/bash
# TODO: Replace Header Description 

#
# Include's
#
_CONFIG_FILE=$HOME/.config/script-settings/
source $_CONFIG_FILE
source $BASH_COLOR_INCL

#
# Global Variables
#

#
# Functions
#

printHelp() {
  echo -e "${_FG_CYAN}${_TX_BOLD}Listing Help: ${_TX_RESET}"
	echo -e " ${_FG_WHITE}${_TX_BOLD}-g: ${_TX_RESET} get Transport Paths"
}

while getopts ":hg:" opt; do
	case ${opt} in
		g )
      transportNumbers+=("$OPTARG");;
		h  ) printHelp >&2; exit 1;;
		\? ) echo -e "${_FG_YELLOW}${_TX_BOLD}Unknown Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		:  ) echo -e "${_FG_YELLOW}${_TX_BOLD}Missing option argument for ${_TX_RESET} -$OPTARG" >&2; exit 1;;
		*  ) echo -e "${_FG_RED}${_TX_BOLD}Unimplemented Option: ${_TX_RESET} -$OPTARG" >&2; exit 1;;
	esac
done

# Standard Behaviour when, no option was supplied.
if ((OPTIND == 1))
then
echo -e "${_FG_RED}${_TX_BOLD}Error: No Option specified ${_TX_RESET}" >&2;
fi

shift $((OPTIND -1))

# Loop through every Argument
for transportNumber in "${transportNumbers[@]}"; do
    _TRANSPORT_NUMBER=$transportNumber
    getTransportPath
    echo ""
done

