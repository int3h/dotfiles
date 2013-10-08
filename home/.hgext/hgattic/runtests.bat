@echo off
rem runtests.bat - command line test runner
rem
rem Copyright 2009 Bill Barry <after.fallout@gmail.com>
rem
rem This software may be used and distributed according to the terms
rem of the GNU General Public License, incorporated herein by reference.

rem This program will run all the test files in a tests subdirectory.
rem   A test is a batch script in the form "testSSSS.bat" with an output file
rem   in the form "testSSSS.out"
rem
rem   A test succeeds if it generates the expected output file.
rem   If a test fails, you can rerun with -v to get diff output.
rem
rem   diff is required to run this and must be available in your path
setlocal
pushd tests

if "%1" == "-v" set verbose=1
if "%1" == "-u" set update=1

set /A numtests= 0
set /A numfails= 0
set /A numpass= 0

for %%t in ("test*.bat") do call :run %%~nt

echo %numtests% tests taken
echo %numpass% tests passed
if %numfails% NEQ 0 echo %numfails% tests failed

goto :end

:run
set /A numtests += 1
call %1.bat > testoutput 2>&1
if "%update%" == "1" call %1.bat > %1.out 2>&1
diff -u %1.out testoutput > diffresults.txt 
for %%R in ("diffresults.txt") do call :checksize %%~zR %1 
erase testoutput
erase diffresults.txt
goto :eof

:checksize
if "%1" == "0" call :testpassed %2 
if "%1" NEQ "0" call :testfailed %2
goto :eof

:testfailed
echo failed %1
set /A numfails += 1
if "%verbose%" == "1" echo diff output:
if "%verbose%" == "1" type diffresults.txt
goto :eof

:testpassed
echo passed %1
set /A numpass += 1
goto :eof

:end
popd
endlocal

:eof
echo on
