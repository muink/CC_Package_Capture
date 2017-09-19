@echo off
mklink /h "%~d2\CCPKG\%~nx1" "%~2"||mklink /h "%~d2\CCPKG\%~n1" "%~dpn2"||set "fname=%~nx1"
cd /d %~d2\CCPKG
set /a tmp=%random%
md %tmp%.tmp>nul 2>nul
move "%~nx1" %tmp%.tmp\>nul 2>nul
move "%~n1" %tmp%.tmp\>nul 2>nul
