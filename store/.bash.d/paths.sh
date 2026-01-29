#!/usr/bin/env bash

# Given two PATH-like strings, this finds any path components that exist in $2 but not in $1, and
# prints them out in PATH-like format (`/foo/bar:/missing/path:`). Does not print anything if
# there are no missing components. Warning: does not preserve ordering of missing parts.
__print_missing_paths() {
    local NEW_PATH="$1"
    local OLD_PATH="$2"

    # (Comments up here because I can't do them inline without breaking things...)
    # `printf` so that there's no trailing newline
    # `comm` finds the differences between two strings, line-by-line
    # Do some bash magic to turn commands output (which split PATH into lines) into fd
    # Finally, recombine the lines into a path-like string
    local DIFFED_PATH="$(printf \
        "$(comm -13 \
            <(echo $NEW_PATH | sed -e "s/:/\n/g" | sort ) \
            <(echo "$OLD_PATH" | sed -e "s/:/\n/g" | sort))" \
        | tr '\n' ':')"

    [[ -n "$DIFFED_PATH" ]] && printf "${DIFFED_PATH}:"
}

__setup_mac_paths() {
    # Added to the start of the normal system PATH
    local CUSTOM_PATH=''
    local OLD_PATH="$PATH"

    # Initialize Homebrew, which sets its path, as calls to other tools may rely on it
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Grep - make Homebrew GNU version the default
    if [[ -d "$(brew --prefix grep)/libexec/gnubin" ]]; then
        CUSTOM_PATH="${CUSTOM_PATH}:$(brew --prefix grep)/libexec/gnubin"
    fi
    # Sed - make Homebrew GNU version the default
    if [[ -d "$(brew --prefix gnu-sed)/libexec/gnubin" ]]; then
        CUSTOM_PATH="${CUSTOM_PATH}:$(brew --prefix gnu-sed)/libexec/gnubin"
    fi

    # Pip - `pip install --user` binaries
    [[ -d $HOME/.local/bin ]] && CUSTOM_PATH="${CUSTOM_PATH}:$HOME/.local/bin"
    # Ruby - `gem install --user-install` binaries
    if which ruby >/dev/null && which gem >/dev/null; then
        CUSTOM_PATH="${CUSTOM_PATH}:$(ruby -rrubygems -e 'puts Gem.user_dir')/bin"
    fi
    # Go
    if type -t go >/dev/null && [[ -d "$(go env GOPATH)/bin" ]]; then
        CUSTOM_PATH="${CUSTOM_PATH}:$(go env GOPATH)/bin"
    fi
    # Rust
    if type -t rustup >/dev/null && [[ -d "$(brew --prefix rustup)/bin" ]]; then
        CUSTOM_PATH="${CUSTOM_PATH}:$(brew --prefix rustup)/bin"
    fi
    # PNPM
    if [[ -d "$HOME/Library/pnpm" ]] && [ -z "${PNPM_HOME}" ]; then
        export PNPM_HOME="$HOME/Library/pnpm"
        CUSTOM_PATH="${CUSTOM_PATH}:${PNPM_HOME}"
    fi

    # OrbStack (Docker Desktop for Mac alternative)
    if [[ -d "$HOME/.orbstack/bin" ]]; then
        CUSTOM_PATH="${CUSTOM_PATH}:$HOME/.orbstack/bin"
    fi


    # My own user bin directory (highest priority)
    [[ -d "${_USER_BIN_DIR}" ]] && CUSTOM_PATH="${_USER_BIN_DIR}:${CUSTOM_PATH}"
    [[ -d "${_USER_BIN_DIR}/mac" ]] && CUSTOM_PATH="${_USER_BIN_DIR}/mac:${CUSTOM_PATH}"


    # This sets the system paths. We start with an empty path to start fresh & build up the PATH
    # from scratch.
    eval "$(PATH= /usr/libexec/path_helper -s)"
    # Re-init Homebrew paths so it's first
    eval "$(/opt/homebrew/bin/brew shellenv)"

    local MISSING_PATHS="$(__print_missing_paths "${CUSTOM_PATH}:$PATH:." "$OLD_PATH")"
    PATH="$(echo "${CUSTOM_PATH}:${MISSING_PATHS}$PATH:." \
        | sed -e 's/::/:/g' -e 's/^://g' -e 's/:$//g')"

    export PATH
}
__setup_mac_paths

unset -f __setup_mac_paths
unset -f __print_missing_paths
