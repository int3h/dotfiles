# ~/.bash_logout: executed by bash(1) when login shell exits.

 if [[ "$OS" == "Linux" ]] && [ "$SHLVL" = 1 ]; then
	# when leaving the console clear the screen to increase privacy
	[ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q

	# When logging out of the top level shell (so, e.g., a SSH session, not a tmux window), reset
	# the sudo timestamp. Useful here because we also disable sudo's tty_tickets option, allowing
	# a single sudo timestamp to be shared among all of the user's sessions, not just that TTY.
	sudo -k
 fi

