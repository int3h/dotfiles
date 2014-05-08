#!/usr/bin/env bash

# Takes in a submodule path as an argument, and sets $SUBMOD_REV to the hash of the currently
# checked out revision of that submodule.
function getRev {
    SUBMOD_REV="$(git submodule status $1 | grep -o -P '^[ +-]\K[0-9a-f]+')"
}

function printHeader {
    printf "\n\e[1m\e[48;5;17m\e[38;5;256m\n=== $1\e[0m\n\n"
}


pushd `git rev-parse --show-toplevel` > /dev/null


printHeader "Updating submodule URLs to match .gitconfig"
git submodule sync

printHeader "Checking out submodules to recorded commit"
# This will make sure each submodule is initialized and checkout the commit currently recorded in
# our repo.
git submodule update --recursive --init

# Save the current YCM revision (before updating) so we can later tell if it was updated
getRev "home/.janus/YouCompleteMe/"
OLD_YCM_REV="$SUBMOD_REV"

printHeader "Pulling latest commit of each submodule"
# Updates each submodule to the latest version
# The 'git pull' could cause a submodule's submodules to need to be updated. Do it with the foreach 
# so that we only update the 2nd-level submodules, and don't accidentally revert our top-level 
# submodules back to their recorded commit (undoing the `git pull` here.)
git submodule foreach 'git pull origin master; git submodule update --recursive --init'

getRev "home/.janus/YouCompleteMe"
NEW_YCM_REV="$SUBMOD_REV"

# Only if we've updated YCM, rebuild it
if [ $OLD_YCM_REV != $NEW_YCM_REV ]; then
	printHeader "Rebuilding YouCompleteMe"
	cd home/.janus/YouCompleteMe
	./install.sh --clang-completer
fi

printHeader "User Messages"

printf 'Janus Vim modules have been updated. Do a `git commit` on your Homesick castle\n'
printf 'to record the updates.\n'

printf "\n\e[1m\e[48;5;0m\e[38;5;160mWARNING:\e[0m "
printf 'Running this script again without commiting updates to git may\n'
printf 'cause undefined behavior, including unnecessary updates, or update reversion.\n\n'
