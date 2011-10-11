@echo off
rem provjeri da li je conf backupiran
if not exist c:\tops\FP_Server.bak   goto :copy_conf

:kill
taskkill /F /IM FP_Server.exe /T
tasklist /FI "IMAGENAME eq FP_Server.exe" 2>NUL | find /I /N "FP_Server.exe">NUL
if "%ERRORLEVEL%"=="0" goto kill 

:start
echo "Startam FP Server" 
cd "c:\tops" 
copy /Y  FP_Server.bak "%USERPROFILE%\Application Data\Tremol\FP_Server.config" 
cd "%PROGRAMFILES%\OPOS\Tremol\Tools\
start FP_Server.exe
exit

:copy_conf
copy  "%USERPROFILE%\Application Data\Tremol\FP_Server.config"  c:\tops\FP_Server.bak
goto start 