@echo off
REM ***********************************************************************************
REM 
REM This script will distribute the jenkins build scripts to the jenkins build server 
REM The user who distribute the scripts must have write permission to the following 
REM folder:	\\st-w4089\tfs\scripts\Common
REM 
REM Will copy build scripts:
REM 	from: C:\Appl\TFS\Statoil.EnergyTrading\ProcessTools\scripts\Common ->
REM 	to 	: \\st-w4089\tfs\scripts\Common
REM 
REM ***********************************************************************************

set TARGET_HOST=st-w4089

REM THIS IS REMOVED WHILE THERE IS NO BATCH SCRIPTS IN PLAY ON \\%TARGET_HOST%\tfs\scripts\Common
REM echo [INFO] Install batch build scripts to '\\%TARGET_HOST%\tfs\scripts\Common'

echo [INFO] Install powershell build scripts to '\\%TARGET_HOST%\tfs\scripts\Common'
xcopy replace-in-template-env.ps1 \\%TARGET_HOST%\tfs\scripts\Common /S /y

REM THIS IS REMOVED WHILE THERE IS NO PYTHON SCRIPTS IN PLAY ON \\%TARGET_HOST%\tfs\scripts\Common
REM echo [INFO] Install python build scripts to '\\%TARGET_HOST%\tfs\scripts\Common'

@echo on
