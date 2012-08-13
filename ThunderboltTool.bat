::  This program is free software: you can redistribute it and/or modify
::    it under the terms of the GNU General Public License as published by
::    the Free Software Foundation, either version 3 of the License, or
::    (at your option) any later version.
::
::    This program is distributed in the hope that it will be useful,
::    but WITHOUT ANY WARRANTY; without even the implied warranty of
::    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::    GNU General Public License for more details.
::
::    You should have received a copy of the GNU General Public License
::    along with this program.  If not, see <http://www.gnu.org/licenses/>.
::    HINT: License is in README.txt.
::
@echo off
SETLOCAL
set verno=v0.2b1
set buildtime=June 14 2012, 12:24 AM EST
title                                            HTC Thunderbolt Tool %verno%
color 0b
IF "%1" == "INFO" (
echo Verno - %verno% >info.log
echo Buildtime - %buildtime% >>info.log
exit
)
::
::Setting up logging
::Special thanks to Alex K. here http://tinyw.in/nh4r
::He solved a tricky log file naming issue for us.
::Because God knows I couldn't have solved it. :P
echo Starting up...
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set log=logs\%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%_%verno%.log
IF NOT EXIST logs (MKDIR logs)
echo Starting Thunderbolt Tool %verno% build %buildtime% at %date% %time% >%log%
::Making sure that we extracted correctly
IF "%PATH%" NEQ "C:\WINDOWS\SYSTEM32" (
echo Setting path >>%log%
set path=C:\WINDOWS\SYSTEM32
)
set uze=no
set sf=here
set rm=here
set dv=here
set modver=
IF NOT EXIST Driver.exe (
set dv=missing
set uze=yes
)
IF NOT EXIST README.txt (
set rm=missing
set uze=yes
)
IF NOT EXIST support_files (
set sf=missing
set uze=yes
)
IF "%uze%" == "yes" (GOTO UNZIP-ERR)
::Other necessary actions
IF NOT EXIST support_files\RAN1 (start README.txt)
echo Program ran for first time. >support_files\RAN1
IF NOT EXIST support_files\download (mkdir support_files\download)
IF EXIST ThunderboltTool.exe (del ThunderboltTool.exe)
::Removing unneeded files
IF EXIST back.bat (del back.bat)
IF EXIST adbwinapi.dll (del adbwinapi.dll)
IF EXIST adbwinusbapi.dll (del adbwinusbapi.dll)
IF EXIST fastboot.exe (del fastboot.exe)
IF EXIST adb.exe (del adb.exe)
::*********************************SKIPPING UPDATES, REMOVE THIS PRIOR TO RELEASE******************************
GOTO PROGRAM rem ADD :: FOR RELEASE VERSIONS
:: * Script update engine  *
echo Checking for updates...
::In case of freshly updated script...
IF EXIST support_files\Script-MD5.txt (del support_files\Script-MD5.txt)
IF EXIST OTA.bat (MOVE OTA.bat support_files\OTA.bat) >NUL
IF EXIST support_files\Script-server-MD5.txt (del support_files\Script-server-MD5.txt)
::Building MD5 of current script
support_files\md5sums ThunderboltTool.bat >support_files\Script-MD5.txt
:: Downloading latest MD5 Definitions
support_files\wget --quiet -O support_files\Script-server-MD5.txt http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/Script-server-MD5.txt?param=test
::Checking to see if there's a new version...
fc /b support_files\Script-MD5.txt support_files\Script-server-MD5.txt >NUL
if errorlevel 1 (
Echo Updating >>%log%
GOTO OTA
)
del support_files\Script-new-MD5.txt >>%log% 2>&1
echo No updates availible. >>%log%
echo -- >>%log%
GOTO PROGRAM

:OTA
echo Updating >>%log%
MOVE support_files\OTA.bat OTA.bat >>%log% 2>&1
OTA.bat
exit
:PROGRAM
::Rooter fix
IF EXIST support_files\root\cp (GOTO skipmv)
IF EXIST support_files\root (
echo Running rooter hotfix >>%log%
copy support_files\AdbWinApi.dll support_files\root\AdbWinApi.dll >NUL
copy support_files\AdbWinUsbApi.dll support_files\root\AdbWinUsbApi.dll >NUL
echo copied >support_files\root\cp
)
:skipmv
::Getting SED and its .dll's if the need exists
:REGETSED
IF NOT EXIST support_files\download\sed.zip (goto skipsedmd5)
FOR /F "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\download\sed.zip' ) do ( set sedmd5=%%a )
echo Our checksum is         %sedmd5% >>%log%
echo The correct checksum is 5F4BA3E44B33934E80257F3948970868  support_files\download\sed.zip >>%log%
IF "%sedmd5%" NEQ "5F4BA3E44B33934E80257F3948970868  support_files\download\sed.zip " (
del support_files\download\sed.zip
GOTO REGETSED
)
GOTO regetzip
:skipsedmd5
echo Getting sed >>%log%
support_files\wget -O support_files\download\sed.zip http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/SED.zip?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
FOR /F "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\download\sed.zip' ) do ( set sedmd5=%%a )
echo Our checksum is         %sedmd5% >>%log%
echo The correct checksum is 5F4BA3E44B33934E80257F3948970868  support_files\download\sed.zip >>%log%
IF "%sedmd5%" NEQ "5F4BA3E44B33934E80257F3948970868  support_files\download\sed.zip " (
del support_files\download\sed.zip
GOTO REGETSED
)
)
IF NOT EXIST support_files\sed.exe (support_files\unzip support_files\download\sed.zip -d support_files\ >>%log%)
:regetzip
IF NOT EXIST support_files\zip.exe (GOTO skipzipmd5)
FOR /F "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\zip.exe' ) do ( set zipmd5=%%a )
IF "%zipmd5%" == "83AF340778E7C353B9A2D2A788C3A13A  support_files\zip.exe " (GOTO donezip)
:skipzipmd5
echo Getting zip >>%log%
support_files\wget --quiet -O support_files\zip.exe http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/zip.exe?param=test
FOR /F "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\zip.exe' ) do ( set zipmd5=%%a )
IF "%zipmd5%" NEQ "83AF340778E7C353B9A2D2A788C3A13A  support_files\zip.exe " (
del support_files\zip.exe
goto regetzip
)
:donezip
IF NOT EXIST logs\RUN_ME_FOR_EMAIL.bat (
echo Getting necessary files..
echo Getting log .bat >>%log%
support_files\wget --quiet -O logs\RUN_ME_FOR_EMAIL.bat http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/RUN_ME_FOR_EMAIL.bat?param=test
)
::Editing OTA.bat
support_files\cat support_files/OTA.bat | support_files\sed -e s/"echo There is a new version of this script availible. Downloading now..."/"echo Updating..."/ >support_files\newota.bat
support_files\cat support_files/newota.bat >support_files\OTA.bat
del support_files\newota.bat
::
IF EXIST support_files\Script-MD5.txt (del support_files\Script-MD5.txt)
IF EXIST support_files\Script-server-MD5.txt (del support_files\Script-server-MD5.txt)
:SKIPOTAEDIT
::Would direct output to log, but it links
::adb to the log so I cannot echo to it afterwards...
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
:MAIN
::Just in case...
IF EXIST support_files\adbroot (del support_files\adbroot)
IF EXIST support_files\bl (del support_files\bl)
IF EXIST support_files\romver (del support_files\romver)
IF EXIST support_files\here (del support_files\here)
::In case of any odd errors
set romver=Unknown
set romver1=Unknown
set bootloader=Unknown
set adbrt=Unknown
set andver=Unknown
set here=NULL
set su=Unknown
set sutest=Unknown
::Seeing if phone is online
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here 2>&1
set here=NULL
set /p here=<support_files\here
del support_files\here
if "%here%" == "a" (GOTO MAIN2)
::If the script is still going at this point,
::and has not went to :MAIN2, we will set a 
::variable that tells the program that the 
::phone is not connected.
support_files\fastboot devices >support_files\fbd 2>&1
FOR /F "tokens=1 delims= " %%a in ( 'support_files\md5sums support_files\fbd' ) do ( set fbd=%%a )
del support_files\fbd
IF "%fbd%" NEQ "D41D8CD98F00B204E9800998ECF8427E " (GOTO FASTBOOTONTOOLBOOT)
echo Phone not connected! >>%log%
set warn=nc
::Skipping unneccessary commands...
GOTO skip
:MAIN2
set warn=
echo Getting phone info >>%log%
echo -- >>%log%
support_files\adb shell mkdir /sdcard/tbolt-tool >NUL 2>&1
::My workaround to get this to work in recovery mode (Just in case)
::Any addidtional /system/bin's before getprop are for this reason also.
FOR /F "tokens=1 delims=" %%a in ( 'support_files\adb shell mount system' ) do ( set bv=%%a )
IF "%bv%" == "Usage: mount [-r] [-w] [-o options] [-t type] device directory " (
echo Phone is normally booted >>%log%
set recovery=No
goto normboot
)
IF "%bv%" == "mount: can't read '/etc/fstab': No such file or directory " (
echo Phone is normally booted >>%log%
set recovery=No
goto normboot
)
echo Phone is in recovery mode >>%log%
support_files\adb shell mount /sdcard >%log% 2>&1
support_files\adb shell mount /data >%log% 2>&1
support_files\adb shell mount /cache >>%log% 2>&1
set recovery=yes

