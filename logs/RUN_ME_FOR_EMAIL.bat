@echo off
title **MAKING SYSTEM LOG, DO NOT EXIT**
IF EXIST logs.zip (del logs.zip)
IF EXIST *_FullSystemLog.log (del *_FullSystemLog.log)
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set log=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%_FullSystemLog.log
echo -- SYSTEM INFO -->%log%
systeminfo >>%log% 
echo -- TASK LIST -->>%log%
tasklist >>%log%
echo -- NET USER -->>%log%
net user >>%log%
echo -- ATTEMPT PHONE LOG -- >>%log%
echo Getting info from phone ...
..\support_files\adb kill-server >>%log% 2>&1
..\support_files\adb shell getprop >>%log% 2>&1
..\support_files\adb kill-server >>%log% 2>&1
title **ZIPPING LOGS, DO NOT EXIT**
cls
echo Zipping logs ...
..\support_files\zip -j ..\logs\logs.zip ..\logs\*.log >NUL 2>&1
del *.log
cls
title Done!
echo.
echo Done!
echo.
echo Please email logs.zip to lukeafrazier@gmail.com and explain the issue.
echo.
echo Press enter to exit.
pause >NUL
exit
