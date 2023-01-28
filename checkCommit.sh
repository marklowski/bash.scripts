#! /usr/bin/bash
# Check if current branch is ahead/behind

gitRemote=$1
gitBranch=$( git branch --show-current )

localBranch="$gitBranch"
remoteBranch="$gitRemote/$gitBranch"

base=$( git merge-base $localBranch $remoteBranch )
localRef=$( git rev-parse $localBranch )
remoteRef=$( git rev-parse $remoteBranch )

echo Checked Git Remote $gitRemote with Branch $gitBranch

if [[ "$localRef" == "$remoteRef" ]]; then
    echo up-to-date
elif [[ "$localRef" == "$base" ]]; then
    echo behind
elif [[ "$remoteRef" == "$base" ]]; then
    echo ahead
else
    echo diverged
fi
