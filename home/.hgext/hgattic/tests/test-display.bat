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
move tmp hgrc
cd ..

rem replace here with test content
echo a > a.txt
call hg addrem
call hg shelve -q a
echo b > b.txt
call hg addrem
call hg shelve -q b
echo ### hg attic
call hg attic
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
