#! /usr/bin/bash
# Check if current branch is ahead/behind

#
# Include's
#
source $BASH_COLOR_INCL
source $BASH_ICON_INCL/incl.Icons.checkCommit

gitRemote=$1
gitBranch=$( git branch --show-current )

localBranch="$gitBranch"
remoteBranch="$gitRemote/$gitBranch"

base=$( git merge-base $localBranch $remoteBranch )
localRef=$( git rev-parse $localBranch )
remoteRef=$( git rev-parse $remoteBranch )

echo -e "Checked Git Remote '${_FG_BLUE}$gitRemote${_TX_RESET}' with Branch '${_FG_BLUE}$gitBranch${_TX_RESET}'"

if [[ "$localRef" == "$remoteRef" ]]; then
    echo -e "${_FG_BLUE}up-to-date ${i_mdi_check}${_TX_RESET}"
elif [[ "$localRef" == "$base" ]]; then
    echo -e "${_FG_YELLOW}behind ${i_oct_repo_pull}${_TX_RESET}"
elif [[ "$remoteRef" == "$base" ]]; then
    echo -e "${_FG_MAGENTA}ahead ${i_oct_repo_push}${_TX_RESET}"
else
    echo -e "${_FG_CYAN}diverged ${i_dev_git_compare}${_TX_RESET}"
fi
