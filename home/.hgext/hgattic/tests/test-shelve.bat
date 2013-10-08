@echo off

rem setup hgattic in a temp test directory
setlocal
cd ..
cd > tmpfile
set /p atticdir= < tmpfile
erase tmpfile
cd tests
mkdir test
cd test
call hg init
cd .hg
echo [extensions] >tmp
echo hgattic=%atticdir%\attic.py >>tmp

rem now that attic shelves hg format patches all the time a user needs to be
rem configured for tests and datetime information must be provided for the
rem shelve command
echo [ui] >>tmp
echo username=Fred Widget ^<fred@example.com^>>>tmp
echo [defaults] >>tmp
echo attic-shelve = -d "0 0" >>tmp

move tmp hgrc
cd ..

rem replace here with test content
echo something > default.txt
call hg addrem
echo ### call hg shelve (should shelve to default)
call hg shelve --git
echo a > a.txt
call hg addrem
call hg st
rem use git format for this so that dates are gone from the default diffs
echo ### call hg shelve --git a
call hg shelve --git a
echo ### call hg shelve (should fail)
call hg shelve
echo ### echo asdf ^> asdf.txt
echo asdf > asdf.txt
echo ### call hg addrem
call hg addrem
echo ### call hg shelve (should fail)
call hg shelve
echo ### call hg revert -a
call hg revert -a
echo ### erase asdf.txt
erase asdf.txt
echo ### a contents
type .hg\attic\a
echo ### hg st
call hg st
echo ### end hg st
call hg unshelve
echo ### hg st
call hg st
echo ### end hg st
echo b >> a.txt
call hg shelve
echo ### a contents
type .hg\attic\a
echo ### unshelve
call hg unshelve
echo ### hg st
call hg st
echo ### end hg st
call hg shelve
echo ### a contents
type .hg\attic\a
echo ### unshelve
call hg unshelve
echo ### hg st
call hg st
echo ### end hg st
call hg shelve -m "commit message"
echo ### a contents
type .hg\attic\a
echo ### unshelve
call hg unshelve
echo ### hg st
call hg st
echo ### end hg st
call hg shelve -m "another message" -u "test user <asdf@asdf.com>"
echo ### a contents
type .hg\attic\a
echo ### unshelve
call hg unshelve
echo ### hg st
call hg st
echo ### end hg st
call hg shelve -d "0 0"
echo ### a contents
type .hg\attic\a
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
