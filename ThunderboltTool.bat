@echo off
set verno=Indev
set buildtime=May 31 2012, 7:37 PM EST
title                                            HTC Thunderbolt Tool %verno%
color 0b
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

::    You should have received a copy of the GNU General Public License
::    along with this program.  If not, see <http://www.gnu.org/licenses/>.
:: 
::Removing unneeded files
IF EXIST support_files\download\TWRP.img.md5 (del support_files\download\TWRP.img.md5)
IF EXIST support_files\download\TWRP-here.md5 (del support_files\download\TWRP-here.md5)
IF EXIST back.bat (del back.bat)
IF EXIST adbwinapi.dll (del adbwinapi.dll)
IF EXIST adbwinusbapi.dll (del adbwinusbapi.dll)
IF EXIST fastboot.exe (del fastboot.exe)
IF EXIST adb.exe (del adb.exe)
::*********************************SKIPPING UPDATES, REMOVE THIS PRIOR TO RELEASE******************************
GOTO PROGRAM
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
if errorlevel 1 (Goto OTA) ELSE (GOTO PROGRAM)
:OTA
MOVE support_files\OTA.bat OTA.bat >NUL
OTA.bat
exit
:PROGRAM
cls
IF NOT EXIST support_files\download (mkdir support_files\download)
echo You are running the current version, %verno%.
echo.
IF EXIST support_files\Script-MD5.txt (del support_files\Script-MD5.txt)
IF EXIST support_files\Script-server-MD5.txt (del support_files\Script-server-MD5.txt)

cls
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
set warn=nc
::Skipping unneccessary commands...
GOTO skip
:MAIN2
set warn=
echo Getting phone info...
::Checking ROM Version
support_files\adb shell getprop ro.product.version>support_files\romver
set /p romver=<support_files\romver
::Checking bootloader
support_files\adb shell getprop ro.bootloader>support_files\bl
set /p bl=<support_files\bl
IF %bl%==6.04.1002 (set bootloader=Revolutionary S-OFF)
IF %bl%==1.04.2000 (set bootloader=ENG S-OFF)
IF %bl%==1.04.0000 (set bootloader=Stock S-ON)
IF %bl%==1.05.0000 (set bootloader=Stock S-ON)
::Seeing if ADB-Rooted so we can determine
::how to carry out certain actions.
support_files\adb shell getprop ro.secure>support_files\adbroot
set /p adbroot=<support_files\adbroot
IF %adbroot%==0 (set adbrt=Yes) ELSE (set adbrt=No)
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
echo                Welcome to the HTC Thunderbolt tool, by trter10.
set m=NULL
echo.
echo Phone information: 
echo.
echo   ROM Version: %romver%
echo         HBOOT: %bootloader%
echo.
echo  MAIN MENU
echo --------------------------------------------------------
echo       1 - S-OFF and root
echo       2 - Boot menu
echo       3 - Extras
echo       4 - About
echo       5 - Exit
echo --------------------------------------------------------
set /p m=Choose what you want to do. 
IF %M%==1 (GOTO ROOT)
IF %M%==2 (GOTO BOOT)
IF %M%==3 (GOTO EXTRAS)
IF %M%==4 (GOTO ABOUT)
IF %M%==5 (GOTO EXIT)
GOTO MAIN

:rootmain
echo                 Welcome to the HTC Thunderbolt tool, by trter10.
set m=NULL
echo.
echo Phone information: 
echo.
echo   ROM Version: %romver%
echo         HBOOT: %bootloader%
echo.
echo *** Means this function does not work YET.
echo.
echo  MAIN MENU
echo --------------------------------------------------------
echo       1 - Unroot
echo       2 - Recovery menu 
echo   *** 3 - Unbrick menu
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
IF %M%==7 (GOTO EXIT)
GOTO MAIN