:normboot
::Checking ROM Version
::Android ver
for /f "tokens=2 delims==" %%a in ( 'support_files\adb shell cat /system/build.prop ^| find "ro.build.version.release"' ) do ( set andver=%%a )
::Workaround for recovery mode so that we can still get romver
::
::Now looing back on this code (It is now 8/4/2012) I have no idea how this adds recovery compatibility.
::But I'm not gonna screw with it.
::
for /f "tokens=2 delims==" %%a in ( 'support_files\adb shell cat /system/build.prop ^| find "ro.product.version"' ) do ( set romver1=%%a )
IF "%romver1%" == "Unknown" (for /f "tokens=2 delims==" %%a in ( 'support_files\adb shell cat /system/build.prop ^| find "ro.build.display.id"' ) do ( set romver1=%%a ))
::In case of CM7
IF "%romver1%" == "GRJ22 " (
set romver2=CM7
for /f "tokens=2 delims==" %%a in ( 'support_files\adb shell cat /system/build.prop ^| find "ro.modversion"' ) do ( set modver=%%a )
)
IF "%romver2%" == "CM7" (set romver1=CyanogenMod 7 -)
set romver=%romver1% %modver%
::Checking bootloader
for /f "tokens=1 delims=" %%a in ( 'support_files\adb shell /system/bin/getprop ro.bootloader' ) do ( set bl=%%a )
IF "%bl%" == "6.04.1002 " (set bootloader=Revolutionary S-OFF)
IF "%bl%" == "1.04.2000 " (set bootloader=ENG S-OFF)
IF "%bl%" == "1.04.0000 " (set bootloader=Stock S-ON)
IF "%bl%" == "1.05.0000 " (set bootloader=Stock S-ON)
::Seeing if ADB-Rooted so we can determine
::how to carry out certain actions.
for /f "tokens=1 delims=" %%a in ( 'support_files\adb shell /system/bin/getprop ro.secure' ) do ( set adbroot=%%a )
IF "%adbroot%" == "0 " (set adbrt=Yes) ELSE (set adbrt=No)
IF "%recovery%" == "yes" (Set adbrt=Yes)
::Seeing if su is updated/installed
::Our assumptions, may change later in script
set suhere=1
set oldsu=- Outdated, please update in app
::Just in case phone is removed in process we echo out these
set su1=Unknown
set suver=Unknown
::For the real work
FOR /F "tokens=2 delims=:" %%a in ( 'support_files\adb shell /system/xbin/su -v') do ( set su1=%%a )
FOR /F "tokens=1 delims=:" %%a in ( 'support_files\adb shell /system/xbin/su -v') do ( set suver=%%a )
::Seeing if they do have su in the first place
IF "%su1%" == " /system/xbin/su: not found " (
set suhere=0
goto skipsu
)
IF "%su1%" == " not found " (
set suhere=0
goto skipsu
)
IF "%su1%" == " permission denied " (
set suhere=0
goto skipsu
)
IF "%su1%" == "SUPERSU " (set sukind=SuperSU)
IF "%su1%" == "Unknown" (set sukind=Superuser)
::Be sure to replace these with the current version when updated
IF "%suver%" == "0.92 " (set oldsu=- Up to date)
IF "%suver%" == "3.1.1 " (set oldsu=- Up to date)
:skipsu
::In case of any errors
cls
::Now to echo the output
echo.
echo Bootloader: %bl% %bootloader% >>%log%
echo ADB rooted: %adbrt% >>%log%
echo ROM Version: %romver% - Android %andver% >>%log%
echo Superuser: %sukind% binary v%suver%%oldsu% >>%log%
echo -- >>%log%
:skip
title                                            HTC Thunderbolt Tool %verno%
set m=NULL
cls
IF "%bl%" == "1.04.2000 " (set rooted=yes)
IF "%bl%" == "6.04.1002 " (set rooted=yes)
IF "%bl%" == "1.04.0000 " (set rooted=no)
IF "%bl%" == "1.05.0000 " (set rooted=no)
::Determining what menu to show
IF "%warn%" == "nc" (GOTO nophonemain)
IF "%rooted%" == "no" (GOTO stockmain)
IF "%suhere%" == "0" (GOTO nosumain)
IF "%rooted%" == "yes" (GOTO rootmain)
:errormain
cls
echo Bootloader info error! >>%log%
echo                Welcome to the HTC Thunderbolt tool, by trter10.
echo.
echo There was an error getting bootloader information.
echo If this persists, please contact me.
echo.
echo Press enter to exit.
pause >NUL
GOTO EXIT
:nosumain
cls
echo Loading no su main >>%log%
echo                Welcome to the HTC Thunderbolt tool, by trter10.
echo.
echo The SU binary is missing from your phone.
echo.
echo Press enter to install it.
pause >NUL
GOTO SOFFNOROOT2

