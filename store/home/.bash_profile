#################################
##### Check which OS we're running and set global flags
#################################

case $(uname -s) in
    Darwin) export OS='Mac';;
    Linux) export OS='Linux';;
esac

_USER_CONFIG_PATH="${_USER_CONFIG_PATH:-${HOME}/.bash.d}"
_USER_BIN_DIR="${_USER_BIN_DIR:-${HOME}/bin}"

[ -f "$_USER_CONFIG_PATH/local" ] && source "$_USER_CONFIG_PATH/local"


#################################
##### Shell options
#################################

# Set the default mode of new files to u=rwx,g=,o=
umask u=rwx,g=rx,o=

# Set the LANG to "C" so that `ls` output is ordered to have dotfiles first, among other things
export LANG="C"
export LC_CTYPE="en_US.UTF-8"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# Support extended pattern matching in bash (e.g., for quantifiers like "*_+([0-9])")
shopt -s extglob
# Correct for minor spelling errors
shopt -s cdspell;
# When doing history expansion, pressing return simply loads the expanded command into the prompt,
# rather the immediately executing it (allowing for review or editing)
shopt -s histverify
# If history expansion fails, reload the original command into the prompt so it can be edited
shopt -s histreedit

# If directory given as a command, cd to that directory
# (Only supported in bash 4 and above)
[ $BASH_VERSINFO -ge 4 ] && shopt -s autocd


# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=10000
export HISTCONTROL=ignoredups:ignorespace;
# Change the file history commands are saved to
export HISTFILE="$_USER_CONFIG_PATH/history"
# Append to the existing history file, rather than overwriting it
shopt -s histappend;
# Save each command when the prompt is re-displayed, rather than only at shell exit
#[[ $_BASHRC_DID_RUN ]] || PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND/%;*( )/} ;}history -a;history -c;history -r";
[[ $_BASHRC_DID_RUN ]] || PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"

#################################
##### PATH setup (dependency of most other commands)
#################################

# We want to avoud setting the path twice, which can happen if, e.g., we're in a tmux subshell. We
# check to see if one our custom path components (~/bin) is in $PATH and only proceed if it isn't.
if [[ ! $_BASHRC_DID_RUN ]]; then
    ## High weight (last added = lowest priority)

    # Homebrew (overrides system tools)
    [[ -d /usr/local/bin ]] && PATH="/usr/local/sbin:/usr/local/bin:$PATH"

    # Apple Silicon homebrew
    [[ -e /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

    # `pip install --user` binaries
    [[ -d $HOME/.local/bin ]] && PATH="$HOME/.local/bin:$PATH"

    # `gem install --user-install` binaries
    if which ruby >/dev/null && which gem >/dev/null; then
        PATH="$(ruby -rrubygems -e 'puts Gem.user_dir')/bin:$PATH"
    fi

	if [[ "$OS" == "Linux" ]]; then
        [[ -d /opt/splunkforwarder/bin ]] && PATH="/opt/splunkforwarder/bin:$PATH"
        [[ -d /opt/splunk/bin ]] && PATH="/opt/splunk/bin:$PATH"
        # In Linux, `npm install -g` normally requires `sudo`. We set the global path to
        # ~/.npm_global and add its bin directory to our $PATH.
        [[ -d ~/.npm_global ]] && PATH="$HOME/.npm_global/bin:$PATH"
        [[ -d "${_USER_BIN_DIR}/linux" ]] && PATH="${_USER_BIN_DIR}/linux:$PATH"
    elif [[ "$OS" == "Mac" ]]; then
        [[ -d "${_USER_BIN_DIR}/mac" ]] && PATH="${_USER_BIN_DIR}/mac:$PATH"
        # Araxis Merge command line utilities (if they're installed)
        [[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]] && PATH="$PATH:/Applications/Araxis Merge.app/Contents/Utilities"
    fi

    if type -t go >/dev/null && [[ -d "$(go env GOPATH)/bin" ]]; then
        PATH="$(go env GOPATH)/bin:$PATH"
    fi

    if type -t rustup >/dev/null && [[ -d "$(brew --prefix rustup)/bin" ]]; then
        PATH="$(brew --prefix rustup)/bin:$PATH"
    fi

    if [[ -d "$HOME/Library/pnpm" ]]; then
        # pnpm
        export PNPM_HOME="$HOME/Library/pnpm"
        case ":$PATH:" in
            *":$PNPM_HOME:"*) ;;
            *) export PATH="$PATH:$PNPM_HOME" ;;
        esac
        # pnpm end
    fi

    # My own user bin directory (highest priority)
    [[ -d "${_USER_BIN_DIR}" ]] && PATH="${_USER_BIN_DIR}:$PATH"

    ## Low weight (last added = lowest priority)

    # Binaries in the CWD
    export PATH="$PATH:."
