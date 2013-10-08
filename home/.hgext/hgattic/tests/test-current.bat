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
echo ### call hg attic --current
call hg attic --current
echo ### echo a ^> a.txt
echo a > a.txt
echo ### call hg addrem
call hg addrem
echo ### call hg st
call hg st
echo ### call hg shelve --git -q a
call hg shelve --git -q a
echo ### call hg attic -c
call hg attic -c
echo ### call hg unshelve -q
call hg unshelve -q
echo ### call hg attic -c
call hg attic -c
echo ### call hg shelve -r -q -m "commit message"
call hg shelve -r -q -m "commit message"
echo ### call hg attic -c
call hg attic -c
echo ### call hg shelve -r -q -m "another message" -u "test user <asdf@asdf.com>"
call hg shelve -r -q -m "another message" -u "test user <asdf@asdf.com>"
echo ### call hg attic -c
call hg attic -c
echo ### call hg shelve -r -q -d "1 0"
call hg shelve -r -q -d "1 0"
echo ### call hg attic -c
call hg attic -c
echo ### call hg shelve
call hg shelve
echo ### echo b ^> b.txt
echo b > b.txt
echo ### call hg add
call hg add
echo ### call hg shelve -m "new message" b
call hg shelve -m "new message" b
echo ### call hg attic -i a
call hg attic --header a
echo ### call hg attic -i b
call hg attic -d b
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