:FASTBOOTONTOOLBOOT
cls
echo Device in fastboot >>%log%
support_files\fastboot getvar version-baseband >support_files\bb 2>&1
set /p baseband1=<support_files\bb
del support_files\bb
FOR /F "tokens=2 delims=:" %%a in ( 'echo %baseband1%' ) do ( set baseband=%%a )
support_files\fastboot getvar security >support_files\sec 2>&1
set /p security1=<support_files\sec
del support_files\sec
FOR /F "tokens=2 delims= " %%a in ( 'echo %security1%' ) do ( set security=%%a )
support_files\fastboot getvar version-bootloader >support_files\bl 2>&1
set /p hbootver1=<support_files\bl
del support_files\bl
FOR /F "tokens=2 delims= " %%a in ( 'echo %hbootver1%' ) do ( set hbootver=%%a )
echo                Welcome to the HTC Thunderbolt tool, by trter10.
echo.
echo WARNING! Device detected in fastboot mode. Please select "REBOOT" on the phone  to begin using the tool.
echo.
echo ----
echo  *S-%security%
echo.
echo  *Hboot %hbootver%
echo.
echo  *Radio%baseband%
echo ----
echo.
echo Press any key to begin searching for device...
pause >NUL
cls
GOTO nophonemain

:stockmain
cls
echo Loading stock main >>%log%
echo -- >>%log%
echo                Welcome to the HTC Thunderbolt tool, by trter10.
echo.
echo Your phone is not S-OFF.
echo.
echo Press enter to S-OFF, install Superuser, and block OTA updates.
echo (This will NOT wipe data, but will void your warranty!)
pause >NUL
GOTO ROOT1

::Old stock main menu, I may decide to re-incorporate it later.
echo                Welcome to the HTC Thunderbolt tool, by trter10.
set m=NULL
echo.
echo Phone information: 
echo.
echo         * WARNING: Phone is stock! You must use 
echo           option 1 before more functions are availible! 
echo.
echo   ROM Version: %romver% - Android %andver%
echo.
echo  MAIN MENU
echo --------------------------------------------------------
echo       1 - S-OFF and root
echo       2 - About
echo       R - Reload info
echo --------------------------------------------------------
set /p m=Choose what you want to do. 
IF "%M%" == "1" (GOTO ROOT1)
IF "%M%" == "2" (GOTO ABOUT)
IF "%M%" == "r" (GOTO SKIPOTAEDIT)
IF "%M%" == "R" (GOTO SKIPOTAEDIT)
IF "%M%" == "NULL" (
echo -- >>%log%
GOTO EXIT
)
GOTO stockmain

:rootmain
cls
echo Loading root main menu >>%log%
echo -- >>%log%
echo                 Welcome to the HTC Thunderbolt tool, by trter10.
set m=NULL
echo.
echo Phone information: 
echo.
echo     ROM Version: %romver%- Android %andver%
IF "%recovery%" == "yes" (echo     Boot mode: Recovery) ELSE (echo     Boot mode: Normal)
echo     %sukind% binary v%suver%%oldsu%
echo.
echo  MAIN MENU
echo --------------------------------------------------------
echo       1 - Recovery menu 
echo       2 - Boot menu
echo       3 - Extras menu
echo       4 - Unroot
echo       5 - About
echo       R - Reload info
echo --------------------------------------------------------
set /p m=Choose what you want to do or hit enter to exit. 
IF "%M%" == "1" (GOTO RECOVERY)
IF "%M%" == "2" (GOTO BOOT)
IF "%M%" == "3" (GOTO EXTRAS)
IF "%M%" == "4" (GOTO UNROOT)
IF "%M%" == "5" (GOTO ABOUT)
IF "%M%" == "r" (GOTO SKIPOTAEDIT)
IF "%M%" == "R" (GOTO SKIPOTAEDIT)
IF "%M%" == "NULL" (
echo -- >>%log%
GOTO EXIT
)
GOTO ROOTMAIN

:nophonemain
echo Loading phone not connected prompt >>%log%
echo -- >>%log%
cls
set m=NULL
echo                Welcome to the HTC Thunderbolt tool, by trter10.
echo.
echo Device not connected! 
echo.
echo If you are having issues, please read the README.txt.
echo.
echo Waiting for device connection...
echo.
:nophonemain2
::I can't use a FOR /F here, because if I do it prints "error: device not found" repeatedly
::So we will do it manually
set here=NULL
support_files\adb shell echo a>support_files\here 2>&1
set /p here=<support_files\here
del support_files\here
if "%here%" NEQ "a" (
GOTO nophonemain2
)
GOTO MAIN

