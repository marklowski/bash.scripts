#!/bin/bash

## Requires: 'JQ' Package to Function correctly
_CONFIG_SYSTEMS_FILE="$HOME/.config/script-settings/systems.json"
_CONFIG_OVERVIEW="$HOME/repositories/overview.json"
_REPOSITORY_PATH="~/repositories"

replaceSpacesWithLinebreaks() {
    local inputString="$1"

    if [[ -n "$inputString" ]]; then
        local resultString=$(echo "$inputString" | sed 's/\x20/\n/g')
    else
        echo "Error: Input string is empty."
        return 1
    fi

    echo "$resultString"
}

populateArrayWithRepositories() {
  local directories="$1"
  local outputArray=()
  
  mapfile -t -d $'\n' outputArray <<< "$directories"
  
  echo "${outputArray[@]}"
}

splitRepositoryAtDot() {
  local inputString="$1"
  local outputArray=()

  parts=($(echo "$inputString" | tr '.' ' '))

  if [ "${#parts[@]}" -le 2 ]; then
      return 1
  fi

  echo "${parts[@]}"
}

## build Json Object for Repository Overview
buildJsonRepository() {
    local group="$1"
    local repository="$2"
    local systems=$(jq -c '.systems' "$_CONFIG_SYSTEMS_FILE")

    # Create the JSON object
    jsonRepository=$(jq -n \
        --arg group "$group" \
        --arg repository "$repository" \
        --arg repositoryPath "$_SYMLINK_PREFIX.$group.$repository.git" \
        --arg creationDate "$(date +"%Y-%m-%d")" \
        --arg creationTime "$(date +"%H:%M:%S")" \
        --arg changeDate "" \
        --arg changeTime "" \
        --argjson systems "$systems" \
        '{
            "group": $group,
            "repository": $repository,
            "repositoryPath": $repositoryPath,
            "creationDate": $creationDate,
            "creationTime": $creationTime,
            "changeDate": $changeDate,
            "changeTime": $changeTime,
            "systems": $systems
          }')

    if [[ $? != 0 ]]; then
        echo "Error: Failed to create JSON object."
        exit 1
    fi

    echo "$jsonRepository"  # Return the JSON object
}

## add Json Object to Repository Overview
addJsonRepository() {
    local json_object="$1"

    # Check if required argument is provided
    if [[ -z "$json_object" ]]; then
        echo "Error: Missing JSON object."
        exit 1
    fi

    # Update properties for date and time
    updated_json=$(jq --arg changeDate "$(date +"%Y-%m-%d")" \
                       --arg changeTime "$(date +"%H:%M:%S")" \
                       '.changeDate = $changeDate | .changeTime = $changeTime | .repositories += [$json_object]' \
                       --argjson json_object "$json_object" "$_CONFIG_OVERVIEW")

    if [[ $? != 0 ]]; then
        echo "Error: Failed to update overview.json."
        exit 1
    fi

    echo "$updated_json" > "$_CONFIG_OVERVIEW"  # Update the overview.json file
}

main () {
  groupIndex=1
  repositoryIndex=2

  # source ~/.config/script-settings/sshData.cfg
  # listOfRepositories="$(ssh $_RASPI_SSH "ls $_REPOSITORY_PATH")"
  listOfRepositories="$(ls $_REPOSITORY_PATH)"

  repositories=$(replaceSpacesWithLinebreaks "$listOfRepositories")
  repositoriesArray=($(populateArrayWithRepositories "$repositories"))

  # Clear Overview File
  echo "" > $_CONFIG_OVERVIEW

  for repository in "${repositoriesArray[@]}"; do
    repositoryParts=($(splitRepositoryAtDot "$repository"))

    if [[ $? != 0 ]]; then
      echo "Warning: Skipped the following Entry '$repository'!"
      continue
    fi

    jsonRepository=$(buildJsonRepository "${repositoryParts[$groupIndex]}" "${repositoryParts[$repositoryIndex]}")
    addJsonRepository "$jsonRepository"

    echo "Success: Added the following Entry '$repository'!"
  done
}

main