:nophonemain
set m=NULL
echo                Welcome to the HTC Thunderbolt tool, by trter10.
echo.
echo                          * WARNING: DEVICE NOT CONNECTED *
echo.
echo --------------------------------------------------------
echo   --Not recognizing the phone!
echo.
echo      -Make sure USB Debugging and Stay Awake are
echo       enabled in Settings - Apps - Development.
echo.
echo      -Make sure HTC Sync, DoubleTwist, EasyTether,
echo       Droid Explorer, etc. are uninstalled.
echo.
echo      -Unplug the phone and plug it back in.
echo.
echo      -Try a different USB Port and/or cable.
echo.
echo      -Disable and re-enable USB Debugging.
echo.
echo      -Run Driver.exe, packaged with this.
echo --------------------------------------------------------
echo Waiting for device connection...
support_files\adb wait-for-device
GOTO MAIN
::
:: -----------------------------------------------------------------------
::
:ROOT
cls
echo ------------------------------
echo             Rooter            
echo ------------------------------
echo.
echo Working...
IF NOT EXIST support_files\download\downgradebypass.zip (GOTO getDB)
IF EXIST support_files\download\downgradebypass.zip.md5 (del support_files\download\downgradebypass.zip.md5)
support_files\wget --quiet -O support_files\download\downgradebypass.zip.md5 http://dl.dropbox.com/u/61129367/DowngradeBypass.zip.md5
support_files\md5sums support_files\download\downgradebypass.zip>support_files\root.md5
fc /b support_files\download\downgradebypass.zip.md5 support_files\root.md5 >NUL
IF "%errorlevel%" == "1" (
:GetDB
echo.
echo It seems you don't yet have the root files.
echo Downloading now...
echo.
IF EXIST support_files\root\ (RMDIR "support_files\root" /S /Q)
support_files\wget -O support_files\download\DowngradeBypass.zip http://dl.dropbox.com/u/61129367/DowngradeBypass.zip
support_files\md5sums support_files\download\DowngradeBypass.zip>support_files\root.md5
fc /b support_files\download\downgradebypass.zip.md5 support_files\root.md5 >NUL
IF errorlevel 1 (GOTO ROOT)
)
title                                            HTC Thunderbolt Tool %verno%
IF NOT EXIST support_files\root (support_files\unzip support_files\download\DowngradeBypass.zip -d support_files\root >NUL)
IF EXIST support_files\download\downgradebypass.zip.md5 (del support_files\download\downgradebypass.zip.md5)
IF EXIST support_files\root.md5 (del support_files\root.md5)
del support_files\adbroot
del support_files\bl
del support_files\romver
del support_files\here
cls
cd support_files\root\
RUN-ME.bat
exit
::
:: -----------------------------------------------------------------------
::

:UNROOT
cls
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Working...
echo X = MsgBox("Please Enjoy the Nyan Cat while you wait for your download to complete.",0+64+4096,"Nyan Notice")>support_files\nyan.vbs
IF NOT EXIST support_files\download\unroot.zip (
cls
echo.
echo It seems you don't yet have the unroot files.
echo Downloading now... This will take awhile...
START support_files\nyan.vbs
START support_files\NyanCat.gif
echo.
:getunroot
support_files\wget -O support_files\download\unroot.zip http://dl.dropbox.com/u/61129367/Unroot.zip
support_files\md5sums support_files\download\unroot.zip>support_files\download\unroot.zip.md5
set /p unrootmd5=<support_files\download\unroot.zip.md5
del support_files\download\unroot.zip.md5
IF "%unrootmd5%" NEQ "9EC2474DEE4F96F5BDBA5C1462F5D77E  support_files\download\unroot.zip" (
cls
title                                            HTC Thunderbolt Tool %verno%
echo ------------------------------
echo            Unrooter            
echo ------------------------------
echo.
echo Error downloading!
del support_files\download\unroot.zip
RMDIR "support_files\unroot" /S /Q >NUL
echo Downloading again...
goto getunroot
)
)
support_files\md5sums support_files\download\unroot.zip>support_files\download\unroot.zip.md5
set /p unrootmd5=<support_files\download\unroot.zip.md5
del support_files\download\unroot.zip.md5
IF "%unrootmd5%" NEQ "9EC2474DEE4F96F5BDBA5C1462F5D77E  support_files\download\unroot.zip" (
del support_files\download\unroot.zip
GOTO UNROOT
)
cls
IF NOT EXIST support_files\unroot (support_files\unzip support_files\download\unroot.zip -d support_files\unroot >NUL)
del support_files\nyan.vbs
del support_files\unroot.md5
del support_files\adbroot
del support_files\bl
del support_files\romver
del support_files\here
cls
cd support_files\unroot
cls
Unroot-NEW.bat
exit
::
:: -----------------------------------------------------------------------
::

