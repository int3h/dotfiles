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
    # Only use color if $TERM is set, and not "dumb"
    if [[ -n $TERM ]] && [[ "$TERM" != "dumb" ]]; then
        printf '%b%s==>%s %s%s\n' "$header_prefix" "$(tput bold)$(tput setaf 4)" "$(tput setaf 15)" "$@" "$(tput sgr0)"
    else
        printf '%s==> %s\n' "$header_prefix" "$@"
    fi
	header_prefix="\n"
}

function print_help() {
	printf 'Usage: %s [--no-upgrades]\n\n' "$(basename "$0")"
	printf 'Install and/or update Vim Janus plugin submodules.\n\n'
	printf 'Options:\n'
	printf "  --no-upgrades   Don't upgrade plugins, just install the version specified in the current commit\n\n"
}


################################################################################
# Setup
################################################################################

case "$1" in
	"-h" | "--help")
		print_help
		exit 0
		;;
	"--no-upgrades")
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

ycm_version_prev="$(getRev "home/.janus/YouCompleteMe/third_party/ycmd")"

printHeader "Syncing configured submodule URLs to match .gitmodules"
git submodule sync --recursive

if [[ $install_only -eq 1 ]]; then
    # Fetch as a separate step, instead of during `update`, so we can take advantage of `--jobs=n`
    #printHeader "Fetching submodules"
    #git fetch --recurse-submodules

    printHeader "Checking out submodules and their dependencies"
    git submodule update --checkout --force --init --recursive

else
    if type -t osascript >/dev/null 2>/dev/null; then
        printHeader "Quitting Atom before changing dotfiles"
        osascript -l JavaScript -e 'var Atom = Application("/Applications/Atom Beta.app");' -e 'if(Atom.running()) { Atom.quit(); }'
    fi

    # So that we can later cleanly commit the changes this script makes (and only those changes)
    printHeader "Stashing dotfile repo changes while we do updates"

    # Note the current stash's hash, so we can determine if `git stash save` created a new stash
    prev_stash="$(git rev-parse stash@{0} 2>/dev/null)"
    git stash save '[Vim Updater] Automatically stashed by "~/.janus/update.sh" so that Vim submodules can be updated'
    curr_stash="$(git rev-parse stash@{0} 2>/dev/null)"

	printHeader "Updating submodules to latest versions"
	git submodule update --checkout --force --init --remote

	printHeader "Automatically committing submodule updates"
	git commit --all --message "Vim: update plugins in ~/.janus to latest versions"

    # If our previous `git stash save` stashed changes, unstash them now
    if [[ "$prev_stash" != "$curr_stash" ]]; then
        # Re-apply the user's existing changes (stashed at the beginning of this script)\
        printHeader "Unstashing dotfile repo changes"
        git stash pop --quiet
    fi
fi


# If YCM's native module hasn't been built yet, or has been updated above, (re-)build it
if ! [[ -e home/.janus/YouCompleteMe/third_party/ycmd/ycm_core.so ]] || [[ "$ycm_version_prev" != "$(getRev "home/.janus/YouCompleteMe/third_party/ycmd")" ]]; then
	printHeader "Rebuilding YouCompleteMe"

    # If `node` and `npm` are installed, enable Tern.js-based completion in YCM
	ycm_addl_args=''
	if type -t node >/dev/null && type -t npm >/dev/null; then
		ycm_addl_args='--tern-completer'
	fi

	(cd home/.janus/YouCompleteMe && python3 ./install.py --clang-completer $ycm_addl_args)
fi
