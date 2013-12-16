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
    #   --max-time 5        Limit the maximim time for the whole operation to 5 second
    #   --head              Only fetch the headers (saves time if the file at the URL is large)
    #   --output /dev/null  Write output to /dev/null
    curl --silent --fail --max-time 5 --head --output /dev/null "$1" 2>&1 >/dev/null
}

