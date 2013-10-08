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
call hg st
call hg shelve --git -q a
call hg unshelve -q
echo ### hg ci -m "commit message"
call hg ci -m "commit message"
echo ### hg log --template "{rev} {desc} {files}\n"
call hg log --template "{rev} {desc} {files}\n"

echo c >> a.txt
call hg shelve --git -q -m "commit message 3" a
call hg unshelve -q
echo ### hg ci
call hg ci
echo ### hg log --template "{rev} {desc} {files}\n"
call hg log --template "{rev} {desc} {files}\n"

echo d >> a.txt
call hg shelve --git -q -m "commit message 4" a
call hg unshelve -q
echo ### hg ci -m "commit message 5"
call hg ci -m "commit message 5"
echo ### hg log --template "{rev} {desc} {files}\n"
call hg log --template "{rev} {desc} {files}\n"
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
