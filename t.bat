@echo off
color 0b
set log=a.txt
cls
echo ------------------------------
echo             Rooter      
echo ------------------------------
echo.
echo Exploiting main version with misctool,
echo thanks con247 ^& drellisdee!
support_files\adb push support_files\root\ICS\misctool /tmp/ >>%log% 2>&1
support_files\adb shell chmod 777 /tmp/misctool
support_files\adb shell /tmp/misctool w 1.00.000.0 >support_files\misc
support_files\cat support_files/misc >>%log%
support_files\cat support_files/misc 
pause >NUl