fi


# Add non-globally installed npm modules' bins to $PATH while you're in install dir or subdir
# Example: in ~/Documents/my-js-project, do `npm install jshint`. `jshint` will be available in your
# path while you're in this dir or a subdir. When you leave, the bin will be removed from your path.
if type -t 'npm' >/dev/null; then
    # Ensure $NPM_TOKEN is always set, even if to an empty string, so that using this env variable
    # in ~/.npmrc won't throw an error about being unable to find the var to replace the token.
    export NPM_TOKEN="$NPM_TOKEN"
    __npm_local_bin_path=""

    add_npm_to_path() {
        local npmBin="$(npm bin 2>/dev/null)"

        # If the new npm bin path matches the old path, then nothing needs to be done
        if [[ $npmBin == $__npm_local_bin_path ]]; then return; fi

        # Remove old npm bin path from $PATH, if we previously added it
        if [[ -n "$__npm_local_bin_path" ]]; then
            PATH="${PATH/":${__npm_local_bin_path}"/}"
            __npm_local_bin_path=""
        fi

        # If there's an npm bin path for the current dir, add that to the path
        if [[ -d "${npmBin}" ]]; then
            PATH="$PATH:${npmBin}"
            __npm_local_bin_path="${npmBin}"
        fi
    }

    [[ $_BASHRC_DID_RUN ]] || PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }add_npm_to_path"
fi


#################################
##### Ubuntu setup
#################################

if [[ $OS == "Linux" ]]; then
    if type -t python27 >/dev/null; then
        alias python='python27'
    fi

    # If `nvm` is installed, initialize it
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        export NVM_DIR="$HOME/.nvm"
        export NVM_SYMLINK_CURRENT=true
        source "$HOME/.nvm/nvm.sh" 2>/dev/null
    fi

    # make less more friendly for non-text input files, see lesspipe(1)
    [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # enable programmable completion features (you don't need to enable
    # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
    # sources /etc/bash.bashrc).
    if ! shopt -oq posix; then
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
    fi

    export EDITOR="vim"
    export VISUAL="vim"

	# Link SSH agent forwarding socket to constant location so that it works even on tmux reconnect
	if [[ ! -z "$SSH_AUTH_SOCK" ]] && [[ "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_auth_sock"  ]] ; then
		command rm -f "$HOME/.ssh/agent_auth_sock" 2>&1 >/dev/null
		ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_auth_sock" 2>&1 >/dev/null
		export SSH_AUTH_SOCK="$HOME/.ssh/agent_auth_sock"
	fi

	# Tell X apps to use (virtual) display 0 (these fail under SSH when they can't find a display)
	[[ -n "$SSH_CLIENT" ]] && export DISPLAY=:0

	# Setup CUDA tools
	if [[ ! $_BASHRC_DID_RUN ]] && [[ -d /usr/local/cuda ]]; then
		export PATH="/usr/local/cuda/bin:$PATH"
		export LD_LIBRARY_PATH="${LD_LIBRARY_PATH+:}/usr/local/cuda/lib64"
		export LIBRARY_PATH="${LIBRARY_PATH+:}/usr/local/cuda/lib64"
		export C_INCLUDE_PATH="${C_INCLUDE_PATH+:}/usr/local/cuda/include"
		export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH+:}/usr/local/cuda/include"
	fi
fi


show_dynamic_motd() {
    [[ "$OS" == "Linux" ]] || return 0

    # Check if we can `sudo` successfully without a password (-n)
    local dosudo="$(sudo -n printf 'sudo' 2>/dev/null)"

    # Check which flavor of Linux we're running under
    if [[ -f /etc/os-release ]]; then
        local os_type="$(. /etc/os-release; echo $ID_LIKE)"
    fi

    if [[ "$os_type" == "debian" ]] && [[ -d /etc/update-motd.d ]]; then
        # On Ubuntu, run the update-motd.d scripts directly, since there's no `update-motd` utility
         $dosudo run-parts /etc/update-motd.d 2>/dev/null
         return
    elif [[ "$os_type" =~ rhel ]] && [[ -x /usr/sbin/update-motd ]] && [[ -n "$dosudo" ]]; then
        # On RedHat-like run `update-motd` if we can sudo to update /etc/motd.
        sudo -n /usr/sbin/update-motd --force >/dev/null 2>/dev/null
    fi

    [[ -f /etc/motd ]] && cat /etc/motd && printf '\n'
}

