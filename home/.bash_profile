export PATH=~/bin:/usr/local/bin:/usr/local/share/npm/bin:$PATH:.:~

export CLICOLOR=1
#export LSCOLORS=ExFxCxDxBxegedabagacad

# This version puts the path in the winodw titlebar
# export PS1="\[\e[37;40;1m\]\u@\h (\W)\[\e[1;36;40m\]\$(vcprompt --format \" [%s:%b%m]\")\[\e[37;40;1m\]\$\[\e[0m\] "
export PS1="\[\e[30;47m\]\u@\h (\W)\$\[\e[0m\] "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

export HISTCONTROL=ignoredups:ignorespace;
export HISTFILE=~/.shell_history
shopt -s histappend;
PROMPT_COMMAND='history -a';

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

# Tell superconductor to compile with clang
export USECLANG=1

export CLASSPATH=~/Dropbox/code/junit/junit-4.10.jar:./:$CLASSPATH

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
