#!/usr/bin/env bash

################################################################################
# helpers.sh
#
# A collection of helper functions for Bash scripts.
# Source this file from your Bash script and call any of the included args
################################################################################

# Echoes the name of the main script file
get_script_name() {
    # $BASH_SOURCE is an array of all the source files of functions calling this function. The
    # last element is always 'main', and the second to last element should be the first source file
    # to be run (that is, the main script file.)
    # '${#BASH_SOURCE[@]}' gets the length of $BASH_SOURCE. We then subtract 1 to get the
    # second-to-last index, then use that to lookup the main script file name & call basename on it.
    #echo "$(basename "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")"

    # Actually, just using the name of the command we're running should suffice :-/
    echo "$(basename $0)"
}


# Echoes the full path to the main script file (path and filename)
get_script_path() {
    pushd `dirname $0` > /dev/null
    local script_path=$(pwd)
    popd > /dev/null
    echo "$script_path/$(get_script_name)"
}


# Echoes its arguments to stdout, word-wrapped to the width of the terminal
wrap() {
    printf '%s\n' "$*" | expand | fold -s -w $(tput cols)
}


printmsg() {
    local msg="$*"
    printf '%s%s==>%s %b%s\n' \
        "$(tput bold)" "$(tput setaf 32)" \
        "$(tput setaf 15)" \
        "$msg" \
        "$(tput sgr0)"
}
alias ohai=printmsg


printwarning() {
    local msg="$*"
    printf '%s%sWarning:%s %b%s\n' \
        "$(tput bold)" "$(tput setaf 227)" \
        "$(tput setaf 15)" \
        "$msg" \
        "$(tput sgr0)"
}
alias opoo=printwarning


printerror() {
    local msg="$*"
    printf '%s%sError:%s %b%s\n' \
        "$(tput bold)" "$(tput setaf 196)" \
        "$(tput setaf 15)" \
        "$msg" \
        "$(tput sgr0)"
}
alias onoe=printerror


# Checks if the URL passed in $1 can be fetched (with cURL) without errors. Returns 0 if so,
# and a non-zero cURL return code otherwise (see `man curl` for meaning of specific values.)
check_url() {
    # You must supply exactly one URL to check; else return an error code
    # (cURL can fetch multiple URLs at once, but the return code will only reflect the last URL
    # fetched. This makes it impossible to detect failure of any but the last URL.)
    if [[ $# -ne 1 ]]; then
        return 1
    fi
    # Use cURL to check if file exists on Apple's web server
    #   --silent            Don't show progress meter or error messages
    #   --fail              Fail on HTTP error code
    #   --max-time 3        Limit the maximim time for the whole operation to 5 second
    #   --write-out ...     Print the HTTP status code of the response to STDOUT
    #   --output /dev/null  Write output to /dev/null
    local http_code="$(curl --silent --fail --max-time 3 --output /dev/null --write-out "%{http_code}" "$1" 2>/dev/null)"
    local curl_exit_code=$?
    # Apple's dumb developer website will returb "300" if a man page isn't found, instead of 404
    if [[ "$http_code" == "300" ]]; then
        return 47
    else
        return $curl_exit_code
    fi
}


# Checks if the user can run `sudo` without requiring a password. If yes, prints 'sudo' and returns
# 0; if not, prints '' (empty string) and returns 1.
can_sudo() {
    if [[ "$(sudo -n printf 'sudo' 2>/dev/null)" == "sudo" ]]; then
        echo 'sudo'
        return 0
    else
        echo ''
        return 1
    fi
}
