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
echo ### mkdir b
mkdir b
echo ### echo b ^> b\b.txt
echo b > b\b.txt
echo ### call hg addrem
call hg addrem
echo ### call hg st
call hg st
echo ### call hg shelve -r --git -q a
call hg shelve -r --git -q a
echo ### cd b
cd b
echo ### call hg shelve --git -q -f b
call hg shelve --git -q -f b
echo ### cd ..
cd ..
echo ### diff .hg\attic\a .hg\attic\b
diff .hg\attic\a .hg\attic\b
echo ### cd b
cd b
echo ### call hg unshelve
call hg unshelve
echo ### call hg st
call hg st
cd ..
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