:RECOVERY
set m=NULL
cls
echo.
echo.
echo  RECOVERY MENU
echo ----------------------------------------------------------
echo       1 - Flash TWRP
echo       2 - Apply my ICS TWRP Theme
echo       3 - Flash Regular CWM
echo       4 - Flash CWM Touch
echo       5 - Flash 4ext ***
echo       6 - Flash RA_GNM ***
echo       7 - Flash RZRecovery ***
echo       8 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (GOTO TWRP)
IF %M%==2 (GOTO TWRP-ICS)
IF %M%==3 (GOTO CWM-REG)
IF %M%==4 (GOTO CWM-TOUCH)
IF %M%==5 (GOTO 4EXT)
IF %M%==6 (GOTO RA_GNM)
IF %M%==7 (GOTO RZRecovery)
IF %M%==8 (GOTO EXIT)
IF "%M%"=="NULL" (GOTO MAIN)
GOTO RECOVERY

:TWRP
cls
echo ------------------------------
echo           Flash TWRP         
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\TWRP.img.md5 http://dl.dropbox.com/u/61129367/TWRP.img.md5
support_files\md5sums support_files\download\TWRP.img>support_files\download\TWRP-here.md5
set /p twrpdl=<support_files\download\TWRP.img.md5
set /p twrphere=<support_files\download\TWRP-here.md5
cls
echo ------------------------------
echo           Flash TWRP         
echo ------------------------------
echo.
IF "%twrpdl%" == "%twrphere%" (GOTO flashtwrp)
echo TWRP not found, or there is an update.
echo Downloading TWRP...
echo.
IF EXIST support_files\download\TWRP.img (del support_files\download\TWRP.img)
support_files\wget --quiet -O support_files\download\TWRP.img http://dl.dropbox.com/u/61129367/TWRP.img
GOTO TWRP
:flashtwrp
echo Flashing TWRP... Please wait...
echo.
del support_files\download\TWRP.img.md5
del support_files\download\TWRP-here.md5
support_files\adb reboot-bootloader
support_files\fastboot flash recovery support_files\download\TWRP.img
support_files\fastboot reboot
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

:CWM-REG
cls
echo ------------------------------
echo           Flash CWM       
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\CWMReg.img.md5 http://dl.dropbox.com/u/61129367/cwmreg.img.md5
support_files\md5sums support_files\download\CWMReg.img>support_files\download\CWM-here.md5
set /p cwmdl=<support_files\download\CWMReg.img.md5
set /p cwmhere=<support_files\download\CWM-here.md5
cls
echo ------------------------------
echo           Flash CWM        
echo ------------------------------
echo.
IF "%cwmdl%" == "%cwmhere%" (GOTO flashcwm)
echo CWM not found, or there is an update.
echo Downloading CWM...
echo.
IF EXIST support_files\download\CWMReg.img (del support_files\download\CWMReg.img)
support_files\wget --quiet -O support_files\download\CWMReg.img http://dl.dropbox.com/u/61129367/cwmreg.img
GOTO CWM-REG
:flashcwm
echo Flashing CWM... Please wait...
echo.
del support_files\download\CWMReg.img.md5
del support_files\download\CWM-here.md5
support_files\adb reboot-bootloader
support_files\fastboot flash recovery support_files\download\CWMReg.img
support_files\fastboot reboot
support_files\adb wait-for-device
support_files\adb reboot recovery
echo.
cls
echo ------------------------------
echo           Flash CWM         
echo ------------------------------
echo.
echo Phone is on its way to ClockWorkMod recovery.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY

:TWRP-ICS
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\ICS.zip.md5 http://dl.dropbox.com/u/61129367/ICS.zip.md5
support_files\md5sums support_files\download\ICS.zip>support_files\download\ICS.md5
set /p themedl=<support_files\download\ICS.zip.md5
set /p themehere=<support_files\download\ICS.md5
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
IF "%themedl%" == "%themehere%" (GOTO applytheme)
echo Theme not found, or there is an update.
echo Downloading theme...
echo.
IF EXIST support_files\download\ICS.zip(del support_files\download\ICS.zip)
support_files\wget --quiet -O support_files\download\ICS.zip http://dl.dropbox.com/u/61129367/ICS.zip
GOTO TWRP-ICS
:applytheme
echo Applying theme...
echo.
del support_files\download\ICS.md5
del support_files\download\ICS.zip.md5
support_files\adb shell mkdir /sdcard/TWRP/theme
support_files\adb push support_files\download\ICS.zip /sdcard/TWRP/theme/ui.zip
support_files\adb reboot recovery
echo.
cls
echo ------------------------------
echo         TWRP ICS Theme        
echo ------------------------------
echo.
echo Phone is on its way to TWRP recovery.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO RECOVERY
:CWM-TOUCH
cls
echo ------------------------------
echo        Flash CWM Touch       
echo ------------------------------
echo.
support_files\wget --quiet -O support_files\download\CWMTouch.img.md5 http://dl.dropbox.com/u/61129367/CWMTouch.img.md5
support_files\md5sums support_files\download\CWMTouch.img>support_files\download\CWMTouch.md5
set /p cwmtouchdl=<support_files\download\CWMTouch.img.md5
set /p cwmtouchhere=<support_files\download\CWMTouch.md5
cls
echo ------------------------------
echo        Flash CWM Touch       
echo ------------------------------
echo.
IF "%cwmtouchdl%" == "%cwmtouchhere%" (GOTO flashcwmtouch)
echo CWM Touch not found, or there is an update.
echo Downloading CWM Touch...
echo.
IF EXIST support_files\download\CWMTouch.img (del support_files\download\CWMTouch.img)
support_files\wget --quiet -O support_files\download\CWMTouch.img http://dl.dropbox.com/u/61129367/CWMTouch.img
GOTO CWM-TOUCH
:flashcwmtouch
echo Flashing CWM Touch... Please wait...
echo.
del support_files\download\CWMTouch.img.md5
del support_files\download\CWMTouch.md5
support_files\adb reboot-bootloader
support_files\fastboot flash recovery support_files\download\CWMTouch.img
support_files\fastboot reboot
support_files\adb wait-for-device
support_files\adb reboot recovery
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
GOTO RECOVERY
:RA_GNM
GOTO RECOVERY
:RZRECOVERY
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
cls
IF "%rooted%" NEQ "yes" (GOTO stockBOOT)
:rootBOOT
echo.
echo.
echo  BOOT MENU
echo ----------------------------------------------------------
echo       1 - Reboot
echo       2 - Hot Reboot (May not work)
echo       3 - Reboot Recovery
echo       4 - Reboot to fastboot
echo       5 - Reboot to hboot
echo       6 - Power off
echo       7 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (
cls
echo Please wait...
support_files\adb reboot
GOTO boot
)
IF %M%==2 (
cls
echo Please wait...
support_files\adb shell stop
support_files\adb shell start
GOTO boot
)
IF %M%==3 (
cls
echo Please wait...
support_files\adb reboot recovery
goto boot
)
IF %M%==4 (
cls
echo Please wait...
support_files\adb reboot-bootloader
goto boot
)
IF %M%==5 (
cls
echo Please wait...
support_files\adb reboot-bootloader
support_files\fastboot oem gotohboot
goto boot
)
IF %M%==6 (
cls
echo Please wait...
support_files\adb reboot-bootloader
support_files\fastboot oem powerdown
goto boot
)
IF %M%==7 (GOTO EXIT)
IF "%M%"=="NULL" (GOTO MAIN)
GOTO BOOT