::
:: -----------------------------------------------------------------------
::
:ROOT1
echo Starting rooter >>%log%
:ROOT
cls
echo ------------------------------
echo             Rooter
echo ------------------------------
echo.
echo Preparing rooter...
IF NOT EXIST support_files\download\DowngradeBypass.zip (GOTO getDB)
IF EXIST support_files\download\downgradebypass.zip.md5 (del support_files\download\downgradebypass.zip.md5)
support_files\wget --quiet -O support_files\download\DowngradeBypass.zip.md5 http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/S-O-DowngradeBypass.zip.md5?param=test
for /f "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\download\DowngradeBypass.zip' ) do ( set rootmd5=%%a )
set /p DBzipMD5=<support_files\download\DowngradeBypass.zip.md5
del support_files\download\DowngradeBypass.zip.md5
echo Our checksum is     %rootmd5% >>%log%
echo Correct checksum is %DBzipMD5% >>%log%
IF "%rootmd5%" NEQ "%DBzipMD5% " (
:GetDB
cls
echo ------------------------------
echo             Rooter            
echo ------------------------------
echo.
echo You don't yet have the rooter files, or there is an update.
echo Downloading now...
echo.
echo Downloading Rooter Files >>%log%
IF EXIST support_files\root\ (RMDIR "support_files\root" /S /Q)
support_files\wget -O support_files\download\DowngradeBypass.zip http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/S-O-DowngradeBypass.zip?param=test >>%log% 2>&1
GOTO ROOT
)
title                                            HTC Thunderbolt Tool %verno%
IF NOT EXIST support_files\root (
echo Unzipping rooter files... >>%log%
support_files\unzip support_files\download\DowngradeBypass.zip -d support_files\root >>%log% 2>&1
)
IF EXIST support_files\root\cp (GOTO skipmv2)
IF EXIST support_files\root (
echo Running rooter hotfix >>%log%
copy support_files\AdbWinApi.dll support_files\root\AdbWinApi.dll >NUL
copy support_files\AdbWinUsbApi.dll support_files\root\AdbWinUsbApi.dll >NUL
echo copied >support_files\root\cp
)
:skipmv2
echo Launching Rooter... >>%log%
echo -- >>%log%
color 0a
cls
set m=NULL
echo ------------------------------  INFO:
echo             Rooter                  -You MUST have an sdcard, the
echo ------------------------------       phone in charge only, stay
echo                                      awake enabled, and the phone
echo Press enter when ready.              screen on and unlocked.
pause >NUL
cls
echo ------------------------------
echo             Rooter      
echo ------------------------------
echo. 
for /f "tokens=1 delims=" %%a in ( 'support_files\adb root' ) do ( set rooted=%%a )
IF "%rooted%"=="adbd is already running as root " (GOTO SUCCESSFUL)
set newver=no
IF "%romver%" == "2.11.605.9 " (set newver=yes)
IF "%romver%" == "2.11.605.19 710RD " (set newver=yes)
IF "%newver%" NEQ "yes" (
echo Phone is on ROM Version %romver% so we will use ZergRush. >>%log%
echo Temp rooting >>%log%
support_files\wget --quiet -O support_files\root\ZergRush http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/ZergRush?param=test
echo You are running an old software 
echo version, so we will temp-root
echo with ZergRush. Thanks Revolutionary 
echo team!
support_files\adb push support_files\root\ZergRush /data/local/ >>%log% 2>&1
support_files\adb shell chmod 777 /data/local/ZergRush
support_files\adb shell /data/local/ZergRush >>%log% 2>&1
support_files\adb wait-for-device
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
GOTO SKIPFRE3VO
)
echo Temp-rooting with fre3vo, thanks TeamWin!
echo You will see some static across the top
echo of your phone screen. This is normal.
echo Phone is on ROM Version %romver% so we will use fre3vo. >>%log%
echo Temp rooting >>%log%
support_files\adb push support_files\root\fre3vo /data/local/fre3vo >>%log% 2>&1
support_files\adb shell chmod 777 /data/local/fre3vo
support_files\adb shell /data/local/fre3vo -debug -start F0000000 -end FFFFFFFF >>%log% 2>&1
support_files\adb wait-for-device
support_files\adb shell rm /data/local/fre3vo
:SKIPFRE3VO
cls
echo ------------------------------
echo             Rooter            
echo ------------------------------
echo.
echo Working...
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
::Ensuring root was successful...
for /f "tokens=1 delims=" %%a in ( 'support_files\adb root' ) do ( set rooted=%%a )
IF "%rooted%"=="adbd is already running as root " (GOTO SUCCESSFUL) ELSE (GOTO UNSUCCESSFUL)
:SUCCESSFUL
cls
echo ------------------------------
echo             Rooter            
echo ------------------------------
echo.
echo Root successful >>%log%
color 0c
echo Success!
echo.
echo Just in case of PG05IMG >>%log%
support_files\adb shell rm /sdcard/PG05IMG.zip >>%log% 2>&1
echo Restarting adb...
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
echo.
for /f "tokens=1 delims=" %%a in ( 'support_files\adb shell getprop ro.serialno' ) do ( set serialno=%%a )
echo X = MsgBox("On the revolutionary website, please scroll down to Download for Windows. Click that button, then cancel the download. Enter your phone's information in the prompts that pop up. The info you need is: Seiral Number: %serialno% Hboot version: %hbootver%. Once you do that, copy your beta key from the website, then paste it into the Revolutionary window. To paste it, right click the title bar of the Revolutionary window then click edit then click paste. If there are two revolutionary windows, you can close one. Please note that for Revolutionary to work you need to uninstall Droid Explorer if you have it. Thanks!",0+64+4096, "PLEASE READ - Message from trter10")>support_files\root\rev.vbs
echo X = MsgBox("Please note that you need to enter Y to download and flash CWM recovery at the end of Revolutionary (If it sticks at waiting for fastboot or rebooting to fastboot once moar make sure you have ran the driver and try unplugging and replugging in the phone.) After Revolutionary completes and CWM is flashed, using the volume buttons to navigate and power to select, you will need to exit fastboot by selecting bootloader, waiting a few seconds, then selecting recovery. Then, CWM will automatically install superuser and reboot.",0+64+4096, "PLEASE READ - Message from trter10")>>support_files\root\rev.vbs
:su-no-ota
echo Putting files on phone >>%log%
echo Putting files on your phone...
echo.
support_files\adb wait-for-device
echo  -SU >>%log%
support_files\adb push support_files\root\su.zip /sdcard/su.zip >>%log% 2>&1
echo  -OTABlock >>%log%
support_files\adb push support_files\root\OTABlock.zip /sdcard/OTABlock.zip >>%log% 2>&1
echo  -Extendedcommand >>%log%
support_files\adb push support_files\root\extendedcommand /cache/recovery/extendedcommand >>%log% 2>&1
echo Starting Revolutionary and the Website....
echo Starting Revolutionary and the Website >>%log%
START iexplore.exe Revolutionary.io
START support_files\root\Revolutionary.exe
START support_files\root\Revolutionary.exe
START support_files\root\rev.vbs
echo -- >>%log%
::Had to do this because :EXIT runs 
::adb kill-server, which messes up rev.
echo Exiting... >>%log%
IF EXIST support_files\adbroot (del support_files\adbroot)
IF EXIST support_files\bl (del support_files\bl)
IF EXIST support_files\romver (del support_files\romver)
IF EXIST support_files\here (del support_files\here)
IF EXIST support_files\Script-new-MD5.txt (del support_files\Script-new-MD5.txt)
exit

