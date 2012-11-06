@echo off
::
:: This file is part of the Script Update Engine by trter10.
::
:: This program is free software. It comes without any warranty, to
:: the extent permitted by applicable law. You can redistribute it
:: and/or modify it under the terms of the Do What The F*** You Want
:: To Public License, Version 2, as published by Sam Hocevar. See
:: http://sam.zoy.org/wtfpl/COPYING for more details.
:: 
::Setting up logging
::Special thanks to Alex K. here http://tinyw.in/nh4r
::He solved a tricky log file naming issue for us.
::Because God knows I couldn't have solved it. :P
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set log=logs\%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%_UPDATE.log
echo Starting Thunderbolt Tool Updater at %date% %time% >%log%
echo -- >>%log%
:MAIN
cls
echo Updating...
echo.
IF NOT EXIST support_files\Script-server-MD5.txt (support_files\wget --quiet -O support_files\Script-server-MD5.txt http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/Script-server-MD5.txt?param=test >>%log%)
del ThunderboltTool.bat
support_files\wget -O support_files\ThunderboltTool.bat http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/ThunderboltTool.bat?param=test >>%log% 2>&1
MOVE support_files\ThunderboltTool.bat ThunderboltTool.bat >>%log%
echo.
::Checking MD5sums again, just to make it failproof.
for /f "tokens=1 delims=" %%a in ( 'support_files\md5sums ThunderboltTool.bat' ) do ( set newmd5=%%a )
set /p servermd5=<support_files\Script-server-MD5.txt
echo Our checksum is      %newmd5% >>%log%
echo Correct checksum is  %servermd5% >>%log%
if "%newmd5%" NEQ "%servermd5%" (
echo Re-Downloading due to bad checksum >>%log%
GOTO MAIN
)
del support_files\Script-new-MD5.txt
cls
ThunderboltTool.bat