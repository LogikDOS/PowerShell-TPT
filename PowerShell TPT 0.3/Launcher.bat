@echo off
echo Starting....
start "" powershell -noprofile -executionpolicy bypass -file engine.ps1 >nul || goto error
exit
:error
echo ERROR No engine.ps1 found please download or create a engine.ps1
pause