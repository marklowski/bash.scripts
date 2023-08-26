#!/bin/bash

## Requires: 'JQ' Package to Function correctly
_CONFIG_SYSTEMS_FILE="$HOME/.config/script-settings/systems.json"
_CONFIG_OVERVIEW="$HOME/repositories/overview.json"

replaceSpacesWithLinebreaks() {
    local input_string="$1"

    if [[ -n "$input_string" ]]; then
        local result_string=$(echo "$input_string" | sed 's/\x20/\n/g')
    else
        echo "Error: Input string is empty."
        return 1
    fi

    echo "$result_string"
}

populateArrayWithDirectories() {
  local directories="$1"
  local output_array=()
  
  mapfile -t -d $'\n' output_array <<< "$directories"
  
  echo "${output_array[@]}"
}

splitAtFirstDot() {
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

main () {
  listOfRepositories="$(ls $_CONFIG_OVERVIEW)"
  repositories=$(replaceSpacesWithLinebreaks "$listOfRepositories")
  directories=($(populateArrayWithDirectories "$repositories"))

  for item in "${directories[@]}"; do
  done
  #categories=($(splitAtFirstDot "${directories[@]}"))
}

main
