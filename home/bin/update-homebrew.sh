#!/usr/bin/env bash

AGENT=~/Library/LaunchAgents/com.matthewtorok.brew-update.plist

if [ $# -gt 0 ]; then
	if [ $1 == "install" ]; then
		echo "Installing LaunchAgent to $AGENT"
		(
		cat <<AGENT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.matthewtorok.brew-update</string>

    <key>ProgramArguments</key>
    <array>
      <string>${BASH_SOURCE[0]}</string>
    </array>

    <key>ExitTimeOut</key>
    <integer>120</integer>

    <key>StartCalendarInterval</key>
    <dict>
      <key>Hour</key>
      <integer>1</integer>

      <key>Minute</key>
      <integer>0</integer>
    </dict>
</dict>
</plist>
AGENT
		) > "$AGENT"
		launchctl load "$AGENT"

	elif [ $1 == "uninstall" ]; then
		echo "Uninstalling agent at $AGENT"
		launchctl unload "$AGENT"
		rm "$AGENT"

	else
		echo "Usage: $0 [install|uninstall]" >&2

	fi
	exit 0
fi


# The code that is run by the LaunchAgent nightly:

# We probably aren't running in normal bash shell, so source my ~/.bash_profile
. ~/.bash_profile
echo $PATH
brew update
OUTDATED=$(brew outdated)
if [ -n "$OUTDATED" ]; then
	touch /Users/mtorok/.brew-outdated
fi
