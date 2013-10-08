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
echo a > a.txt
call hg addrem
call hg shelve -q --git a
echo b > b.txt
call hg addrem
call hg shelve -q --git b
echo ### hg st
call hg st
echo ### hg unshelve
call hg unshelve
echo ### hg st
call hg st
call hg shelve -q
echo ### hg unshelve a
call hg unshelve a
echo ### hg st
call hg st
echo ### hg unshelve b (should fail)
call hg unshelve b
echo ### hg unshelve -f b (should pass)
call hg unshelve -f b
echo ### hg st
call hg st
echo ### current applied patch
type .hg\attic\.applied
echo ### hg shelve c (should fail)
call hg shelve c
echo ### hg shelve -f c (should pass)
call hg shelve -f --git c
echo ### hg st
call hg st
echo ### contents of c
type .hg\attic\c
echo ### files in attic
for %%f in (.hg\attic\*.*) do echo %%f
echo ### call hg unshelve --delete b
call hg unshelve --delete b
echo ### call hg unshelve --delete a (should fail)
call hg unshelve --delete a
echo ### call hg unshelve --delete -f a
call hg unshelve --delete -f a
echo ### files in attic
for %%f in (.hg\attic\*.*) do echo %%f
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
