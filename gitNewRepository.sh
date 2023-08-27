#!/bin/bash

## Requires: 'JQ' Package to Function correctly

source $BASH_COLOR_INCL

# Create git repo if not existent
_CONFIG_SYSTEMS_FILE="$HOME/.config/script-settings/systems.json"
_CONFIG_OVERVIEW="$HOME/repositories/overview.json"

# Global Variables
_NEW_REPOSITORY=$1

_REPOSITORY_PREFIX=""
_REPOSITORY_NAME=""

_DIRECTORY_PREFIX="/mnt/hdd/repositories/"
_DIRECTORY_PATH=""

_SYMLINK_PREFIX="$HOME/repositories/"
_SYMLINK_PATH=""

_GIT_SUFFIX='.git'

_POST_RECEIVE_HOOK="$HOME/post-receive"

# Title: Utility Functions
trimWhiteSpaces() {
    local inputVar="$1"
    local trimmedVar
    trimmedVar=$(echo "$inputVar" | tr -d '[:space:]')
    echo "$trimmedVar"
}

addGitSuffix() {
    local inputVar="$1"
    local varWithSuffix
    trimmedVar="$inputVar$_GIT_SUFFIX"
    echo "$trimmedVar"
}

# Title: Sub Functions

##Split imported String into Folder/Repository
splitUserInput() {
    readarray -d . -t repository_array <<< "$_NEW_REPOSITORY"
    for (( counter=0; counter < ${#repository_array[*]}; counter++))
    do
        if [ $counter = 0 ]; then
            _REPOSITORY_PREFIX=$_DIRECTORY_PATH${repository_array[counter]}
        else
            [[ -n $_REPOSITORY_NAME ]] && buffer="$_REPOSITORY_NAME."
            _REPOSITORY_NAME="$buffer${repository_array[counter]}"
        fi
    done
}

## remove whitespaces and set directory path
setDirectoryPath() {
    if [[ "$_REPOSITORY_NAME" == *"$_GIT_SUFFIX"* ]]; then
			echo -e "${_FG_YELLOW}Invalid Repository Name: ${_TX_RESET} Try Again without '.git'"
      exit 1
    fi

    _REPOSITORY_NAME=$(trimWhiteSpaces $_REPOSITORY_NAME)

    repositoryWithSuffix=$(addGitSuffix $_REPOSITORY_NAME)
    _DIRECTORY_PATH="$_DIRECTORY_PREFIX$_REPOSITORY_PREFIX/$repositoryWithSuffix"
}

## remove whitespaces and symlink path
setSymlinkPath() {
    if [[ "$_NEW_REPOSITORY" == *"$_GIT_SUFFIX"* ]]; then
			echo -e "${_FG_YELLOW}Invalid Repository Name: ${_TX_RESET} Try Again without '.git'"
      exit 1
    fi

    _NEW_REPOSITORY=$(trimWhiteSpaces $_NEW_REPOSITORY)

    repositoryWithSuffix=$(addGitSuffix $_NEW_REPOSITORY)
    _SYMLINK_PATH="$_SYMLINK_PREFIX$repositoryWithSuffix"
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

## build Json Object for Repository Overview
buildJsonRepository() {
    local group="$1"
    local repository="$2"
    local systems=$(jq -c '.systems' "$_CONFIG_SYSTEMS_FILE")

    # Create the JSON object
    json_obj=$(jq -n \
        --arg group "$group" \
        --arg repository "$repository" \
        --arg repositoryPath "$_SYMLINK_PREFIX/$group.$repository.git" \
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
        echo -e "${_FG_RED}Error${_TX_RESET}: Failed to create JSON object."
        exit 1
    fi

    echo "$json_obj"  # Return the JSON object
}

## add Json Object to Repository Overview
addJsonRepository() {
    local json_object="$1"

    # Check if required argument is provided
    if [[ -z "$json_object" ]]; then
        echo -e "${_FG_RED}Error${_TX_RESET}: Missing JSON object."
        exit 1
    fi

    # Update properties for date and time
    updated_json=$(jq --arg changeDate "$(date +"%Y-%m-%d")" \
                       --arg changeTime "$(date +"%H:%M:%S")" \
                       '.changeDate = $changeDate | .changeTime = $changeTime | .repositories += [$json_object]' \
                       --argjson json_object "$json_object" "$_CONFIG_OVERVIEW")

    if [[ $? != 0 ]]; then
        echo -e "${_FG_RED}Error${_TX_RESET}: Failed to update overview.json."
        exit 1
    fi

    echo "$updated_json" > "$_CONFIG_OVERVIEW"  # Update the overview.json file
}


# Title: Execution Functions

## handle Repository preparation
prepareRepository() {
    splitUserInput
    setDirectoryPath
    setSymlinkPath
}

## handle JSON Repository creation
handleJsonRepository() {

    # try to update existing Repository Object
    updateJsonRepository "$_REPOSITORY_PREFIX" "$_REPOSITORY_NAME"

    if [[ ! -e $_CONFIG_OVERVIEW ]]; then
        echo `{
            "changeDate": "",
            "changeTime": "",
            "repositories": []
        }` > $_CONFIG_OVERVIEW
    fi

    # no Repository Object was found, build & create New Repository Object
    # Call the addJsonRepository function to add the Repository Object to Overview.json
    jsonRepository=$(buildJsonRepository "$_REPOSITORY_PREFIX" "$_REPOSITORY_NAME")
    addJsonRepository "$jsonRepository"

    echo -e "${_FG_GREEN}Success${_TX_RESET}: Repository Object added to Overview.json."
}

## create Repository Directories
createRepository() {
    if [[ -d "$_DIRECTORY_PATH" ]]; then
			echo -e "${_FG_RED}Error: ${_TX_RESET} Git Repository exists already!"
      exit 1
    fi

    # create directory with possible parents
    mkdir -p "$_DIRECTORY_PATH"
    cd $_DIRECTORY_PATH

    # add git initialization & hooks
    git init --bare
    ln -s $_POST_RECEIVE_HOOK ./hooks

    # add symlink
    ln -s $_DIRECTORY_PATH $_SYMLINK_PATH
}

## main Execution
main() {
    prepareRepository

    createRepository

    handleJsonRepository
}

main
