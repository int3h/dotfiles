#!/usr/bin/env bash

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	printf 'Usage: %s [install]\n\n' "$(basename "$0")"
	printf 'Install and/or update Vim Janus plugin submodules.\n\n'
	printf 'Options:\n'
	printf "  install     don't update submodules to latest version; install as-is\n\n"
	exit 0
fi

install_only=
if [[ $1 == "install" ]]; then
	install_only=1
fi

# Takes in a submodule path as an argument, and sets $SUBMOD_REV to the hash of the currently
# checked out revision of that submodule (if any.)
function getRev {
	# The submodule isn't checked out if its .git file doesn't exist, so return '0' in that case
	if [[ -f "${1}/.git" ]]; then
		SUBMOD_REV="$(git submodule status $1 | grep -o -P '^[ +-]\K[0-9a-f]+')"
	else
		SUBMOD_REV="0"
	fi
}

function printHeader {
    printf "\n\e[1m\e[48;5;17m\e[38;5;256m\n=== $1\e[0m\n\n"
}


pushd `git rev-parse --show-toplevel` > /dev/null

if [[ $(git status -s .gitmodules) ]]; then
	printf 'ERROR: Your .gitmodules file has uncommitted changes. This prevents us from\n' >&2
	printf 'recording the changes from pulling the latest revision of the submodules. Please\n' >&2
	printf 'commit or revert your changes to this file (listed as changes to the submodules.)\n\n' >&2
	exit 1
fi

# So that we can later cleanly commit the changes this script makes (and only those changes)
git stash -q

printHeader "Updating submodule URLs to match .gitconfig"
git submodule sync

printHeader "Checking out submodules to recorded commit"
# This will make sure each submodule is initialized and checkout the commit currently recorded in
# our repo.
git submodule update --recursive --init

# Save the current YCM revision (before updating) so we can later tell if it was updated

getRev "home/.janus/YouCompleteMe/"
OLD_YCM_REV="$SUBMOD_REV"

if [[ $install_only != 1 ]]; then
	printHeader "Pulling latest commit of each submodule"
	# Updates each submodule to the latest version
	# The 'git pull' could cause a submodule's submodules to need to be updated. Do it with the foreach
	# so that we only update the 2nd-level submodules, and don't accidentally revert our top-level
	# submodules back to their recorded commit (undoing the `git pull` here.)
	git submodule foreach 'git pull origin master; git submodule update --recursive --init'


	printHeader "Committing updates to git repo"
	git add -u
	git commit -m "Vim: update plugins in ~/.janus to latest versions"
fi

# Re-apply the user's existing changes (stashed at the beginning of this script)
git stash pop -q


getRev "home/.janus/YouCompleteMe"
NEW_YCM_REV="$SUBMOD_REV"

# Only if we've updated YCM, rebuild it
if [[ "$OLD_YCM_REV" != "$NEW_YCM_REV" ]]; then
	printHeader "Rebuilding YouCompleteMe"
	pushd home/.janus/YouCompleteMe >/dev/null
	# On Linux, don't install clang completer (may not have the libs available)
	if [[ $OS == "Linux" ]]; then
		./install.sh
	else
		./install.sh --clang-completer
	fi
	popd >/dev/null
fi

printHeader "Installing tern_for_vim npm dependencies"
pushd home/.janus/tern_for_vim >/dev/null
npm install
popd >/dev/null


popd >/dev/null
