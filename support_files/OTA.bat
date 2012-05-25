@echo off
::
:: This file is part of the Script Update Engine by trter10.
::
:: This program is free software. It comes without any warranty, to
:: the extent permitted by applicable law. You can redistribute it
:: and/or modify it under the terms of the Do What The Fuck You Want
:: To Public License, Version 2, as published by Sam Hocevar. See
:: http://sam.zoy.org/wtfpl/COPYING for more details.
:: 
echo.
echo -There is a new version of this script availible. Downloading now...
echo.
IF NOT EXIST support_files\Script-server-MD5.txt (support_files\wget --quiet -O support_files\Script-server-MD5.txt http://dl.dropbox.com/u/61129367/Script-server-MD5.txt)
::Getting new version's download link.
del ThunderboltTool.bat
support_files\wget -O support_files\ThunderboltTool.bat http://dl.dropbox.com/u/61129367/ThunderboltTool.bat
MOVE support_files\ThunderboltTool.bat ThunderboltTool.bat >NUL
echo.
::Checking MD5sums again, just to make it failproof.
support_files\md5sums ThunderboltTool.bat>support_files\Script-new-MD5.txt
fc /b support_files\Script-new-MD5.txt support_files\Script-server-MD5.txt >NUL
if errorlevel 1 (Goto re-DL)
start ThunderboltTool.bat
del support_files\Script-new-MD5.bat
exit
:re-DL
del ThunderboltTool.bat
support_files\wget -O support_files\ThunderboltTool.bat http://dl.dropbox.com/u/61129367/ThunderboltTool.bat
MOVE support_files\ThunderboltTool.bat ThunderboltTool.bat >NUL
echo.
::Checking MD5sums again, just to make it failproof.
support_files\md5sums ThunderboltTool.bat>support_files\Script-new-MD5.txt
fc /b support_files\Script-new-MD5.txt support_files\Script-server-MD5.txt >NUL
if errorlevel 1 (Goto re-DL)
start ThunderboltTool.bat
del support_files\Script-new-MD5.bat
exit