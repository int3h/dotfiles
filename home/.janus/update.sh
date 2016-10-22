#!/usr/bin/env bash

install_only=

################################################################################
# Helper Functions
################################################################################

# Takes the path to a Git repo as $1, and prints the hash of the HEAD checkout
function getRev {
	git -C "$1" rev-parse HEAD 2>/dev/null || printf '0'
}

function printHeader {
	printf '%b%s==>%s %s%s\n' "$header_prefix" "$(tput bold)$(tput setaf 4)" "$(tput setaf 15)" "$@" "$(tput sgr0)"
	header_prefix="\n"
}

function print_help() {
	printf 'Usage: %s [install]\n\n' "$(basename "$0")"
	printf 'Install and/or update Vim Janus plugin submodules.\n\n'
	printf 'Options:\n'
	printf "  install     don't update submodules to latest version; install as-is\n\n"
}


################################################################################
# Setup
################################################################################

case "$1" in
	"-h" | "--help")
		print_help
		exit 0
		;;
	"install")
		install_only=1
		;;
	"")
		;;
	*)
		printf 'Error: unrecognized option "%s"\n\n' "$1" >&2
		print_help >&2
		exit 1
esac

cd "$(dirname "$0")"
cd "$(git rev-parse --show-toplevel)"

# We stash uncommited changes before doing updates. Since .gitmodules changes affect updates, if we
# stash it, then our updates will not be what the user exepcts.
if [[ $(git status -s .gitmodules) ]]; then
	printf 'ERROR: Unable to update Vim plugins because of uncommited changes in dotfile repo .gitmodules\n' >&2
	printf 'Please commit or revert the pending changes in .gitmodules, and try again.\n' >&2
	exit 1
fi


################################################################################
# Actions
################################################################################

printHeader "Updating Janus core"
(cd "$HOME/.vim/" && rake) || (printf 'Fatal Error: Janus not installed\n\n' && exit 2)

printHeader "Quitting Atom before changing dotfiles"
osascript -e 'if application "/Applications/Atom Beta.app" is running then tell application "/Applications/Atom Beta.app" to quit'

printHeader "Stashing dotfile repo changes while we do updates"
# So that we can later cleanly commit the changes this script makes (and only those changes)
git stash
ycm_version_prev="$(getRev "home/.janus/YouCompleteMe/third_party/ycmd")"

printHeader "Syncing configured submodule URLs to match .gitmodules"
git submodule sync --recursive

# Fetch as a separate step, instead of during `update`, so we can take advantage of `--jobs=n`
printHeader "Fetching submodules"
git fetch --recurse-submodules --jobs=16

if [[ $install_only != 1 ]]; then
	printHeader "Updating submodules to latest versions"
	git submodule update --checkout --force --init --remote --no-fetch

	printHeader "Automatically committing submodule updates"
	git commit --all --message "Vim: update plugins in ~/.janus to latest versions"
fi

printHeader "Checking out submodules and their dependencies"
git submodule update --checkout --force --init --recursive

# Re-apply the user's existing changes (stashed at the beginning of this script)\
printHeader "Unstashing dotfile repo changes"
git stash pop -q

# If YCM's native module hasn't been built yet, or has been updated above, (re-)build it
if ! [[ -e home/.janus/YouCompleteMe/third_party/ycmd/ycm_core.so ]] || \
     [[ "$ycm_version_prev" != "$(getRev "home/.janus/YouCompleteMe/third_party/ycmd")" ]]; then
	printHeader "Rebuilding YouCompleteMe"
	(cd home/.janus/YouCompleteMe && ./install.py --tern-completer --clang-completer)
fi
