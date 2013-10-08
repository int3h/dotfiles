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
echo ### echo a ^> a.txt
echo a > a.txt
echo ### call hg addrem
call hg addrem
echo ### call hg st
call hg st
echo ### call hg shelve --git -q a
call hg shelve --git -q a
echo ### call hg unshelve -q
call hg unshelve -q
echo ### type .hg\attic\a
type .hg\attic\a
echo ### echo b ^>^> a.txt
echo b >> a.txt
echo ### call hg shelve --refresh
call hg shelve --refresh
echo ### type .hg\attic\a
type .hg\attic\a
echo ### call hg shelve -r -m test
call hg shelve -r -m test
echo ### type .hg\attic\a
type .hg\attic\a
echo ### call hg shelve -r b
call hg shelve -r b
echo ### call hg shelve -r -f b
call hg shelve -r -f b
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
