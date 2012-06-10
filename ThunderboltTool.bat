::
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
set verno=v0.1b3
set buildtime=June 9 2012, 7:50 PM EST
title                                            HTC Thunderbolt Tool %verno%
color 0b
IF NOT EXIST support_files (GOTO UNZIP-ERR)
IF NOT EXIST support_files\RAN (start README.txt)
echo Program ran for first time. >support_files\RAN
IF NOT EXIST support_files\download (mkdir support_files\download)
::
::Setting up logging
::Special thanks to Alex K. here http://tinyw.in/nh4r
::He solved a tricky log file naming issue for us.
::Because God knows I couldn't have solved it. :P
set hr=%time:~0,2%
if "%hr:~0,1%" equ " " set hr=0%hr:~1,1%
set log=logs\%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hr%%time:~3,2%%time:~6,2%_%verno%.log
IF NOT EXIST logs (MKDIR logs)
echo Starting Thunderbolt Tool %verno% build %buildtime% at %date% %time% >%log%
::Removing unneeded files
IF EXIST back.bat (del back.bat)
IF EXIST adbwinapi.dll (del adbwinapi.dll)
IF EXIST adbwinusbapi.dll (del adbwinusbapi.dll)
IF EXIST fastboot.exe (del fastboot.exe)
IF EXIST adb.exe (del adb.exe)
::*********************************SKIPPING UPDATES, REMOVE THIS PRIOR TO RELEASE******************************
::GOTO PROGRAM rem ADD :: FOR RELEASE VERSIONS
:: * Script update engine  *
echo Checking for updates...
::In case of freshly updated script...
IF EXIST support_files\Script-MD5.txt (del support_files\Script-MD5.txt)
IF EXIST OTA.bat (MOVE OTA.bat support_files\OTA.bat) >NUL
IF EXIST support_files\Script-server-MD5.txt (del support_files\Script-server-MD5.txt)
::Building MD5 of current script
support_files\md5sums ThunderboltTool.bat >support_files\Script-MD5.txt
:: Downloading latest MD5 Definitions
support_files\wget --quiet -O support_files\Script-server-MD5.txt http://dl.dropbox.com/u/61129367/Script-server-MD5.txt
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
cls
::Getting SED and its .dll's if the need exists
:REGETSED
cls
IF NOT EXIST support_files\download\sed.zip (
echo Getting necessary files...
echo Getting sed >>%log%
support_files\wget -O support_files\download\sed.zip http://dl.dropbox.com/u/61129367/SED.zip >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
support_files\md5sums support_files\download\sed.zip>support_files\download\sed.zip.md5
set /p sedmd5=<support_files\download\sed.zip.md5
del support_files\download\sed.zip.md5
echo Our checksum is         %sedmd5% >>%log%
echo The correct checksum is 5F4BA3E44B33934E80257F3948970868  support_files\download\sed.zip >>%log%
IF "%sedmd5%" NEQ "5F4BA3E44B33934E80257F3948970868  support_files\download\sed.zip" (
del support_files\download\sed.zip
GOTO REGETSED
)
)
IF NOT EXIST support_files\sed.exe (support_files\unzip support_files\download\sed.zip -d support_files\ >>%log%)
cls
::Editing OTA.bat
support_files\cat support_files/OTA.bat | support_files\sed -e s/"echo There is a new version of this script availible. Downloading now..."/"echo Updating..."/ >support_files\newota.bat
support_files\cat support_files/newota.bat >support_files\OTA.bat
del support_files\newota.bat
::
IF EXIST support_files\Script-MD5.txt (del support_files\Script-MD5.txt)
IF EXIST support_files\Script-server-MD5.txt (del support_files\Script-server-MD5.txt)
:SKIPOTAEDIT
echo Starting ADB...
support_files\adb kill-server
support_files\adb start-server
:MAIN
cls
::Just in case...
IF EXIST support_files\adbroot (del support_files\adbroot)
IF EXIST support_files\bl (del support_files\bl)
IF EXIST support_files\romver (del support_files\romver)
IF EXIST support_files\here (del support_files\here)
::In case of any odd errors
set romver=Unknown
set bootloader=Unknown
set adbrt=Unknown
set here=NULL
::Seeing if phone is online
support_files\adb shell echo a>support_files\here
set /p here=<support_files\here
if "%here%" == "a" (goto MAIN2)
::If the script is still going at this point,
::and has not went to :MAIN2, we will set a 
::variable that tells the program that the 
::phone is not connected.
echo Phone not connected! >>%log%
set warn=nc
::Skipping unneccessary commands...
GOTO skip
:MAIN2
set warn=
echo Getting phone info...
echo Getting phone info... >>%log%
echo -- >>%log%
::My workaround to get this to work in recovery mode (Just in case)
::The addidtional /system/bin's are for this reason also.
support_files\adb shell mount system >>support_files\mount 2>&1
set /p bv=<support_files\mount
del support_files\mount
IF "%bv%" == "Usage: mount [-r] [-w] [-o options] [-t type] device directory" (
echo Phone is normally booted >>%log%
set recovery=No
) ELSE (
echo Phone is in recovery mode >>%log%
set recovery=yes
)
::Checking ROM Version
support_files\adb shell /system/bin/getprop ro.product.version>support_files\romver
set /p romver=<support_files\romver
::Checking bootloader
support_files\adb shell /system/bin/getprop ro.bootloader>support_files\bl
set /p bl=<support_files\bl
IF %bl%==6.04.1002 (set bootloader=Revolutionary S-OFF)
IF %bl%==1.04.2000 (set bootloader=ENG S-OFF)
IF %bl%==1.04.0000 (set bootloader=Stock S-ON)
IF %bl%==1.05.0000 (set bootloader=Stock S-ON)
::Seeing if ADB-Rooted so we can determine
::how to carry out certain actions.
support_files\adb shell /system/bin/getprop ro.secure>support_files\adbroot
set /p adbroot=<support_files\adbroot
IF %adbroot%==0 (set adbrt=Yes) ELSE (set adbrt=No)
IF "%recovery%" == "yes" (Set adbrt=Yes)
IF EXIST support_files\adbroot (del support_files\adbroot)
IF EXIST support_files\bl (del support_files\bl)
IF EXIST support_files\romver (del support_files\romver)
IF EXIST support_files\here (del support_files\here)
echo Bootloader: %bl% %bootloader% >>%log%
echo ADB rooted: %adbrt% >>%log%
echo ROM Version: %romver% >>%log%
echo -- >>%log%
:skip
title                                            HTC Thunderbolt Tool %verno%
set m=NULL
cls
IF "%bl%" == "1.04.2000" (set rooted=yes)
IF "%bl%" == "6.04.1002" (set rooted=yes)
IF "%bl%" == "1.04.0000" (set rooted=no)
IF "%bl%" == "1.05.0000" (set rooted=no)
::Determining what menu to show
IF "%warn%" == "nc" (GOTO nophonemain)
IF "%rooted%" == "no" (GOTO stockmain)
IF "%rooted%" == "yes" (GOTO rootmain)
:stockmain
echo Loading stock main menu >>%log%
echo -- >>%log%
echo                Welcome to the HTC Thunderbolt tool, by trter10.
set m=NULL
echo.
echo Phone information: 
echo.
echo         * WARNING: Phone is stock! You must use 
echo           option 1 before more functions are availible! 
echo.
echo   ROM Version: %romver%
echo.
echo  MAIN MENU
echo --------------------------------------------------------
echo       1 - S-OFF and root
echo       2 - Boot menu
echo       3 - About
echo       4 - Exit
echo --------------------------------------------------------
set /p m=Choose what you want to do. 
IF %M%==1 (GOTO ROOT1)
IF %M%==2 (GOTO BOOT)
IF %M%==3 (GOTO ABOUT)
IF %M%==4 (
echo -- >>%log%
GOTO EXIT
)
GOTO MAIN

