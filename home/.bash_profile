# Only add npm to our path if it exists
[[ -d /usr/local/share/npm/bin ]] && PATH="/usr/local/share/npm/bin:$PATH"

PATH="/Users/mtorok/bin:/usr/local/bin:$PATH:."

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
if [ $BASH_VERSINFO -ge 4 ]
then
  shopt -s autocd
fi

export CLICOLOR=1
#export LSCOLORS=ExFxCxDxBxegedabagacad
# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'

# Prompt will be 'username (pwd)$ ', colored with white-on-green
# The below version adds more '$' for every level deeper the shell is nested
export PS1="\[\e[1;42m\]\u (\W)$(eval "printf '\\$%.0s' {1..$SHLVL}")\[\e[0m\] "
# The below version adds '[n]' before the '$' if the shell is nested, where n is the nesting level
#export PS1="\[\e[1;42m\]\u (\W)$(((SHLVL>1))&&echo "[$SHLVL]")\$\[\e[0m\] "

# These are a hacky trick s.t. $PS{2,3,4} will be indented the same as $PS1: we simply have the
# other PS' print exactly the same thing as PS1, but we just make the first part (the user and PWD)
# print in black-on-black color.
export PS2="\[\e[1m\e[48;5;0m\e[38;5;0m\]\u (\W)\[\e[0m\e[1;42m\]$(eval "printf '>%.0s' {1..$SHLVL}")\[\e[0m\] "
export PS3="\[\e[1m\e[48;5;0m\e[38;5;0m\]\u (\W)\[\e[0m\e[1;42m\]$(eval "printf '|%.0s' {1..$SHLVL}")\[\e[0m\] "
export PS4="\[\e[1m\e[48;5;0m\e[38;5;0m\]\u (\W)\[\e[0m\e[1;42m\]$(eval "printf '+%.0s' {1..$SHLVL}")\[\e[0m\] "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;\w\a\]$PS1"
    ;;
  *)
    ;;
esac


export HISTCONTROL=ignoredups:ignorespace;
# Change the file history commands are saved to
export HISTFILE=~/.shell_history
# Append to the existing history file, rather than overwriting it
shopt -s histappend;
# Save each command when the prompt is re-displayed, rather than only at shell exit
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND/%;*( )/} ;} history -a";


export EDITOR='mvim -f'
export VISUAL='mvim -f'

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

if [ -f ~/.shell_aliases ]; then
  . ~/.shell_aliases
fi

if [ -f ~/.shell_commands ]; then
  source ~/.shell_commands
fi

# Put junit in Java classpath
if [ -f ~/Dropbox/code/junit/junit-4.10.jar ]; then
    export CLASSPATH=~/Dropbox/code/junit/junit-4.10.jar:./:$CLASSPATH
fi

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Display a message at login with an interactive shell if any homebrew packages need updating
# This assumes that `brew update` is regularly run (e.g., by cron) to pull the latest package info.
if [ -t 0  -a  -f ~/.brew-outdated ]; then
  OUTDATED=$(brew outdated)
  if [ -z "$OUTDATED" ]; then
    # If brew is reporting that there are no more outdated packages, then delete ~/.brew-outdated
    rm ~/.brew-outdated
  else
    echo -e "\e[1m\e[48;5;26m\e[38;5;125mhomebrew installed packages are outdated. Run \`brew outdated\` to see outdated packages, and \`brew upgrade\` to upgrade outdated packages.\e[0m"
    echo "$OUTDATED"
    echo
  fi
fi


# Initialize 'autojump' utility
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# Initialize the 'Generic Colouriser' utility
if [[ -s `brew --prefix`/etc/grc.bashrc ]]; then
  . `brew --prefix`/etc/grc.bashrc
  # Since grc overwrites our existing 'make' alias, fix it up to include both grc & our changes
  alias make='colourify make -j 8'
fi

