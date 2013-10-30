@echo off
REM ***********************************************************************************
REM 
REM This script will distribute the jenkins build scripts to the jenkins build server 
REM The user who distribute the scripts must have write permission to the following 
REM folder:	\\tr-w03\tfs\scripts\energyBOSS
REM 
REM Will copy build scripts:
REM 	from: C:\Appl\TFS\Statoil.EnergyTrading\ProcessTools\scripts\energyBOSS ->
REM 	to 	: \\tr-w03\tfs\scripts\energyBOSS
REM 
REM ***********************************************************************************

set TARGET_HOST=tr-w03

echo [INFO] Install batch build scripts to '\\%TARGET_HOST%\tfs\scripts\energyBOSS'
xcopy *.bat \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y

echo [INFO] Install powershell build scripts to '\\%TARGET_HOST%\tfs\scripts\energyBOSS'
xcopy *.ps1 \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y

echo [INFO] Install python build scripts to '\\%TARGET_HOST%\tfs\scripts\energyBOSS'
xcopy *.py \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y

echo [INFO] Delete 'distribute' files copied
del \\%TARGET_HOST%\tfs\scripts\energyBOSS\distribute*.bat /Q

@echo on