:stockboot
echo.
echo.
echo  BOOT MENU
echo ----------------------------------------------------------
echo       1 - Reboot
echo       2 - Reboot Recovery
echo       3 - Reboot to fastboot
echo       4 - Power off
echo       5 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (
cls
echo Please wait...
support_files\adb reboot
GOTO boot
)
IF %M%==2 (
cls
echo Please wait...
support_files\adb reboot recovery
goto boot
)
IF %M%==3 (
cls
echo Please wait...
support_files\adb reboot-bootloader
goto boot
)

IF %M%==4 (
cls
echo Please wait...
support_files\adb reboot-bootloader
support_files\fastboot oem powerdown
goto boot
)
IF %M%==5 (GOTO EXIT)
IF %M%==NULL (GOTO MAIN)
GOTO BOOT
::
:: -----------------------------------------------------------------------
::

:EXTRAS
set m=NULL
cls
echo.
echo.
echo  EXTRAS MENU
echo ----------------------------------------------------------
echo       1 - Disable OTA Updates
echo       2 - Re-enable OTA Updates
::echo       3 - Update Superuser
echo       3 - Run ADB/Fastboot cmd (Enter back to return)
echo       4 - Install Busybox
echo       5 - Exit
echo ----------------------------------------------------------
set /p m=Choose what you want to do or hit ENTER for main menu. 
IF %M%==1 (GOTO OTABlock)
IF %M%==2 (GOTO OTAEnable)
::IF %M%==3 (GOTO SUUpdates)
IF %M%==3 (
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
IF %M%==4 (GOTO bbox)
IF %M%==5 (GOTO EXIT)
IF "%M%"=="NULL" (GOTO MAIN)
GOTO EXTRAS
:: ------------

:OTABlock
IF "%adbrt%"=="Yes" (GOTO blockrooted)
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
echo Rebooting to recovery...
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforrecodisable)
PING 1.1.1.1 -n 1 -w 4000 >NUL
echo Working...
support_files\adb shell mount /system
support_files\adb shell rm /system/app/DmClient.apk
support_files\adb reboot
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
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Working...
support_files\adb remount >NUL
support_files\adb shell rm /system/app/DmClient.apk
support_files\adb reboot
cls
echo ------------------------------
echo      OTA Update Disabler
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS

:: ------------

