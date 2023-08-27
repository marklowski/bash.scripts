#!/bin/bash

_CONFIG_OVERVIEW="$HOME/repositories/overview.json"

splitRepositoryAtDot() {
  local inputString="$1"
  local outputArray=()

  parts=($(echo "$inputString" | tr '.' ' '))

  if [ "${#parts[@]}" -le 2 ]; then
      return 1
  fi

  echo "${parts[@]}"
}

updateJsonRepository() {
    local group="$1"
    local repository="$2"

    # Check if required arguments are provided
    if [[ -z "$group" || -z "$repository" ]]; then
        echo -e "${_FG_RED}Error${_TX_RESET}: Missing arguments."
        exit 1
    fi

    # Check if overview.json exists
    if [[ ! -f "$_CONFIG_OVERVIEW" ]]; then
        echo -e "${_FG_BLUE}INFO:${_TX_RESET} Overview.json not found. Continuing with normal procedure."
        return 0
    fi

    # Update properties for specific object if found
    updated_json=$(jq \
      --arg group "$group" \
      --arg repository "$repository" \
      --arg changeDate "$(date +"%Y-%m-%d")" \
      --arg changeTime "$(date +"%H:%M:%S")" \
      '
        if (.repositories | any(.group == $group and .repository == $repository)) then
            .repositories |= map(
                if .group == $group and .repository == $repository then
                    .changeDate = $changeDate
                    | .changeTime = $changeTime
                    | .systems |= map(
                        . + { "hasChanges": true }
                    )
                    else .
                end
            )
            else .
        end' "$_CONFIG_OVERVIEW")

    if [[ $? != 0 ]]; then
        echo -e "${_FG_RED}Error${_TX_RESET}: Failed to update overview.json."
        exit 1
    fi

    if [[ "$updated_json" != "$(cat "$_CONFIG_OVERVIEW")" ]]; then
        echo "$updated_json" > "$_CONFIG_OVERVIEW"  # Update the overview.json file
        echo -e "${_FG_GREEN}Success${_TX_RESET}: Updated existing Repository Object."
        exit 2
    else
        return 0
    fi
}

main () {
  groupIndex=0
  repositoryIndex=1
  currentDirectory=${PWD##*/}
  currentUser=$USER

  splitRepositoryAtDot "$currentDirectory"

  if [[ $? != 0 ]]; then
    echo -e "${_FG_YELLOW}Warning${_TX_RESET}: Skipped the following Entry ${_FG_BLUE}'$repository'${_TX_RESET}!"
    continue
  fi

  updateJsonRepository "${repositoryParts[$groupIndex]}" "${repositoryParts[$repositoryIndex]}"
}

main 
