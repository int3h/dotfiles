#################################
##### Check which OS we're running and set global flags
#################################

case $(uname -s) in
	Darwin) export OS='Mac';;
	Linux) export OS='Linux';;
esac

#################################
##### PATH setup (dependency of most other commands)
#################################

# Only add npm to our path if it exists
[[ -d /usr/local/share/npm/bin ]] && PATH="$PATH:/usr/local/share/npm/bin"
# Add in Araxis Merge command line utilities if they're installed
[[ -d "$HOME/bin/araxis" ]] && PATH="$PATH:$HOME/bin/araxis"
# Add homebrew's path (it's already in the PATH by default, but we need to add
# it earlier so that its tools overrides the system's tools.)
[[ -d /usr/local/bin ]] && PATH="/usr/local/bin:$PATH"
# Add my personal 'bin' directory
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
# With the lowest weight, execute binaries in the CWD
PATH="$PATH:."

#################################
##### Shell options
#################################

# Set the default mode of new files to u=rwx,g=rx,o=
# umask 0027

# Set the LANG to "C" so that `ls` output is ordered to have dotfiles first, among other things
export LANG="C"
export LC_CTYPE="en_US.UTF-8"

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


export HISTCONTROL=ignoredups:ignorespace;
# Change the file history commands are saved to
export HISTFILE=~/.shell_history
# Append to the existing history file, rather than overwriting it
shopt -s histappend;
# Save each command when the prompt is re-displayed, rather than only at shell exit
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND/%;*( )/} ;} history -a";


#################################
##### Ubuntu default setup
#################################

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

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

#################################
##### Setup installed tools
#################################


if hash vim 2>/dev/null; then
    export EDITOR='vim'
    export VISUAL='vim'
fi


# export RBENV_ROOT=/usr/local/var/rbenv
#if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if [[ -x ~/.rbenv/bin/rbenv ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi


# If the `keychain` utility is installed, alias `ssh` and `git` so that they trigger it before
# running (the alternative is to run `keychain` during login, but this method means that we'll
# only be prompted for our SSH key password if we use ssh/git, not indicriminately during login.)
if [[ -x /usr/bin/keychain ]]; then
    alias ssh='eval $(/usr/bin/keychain --eval --agents ssh -Q --quiet ~/.ssh/*_rsa) && ssh'
    alias git='eval $(/usr/bin/keychain --eval --agents ssh -Q --quiet ~/.ssh/*_rsa) && git'
fi

#################################
##### Source secondary config files
#################################

[ -f ~/.shell_private ] && source ~/.shell_private
[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_commands ] && source ~/.shell_commands


#################################
##### Interactive mode config
#################################
case $- in
*i*)
    export CLICOLOR=1
    #export LSCOLORS=ExFxCxDxBxegedabagacad

    # Tell grep to highlight matches
    export GREP_OPTIONS='--color=auto'

    ########## Prompt config

	case "$TERM" in
		screen*)
			PROMPT_COLOR="\e[1m\e[48;5;6m\e[38;5;227m"
			NUM_PROMPTS="$((SHLVL - 1))"
			;;
		*)
			PROMPT_COLOR="\e[1m\e[48;5;6m"
			NUM_PROMPTS=$SHLVL
			;;
	esac


    # The below version adds more '$' for every level deeper the shell is nested
    export PS1="\[$PROMPT_COLOR\]\u@\H (\w)$(eval "printf '\\$%.0s' {1..$NUM_PROMPTS}")\[\e[0m\] "
    # The below version adds '[n]' before the '$' if the shell is nested, where n is the nesting level
    #export PS1="\[\e[1;42m\]\u (\W)$(((SHLVL>1))&&echo "[$SHLVL]")\$\[\e[0m\] "

    # Kinda hacky way to indent PS2 to the same level as PS1: we make PS2 virtually the same as PS1,
    # however we insert a command to clear the printed text ('tput el1') right before we print the
    # prompt seperator character ('>') so that we erase the username+PWD but retain the cursor position
    export PS2="\[$PROMPT_COLOR\]\u (\W)\[$(tput el1)$PROMPT_COLOR\]$(eval "printf '>%.0s' {1..$NUM_PROMPTS}")\[\e[0m\] "

    # Set terminal title to user@host:dir
    export PS1="\[\e]0;\w\a\]$PS1"

    unset PROMPT_COLOR
    unset NUM_PROMPTS

    ;;
esac
