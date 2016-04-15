# size
regexp=(\s|^)(\d+)([.,]\d+)?\s?([kKMG][bB]|[bB]|[kKMG])(?=[\s,]|$)
colours=unchanged,unchanged,blue,blue,bold green
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
# root
regexp=root|wheel|admin(?=\s|$)
colours=red
=======
# Hide the 'number of links' column that comes after the file permissions
regexp=(?<=^[-bcCdDlMnpPs?][-r][-w][-xsStT][-r][-w][-xsStT][-r][-w][-xsStT][@+ ])(\s*)(\d+)
colours=unchanged,unchanged,concealed
=======
# Arrow used to denote `link -> target`
regexp=\s(->)\s
colours=unchanged,bold white
=======
# Permissions
regexp=(?:\s|^)((-)|[bcCdDlMnpPs?])((?:(-)|[wrxsStT]){3})((?:(-)|[wrxsStT]){3})((?:(-)|[wrxsStT]){3})([@+]?)(?=\s|$)
# colours=unchanged,"\033[1;38;5;27m",default,"\033[38;5;45m",default,"\033[38;5;46m",default,"\033[38;5;48m",default,"\033[1;38;5;51m"
colours=unchanged,bold blue,default,bold green,default,bold yellow,default,bold red,default,"\033[1;38;5;51m"