:rootmain
echo Loading root main menu >>%log%
echo -- >>%log%
echo                 Welcome to the HTC Thunderbolt tool, by trter10.
set m=NULL
echo.
echo Phone information: 
echo.
echo   ROM Version: %romver%
echo         HBOOT: %bootloader%
IF "%recovery%" == "yes" (echo     Boot mode: Recovery) ELSE (echo     Boot mode: Normal)
echo.
echo  MAIN MENU
echo --------------------------------------------------------
echo       1 - Unroot
echo       2 - Recovery menu 
echo       3 - Unbrick menu  ** COMING SOON **
echo       4 - Boot menu
echo       5 - Extras
echo       6 - About
echo       7 - Exit
echo --------------------------------------------------------
set /p m=Choose what you want to do. 
IF %M%==1 (GOTO UNROOT)
IF %M%==2 (GOTO RECOVERY)
IF %M%==3 (GOTO UNBRICK)
IF %M%==4 (GOTO BOOT)
IF %M%==5 (GOTO EXTRAS)
IF %M%==6 (GOTO ABOUT)
IF %M%==7 (
GOTO EXIT
echo -- >>%log%
)
GOTO MAIN

:nophonemain
echo Loading phone not connected prompt >>%log%
echo -- >>%log%
:nophonemain2
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
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here 2>&1
set here=NULL
set /p here=<support_files\here
del support_files\here
if "%here%" NEQ "a" (
PING 1.1.1.1 -n 1 -w 2000 >NUL
GOTO nophonemain2
)
PING 1.1.1.1 -n 1 -w 3000 >NUL
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
echo Working...
IF NOT EXIST support_files\download\DowngradeBypass.zip (GOTO getDB)
IF EXIST support_files\download\downgradebypass.zip.md5 (del support_files\download\downgradebypass.zip.md5)
support_files\wget --quiet -O support_files\download\DowngradeBypass.zip.md5 http://dl.dropbox.com/u/61129367/S-O-DowngradeBypass.zip.md5
support_files\md5sums support_files\download\DowngradeBypass.zip>support_files\download\root.md5
set /p rootmd5=<support_files\download\root.md5
set /p DBzipMD5=<support_files\download\DowngradeBypass.zip.md5
echo Our checksum is     %rootmd5% >>%log%
echo Correct checksum is %DBzipMD5% >>%log%
IF "%rootmd5%" NEQ "%DBzipMD5%" (
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
support_files\wget -O support_files\download\DowngradeBypass.zip http://dl.dropbox.com/u/61129367/S-O-DowngradeBypass.zip >>%log% 2>&1
GOTO ROOT
)
title                                            HTC Thunderbolt Tool %verno%
IF NOT EXIST support_files\root (
echo Unzipping rooter files... >>%log%
support_files\unzip support_files\download\DowngradeBypass.zip -d support_files\root >>%log% 2>&1
)
IF EXIST support_files\download\downgradebypass.zip.md5 (del support_files\download\downgradebypass.zip.md5)
IF EXIST support_files\download\root.md5 (del support_files\download\root.md5)
echo Launching Rooter... >>%log%
echo -- >>%log%
color 0a
cls
set m=NULL
echo ------------------------------
echo             Rooter      
echo ------------------------------
echo.
echo Press enter when ready.
pause >NUL
cls
echo ------------------------------
echo             Rooter      
echo ------------------------------
echo. 
set newver=no
IF "%romver%" == "2.11.605.9" (set newver=yes)
IF "%romver%" == "2.11.605.19 710RD" (set newver=yes)
IF "%newver%" NEQ "yes" (
echo Phone is on ROM Version %romver% so we will use ZergRush. >>%log%
echo Temp rooting >>%log%
support_files\wget --quiet -O support_files\root\ZergRush http://dl.dropbox.com/u/61129367/ZergRush
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
support_files\adb root >support_files\adb-running-as
set /p rooted=<support_files\adb-running-as
del support_files\adb-running-as
::Ensuring root was successful...
IF "%rooted%"=="adbd is already running as root" (GOTO SUCCESSFUL) ELSE (GOTO UNSUCCESSFUL)
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
support_files\adb shell getprop ro.bootloader >support_files\bl
support_files\adb shell getprop ro.serialno >support_files\sn
echo Restarting adb...
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
echo.
set /p serialno=<support_files\sn
set /p hbootver=<support_files\bl
del support_files\sn
del support_files\bl
echo X = MsgBox("On the revolutionary website, please scroll down to Download for Windows. Click that button, then cancel the download. Enter your phone's information in the prompts that pop up. The info you need is: Seiral Number: %serialno% Hboot version: %hbootver%. Once you do that, copy your beta key from the website, then paste it into the Revolutionary window. To paste it, right click the title bar of the Revolutionary window then click edit then click paste. If there are two revolutionary windows, you can close one. Please note that for Revolutionary to work you need to uninstall Droid Explorer if you have it. Thanks!",0+64+4096, "PLEASE READ - Message from trter10")>support_files\root\rev.vbs
echo X = MsgBox("Please note that you need to enter Y to download and flash CWM recovery at the end of Revolutionary. After Revolutionary completes, using the volume buttons to navigate and power to select, you will need to exit fastboot by selecting bootloader, waiting a few seconds, then selecting recovery. Then, CWM will automatically install superuser and reboot.",0+64+4096, "PLEASE READ - Message from trter10")>>support_files\root\rev.vbs
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
echo Working...
IF NOT EXIST support_files\download\unroot.zip (GOTO getunroot)
support_files\md5sums support_files\download\unroot.zip>support_files\download\unroothere.md5
set /p unroothere=<support_files\download\unroothere.md5
del support_files\download\unroothere.md5
echo Our checksum is     %unroothere% >>%log%
echo Correct checksum is 770CF07D8DF125E145A4EABF3E7F95B1  support_files\download\unroot.zip >>%log%
IF "%unroothere%" == "770CF07D8DF125E145A4EABF3E7F95B1  support_files\download\unroot.zip" (GOTO rununroot)
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
support_files\wget -O support_files\download\unroot.zip http://dl.dropbox.com/u/61129367/S-O-Unroot.zip >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO UNROOT2
:rununroot
IF NOT EXIST support_files\unroot (
echo Unzipping unrooter files... >>%log%
support_files\unzip support_files\download\unroot.zip -d support_files\unroot >>%log% 2>&1
)
support_files\md5sums support_files\unroot\Stock-ROM.zip >support_files\unroot\stockromhere.md5
set /p stockromhere=<support_files\unroot\stockromhere.md5
del support_files\unroot\stockromhere.md5
echo Our Stock ROM checksum is %stockromhere%
echo The correct checksum is   013CBDD3A9B28BC894631008FA2148E2  support_files\unroot\Stock-ROM.zip
IF "%stockromhere%" NEQ "013CBDD3A9B28BC894631008FA2148E2  support_files\unroot\Stock-ROM.zip" (
echo Re-unzipping unroot.zip due to bad Stock-ROM.zip checksum >>%log%
RMDIR "support_files\unroot" /S /Q
GOTO rununroot
)
cls
echo Launching Unrooter >>%log%
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo  -This will restore COMPLETELY 
echo   to stock.
echo  -This will wipe data.
echo  -You must have an SD card
echo   with at least 455 MB of free 
echo   space.
echo  -You must have a full charge.
echo ------------------------------
echo.
echo Press enter when ready.
pause >NUL
:REPUSH
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo. 
echo Pushing stock files to sdcard... 
echo This will take a few minutes...
echo.
echo Just in case of PG05IMG >>%log%
support_files\adb shell rm /sdcard/PG05IMG.zip >>%log% 2>&1
echo Pushing files >>%log%
IF EXIST support_files\unroot\filepush (del support_files\unroot\filepush)
support_files\adb push support_files\unroot\Stock-ROM.zip /sdcard/PG05IMG.zip >>support_files\unroot\filepush 2>&1
support_files\cat support_files/unroot/filepush >>%log% 2>&1
:CHECKPUSH
set m=NULL
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo. 
support_files\cat support_files/unroot/filepush
echo.
echo Did the file push correctly? 
echo (If it has random numbers
echo  you are ok.) 1 - Yes  2 - No
echo (If not, make sure Stay 
set /p m=Awake is enabled and try again.) 
IF %M%==1 (GOTO GOOD)
IF %M%==2 (
echo Need to repush >>%log%
GOTO REPUSH
)
GOTO CHECKPUSH
:GOOD
echo File pushed >>%log%
del support_files\unroot\filepush
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
echo Congratulations! You are now unrooted!
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
ThunderboltTool.bat
::
:: -----------------------------------------------------------------------
::

:RECOVERY
set m=NULL
cls
echo Loading recovery menu >>%log%
echo.
echo.
echo  RECOVERY MENU
echo ----------------------------------------------------------
echo       1 - Flash TWRP
echo       2 - Apply my ICS TWRP Theme
echo       3 - Flash Regular CWM
echo       4 - Flash CWM Touch
echo       5 - Install 4ext Recovery Updater (Flash in app)
echo       6 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (GOTO TWRP)
IF %M%==2 (GOTO TWRPICS)
IF %M%==3 (GOTO CWMREG)
IF %M%==4 (GOTO CWMTOUCH)
IF %M%==5 (GOTO 4ext)
IF %M%==6 (
echo -- >>%log%
GOTO EXIT
)
IF %M%==NULL (
echo -- >>%log%
GOTO MAIN
)
GOTO RECOVERY

:TWRP
echo Chose option 1 - Flash TWRP >>%log%
:TWRP2
cls
echo ------------------------------
echo           Flash TWRP         
echo ------------------------------
echo.
echo Working...
support_files\wget --quiet -O support_files\download\TWRP.img.md5 http://dl.dropbox.com/u/61129367/TWRP.img.md5
support_files\md5sums support_files\download\TWRP.img>support_files\download\TWRP-here.md5 2>&1
set /p twrpdl=<support_files\download\TWRP.img.md5
set /p twrphere=<support_files\download\TWRP-here.md5
echo Our checksum is     %twrphere% >>%log%
echo Correct checksum is %twrpdl% >>%log%
cls
echo ------------------------------
echo           Flash TWRP         
echo ------------------------------
echo.
IF "%twrpdl%" == "%twrphere%" (GOTO flashtwrp)
echo TWRP not found, or there is an update.
echo Downloading TWRP...
echo Updating/Getting TWRP >>%log%
echo.
IF EXIST support_files\download\TWRP.img (del support_files\download\TWRP.img)
support_files\wget -O support_files\download\TWRP.img http://dl.dropbox.com/u/61129367/TWRP.img >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO TWRP2
:flashtwrp
cls
echo ------------------------------
echo           Flash TWRP         
echo ------------------------------
echo.
echo Flashing TWRP... Please wait...
echo Flashing TWRP >>%log%
echo.
del support_files\download\TWRP.img.md5
del support_files\download\TWRP-here.md5
support_files\adb reboot-bootloader
support_files\fastboot flash recovery support_files\download\TWRP.img >>%log% 2>&1
support_files\fastboot reboot >>%log% 2>&1
support_files\adb wait-for-device
support_files\adb reboot recovery
echo.
cls
echo ------------------------------
echo           Flash TWRP         
echo ------------------------------
echo.
echo Phone is on its way to TWRP recovery.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:CWMREG
echo Chose option 3 - Flash Regular CWM >>%log%
:CWMREG2
cls
echo ------------------------------
echo           Flash CWM       
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\CWMReg.img.md5 http://dl.dropbox.com/u/61129367/cwmreg.img.md5
support_files\md5sums support_files\download\CWMReg.img>support_files\download\CWM-here.md5 2>&1
set /p cwmdl=<support_files\download\CWMReg.img.md5
set /p cwmhere=<support_files\download\CWM-here.md5
echo Our checksum is     %cwmhere% >>%log%
echo Correct checksum is %cwmdl% >>%log%
cls
echo ------------------------------
echo           Flash CWM        
echo ------------------------------
echo.
IF "%cwmdl%" == "%cwmhere%" (GOTO flashcwm)
echo Updating/Getting CWM >>%log%
echo CWM not found, or there is an update.
echo Downloading CWM...
echo.
IF EXIST support_files\download\CWMReg.img (del support_files\download\CWMReg.img)
support_files\wget -O support_files\download\CWMReg.img http://dl.dropbox.com/u/61129367/cwmreg.img >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO CWMREG2
:flashcwm
echo Flashing CWM >>%log%
echo Flashing CWM... Please wait...
echo.
del support_files\download\CWMReg.img.md5
del support_files\download\CWM-here.md5
support_files\adb reboot-bootloader
support_files\fastboot flash recovery support_files\download\CWMReg.img >>%log% 2>&1
support_files\fastboot reboot >>%log% 2>&1
support_files\adb wait-for-device
support_files\adb reboot recovery
echo Done flashing >>%log%
echo.
cls
echo ------------------------------
echo           Flash CWM         
echo ------------------------------
echo.
echo Phone is on its way to ClockWorkMod recovery.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:TWRPICS
echo Chose option 2 - Apply My ICS TWRP Theme
:TWRPICS2
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\ICS.zip.md5 http://dl.dropbox.com/u/61129367/ICS.zip.md5
support_files\md5sums support_files\download\ICS.zip>support_files\download\ICS.md5
set /p themedl=<support_files\download\ICS.zip.md5
set /p themehere=<support_files\download\ICS.md5
echo Our checksum is     %themehere% >>%log%
echo Correct checksum is %themedl% >>%log%
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
IF "%themedl%" == "%themehere%" (GOTO applytheme)
echo Updating/Getting theme >>%log%
echo Theme not found, or there is an update.
echo Downloading theme...
echo.
IF EXIST support_files\download\ICS.zip(del support_files\download\ICS.zip)
support_files\wget -O support_files\download\ICS.zip http://dl.dropbox.com/u/61129367/ICS.zip >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO TWRPICS2
:applytheme
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
echo Applying theme...
echo Applying theme >>%log%
echo.
del support_files\download\ICS.md5
del support_files\download\ICS.zip.md5
support_files\adb shell mkdir /sdcard/TWRP/theme >>%log% 2>&1
support_files\adb push support_files\download\ICS.zip /sdcard/TWRP/theme/ui.zip >>%log% 2>&1
support_files\adb reboot recovery
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
echo Done flashing >>%log%
echo -- >>%log%
echo.
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
echo Phone is on its way to TWRP recovery.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:CWMTOUCH
echo Chose option 4 - Flash CWM Touch >>%log%
:CWMTOUCH2
cls
echo ------------------------------
echo        Flash CWM Touch       
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\CWMTouch.img.md5 http://dl.dropbox.com/u/61129367/CWMTouch.img.md5
support_files\md5sums support_files\download\CWMTouch.img>support_files\download\CWMTouch.md5
set /p cwmtouchdl=<support_files\download\CWMTouch.img.md5
set /p cwmtouchhere=<support_files\download\CWMTouch.md5
echo Our checksum is         %cwmtouchhere% >>%log%
echo The correct checksum is %cwmtouchdl% >>%log%
del support_files\download\CWMTouch.img.md5
del support_files\download\CWMTouch.md5
cls
echo ------------------------------
echo        Flash CWM Touch       
echo ------------------------------
echo.
IF "%cwmtouchdl%" == "%cwmtouchhere%" (GOTO flashcwmtouch)
echo CWM Touch not found, or there is an update.
echo Downloading CWM Touch...
echo.
echo Updating/Getting CWM Touch >>%log%
IF EXIST support_files\download\CWMTouch.img (del support_files\download\CWMTouch.img)
support_files\wget -O support_files\download\CWMTouch.img http://dl.dropbox.com/u/61129367/CWMTouch.img >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
GOTO CWMTOUCH2
:flashcwmtouch
echo Flashing CWM Touch... Please wait...
echo Flashing CWM Touch >>%log%
echo.
support_files\adb reboot-bootloader
support_files\fastboot flash recovery support_files\download\CWMTouch.img >>%log% 2>&1
support_files\fastboot reboot >>%log% 2>&1
support_files\adb wait-for-device
support_files\adb reboot recovery
echo Done flashing >>%log%
echo -- >>%log%
echo.
cls
echo ------------------------------
echo        Flash CWM Touch       
echo ------------------------------
echo.
echo Phone is on its way to ClockWorkMod Touch recovery.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:4ext
echo Chose Option 5 - Install 4ext Recovery Updater >>%log%
:4ext2
cls
echo ------------------------------
echo        Install 4ext app        
echo ------------------------------
echo.
IF NOT EXIST support_files\download\4ext.apk (GOTO get4ext)
echo Working...
support_files\wget --quiet -O support_files\download\4ext.apk.md5 http://dl.dropbox.com/u/61129367/4ext.apk.md5
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
support_files\wget -O support_files\download\4ext.apk http://dl.dropbox.com/u/61129367/4ext.apk >>%log% 2>&1
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
echo       7 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (
cls
echo Please wait...
echo Chose option 1 - Reboot >>%log%
support_files\adb reboot
GOTO boot
)
IF %M%==2 (
cls
echo Please wait...
echo Chose option 2 - Hot Reboot >>%log%
support_files\adb shell stop
support_files\adb shell start
GOTO boot
)
IF %M%==3 (
cls
echo Please wait...
echo Chose option 3 - Reboot recovery >>%log%
support_files\adb reboot recovery
goto boot
)
IF %M%==4 (
cls
echo Please wait...
echo Chose option 4 - Reboot to fastboot >>%log%
support_files\adb reboot-bootloader
goto boot
)
IF %M%==5 (
cls
echo Please wait...
echo Chose option 5 - Reboot to hboot >>%log%
support_files\adb reboot-bootloader
support_files\fastboot oem gotohboot >>%log% 2>&1
goto boot
)
IF %M%==6 (
cls
echo Please wait...
echo Chose option 6 - Power off
support_files\adb reboot-bootloader
support_files\fastboot oem powerdown >>%log% 2>&1
goto boot
)
IF %M%==7 (
echo -- >>%log%
GOTO EXIT
)
IF %M%==NULL (GOTO MAIN)
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
echo       5 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (
cls
echo Please wait...
echo Chose option 1 - Reboot >>%log%
support_files\adb reboot
GOTO boot
)
IF %M%==2 (
cls
echo Please wait...
echo Chose option 2 - Reboot recovery >>%log%
support_files\adb reboot recovery
goto boot
)
IF %M%==3 (
cls
echo Please wait...
echo Chose option 3 - Reboot to fastboot >>%log%
support_files\adb reboot-bootloader
goto boot
)

IF %M%==4 (
cls
echo Please wait...
echo Chose option 4 - Power off
support_files\adb reboot-bootloader
support_files\fastboot oem powerdown >>%log% 2>&1
goto boot
)
IF %M%==5 (
echo -- >>%log%
GOTO EXIT
)
IF %M%==NULL (GOTO MAIN)
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
echo       1 - Disable OTA Updates
::echo       3 - Update Superuser
echo       2 - Run ADB/Fastboot cmd (Enter back to return)
echo       3 - Install Busybox
::echo       4 - Splash Screen Tool by TrueBlue_Drew @ XDA
::echo       5 - Disable shutter sounds *Illegal in some places!
::echo       6 - Re-enable shutter sounds
echo       4 - Clear logs
echo       5 - Exit
echo       ** MORE COMING SOON **
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (GOTO OTABlock)
::IF %M%==3 (GOTO SUUpdates)
IF %M%==2 (
echo Chose option 2 - Run ADB/Fastboot cmd >>%log%
cls
title Command Prompt
color 07
echo @echo off>back.bat
echo del adb.exe>>back.bat
echo del fastboot.exe>>back.bat
echo del adbwinapi.dll>>back.bat
echo del adbwinusbapi.dll>>back.bat
echo ThunderboltTool.bat>>back.bat
COPY support_files\adb.exe adb.exe
COPY support_files\fastboot.exe fastboot.exe
COPY support_files\adbwinapi.dll adbwinapi.dll
COPY support_files\adbwinusbapi.dll adbwinusbapi.dll
cls
cmd
)
IF %M%==3 (GOTO bbox)
::IF %M%==4 (GOTO splash)
IF %M%==4 (
echo Chose option 4 - Clear logs >>%log%
MOVE %log% %log%.bak
del logs\*.log
MOVE %log%.bak %log%
)
IF %M%==5 (
echo -- >>%log%
GOTO EXIT
)
IF %M%==NULL (GOTO MAIN)
GOTO EXTRAS
:: ------------

:OTABlock
echo Chose option 1 - Block OTA Updates
IF "%adbrt%"=="Yes" (GOTO blockrooted)
echo  -Not ADB rooted >>%log%
cls
echo ------------------------------
echo      OTA Update Disabler      
echo ------------------------------
echo.
echo Rebooting to recovery...
support_files\adb reboot recovery
:waitforrecodisable
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
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
support_files\wget --quiet -O support_files\download\extendedcommand http://dl.dropbox.com/u/61129367/extendedcommand
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
support_files\wget -O support_files\download\busybox http://dl.dropbox.com/u/61129367/busybox >>%log% 2>&1
title                                            HTC Thunderbolt Tool %verno%
echo.
)
IF "%adbrt%"=="Yes" (GOTO bboxrooted)
echo  -Not ADB Rooted >>%log%
echo Rebooting to recovery...
echo.
support_files\adb reboot recovery
:waitforrecobbox
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
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
support_files\adb shell mount /system
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

