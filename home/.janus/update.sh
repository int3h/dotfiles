#!/usr/bin/env bash

# Takes in a submodule path as an argument, and sets $SUBMOD_REV to the hash of the currently
# checked out revision of that submodule.
function getRev {
    SUBMOD_REV="$(git submodule status $1 | grep -o -P '^[ +-]\K[0-9a-f]+')"
}

function printHeader {
    printf "\n\e[1m\e[48;5;17m\e[38;5;256m\n### $1\e[0m\n\n"
}


pushd `git rev-parse --show-toplevel` > /dev/null

printHeader "Updating submodule URLs to match .gitconfig"
git submodule sync

printHeader "Checking out submodules to recorded commit"
git submodule update --recursive --init

getRev "home/.janus/YouCompleteMe/"
OLD_YCM_REV="$SUBMOD_REV"

printHeader "Pulling latest commit of each submodule"
git submodule foreach git pull origin master

getRev "home/.janus/YouCompleteMe"
NEW_YCM_REV="$SUBMOD_REV"

# Only if we've updated YCM, rebuild it
if [ $OLD_YCM_REV != $NEW_YCM_REV ]; then
    printHeader "Rebuilding YouCompleteMe"
    cd home/.janus/YouCompleteMe
    ./install.sh --clang-completer
fi
