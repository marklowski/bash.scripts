#!/bin/bash
# Create git repo if not existent

# Global Variables
_NEW_REPOSITORY=$1

_REPOSITORY_PREFIX=""
_REPOSITORY_NAME=""

_DIRECTORY_PREFIX="/mnt/hdd/repositories/"
_DIRECTORY_PATH=""

_SYMLINK_PREFIX="$HOME/repositories/"
_SYMLINK_PATH=""

_GIT_SUFFIX='.git'

_REPOSITORY=$1
_POST_RECEIVE_HOOK="$HOME/post-receive"

# Split imported String into Folder/Repository
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

# remove whitespaces and set directory path
[[ "$_REPOSITORY_NAME" == *"$_GIT_SUFFIX"* ]] || 
    _REPOSITORY_NAME="$(echo -e "$_REPOSITORY_NAME$_GIT_SUFFIX" | tr -d '[:space:]')" &&
    _DIRECTORY_PATH="$_DIRECTORY_PREFIX$_REPOSITORY_PREFIX/$_REPOSITORY_NAME"

# remove whitespaces and symlink path
[[ "$_NEW_REPOSITORY" == *"$_GIT_SUFFIX"* ]] ||
    _NEW_REPOSITORY="$(echo -e "$_NEW_REPOSITORY$_GIT_SUFFIX" | tr -d '[:space:]')" &&
    _SYMLINK_PATH="$_SYMLINK_PREFIX$_NEW_REPOSITORY"

# check if Repository exists already
[[ ! -d "$_DIRECTORY_PATH" ]] && 
    echo $_DIRECTORY_PATH > $HOME/manageNewProjects.txt && 
    mkdir -p "$_DIRECTORY_PATH" &&
    cd $_DIRECTORY_PATH && 
    git init --bare && 
    cp $_POST_RECEIVE_HOOK ./hooks &&
    ln -s $_DIRECTORY_PATH $_SYMLINK_PATH ||
    echo 'Git Repository already exists'
