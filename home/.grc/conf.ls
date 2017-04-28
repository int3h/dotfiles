regexp=^\s+(.*)$
colours=unchanged,dark bold
count=stop
======
# size
regexp=\s+([\d\.]{1,3})([BbKkGgPp])\s+
colours=unchanged,blue,bold blue
=======
# time
regexp=(\s|^)\d+(:\d+)+(?=[\s,]|$)
colours=dark
=======
# month + day
regexp=\s([A-Z][a-z]{2})(\s[0-3\s][0-9])?(?=\s)
colours=default
=======
# year
regexp=(?<=\s[A-Z][a-z][a-z]\s[0-3\s][0-9])\s+([1-2][0-9]{3})(?=\s)
colours=unchanged,dark
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
# colours=unchanged,"\033[1;38;5;27m",default,"\033[38;5;45m",default,"\033[38;5;46m",default,"\033[38;5;48m",default,"\033[1;38;5;51m"
colours=unchanged,bold blue,default,bold green,default,bold yellow,default,bold red,default,"\033[1;38;5;51m"
=======
# Trailing slash
regexp=(/)(?:$| -> )
colours=blue