#################################
##### OS X setup
#################################

if [[ $OS == "Mac" ]]; then
    if type -t mvim >/dev/null; then
        export EDITOR='mvim -f'
        export VISUAL='mvim -f'
    fi

    [[ -d ${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin ]] && PATH="${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin:$PATH"
    [[ -d ${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin ]] && PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"

    # bash-completion2 homebrew package init
    [ -f $HOMEBREW_PREFIX/share/bash-completion/bash_completion ] && . $HOMEBREW_PREFIX/share/bash-completion/bash_completion
    # bash-completion (i.e. v1.x) homebrew package init
    [ -f $HOMEBREW_PREFIX/etc/bash_completion ] && . $HOMEBREW_PREFIX/etc/bash_completion

    # If `nvm` is installed, initialize it
    if [[ -s "$(brew --prefix nvm 2>/dev/null)/nvm.sh" ]]; then
        export NVM_DIR="$HOME/.nvm"
        export NVM_SYMLINK_CURRENT=true
        #source "$(brew --prefix nvm)/nvm.sh"
    fi

    # Enable auto-completion of AWS cli tools
    type -t aws_completer >/dev/null && complete -C aws_completer aws
    # Enable auto-completion of `hman`
    if type -t hman >/dev/null && [[ -f /usr/local/share/bash-completion/completions/man ]]; then
        source /usr/local/share/bash-completion/completions/man && complete -F _man hman
    fi

    type -t rbenv>/dev/null && export RBENV_ROOT=/usr/local/var/rbenv && eval "$(rbenv init -)"

    # Initialize 'autojump' utility
    [[ -s $HOMEBREW_PREFIX/etc/profile.d/autojump.sh ]] && . $HOMEBREW_PREFIX/etc/profile.d/autojump.sh

    # If Java is installed, export the JRE path as $JAVA_HOME, which apps like ec2-cli use.
    # The `java_home` utility is a standard part of OS X, and will either print Java's home path, if
    # Java is installed, or print an error and exit non-zero. Only export $JAVA_HOME if it succeeds.
    installed_java_home="$(/usr/libexec/java_home --failfast 2>/dev/null)"
    [[ $? == 0 ]] && [[ -n "$installed_java_home" ]] && export JAVA_HOME="$installed_java_home"
    unset installed_java_home

    # Setup ec2 api tools
    # $AWS_ACCESS_KEY and $AWS_SECRET_KEY should be set in shell_local or similar
    if type -t ec2-cmd >/dev/null; then
        # Find the path to the ec2 api tools libexec directory
        ec2_symlink="$(which ec2-cmd)"
        # Get the asbsolute path to the cmd by combining the dir to it + (relative) symlink pointer
        ec2_abs_path="$(printf '%s/%s' "$(dirname "$ec2_symlink")" "$(readlink "$ec2_symlink")")"
        # We can get to the libexec path relative to the absolute cmd path
        ec2_libexec="$(printf '%s/../libexec' "$(dirname "$ec2_abs_path")")"

        [[ -d "$ec2_libexec" ]] && export EC2_HOME="$ec2_libexec"
        unset ec2_symlink ec2_abs_path ec2_libexec
    fi
    if type -t ec2-ami-tools-version >/dev/null; then
        # Same for ec2 ami tools
        ec2_symlink="$(which ec2-ami-tools-version)"
        ec2_abs_path="$(printf '%s/%s' "$(dirname "$ec2_symlink")" "$(readlink "$ec2_symlink")")"
        ec2_libexec="$(printf '%s/../libexec' "$(dirname "$ec2_abs_path")")"
        [[ -d "$ec2_libexec" ]] && export EC2_AMITOOL_HOME="$ec2_libexec"
        unset ec2_symlink ec2_abs_path ec2_libexec
    fi

fi


#################################
##### Setup installed tools
#################################

# Add in Grunt completions
type -t grunt >/dev/null && eval "$(grunt --completion=bash)"

# npm completion
type -t npm >/dev/null && . <(npm completion)
export GIT_SSH_COMMAND="ssh -o PermitLocalCommand=no -o ServerAliveInterval=0"

# Enable "The Fuck" (https://github.com/nvbn/thefuck)
type -t thefuck >/dev/null && eval $(thefuck --alias)

[ -e "$HOME/.nvm" ] && export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Tell `less` to ignore case when searching, unless search term has an uppercase letter; to output
# ANSI color escape codes correctly; scroll, not wrap, long lines; and, if there is only one
# screen's worth of output, to print that, and exit.
export LESS="-iRS"
# Tell `less` to use pretty colors when formatting a man page
# Source: https://gist.github.com/reklis/6250044
export LESS_TERMCAP_mb=$(printf "\e[1;34m")
export LESS_TERMCAP_md=$(printf "\e[1;34m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;37m")


#################################
##### Source secondary config files
#################################

[ -e "$_USER_CONFIG_PATH/__init__.sh" ] && source "$_USER_CONFIG_PATH/__init__.sh"


#################################
##### Interactive mode config
#################################

__SHORTENED_PWD=""
# Changes $PROMPT_DIRTRIM so that '\w' is $PS1 is a reasonable length for the terminal width
function resize_prompt_dirtrim() {
    # Only evaluate if we've changed directories since the last time we evaluated
    if [ "$__SHORTENED_PWD" != "$PWD" ]; then
        # The maximum % of columns $PWD should be (0-100%).
        [[ $PWD_WIDTH_MAX ]] || PWD_WIDTH_MAX=40
        # Max # of characters PWD, given the user-set PWD % (take off 4 chars to account for '/...' in
        # the dirtrim'ed PWD.)
        local maxLength="$(( ( ( $COLUMNS * $PWD_WIDTH_MAX ) / 100 ) - 4 ))"

        # Turn $HOME in PWD into '~' (linebroken to fix bug with Vim's bash syntax highlighting)
        local pwdHomed="${PWD/#\
$HOME/\~\/}"
        [[ $maxLength -ge ${#pwdHomed} ]] && maxLength="${#pwdHomed}"
        # Trim PWD to have the maximum desired characters, taken from the end
        local pwdDesired="${pwdHomed:(-$maxLength)}"
        # Delete all non '/' characters from PWD
        local numPaths="${pwdDesired//[^\/]}"
        # Count how many '/' characters there were in PWD (a rough estimate of how many directories
        # there were in our trimmed PWD) and set $PROMPT_DIRTRIM to this number
        PROMPT_DIRTRIM="${#numPaths}"
        if [[ $PROMPT_DIRTRIM -lt 1 ]]; then PROMPT_DIRTRIM=1; fi

        __SHORTENED_PWD="$PWD"
    fi
}


case $- in
*i*)
    if [[ $TERM != dumb ]] && tput cols >/dev/null 2>/dev/null; then
        if [[ $_BASHRC_DID_RUN != 1 ]]; then
            PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }resize_prompt_dirtrim"
        fi
        PROMPT_DIRTRIM=3

        export CLICOLOR=1
        # Colors used by `ls` on OS X (OS X's default value shown, for reference)
        #export LSCOLORS='exfxcxdxbxegedabagacad'
        # Colors used by Bash path completion w/ `colored-stats` (set to resemble OS X default `ls`)
        export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'


        ########## Prompt config
        case "$TERM" in
            screen*)
                NUM_PROMPTS="$((SHLVL - 1))"
                ;;
            *)
                #PROMPT_COLOR="${COLOR_RESET}$(tput bold)$(tput setab 6)"
                NUM_PROMPTS=$SHLVL
                ;;
        esac
        PROMPT_CHAR="$(printf '\\$%.0s' {1..$NUM_PROMPTS})"

        # Prompt will be 'username (pwd)$ ', colored with white-on-green
        COLOR_RESET="$(tput sgr0)"
        if [[ -z $PROMPT_COLOR ]]; then
            if type -t hashcolor >/dev/null 2>&1; then
                hashedColor=($(hashcolor $HOSTNAME))
                PROMPT_COLOR="$(tput bold)$(tput setab ${hashedColor[0]})$(tput setaf ${hashedColor[1]})"
                unset hashedColor
            else
                PROMPT_COLOR="$(tput setab 33)$(tput bold)"
            fi
        fi

        # If Bash version >= 4.4
        if [[ $BASH_VERSINFO -ge 5 ]]; then
            # We set these readline variables here, rather than .inputrc, so we can set them
            # dynamically, using the calculated prompt color in this script.
            bind "set show-mode-in-prompt on"
            # In insert mode, use the standard prompt colors and insert ">>> "
            bind "set vi-ins-mode-string \"\\1${COLOR_RESET}\\2\""
            # In command mode, reverse the standard prompt colors, and print "::: "
            bind "set vi-cmd-mode-string \"\\1${COLOR_RESET}$(tput rev)\\2\""

            PROMPT_CLR_CMD="$PROMPT_COLOR"
            # Set the prompt color in the Vi mode string (inserted by readline at the start of
            # a line) instead of $PS1, so that we can change it based off the current Vi mode.
            export PS2="${PROMPT_COLOR}$(echo $USER | sed -e 's/./ /g')...>${COLOR_RESET} "
        else
            PROMPT_CLR_CMD="${COLOR_RESET}$PROMPT_COLOR"
        fi

        if [[ -z $PROMPT_TEXT ]]; then
            if [[ $OS == "Mac" ]]; then
                PROMPT_TEXT='\u (\w)'
            else
                PROMPT_TEXT="\\u@$(hostname -f) (\\w)"
            fi
        fi

        # The below version adds more '$' for every level deeper the shell is nested
        export PS1="\\[${PROMPT_CLR_CMD}\\]${PROMPT_TEXT}${PROMPT_CHAR}\\[${COLOR_RESET}\\] "
        # The below version adds '[n]' before the '$' if the shell is nested, where n is the nesting level
        #export PS1="\[\e[1;42m\]\u (\W)$(((SHLVL>1))&&echo "[$SHLVL]")\$\[\e[0m\] "

        # Kinda hacky way to indent PS2 to the same level as PS1: we make PS2 virtually the same as PS1,
        # however we insert a command to clear the printed text ('tput el1') right before we print the
        # prompt seperator character ('>') so that we erase the username+PWD but retain the cursor position
        #export PS2="${PROMPT_TEXT}(\w)[$(tput el1)$PROMPT_CLR_CMD\]$(eval "printf '>%.0s' {1..$NUM_PROMPTS}")\[${COLOR_RESET}\] "

        unset PROMPT_CLR_CMD
        unset NUM_PROMPTS
        unset PROMPT_CHAR
        unset COLOR_RESET
        unset PROMPT_TEXT

        if [[ $OS == "Mac" ]]; then
            # Set the tab name in Terminal.app to the basename of PWD
            # Change '1' to {2,1} to set {window,tab+window} title. /etc/bashrc already sends PWD to
            # Terminal.app via $PROMPT_COMMAND, which sets the file breadcrumb in the title bar.
            PS1="\\[\\e]1;\\W\\a\\]${PS1}"

            if [[ -s $HOMEBREW_PREFIX/etc/grc.sh ]]; then
                GRC_ALIASES=true
                # Initialize the 'Generic Colouriser' utility
                . $HOMEBREW_PREFIX/etc/grc.sh
                # Since grc overwrites our existing 'make' alias, fix it up to include both grc & our changes
                alias make="colourify make -j $(( $(sysctl -n hw.ncpu) + 1 ))"
            fi
        fi

        # Remove duplicate entries from $PATH. Maintains current $PATH component ordering, using
        # first occurrence
        export PATH="$(echo "$PATH" \
            | sed -e 's/:\(:\|$\)/:.\1/g' \
            | awk 'BEGIN { RS=":";   } { path=$0; if($0 == "" || $0 == "\n") {path="."} n[path]++; if(n[path] < 2) { printf(":%s", $0);  }   }' \
            | cut -c 2- \
        )"

        export PROMPT_COMMAND
        export _BASHRC_DID_RUN=1

        # Initialize iTerm2 integration (works on Linux over SSH, too)
        [[ -f ~/.iterm2_shell_integration.bash ]] && [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && \
            source ~/.iterm2_shell_integration.bash

        [[ "$OS" == "Mac" ]] && type -t archey >/dev/null && archey 2>/dev/null

        ########## Launch tmux by default
        if type -t tmux 2>&1 >/dev/null && [[ -n "$SSH_CLIENT" ]]; then
            if test -z "$TMUX"; then
                tmux new-session -A -s "${USER//./}"
            else
                show_dynamic_motd
            fi
        fi
    fi
    ;;
esac


export _BASHRC_DID_RUN=1