:SHUTTERDisable
echo Chose option 5 - Remove shutter sounds >>%log%
IF "%adbrt%"=="Yes" (GOTO shutterrooted)
echo  -Not ADB Rooted >>%log%
cls
echo ------------------------------
echo     Shutter sound remover
echo ------------------------------
echo.
echo Rebooting to recovery...
echo.
support_files\adb reboot recovery
:waitforrecoshutter
cls
echo ------------------------------
echo     Shutter sound remover
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforrecoshutter)
del support_files\here
PING 1.1.1.1 -n 1 -w 4000 >NUL
echo Working...
echo Working >>%log%
support_files\adb shell mount /system >>%log% 2>&1
support_files\adb shell mv /system/media/audio/ui/camera_click.ogg /system/media/audio/ui/camera_click.bak
support_files\adb shell mv /system/media/audio/ui/VideoRecord.ogg /system/media/audio/ui/VideoRecord.bak
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
cls
echo ------------------------------
echo     Shutter sound remover
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS
:shutterrooted
echo  -ADB Rooted >>%log%
cls
echo ------------------------------
echo     Shutter sound remover
echo ------------------------------
echo.
echo Working...
echo Working >>%log%
support_files\adb remount >>%log% 2>&1
support_files\adb shell mv /system/media/audio/ui/camera_click.ogg /system/media/audio/ui/camera_click.bak
support_files\adb shell mv /system/media/audio/ui/VideoRecord.ogg /system/media/audio/ui/VideoRecord.bak
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
cls
echo ------------------------------
echo     Shutter sound remover
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS

