case $- in
	*i*) ;;
	  *) return;;
esac

if [ -f /etc/profile ]; then
   source /etc/profile
fi

if [ -f ~/.bash_profile ]; then
   source ~/.bash_profile
fi