:UNSUCCESSFUL
cls
echo Root unsuccessful >>%log%
echo -- >>%log%
echo ------------------------------
echo             Rooter            
echo ------------------------------
echo.
echo Root unsuccessful! :(
echo.
echo Try pulling your battery and running again.
echo.
pause
GOTO EXIT
::
:: -----------------------------------------------------------------------
::

:UNROOT
echo Starting unrooter >>%log%
:UNROOT2
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Preparing unrooter...
IF NOT EXIST support_files\download\unroot.zip (GOTO getunroot)
for /f "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\download\unroot.zip' ) do ( set unroothere=%%a )
echo Our checksum is     %unroothere% >>%log%
echo Correct checksum is 770CF07D8DF125E145A4EABF3E7F95B1  support_files\download\unroot.zip >>%log%
IF "%unroothere%" == "770CF07D8DF125E145A4EABF3E7F95B1  support_files\download\unroot.zip " (GOTO rununroot)
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Re-getting unroot files due to bad checksum >>%log%
echo Bad download! Sorry!
echo Redownloading...
GOTO Justgetunroot
:getunroot
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Getting unroot files >>%log%
echo You don't yet have the unroot files.
echo Downloading now... This will take awhile...
echo.
:Justgetunroot
IF EXIST support_files\unroot\ (RMDIR "support_files\unroot" /S /Q)
support_files\wget -O support_files\download\unroot.zip http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/S-O-Unroot.zip?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO UNROOT2
:rununroot
IF NOT EXIST support_files\unroot (
echo Unzipping unrooter files... >>%log%
support_files\unzip support_files\download\unroot.zip -d support_files\unroot >>%log% 2>&1
)
for /f "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\unroot\Stock-ROM.zip' ) do ( set stockromhere=%%a )
echo Our Stock ROM checksum is %stockromhere% >>%log%
echo The correct checksum is   013CBDD3A9B28BC894631008FA2148E2  support_files\unroot\Stock-ROM.zip >>%log%
IF "%stockromhere%" NEQ "013CBDD3A9B28BC894631008FA2148E2  support_files\unroot\Stock-ROM.zip " (
echo Re-unzipping unroot.zip due to bad Stock-ROM.zip checksum >>%log%
RMDIR "support_files\unroot" /S /Q
GOTO rununroot
)
cls
color 0a
echo Launching Unrooter >>%log%
echo ------------------------------  INFO:
echo            Unrooter                 -This will restore COMPLETELY to 
echo ------------------------------       stock. (ROM, splash screen, etc)
echo.
echo Press enter when ready.             -THIS WILL WIPE DATA!! (Contacts, apps...)
echo.
echo                                     -You MUST have an SDCard with at
echo                                      least 455 MB of free space.
echo.
echo                                     -You must have a full battery charge.
echo.
pause >NUL
:REPUSH
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo. 
echo Pushing stock RUU to SDCard... 
echo This will take a few minutes...
echo.
echo Just in case of PG05IMG >>%log%
support_files\adb shell rm /sdcard/PG05IMG.zip >>%log% 2>&1
echo Pushing files >>%log%
support_files\adb push support_files\unroot\Stock-ROM.zip /sdcard/PG05IMG.zip >support_files\push 2>&1
support_files\cat support_files/push >>%log% 2>&1
for /f "tokens=2 delims=(" %%a in ( 'support_files\cat support_files/push' ) do ( set push1=%%a )
echo %push1% >support_files\push
for /f "tokens=1 delims=i" %%a in ( 'support_files\cat support_files/push' ) do ( set push2=%%a )
IF "%push2%" == "462205613 bytes  " (goto good)
del support_files\push
:badpush
set m=NULL
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo. 
echo It appears thete was an error 
echo pushing the RUU.
echo.
echo Please make sure Stay Awake and
echo Charge Only are enabled. The phone
echo screen must stay on for the push.
echo.
echo Press enter to repush...
pause >NUL
 goto REPUSH
:GOOD
echo File pushed >>%log%
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Rebooting to fastboot...
support_files\adb reboot-bootloader
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Your phone's serial number should
echo be below. If it is not, you might 
echo not have ran Driver.exe.
echo.
support_files\fastboot oem readserialno
echo.
echo Press enter if it is.
pause >NUL
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Unlocking HBOOT >>%log%
echo Unlocking HBOOT...
support_files\fastboot oem mw 8d08ac54 1 31302E30 >>%log% 2>&1
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Switching to HBOOT >>%log%
echo Switching to HBOOT...
support_files\fastboot oem gotohboot >>%log% 2>&1
cls
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo ------------------------------------------------------------------------------
echo Wait a few seconds, and your phone will load a file. This will take awhile.
echo Then, press VOLUME UP to confirm that you want to flash the file.
echo DO NOT freak out, this step takes awhile too. DO NOT I repeat DO NOT power off  the phone!!
echo.
echo It will power cycle during the RUU, DO NOT mess with it, just let it run its    course.
echo.
echo Please make sure that the flash completed successfully. It will say - Bypassed  on one.
echo If it did not flash successfully, DO NOT TURN OFF YOUR PHONE, download an IRC   client and seek help on #thunderbolt on irc.andirc.net
echo.
echo If it flashed correctly, and your phone says "Update Complete...", press POWER.
echo If your phone sits there turned off for a minute or more with the orange light  on, just hold the power button for a second or two and let go.
echo Then, when you are back at your homescreen, go through the activation menu,     enable USB debugging again, and set to charge only.
echo ------------------------------------------------------------------------------
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
support_files\adb wait-for-device
support_files\adb shell rm /sdcard/PG05IMG.zip
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Unroot complete!
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
color 0b
GOTO MAIN
::
:: -----------------------------------------------------------------------
::

:RECOVERY
::support_files\adb shell am start -a EXT_RecoveryInterface -e read_from_prop /sdcard/test.prop
::backup.name=my-Test-Backup
::factory.reset=true
::wipe.cache=true
::wipe.dalvik=true
::install1=/sdcard/test1.zip
::install2=/sdcard/test2.zip
set m=NULL
cls
echo Loading recovery menu >>%log%
echo.
echo         * This tool assumes that you use 4eXT recovery.
echo           Please flash it if you haven't yet.
echo.
echo         * 4eXT is NOT compatible with TWRP backups, but 
echo           is compatible with CWM backups.
echo.
echo         * If the app fails, use the "S-OFF but no root?"
echo           option in the Extras menu.
echo.
echo.
echo  RECOVERY MENU
echo ----------------------------------------------------------
echo       1 - Install/run Recovery Updater (Flash 4eXT in app)
echo.
echo  *Coming soon: Install zip, Backup, and Restore (Not 
echo   currently implemented due to technical difficulties)
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit enter for main menu. 
IF "%M%" == "1" (GOTO 4ext)
::IF "%M%" == "2" (GOTO installzip)
::IF "%M%" == "3" (GOTO backuprom)
::IF "%M%" == "4" (GOTO restorerom)
::IF "%M%" == "5" (GOTO MD5)
IF "%M%" == "NULL" (
echo -- >>%log%
GOTO MAIN
)
GOTO RECOVERY

:4ext
echo Chose Option 1 - Install 4ext Recovery Updater >>%log%
:4ext2
cls
echo ------------------------------
echo        Install 4ext app        
echo ------------------------------
echo.
IF NOT EXIST support_files\download\4ext.apk (GOTO get4ext)
echo Working...
support_files\wget --quiet -O support_files\download\4ext.apk.md5 http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/4ext.apk.md5?param=test
support_files\md5sums support_files\download\4ext.apk>support_files\download\4exthere.md5
set /p extdl=<support_files\download\4ext.apk.md5
set /p exthere=<support_files\download\4exthere.md5
echo Our checksum is         %exthere% >>%log%
echo The correct checksum is %extdl% >>%log%
del support_files\download\4exthere.md5
del support_files\download\4ext.apk.md5
cls
echo ------------------------------
echo        Install 4ext app      
echo ------------------------------
echo.
IF "%exthere%" == "%extdl%" GOTO INSTALL4ext
:get4ext
echo 4ext app not found, or there is an update.
echo Downloading 4ext app...
echo Updating/Getting 4ext app >>%log%
echo.
IF EXIST support_files\download\4ext.apk (del support_files\download\4ext.apk)
support_files\wget -O support_files\download\4ext.apk http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/4ext.apk?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO 4ext2
:INSTALL4ext
cls
echo ------------------------------
echo        Install 4ext app        
echo ------------------------------
echo.
echo Installing and runnning...
echo Installing and runnning >>%log% 2>&1
support_files\adb install support_files\download\4ext.apk >>%log% 2>&1
support_files\adb shell am start -a android.intent.action.MAIN -n ext.recovery.updater/.RecoveryControl >>%log% 2>&1
echo Done >>%log%
cls
echo ------------------------------
echo        Install 4ext app         
echo ------------------------------
echo.
echo You can now use the 4ext app to flash and 
echo configure 4ext.
echo.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:installzip
echo Chose option 2 - Install zip >>%log%
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo Make sure the zip is in the folder with
echo this and is the only .zip in the folder!
echo.
echo Press enter when you're ready to install.
pause >NUL
:recheckzip
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo Preparing zip installer...
IF NOT EXIST *.zip (GOTO nozip)
MOVE *.zip support_files\install.zip >support_files\mv 2>&1
set /p mv=<support_files\mv
del support_files\mv
IF "%mv%" == "Cannot move multiple files to a single file." (goto morezip) ELSE (GOTO repushinstallzip)
:morezip
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo It appears that there is more than
echo one .zip in the folder. Please remove
echo the one not being used and press enter.
PAUSE >NUL
goto recheckzip
:nozip
echo No zip! >>%log%
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo I can't find the .zip. Did you put 
echo it in the folder with this tool?
echo.
echo Press enter to retry.
pause >NUL
GOTO recheckzip
:repushinstallzip
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo Pushing zip to sdcard...
support_files\adb shell rm /sdcard/tbolt-tool/backup.prop >NUL 2>&1
support_files\adb shell rm /sdcard/tbolt-tool/install.prop >NUL 2>&1
support_files\adb shell rm /sdcard/tbolt-tool/install.zip >NUL 2>&1
support_files\adb push support_files\install.zip /sdcard/tbolt-tool/install.zip >>%log% 2>&1
support_files\adb shell ls /sdcard/tbolt-tool/ >support_files\push
set /p push=<support_files\push
del support_files\push
IF "%push%" NEQ "install.zip" (GOTO badinstallpush)
echo install_zip("/sdcard/tbolt-tool/install.zip"); >support_files\install
support_files\adb push support_files\install /data/local/install
del support_files\install
support_files\adb shell /system/bin/su --command mv /data/local/install /cache/recovery/extendedcommand
pause
move support_files\install.zip InstalledZip.zip >>%log% 2>&1
support_files\adb reboot recovery
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo File will install and phone will reboot.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:badinstallpush
echo Bad file push >>%log%
cls
echo ------------------------------
echo          Install zip          
echo ------------------------------
echo.
echo It appears thete was an error 
echo pushing the file.
echo.
echo Please make sure Stay Awake and
echo Charge Only are enabled. The phone
echo screen must stay on for the push.
echo.
echo Press enter to repush...
pause >NUL
GOTO repushinstallzip

:backuprom
echo Chose option 3 - Backup ROM >>%log%
cls
echo ------------------------------
echo           Backup ROM          
echo ------------------------------
echo.
set /p backupname=What should we name the backup? 
cls
echo ------------------------------
echo           Backup ROM          
echo ------------------------------
echo.
echo Working...
echo Naming backup %backupname% >>%log%
support_files\adb shell rm /sdcard/tbolt-tool/backup.prop >NUL 2>&1
support_files\adb shell "echo "backup.name=%backupname%" >/sdcard/tbolt-tool/backup.prop"
support_files\adb shell am start -a EXT_RecoveryInterface -e read_from_prop /sdcard/tbolt-tool/backup.prop >>%log% 2>&1
cls
echo ------------------------------
echo           Backup ROM          
echo ------------------------------
echo.
echo Phone will backup and restart.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:restorerom
echo Chose option 4 - Restore Backup >>%log%
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo ----------------------------------------------------------
support_files\adb shell ls /sdcard/clockworkmod/backup
echo ----------------------------------------------------------
echo Which backup do you want to restore? 
set /p restorename=(Type the full name, case sensitive.) 
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo Working...
echo Restoring %restorename% >>%log%
echo restore_rom("/sdcard/clockworkmod/backup/%restorename%");>support_files\restore
IF "%adbrt%" == "Yes" (GOTO restorerooted)
echo  -Not ADB Rooted >>%log%
support_files\adb reboot recovery
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
:waitforrecorestore
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here 2>&1
set here=NULL
set /p here=<support_files\here
del support_files\here
if "%here%" NEQ "a" (GOTO waitforrecorestore)
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo Working...
echo Mounting and pushing >>%log%
support_files\adb shell mount /cache >>%log% 2>&1
support_files\adb push support_files\restore /cache/recovery/extendedcommand >>%log% 2>&1
del support_files\restore
support_files\adb reboot recovery
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo Phone will re-enter recovery, restore, and restart.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY
:restorerooted
echo  -ADB Rooted >>%log%
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo Working...
echo Pushing to extendedcommand >>%log%
support_files\adb push support_files\restore /cache/recovery/extendedcommand >>%log% 2>&1
del support_files\restore
support_files\adb reboot recovery
cls
echo ------------------------------
echo         Restore backup        
echo ------------------------------
echo.
echo Phone will restore and restart.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

::
:: -----------------------------------------------------------------------
::

:UNBRICK
GOTO MAIN
echo UNBRICK MENU
echo --------------------------------------------------------
echo  How did you "brick"?
echo.
echo      1 - OTA update
echo      2 - Installing a ROM
echo      3 - 
echo      4 -
echo      5 -
echo      6 -
echo      7 -
echo      8 -
echo --------------------------------------------------------
::
:: -----------------------------------------------------------------------
::
:BOOT
set m=NULL
echo Loading boot menu >>%log%
cls
IF "%rooted%" NEQ "yes" (GOTO stockBOOT)
:rootBOOT
echo  -Rooted >>%log%
echo.
echo.
echo  BOOT MENU
echo ----------------------------------------------------------
echo       1 - Reboot
echo       2 - Hot reboot
echo       3 - Reboot recovery
echo       4 - Reboot to fastboot
echo       5 - Reboot to hboot
echo       6 - Power off
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit enter for main menu. 
IF "%M%" == "1" (
cls
echo Please wait...
echo Chose option 1 - Reboot >>%log%
support_files\adb reboot
GOTO boot
)
IF "%M%" == "2" (
cls
echo Please wait...
echo Chose option 2 - Hot Reboot >>%log%
support_files\adb shell stop
support_files\adb shell start
GOTO boot
)
IF "%M%" == "3" (
cls
echo Please wait...
echo Chose option 3 - Reboot recovery >>%log%
support_files\adb reboot recovery
goto boot
)
IF "%M%" == "4" (
cls
echo Please wait...
echo Chose option 4 - Reboot to fastboot >>%log%
support_files\adb reboot-bootloader
goto boot
)
IF "%M%" == "5" (
cls
echo Please wait...
echo Chose option 5 - Reboot to hboot >>%log%
support_files\adb reboot-bootloader
support_files\fastboot oem gotohboot >>%log% 2>&1
goto boot
)
IF "%M%" == "6" (
cls
echo Please wait...
echo Chose option 6 - Power off
support_files\adb reboot-bootloader
support_files\fastboot oem powerdown >>%log% 2>&1
goto boot
)
IF "%M%" == "NULL" (GOTO MAIN)
GOTO rootBOOT

:stockboot
echo  -Stock >>%log%
echo.
echo.
echo  BOOT MENU
echo ----------------------------------------------------------
echo       1 - Reboot
echo       2 - Reboot recovery
echo       3 - Reboot to fastboot
echo       4 - Power off
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit enter for main menu. 
IF "%M%" == "1" (
cls
echo Please wait...
echo Chose option 1 - Reboot >>%log%
support_files\adb reboot
GOTO boot
)
IF "%M%" == "2" (
cls
echo Please wait...
echo Chose option 2 - Reboot recovery >>%log%
support_files\adb reboot recovery
goto boot
)
IF "%M%" == "3" (
cls
echo Please wait...
echo Chose option 3 - Reboot to fastboot >>%log%
support_files\adb reboot-bootloader
goto boot
)

IF "%M%" == "4" (
cls
echo Please wait...
echo Chose option 4 - Power off
support_files\adb reboot-bootloader
support_files\fastboot oem powerdown >>%log% 2>&1
goto boot
)
IF "%M%" == "NULL" (
echo -- >>%log%
GOTO MAIN
)
GOTO BOOT
::
:: -----------------------------------------------------------------------
::

:EXTRAS
set m=NULL
cls
echo Loading extras menu >>%log%
echo.
echo.
echo  EXTRAS MENU
echo ----------------------------------------------------------
echo       1 - Disable OTA Updates (Already done if rooted with 
echo           this)
::echo       3 - Update Superuser
echo       2 - Run ADB/Fastboot cmd
echo       3 - Install Busybox
::echo       4 - Splash Screen Tool by TrueBlue_Drew @ XDA
::echo       5 - Disable shutter sounds *Illegal in some places!
::echo       6 - Re-enable shutter sounds
echo       4 - S-OFF but no root? (Should not be necessary)
echo       5 - Reset Thunderbolt Tool
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit enter for main menu. 
IF "%M%" == "1" (GOTO OTABlock)
::IF %M%==3 (GOTO SUUpdates)
IF "%M%" == "2" (
echo Chose option 2 - Run ADB/Fastboot cmd >>%log%
cls
title Command Prompt
color 07
COPY support_files\adb.exe adb.exe >NUL
COPY support_files\fastboot.exe fastboot.exe >NUL
COPY support_files\adbwinapi.dll adbwinapi.dll >NUL
COPY support_files\adbwinusbapi.dll adbwinusbapi.dll >NUL
cls
cmd
)
IF "%M%" == "3" (GOTO bbox)
::IF %M%==4 (GOTO splash)
IF "%M%" == "4" (GOTO SOFFNOROOT)
IF "%M%" == "5" (GOTO CLEARPROG)
IF "%M%" == "NULL" (GOTO MAIN)
GOTO EXTRAS
:: ------------

:OTABlock
echo Chose option 1 - Block OTA Updates
IF "%adbrt%" == "Yes" (GOTO blockrooted)
echo  -Not ADB rooted >>%log%
cls
echo ------------------------------
echo      OTA Update Disabler      
echo ------------------------------
echo.
echo Rebooting to recovery...
support_files\adb reboot recovery
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
:waitforrecodisable
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here 2>&1
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforrecodisable)
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Working >>%log%
echo Working...
support_files\adb shell mount /system
support_files\adb shell rm /system/app/DmClient.apk >>%log% 2>&1
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
echo.
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS

