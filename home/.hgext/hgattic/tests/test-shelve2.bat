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
echo ### echo a ^> a.txt
echo a > a.txt
echo ### call hg addrem
call hg addrem
echo ### call hg shelve a
call hg shelve a
echo ### echo b ^> b.txt
echo b > b.txt
echo ### call hg addrem
call hg addrem
echo ### call hg shelve a (should fail)
call hg shelve a
echo ### call hg attic
call hg attic
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
