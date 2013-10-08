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
echo ### echo b ^> b.txt
echo b > b.txt
echo ### call hg addrem
call hg addrem
call hg ci -m "commit"
echo ### echo a ^>^> a.txt
echo a >> a.txt
echo ### echo b ^>^> b.txt
echo b >> b.txt
echo ### call hg st
call hg st
echo ### call hg shelve --interactive --git a
call hg shelve --interactive --git a
echo ### echo hgext.record= ^>^>.hg\hgrc
echo hgext.record= >>.hg\hgrc
echo ### call hg shelve --interactive --git a
echo ### answer f then s
call hg shelve --interactive --git a
echo ### call hg st
call hg st
echo ### files in attic
for %%f in (.hg\attic\*.*) do echo %%f
echo ### call hg unshelve (should fail)
call hg unshelve
echo ### call hg shelve b
call hg shelve b
echo ### call hg unshelve a
call hg unshelve a
echo ### call hg st
call hg st
rem end test content

rem cleanup
cd ..
rmdir /S /Q test
endlocal