:blockrooted
echo  -ADB rooted >>%log%
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Working...
echo Working >>%log%
support_files\adb remount >>%log% 2>&1
support_files\adb shell rm /system/app/DmClient.apk >>%log% 2>&1
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS

:SUUpdates
cls
IF EXIST support_files\download\su.zip (del support_files\download\su.zip)
echo.
echo Downloading latest SU files...
support_files\wget --quiet -O support_files\download\su.zip http://downloads.androidsu.com/superuser/Superuser-3.0.7-efghi-signed.zip
echo.
echo Prepping phone...
support_files\wget --quiet -O support_files\download\extendedcommand http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/extendedcommand?param=test
support_files\adb push support_files\download\extendedcommand /cache/recovery/
support_files\adb push support_files\download\su.zip /sdcard/su.zip
support_files\adb shell "echo install /sdcard/su.zip>/cache/recovery/openrecoveryscript"
del support_files\download\su.zip
del support_files\download\extendedcommand
echo.
echo Rebooting to recovery...
support_files\adb reboot recovery
echo.
echo File will flash and phone will reboot.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS

:bbox
echo Chose option 3 - Install busybox >>%log%
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
IF NOT EXIST support_files\download\busybox (
echo Downloading busybox...
echo Getting busybox >>%log%
support_files\wget -O support_files\download\busybox http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/busybox?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
echo.
)
IF "%adbrt%" == "Yes" (GOTO bboxrooted)
echo  -Not ADB Rooted >>%log%
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Rebooting to recovery...
echo.
support_files\adb reboot recovery
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
:waitforrecobbox
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here 2>&1
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforrecobbox)
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Working...
echo Working >>%log%
@echo on
support_files\adb shell mount /system
support_files\adb shell rm -r /system/xbin/busybox >>%log% 2>&1
support_files\adb push support_files\download\busybox /system/xbin/ >>%log% 2>&1
support_files\adb shell chown root.shell /system/xbin/busybox
support_files\adb shell chmod 04755 /system/xbin/busybox
support_files\adb shell "/system/xbin/busybox --install -s /system/xbin"
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
@echo off
pause
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS
:bboxrooted
echo  -ADB Rooted >>%log%
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Working...
echo Working >>%log%
support_files\adb remount >>%log% 2>&1
support_files\adb shell rm -r /system/xbin/busybox >>%log% 2>&1
support_files\adb push support_files\download\busybox /system/xbin/ >>%log% 2>&1
support_files\adb shell chown root.shell /system/xbin/busybox
support_files\adb shell chmod 04755 /system/xbin/busybox
support_files\adb shell ./system/xbin/busybox --install -s /system/xbin
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS

