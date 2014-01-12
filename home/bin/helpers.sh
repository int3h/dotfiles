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
    echo -ne "$@" | expand | fold -s -w $(tput cols)
}


# Runs the command given as arguments with administrator privileges, prompting the user via a GUI
# dialog for their password. Useful if your script is running outside a terminal session, but you
# still need to get the user's password to elevate privileges.
sudo_gui() {
    osascript -e "do shell script \"$@\" with administrator privileges"
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
    curl --silent --fail --max-time 3 --head --output /dev/null "$1" 2>&1 >/dev/null
}


# TODO: generate_launchagent(): function for creating a LaunchAgent
#   command: list of program + arguments to run
#   extra: a string of additional plist data to add to the launch_agent
# should echo the plist to stdout

# TODO: write_launchagent(): writes out the launchd plist to the proper location
# Takes a string representing the plist content. (Optionally, the name of the plist? Would allow for
# a descriptive filename, but if we wanted to set the label, we'd have to modify the plist content.
# We could also take the name from the existing plist label.)
# If the user is not root, writes out the agent to ~/Library/LaunchAgents/.
# If the user is root, writes out the daemon to /Library/LaunchDaemons/, `chown root:wheel`, and
# `chmod 600` the file.

# TODO: run_after_reboot(): function for creating a 'run at next boot' Launch Daemon
# Calls generate_launchagent(), with the following changes:
#   The command to be run is modified to be a call with `bash -c 'rm $plist; $cmd'`, where $cmd
#       is the original command, and $plist is the location of the LaunchAgent .plist file.
#   In the extra options, "LaunchOnlyOnce" is set to true
# FIXME: we need to know the path of the plist when we modify the command (so we can delete it
# after running) but if we seperate the writing of the plist into a stand-alone function, we won't
# know the path until after we've written it.
# We could create another function whose job is to just to create a filename and/or job label. This
# would be used by both write_launchagent(), and anybody who needs to know the filename ahead of
# time.

# TODO: run_at(): create a launchagent which runs at a calendar interval
# run_at minute [hour [weekday]]
# Calls generate_launchagent() sets extra to add the StartCalendarInterval dict, then loads
# the job into launchctl.

# TODO: run_every(): create a launchagent which runs every n minutes.
# Call generate_launchagent() with the extra set to add the key StartInterval, with an integer
# value. Then loads the job into launchctl.
