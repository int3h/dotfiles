#!/usr/bin/env bash

# Commands to bookmark and recall directories, as in for `cd`

BOOKMARK_FILE=~/.bookmarks

if [ ! -f "$BOOKMARK_FILE" ]; then  # if doesn't exist, create it
	touch "$BOOKMARK_FILE"
    echo "#!/usr/bin/env bash" > "$BOOKMARK_FILE"
    echo "# User-defined directory bookmarks. Create with 'save [name]', view with 'show'" >> "$BOOKMARK_FILE"
fi

alias showbookmarks="cat $BOOKMARK_FILE | grep -v '^#'"
bookmark (){
    # add the new bookmark to the file
	echo "$@"="`pwd`" >> "$BOOKMARK_FILE"; 
    # strip out any empty bookmark entries
    sed -e 's/[a-zA-Z_][a-zA-Z0-9_]*=$//' -e '/^$/ d' -i '' "$BOOKMARK_FILE"
    # source the file
    source "$BOOKMARK_FILE" 
}
rmbookmark (){
    sed -e "s/$1=.*\$//" -e '/^$/ d' -i '' "$BOOKMARK_FILE"
}
source "$BOOKMARK_FILE"  # Initialization for the above 'save' facility: source the .sdirs file
shopt -s cdable_vars # set the bash option so that no '$' is required when using the above facility