:splash
cls
echo.
echo PLEASE NOTE! Images MUST be 480x800 or it will not work!
echo.
set m=NULL
echo  SPLASH SCREEN MENU
echo ----------------------------------------------------------
echo       1 - Convert and flash .png image
echo       2 - Convert and flash .jpg image
echo       3 - Convert and flash .bmp image
echo       1 - Just convert .png to .img
echo       1 - Just convert .jpg to .img
echo       1 - Just convert .bmp to .img
echo       4 - Convert .img to .png format for editing
echo       5 - Make backup of current splash screen from phone
echo       6 - Fastboot flash existing splash screen .img
echo       7 - Thank TrueBlue_Drew on XDA for this function
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit enter for main menu. 
IF %menu%==1 (goto png)
IF %menu%==2 (goto jpg)
IF %menu%==3 (goto bmp)
IF %menu%==4 (goto img)
IF %menu%==5 (goto backup)
IF %menu%==6 (goto flash)
IF %menu%==7 (goto thank)
IF %M%==NULL (GOTO MAIN)
GOTO RECOVERY

:CLEARPROG
echo Chose option 5 - Reset tool >>%log%
:CLEARPROG2
color 0c
set M=NULL
cls
echo ------------------------------
echo     Reset Thunderbolt Tool
echo ------------------------------
echo.
echo WARNING! This will delete all downloaded
echo files and will clear all logs. Only use
echo if you want to return the tool to how it
echo was when you first ran it. 
echo.
set /p M=Press 1 to continue or enter to return. 
color 0b
IF "%M%" == "1" (goto wipeprog)
IF "%M%" == "NULL" (goto extras)
GOTO CLEARPROG2

