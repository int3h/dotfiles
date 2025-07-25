regexp=^\s+(.*)$
colours=unchanged,dark bold
count=stop
======
# size
regexp=\s+([\d\.]{1,3})([BbKkMmGgPp])\s+
colours=unchanged,blue,bold blue
=======
# Date and time
regexp=\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Nov|Dec)\s\s?(\d?\d)\s(?:([0-2]\d:[0-5]\d)|\s([12]\d\d\d))\s
# All cyan. Month is bold, day is normal, and if a day is present it's dark, else the year is bright
colours=unchanged,cyan,cyan,dark cyan,bold cyan
========
# Hide 'number of links', darken user + group, hide no flags ('-') + make set flags bright blue
regexp=^(?:[^\s]+\s+)(\d+)\s+([^\s]+)\s+([^\s]+)\s+(?:(-)|([^\s-]+))\s+
colours=unchanged,concealed,dark,dark,concealed,"\033[1;38;5;51m"
========
# root
regexp=root|wheel|admin(?=\s|$)
colours=red
=======
# Arrow used to denote `link -> target`
regexp=\s(->)\s(.*)$
colours=unchanged,dark,underline dark
=======
# Permissions
regexp=(?:\s|^)((-)|[bcCdDlMnpPs?])((?:(-)|[wrxsStT]){3})((?:(-)|[wrxsStT]){3})((?:(-)|[wrxsStT]){3})([@+]?)(?=\s|$)
colours=unchanged,bold blue,default,bold green,default,bold yellow,default,bold red,default,"\033[1;38;5;51m"
=======
# Trailing slash
regexp=(/)(?:$| -> )
colours=blue
