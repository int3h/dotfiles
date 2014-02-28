#################################
##### PATH setup (dependency of most other commands)
#################################

# Only add npm to our path if it exists
[[ -d /usr/local/share/npm/bin ]] && PATH="$PATH:/usr/local/share/npm/bin"
# Add in Araxis Merge command line utilities if they're installed
[[ -d "$HOME/bin/araxis" ]] && PATH="$PATH:$HOME/bin/araxis"
# Add homebrew's path (it's already in the PATH by default, but we need to add
# it earlier so that its tools overrides the system's tools.)
PATH="/usr/local/bin:$PATH"
# Add my personal 'bin' directory
PATH="$HOME/bin:$PATH"
# With the lowest weight, execute binaries in the CWD
PATH="$PATH:."

#################################
##### Shell options
#################################

# Set the default mode of new files to u=rwx,g=rx,o=
umask 0027

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
##### Setup installed tools
#################################

# Homebrew-installed programs are in the homebrew directory
if hash brew 2>/dev/null; then
    BREW_PREFIX=$(brew --prefix)
else
    # If homebrew isn't installed, set this to a value that will guarantee
    # failure when checking if a homebrew-installed program exists
    BREW_PREFIX=/dev/null/brew
fi

# Put junit in Java classpath
[ -f ~/Dropbox/code/junit/junit-4.10.jar ] && export CLASSPATH=~/Dropbox/code/junit/junit-4.10.jar:./:$CLASSPATH

if hash mvim 2>/dev/null; then
    export EDITOR='mvim -f'
    export VISUAL='mvim -f'
fi

[ -f $BREW_PREFIX/etc/bash_completion ] &&. $BREW_PREFIX/etc/bash_completion

export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Initialize 'autojump' utility
[[ -s $BREW_PREFIX/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh


#################################
##### Source secondary config files
#################################

[ -f ~/.shell_aliases ] && . ~/.shell_aliases
[ -f ~/.shell_commands ] && source ~/.shell_commands
[ -f ~/.shell_private ] && source ~/.shell_private


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

    # Prompt will be 'username (pwd)$ ', colored with white-on-green
    PROMPT_COLOR="\e[1m\e[48;5;2;38;5;256m"

    # The below version adds more '$' for every level deeper the shell is nested
    export PS1="\[$PROMPT_COLOR\]\u (\w)$(eval "printf '\\$%.0s' {1..$SHLVL}")\[\e[0m\] "
    # The below version adds '[n]' before the '$' if the shell is nested, where n is the nesting level
    #export PS1="\[\e[1;42m\]\u (\W)$(((SHLVL>1))&&echo "[$SHLVL]")\$\[\e[0m\] "

    # Kinda hacky way to indent PS2 to the same level as PS1: we make PS2 virtually the same as PS1,
    # however we insert a command to clear the printed text ('tput el1') right before we print the 
    # prompt seperator character ('>') so that we erase the username+PWD but retain the cursor position
    export PS2="\[$PROMPT_COLOR\]\u (\W)\[$(tput el1)$PROMPT_COLOR\]$(eval "printf '>%.0s' {1..$SHLVL}")\[\e[0m\] "
    unset PROMPT_COLOR

    # Set terminal title to user@host:dir
    export PS1="\[\e]0;\w\a\]$PS1"

    [ -x ~/mac-scripts/launchd-update-homebrew.sh ] && ~/mac-scripts/launchd-update-homebrew.sh display

    # Initialize the 'Generic Colouriser' utility
    if [[ -s $BREW_PREFIX/etc/grc.bashrc ]]; then
      . $BREW_PREFIX/etc/grc.bashrc
      # Since grc overwrites our existing 'make' alias, fix it up to include both grc & our changes
      alias make='colourify make -j 8'
    fi
    ;;
esac
