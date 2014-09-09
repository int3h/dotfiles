#################################
##### Check which OS we're running and set global flags
#################################

case $(uname -s) in
    Darwin) export OS='Mac';;
    Linux) export OS='Linux';;
esac

[ -f ~/.config/bash/shell_local ] && source ~/.config/bash/shell_local


#################################
##### Shell options
#################################

# Set the default mode of new files to u=rwx,g=rx,o=
umask 0027

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
HISTSIZE=1000
HISTFILESIZE=2000
export HISTCONTROL=ignoredups:ignorespace;
# Change the file history commands are saved to
export HISTFILE=~/.config/bash/shell_history
# Append to the existing history file, rather than overwriting it
shopt -s histappend;
# Save each command when the prompt is re-displayed, rather than only at shell exit
[[ $_BASHRC_DID_RUN ]] || PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND/%;*( )/} ;} history -a";


#################################
##### PATH setup (dependency of most other commands)
#################################

# We want to avoud setting the path twice, which can happen if, e.g., we're in a tmux subshell. We
# check to see if one our custom path components (~/bin) is in $PATH and only proceed if it isn't.
if [[ ! $_BASHRC_DID_RUN ]]; then
    ## High weight (last added = highest priority)

    # Homebrew (overrides system tools)
    [[ -d /usr/local/bin ]] && PATH="/usr/local/bin:$PATH"
    # `pip install --user` binaries
    [[ -d $HOME/.local/bin ]] && PATH="$HOME/.local/bin:$PATH"
    # My own user bin directory (highest priority)
    [[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"
	[[ "$OS" == "Mac" ]] && [[ -d "$HOME/bin/mac" ]] && PATH="$HOME/bin/mac:$PATH"

    ## Low weight (last added = lowest priority)

    # Araxis Merge command line utilities (if they're installed)
    [[ -d "$HOME/bin/araxis" ]] && PATH="$PATH:$HOME/bin/araxis"
    # Binaries in the CWD
    export PATH="$PATH:."
fi


# Add non-globally installed npm modules' bins to $PATH while you're in install dir or subdir
# Example: in ~/Documents/my-js-project, do `npm install jshint`. `jshint` will be available in your
# path while you're in this dir or a subdir. When you leave, the bin will be removed from your path.
if type -t 'npm' >/dev/null; then
    __npm_local_bin_path=""

    add_npm_to_path() {
        local npmRoot="$(npm root)/.bin"

        # If the new npm bin path matches the old path, then nothing needs to be done
        if [[ $npmRoot == $__npm_local_bin_path ]]; then return; fi

        # Remove old npm bin path from $PATH, if we previously added it
        if [[ -n "$__npm_local_bin_path" ]]; then
            PATH="${PATH/":${__npm_local_bin_path}"/}"
            __npm_local_bin_path=""
        fi

        # If there's an npm bin path for the current dir, add that to the path
        if [[ -d "${npmRoot}" ]]; then
            PATH="$PATH:${npmRoot}"
            __npm_local_bin_path="${npmRoot}"
        fi

        export PATH
        export __npm_local_bin_path
    }

    [[ $_BASHRC_DID_RUN ]] || export PROMPT_COMMAND="${PROMPT_COMMAND}; add_npm_to_path" && \
        export __npm_local_bin_path
fi


#################################
##### Ubuntu setup
#################################

if [[ $OS == "Linux" ]]; then
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

	# This doesn't seem to work, so we should ln -s this file to ~/.gitconfig
    #export GIT_CONFIG=~/.gitsupport/gitconfig.linux

	# Tell GUI apps to use (virtual) display 0 (else in ssh they will fail when they can't find
	# a display)
	export DISPLAY=:0

	# Setup CUDA tools
	if [[ ! $_BASHRC_DID_RUN ]] && [[ -d /usr/local/cuda ]]; then
		export PATH="/usr/local/cuda/bin:$PATH"
		export LD_LIBRARY_PATH="${LD_LIBRARY_PATH+:}/usr/local/cuda/lib64"
		export LIBRARY_PATH="${LIBRARY_PATH+:}/usr/local/cuda/lib64"
		export C_INCLUDE_PATH="${C_INCLUDE_PATH+:}/usr/local/cuda/include"
		export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH+:}/usr/local/cuda/include"
	fi
fi


#################################
##### OS X setup
#################################

if [[ $OS == "Mac" ]]; then
    # Homebrew-installed programs are in the homebrew directory
    if hash brew 2>/dev/null; then
        BREW_PREFIX=$(brew --prefix)
    else
        # If homebrew isn't installed, set this to a value that will guarantee
        # failure when checking if a homebrew-installed program exists
        BREW_PREFIX=/dev/null/brew
    fi

    if type -t mvim >/dev/null; then
        export EDITOR='mvim -f'
        export VISUAL='mvim -f'
    fi

    [ -f $BREW_PREFIX/etc/bash_completion ] && . $BREW_PREFIX/etc/bash_completion

    type -t rbenv>/dev/null && export RBENV_ROOT=/usr/local/var/rbenv && eval "$(rbenv init -)"

    # Initialize 'autojump' utility
    [[ -s $BREW_PREFIX/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

    # Needed for ec2 api tools; otherwise nice to have
    export JAVA_HOME="$(/usr/libexec/java_home)"

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

	# This doesn't seem to work, so we should ln -s this file to ~/.gitconfig
    #export GIT_CONFIG=~/.gitsupport/gitconfig.mac
fi


#################################
##### Setup installed tools
#################################

# Add in Grunt completions
type -t grunt >/dev/null && eval "$(grunt --completion=bash)"


#################################
##### Source secondary config files
#################################

[ -f ~/.config/bash/shell_aliases ] && source ~/.config/bash/shell_aliases
[ -f ~/.config/bash/shell_commands ] && source ~/.config/bash/shell_commands


#################################
##### Interactive mode config
#################################

__SHORTENED_PWD=""
# Changes $PROMPT_DIRTRIM so that '\w' is $PS1 is a reasonable length for the terminal width
function resize_prompt_dirtrim() {
    # Only evaluate if we've changed directories since the last time we evaluated
    if [ "$__SHORTENED_PWD" != "$PWD" ]; then
        # The maximum % of columns $PWD should be (0-100%).
        local PWD_WIDTH_MAX=40
        # Max # of characters PWD, given the user-set PWD % (take off 4 chars to account for '/...' in
        # the dirtrim'ed PWD.)
        local maxLength="$(( ( ( $COLUMNS * $PWD_WIDTH_MAX ) / 100 ) - 4 ))"

        # Turn $HOME in PWD into '~'
        local pwdHomed="${PWD/#$HOME/\~\/}"
        # Trim PWD to have the maximum desired characters, taken from the end
        local pwdDesired="${pwdHomed:(-$maxLength)}"
        # Delete all non '/' characters from PWD
        local numPaths="${pwdDesired//[^\/]}"
        # Count how many '/' characters there were in PWD (a rough estimate of how many directories
        # there were in our trimmed PWD) and set $PROMPT_DIRTRIM to this number
        PROMPT_DIRTRIM="${#numPaths}"
        __SHORTENED_PWD="$PWD"
    fi
}


case $- in
*i*)
    [[ $_BASHRC_DID_RUN ]] || export PROMPT_COMMAND="$PROMPT_COMMAND; resize_prompt_dirtrim"

    export CLICOLOR=1
    #export LSCOLORS=ExFxCxDxBxegedabagacad

    # Tell grep to highlight matches
    export GREP_OPTIONS='--color=auto'

    PROMPT_DIRTRIM=3

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

    # Prompt will be 'username (pwd)$ ', colored with white-on-green
    COLOR_RESET="$(tput sgr0)"
    if [[ -z $PROMPT_COLOR ]]; then
        if type -t hashcolor >/dev/null 2>&1; then
            hashedColor=($(hashcolor $HOSTNAME))
            PROMPT_COLOR="$(tput setab ${hashedColor[0]})$(tput setaf ${hashedColor[1]})"
            unset hashedColor
        else
            PROMPT_COLOR="$(tput setab 33)"
        fi
    fi
    PROMPT_CLR_CMD="${COLOR_RESET}$(tput bold)$PROMPT_COLOR"

    if [[ -z $PROMPT_TEXT ]]; then
    if [[ $OS == "Mac" ]]; then
        PROMPT_TEXT='\u (\w)'
    else
        PROMPT_TEXT='\u@\H (\w)'
    fi
    fi

    # The below version adds more '$' for every level deeper the shell is nested
    export PS1="\[${PROMPT_CLR_CMD}\]${PROMPT_TEXT}$(eval "printf '\\$%.0s' {1..$NUM_PROMPTS}")\[${COLOR_RESET}\] "
    # The below version adds '[n]' before the '$' if the shell is nested, where n is the nesting level
    #export PS1="\[\e[1;42m\]\u (\W)$(((SHLVL>1))&&echo "[$SHLVL]")\$\[\e[0m\] "

    # Kinda hacky way to indent PS2 to the same level as PS1: we make PS2 virtually the same as PS1,
    # however we insert a command to clear the printed text ('tput el1') right before we print the
    # prompt seperator character ('>') so that we erase the username+PWD but retain the cursor position
    export PS2="${PROMPT_TEXT}(\w)[$(tput el1)$PROMPT_CLR_CMD\]$(eval "printf '>%.0s' {1..$NUM_PROMPTS}")\[${COLOR_RESET}\] "

    unset PROMPT_CLR_CMD
    unset NUM_PROMPTS
    unset COLOR_RESET
    unset PROMPT_TEXT

    if [[ $OS == "Mac" ]]; then
        # Set the tab name in Terminal.app to the basename of PWD
        # Change '1' to {2,1} to set {window,tab+window} title. /etc/bashrc already sends PWD to
        # Terminal.app via $PROMPT_COMMAND, which sets the file breadcrumb in the title bar.
        PS1="\[\e]1;\W\a\]${PS1}"

        if [[ -s $BREW_PREFIX/etc/grc.bashrc ]]; then
            # Initialize the 'Generic Colouriser' utility
            . $BREW_PREFIX/etc/grc.bashrc
            # Since grc overwrites our existing 'make' alias, fix it up to include both grc & our changes
            alias make="make -j $(( $(sysctl -n hw.ncpu) + 1 ))"
        fi

        [ -x ~/mac-scripts/launchd-update-homebrew.sh ] && ~/mac-scripts/launchd-update-homebrew.sh display
    fi

     ########## Launch tmux by default
    if type -t tmux 2>&1 >/dev/null && test -z "$TMUX"; then
        tmux new-session -A -s "$USER"
    fi
    ;;
esac


export _BASHRC_DID_RUN=1
