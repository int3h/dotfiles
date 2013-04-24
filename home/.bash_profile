export PATH=~/bin:/usr/local/bin:/usr/local/share/npm/bin:$PATH:.:~

export CLICOLOR=1
#export LSCOLORS=ExFxCxDxBxegedabagacad

# Prompt will be 'username (pwd)$ ', colored with white-on-green
export PS1="\[\e[1;42m\]\u (\W)\$\[\e[0m\] "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;\w\a\]$PS1"
    ;;
  *)
    ;;
esac

export HISTCONTROL=ignoredups:ignorespace;
export HISTFILE=~/.shell_history
shopt -s histappend;
# Save each command when the prompt is re-displayed, rather than only at shell exit
PROMPT_COMMAND="history -a; $PROMPT_COMMAND";

# Support extended pattern matching in bash (e.g., for quantifiers like "*_+([0-9])")
shopt -s extglob
# Correct for minor spelling errors
shopt -s cdspell;
# If directory given as a command, cd to that directory
# (Only supported in bash 4 and above)
if [ $BASH_VERSINFO -ge 4 ]
then
  shopt -s autocd
fi

# Use SublimeText 2 as default editor
export EDITOR='mvim -f'

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

if [ -f ~/.shell_aliases ]; then
  . ~/.shell_aliases
fi

if [ -f ~/.shell_commands ]; then
  source ~/.shell_commands
fi

# Tell MrSync (our rsync convienance wrapper) to use ~/.rsync_exclude.conf for exlcude patterns
export MRSYNC_EXCLUDE_FILE="~/.rsync_exclude.conf"

export CLASSPATH=~/Dropbox/code/junit/junit-4.10.jar:./:$CLASSPATH

export PYTHONPATH="$(brew --prefix)/lib/python2.7/site-packages:$PYTHONPATH"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Display a message at login with an interactive shell if any homebrew packages need updating
# This assumes that `brew update` is regularly run (e.g., by cron) to pull the latest package info.
case "$-" in
*i*)    if [[ `brew outdated` != '' ]]; then
            echo
            echo -e "\e[1m\e[48;5;17m\e[38;5;9mhomebrew installed packages are outdated. Run \`brew outdated\` to see outdated packages, and \`brew upgrade\` to upgrade outdated packages.\e[0m"
            echo
        fi
        ;;
*)      continue ;;
esac

# Boomark and recalls functionaility
if [ -f ~/.dir_bookmark.sh ]; then
    . ~/.dir_bookmark.sh
fi
