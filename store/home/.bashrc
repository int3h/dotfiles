case $- in
	*i*) ;;
	  *) return;;
esac

if [ -f /etc/profile ]; then
    if [ $(uname -s) != "Darwin" ]; then
        source /etc/profile
    else
        if [ -z "$PS1" ]; then
            shopt -s checkwinsize
            [ -r "/etc/bashrc_$TERM_PROGRAM" ] && . "/etc/bashrc_$TERM_PROGRAM"
        fi
    fi
fi

if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
fi