:wipeprog
cls
echo ------------------------------
echo     Reset Thunderbolt Tool
echo ------------------------------
echo.
echo Resetting >>%log%
echo Resetting...
echo.
MOVE %log% %log%.bak
del logs\*.log
MOVE %log%.bak %log%
RMDIR "support_files\download" /S /Q >>%log%
RMDIR "support_files\root" /S /Q >>%log%
RMDIR "support_files\unroot" /S /Q >>%log%
del support_files\RAN >>%log%
del support_files\RAN1 >>%log%
cls
echo ------------------------------
echo     Reset Thunderbolt Tool
echo ------------------------------
echo.
echo Done! Tool is restarting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
ThunderboltTool.bat
::
:: -----------------------------------------------------------------------
::
:ABOUT
echo Loading about screen >>%log%
cls
color 0c
echo.
echo.
echo              HTC Thunderbolt Tool %verno% - %buildtime%
echo.
echo                              Created by trter10
echo.
echo.
echo       All of this application's source code is public.
echo       You can view it here: http://tinyw.in/TboltTool
echo.
echo       --
echo.
echo       Contact eMail: lukeafrazier@gmail.com
echo       Donation link: http://tinyw.in/TrterDonate
echo       Twitter: @trter10
echo.
echo       --
echo.
echo       See the accompanying README.txt for liscensing information.
echo.
echo ----------------------------------------------------------
echo Press enter to return to the main menu...
pause >NUL
color 0b
GOTO main
::
:: -----------------------------------------------------------------------
::

:SOFFNOROOT
echo Chose option 6 - S-OFF but no root >>%log%
:SOFFNOROOT2
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo For this to work, you must have an 
echo SDCard, the phone in charge only mode,
echo stay awake enabled, and the phone
echo screen on and unlocked.
echo.

echo Working...
IF NOT EXIST support_files\download\su.zip (
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Downloading Superuser files...
echo Getting su >>%log%
support_files\wget -O support_files\download\su.zip http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/su.zip?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
FOR /F "tokens=1 delims=" %%a in ( 'support_files\md5sums support_files\download\su.zip' ) do ( set SUmd5=%%a )
echo Our checksum is         %SUmd5% >>%log%
echo The correct checksum is FC462FA0630379EDBE10006B1D19D9B1  support_files\download\su.zip >>%log%
IF "%SUmd5%" NEQ "FC462FA0630379EDBE10006B1D19D9B1  support_files\download\su.zip " (
del support_files\download\su.zip
GOTO SOFFNOROOT2
)
)
IF NOT EXIST support_files\download\OTABlock.zip (
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Downloading OTA Block files...
echo Getting otablock >>%log%
support_files\wget -O support_files\download\OTABlock.zip http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/OTABlock.zip?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
)
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Working...
IF EXIST support_files\download\extendedcommand-noroot (del support_files\download\extendedcommand-noroot)
support_files\wget -O support_files\download\extendedcommand-noroot http://www.androidfilehost.com/main/Thunderbolt_Developers/trter10/extendedcommand-noroot?param=test >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
echo Pushing files >>%log%
support_files\adb push support_files\download\OTABlock.zip /sdcard/ >>%log% 2>&1
support_files\adb push support_files\download\su.zip /sdcard/ >>%log% 2>&1
:4extinstallsu
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Downloading latest 4eXT recovery...
IF EXIST support_files\download\4ext.zip (del support_files\download\4ext.zip)
echo Getting 4eXT >>%log%
support_files\wget -O support_files\download\4ext.zip http://www.4ext.net/ddl/mecha/recovery.zip >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Working...
IF EXIST support_files\download\4ext (RMDIR "support_files\download\4ext" /S /Q)
mkdir support_files\download\4ext\
support_files\unzip support_files\download\4ext.zip -d support_files\download\4ext\ >>%log%
FOR /F "tokens=1 delims=" %%a in ( 'support_files\md5sums -n -l support_files\download\4ext\recovery.img' ) do ( set exthere=%%a )
set /p extdl=<support_files\download\4ext\recovery.md5
echo Our checksum is     %exthere% >>%log%
echo Correct checksum is %extdl% >>%log%
echo.
IF "%extdl% " NEQ "%exthere%" (GOTO 4extinstallsu)
:flash4extSU
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Flashing 4eXT >>%log%
echo Flashing 4eXT... Please wait...
echo.
echo Rebooting to bootloder >>%log%
support_files\adb reboot-bootloader
echo Flashing recovery img >>%log%
support_files\fastboot flash recovery support_files\download\4ext\recovery.img >>%log% 2>&1
echo Rebooting >>%log%
support_files\fastboot reboot >>%log% 2>&1
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Please wait...
echo Waiting for device  >>%log%
support_files\adb wait-for-device
echo Rebooting to recovery >>%log%
support_files\adb reboot recovery
echo Done flashing >>%log%
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo If the phone is stuck on the white HTC Screen for 20+ secs, pull the battery,
echo unplug phone, put battery back in, hold volume down and power until HBOOT 
echo shows, wait about 7 seconds, and select recovery. Then plug the phone back in.
echo.
echo Waiting for recovery...
:waitforrecosu
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here 2>&1
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforrecosu)
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo Working...
echo working >>%log%
support_files\adb shell mount /cache >>%log% 2>&1
support_files\adb push support_files\download\extendedcommand-noroot /cache/recovery/extendedcommand >>%log% 2>&1
support_files\adb reboot recovery
cls
echo ------------------------------
echo       Install Superuser      
echo ------------------------------
echo.
echo When it re-enters recovery, it will 
echo install superuser and block OTAs.
echo.
echo Your phone will reboot and be rooted :)
echo.
echo Once the phone is booted, please choose 
echo option 1 in the recovery menu. Then
echo configure 4eXT in the app.
echo.
IF "%suhere%" NEQ "0" (
echo Press enter to return to the extras menu...
PAUSE >NUL
GOTO EXTRAS
)
IF "%suhere%" == "0" (
echo Press enter to go to the main menu...
PAUSE >NUL
GOTO MAIN
)

:UNZIP-ERR
echo Extraction error! >>%log%
cls
color 0c
echo.
echo It appears that there was an error extracting.
echo Try redownloading and re-running.
echo.
echo Files necessary:
echo.
echo           Driver - %dv%
echo    support_files - %sf%
echo           Readme - %rm%
echo           Driver - %dv% >>%log%
echo    support_files - %sf% >>%log%
echo           Readme - %rm% >>%log%
echo.
echo Press enter to exit...
pause >NUL

:EXIT
echo Exiting... >>%log%
IF EXIST support_files\Script-new-MD5.txt (del support_files\Script-new-MD5.txt)
support_files\adb kill-server
ENDLOCAL