:SHUTTEREnable
echo Chose option 6 - Restore shutter sounds >>%log%
IF "%adbrt%"=="Yes" (GOTO rshutterrooted)
echo  -Not ADB Rooted >>%log%
cls
echo ------------------------------
echo    Shutter sound restorer
echo ------------------------------
echo.
echo Rebooting to recovery...
echo.
support_files\adb reboot recovery
:rwaitforrecoshutter
cls
echo ------------------------------
echo    Shutter sound restorer
echo ------------------------------
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO rwaitforrecoshutter)
del support_files\here
PING 1.1.1.1 -n 1 -w 4000 >NUL
cls
echo ------------------------------
echo    Shutter sound restorer
echo ------------------------------
echo.
echo Working...
echo Working >>%log%
support_files\adb shell mount /system >>%log% 2>&1
support_files\adb shell mv /system/media/audio/ui/camera_click.bak /system/media/audio/ui/camera_click.ogg
support_files\adb shell mv /system/media/audio/ui/VideoRecord.bak /system/media/audio/ui/VideoRecord.ogg
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
cls
echo ------------------------------
echo    Shutter sound restorer
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS
:rshutterrooted
echo  -ADB Rooted >>%log%
cls
echo ------------------------------
echo    Shutter sound restorer
echo ------------------------------
echo.
echo Working...
echo Working >>%log%
support_files\adb remount >>%log% 2>&1
support_files\adb shell mv /system/media/audio/ui/camera_click.bak /system/media/audio/ui/camera_click.ogg
support_files\adb shell mv /system/media/audio/ui/VideoRecord.bak /system/media/audio/ui/VideoRecord.ogg
support_files\adb reboot
support_files\adb kill-server >NUL 2>&1
support_files\adb start-server >NUL 2>&1
cls
echo ------------------------------
echo    Shutter sound restorer
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
echo       8 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %menu%==2 (goto png)
IF %menu%==3 (goto jpg)
IF %menu%==4 (goto bmp)
IF %menu%==5 (goto img)
IF %menu%==6 (goto backup)
IF %menu%==7 (goto flash)
IF %menu%==8 (goto thank)
IF %menu%==0 (goto quit)
IF %M%==NULL (GOTO MAIN)
GOTO RECOVERY
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
echo       Donation link: http://tinyw.in/TrterDonate
echo       Twitter: @trter10
echo       Contact eMail: lukeafrazier@gmail.com
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

:EXIT
echo Exiting... >>%log%
IF EXIST support_files\Script-new-MD5.txt (del support_files\Script-new-MD5.txt)
support_files\adb kill-server
ENDLOCAL
exit

:UNZIP-ERR
cls
color 0c
echo.
echo It appears that you did not unzip the file correctly. 
echo Right click on the zip, and click extract all.
echo Make sure "Show extracted files when complete" is selected,
echo and click extract. Then run ThunderboltTool.bat in the folder
echo that pops up.
echo.
echo Press ENTER to exit...
pause >NUL
exit