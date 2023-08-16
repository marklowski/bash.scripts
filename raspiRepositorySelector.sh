#! /bin/bash

# Color Include
source $BASH_COLOR_INCL

# Source SSH Settings
source ~/.config/script-settings/sshData.cfg

# Get List of Repositories
_LIST_OF_REPOSITORIES="$(ssh $_RASPI_SSH "ls $_RASPI_PATH")"

declare -a _DIRECTORIES

replace_spaces_with_linebreaks() {
    local input_string="$_LIST_OF_REPOSITORIES"

    if [[ -n "$input_string" ]]; then
        local result_string=$(echo "$input_string" | sed 's/\x20/\n/g')
    else
        echo "Error: Input string is empty."
        return 1
    fi

    echo "$result_string"
}

split_at_first_dot() {
  local input_array=("$@")
  local output_array=()

  
  for element in "${input_array[@]}"; do
    if [[ "$element" == *.* ]]; then
      output_array+=("${element%%.*}")
    else
      output_array+=("$element")
    fi
  done

  echo "${output_array[@]}"
}

populate_array_with_directories() {
  local directories="$1"
  local output_array=()
  
  mapfile -t -d $'\n' output_array <<< "$directories"
  
  echo "${output_array[@]}"
}

remove_duplicates() {
  local input_array=("$@")
  local output_array=()

  for element in "${input_array[@]}"; do
    if [[ ! " ${output_array[@]} " =~ " $element " ]]; then
      output_array+=("$element")
    fi
  done

  echo "${output_array[@]}"
}

repositories=$(replace_spaces_with_linebreaks)
directories=($(populate_array_with_directories "$repositories"))
categories=($(split_at_first_dot "${directories[@]}"))
uniqueCategories=($(remove_duplicates "${categories[@]}"))

 echo "---"
 echo "Unique categories"
 for element in "${uniqueCategories[@]}"; do
   echo $element
 done
# echo "---"
# echo "directoryArray"
# for element in "${directoryArray[@]}"; do
#   echo $element
# done
#while getopts ":hcle:r:C:" opt; do
#case ${opt} in
#		h )
#			echo -e "${_FG_CYAN}Listing Help: ${_TX_RESET}"
#			echo -e "${_FG_WHITE}-l: ${_TX_RESET} List Local Changes"
#			echo -e "${_FG_WHITE}-r: ${_TX_RESET} List Remote Changes(Work=W, Home=H)"
#			echo -e "${_FG_WHITE}-c: ${_TX_RESET} Clear Local File"
#			echo -e "${_FG_WHITE}-C: ${_TX_RESET} Clear Remote File (Work=W, Home=H)"
#			echo -e "${_FG_WHITE}-e: ${_TX_RESET} Execute Program\n"
#			exit 1
#			;;
#		c )
#			clearConfig
#			;;
#		l )
#			listConfig
#			;;
#		e )
#			pushProjects
#			remote_opt=$OPTARG
#			clearConfigRemote
#			;;
#		r )
#			remote_opt=$OPTARG
#			listConfigRemote
#			;;
#		C )
#			remote_opt=$OPTARG
#			clearConfigRemote
#			;;
#		\? )
#			echo -e "${_FG_YELLOW}Invalid Option: ${_TX_RESET} $OPTARG" 1>&2
#			exit 1
#			;;
#		: )
#            echo -e "${_FG_YELLOW}Invalid Option: ${_TX_RESET} -$OPTARG requires an argument \n" 1>&2
#            exit 1
#            ;;
#	esac
#done
#shift $((OPTIND -1))