:OTAEnable
IF "%adbrt%"=="Yes" (GOTO enablerooted)
cls
echo ------------------------------
echo     OTA Update re-enabler
echo ------------------------------
IF NOT EXIST support_files\download\DmClient.apk (
echo Downloading necessary file...
support_files\wget --quiet -O support_files\download\DmClient.apk http://dl.dropbox.com/u/61129367/DmClient.apk
support_files\md5sums support_files\download\DmClient.apk>support_files\download\DmClient.apk.md5
set /p otamd5=<support_files\download\DmClient.apk.md5
IF "%otamd5%" NEQ "CB8B423E04EDEE0C0E3F601E88C9E046  support_files\download\DmClient.apk" (
del support_files\download\DmClient.apk
del support_files\download\DmClient.apk.md5
cls
GOTO OTAEnable
)
echo.
IF EXIST support_files\download\DmClient.apk.md5 (del support_files\download\DmClient.apk.md5)
)
echo Rebooting to recovery...
support_files\adb reboot recovery
:waitforreco
cls
echo ------------------------------
echo     OTA Update re-enabler
echo ------------------------------
echo.
echo Rebooting to recovery...
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforreco)
PING 1.1.1.1 -n 1 -w 4000 >NUL
echo Working...
support_files\adb shell mount /system
support_files\adb push support_files\download\DmClient.apk /system/app/DmClient.apk
support_files\adb shell chmod 644 /system/app/DmClient.apk
support_files\adb reboot
cls
echo ------------------------------
echo     OTA Update re-enabler
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS
:enablerooted
cls
echo ------------------------------
echo     OTA Update re-enabler
echo ------------------------------
echo.
IF NOT EXIST support_files\download\DmClient.apk (
echo Downloading necessary file...
support_files\wget --quiet -O support_files\download\DmClient.apk http://dl.dropbox.com/u/61129367/DmClient.apk
support_files\md5sums support_files\download\DmClient.apk>support_files\download\DmClient.apk.md5
set /p otamd5=<support_files\download\DmClient.apk.md5
IF "%otamd5%" NEQ "CB8B423E04EDEE0C0E3F601E88C9E046  support_files\download\DmClient.apk" (
del support_files\download\DmClient.apk
del support_files\download\DmClient.apk.md5
cls
GOTO enablerooted
)
IF EXIST support_files\download\DmClient.apk.md5 (del support_files\download\DmClient.apk.md5)
echo.
)
echo Working...
support_files\adb remount >NUL
support_files\adb push support_files\download\DmClient.apk /system/app/DmClient.apk >NUL
support_files\adb shell chmod 644 /system/app/DmClient.apk
support_files\adb reboot
cls
echo ------------------------------
echo     OTA Update re-enabler
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
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
IF NOT EXIST support_files\download\busybox (
echo Downloading busybox...
support_files\wget --quiet -O support_files\download\busybox http://dl.dropbox.com/u/61129367/busybox
echo.
)
IF "%adbrt%"=="Yes" (GOTO bboxrooted)
echo Rebooting to recovery...
echo.
support_files\adb reboot recovery
:waitforrecobbox
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Rebooting to recovery...
echo.
echo Waiting for recovery...
echo.
IF EXIST support_files\here (del support_files\here)
support_files\adb shell echo a>support_files\here
set here=NULL
set /p here=<support_files\here
if "%here%" NEQ "a" (GOTO waitforrecobbox)
PING 1.1.1.1 -n 1 -w 4000 >NUL
echo Working...
support_files\adb shell mount /system
support_files\adb shell rm -r /system/xbin/busybox
support_files\adb push support_files\download\busybox /system/xbin/
support_files\adb shell chown root.shell /system/xbin/busybox
support_files\adb shell chmod 04755 /system/xbin/busybox
support_files\adb shell ./system/xbin/busybox --install -s /system/xbin
support_files\adb reboot
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS
:bboxrooted
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Working...
support_files\adb remount >NUL
support_files\adb shell rm -r /system/xbin/busybox
support_files\adb push support_files\download\busybox /system/xbin/
support_files\adb shell chown root.shell /system/xbin/busybox
support_files\adb shell chmod 04755 /system/xbin/busybox
support_files\adb shell ./system/xbin/busybox --install -s /system/xbin
support_files\adb reboot
cls
echo ------------------------------
echo        Busybox installer
echo ------------------------------
echo.
echo Done! Phone is rebooting.
PING 1.1.1.1 -n 1 -w 4000 >NUL
GOTO EXTRAS
::
:: -----------------------------------------------------------------------
::

:ABOUT
cls
color 0c
echo.
echo.
echo              HTC Thunderbolt tool %verno% - %buildtime%
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
IF EXIST support_files\download\TWRP.img.md5 (del support_files\download\TWRP.img.md5)
IF EXIST support_files\download\TWRP-here.md5 (del support_files\download\TWRP-here.md5)
IF EXIST support_files\adbroot (del support_files\adbroot)
IF EXIST support_files\bl (del support_files\bl)
IF EXIST support_files\romver (del support_files\romver)
IF EXIST support_files\here (del support_files\here)
IF EXIST support_files\Script-new-MD5.txt (del support_files\Script-new-MD5.txt)
support_files\adb kill-server
exit