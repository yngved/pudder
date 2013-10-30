@echo off
REM ***********************************************************************************
REM 
REM This script will distribute the jenkins build scripts to the jenkins build server 
REM The user who distribute the scripts must have write permission to the following 
REM folder:	\\st-w4089\tfs\scripts\energyBOSS
REM 
REM Will copy build scripts:
REM 	from: C:\Appl\TFS\Statoil.EnergyTrading\ProcessTools\scripts\energyBOSS ->
REM 	to 	: \\st-w4089\tfs\scripts\energyBOSS
REM 
REM ***********************************************************************************

set TARGET_HOST=st-w4089

REM xcopy the batch scripts recursively
echo [INFO] Install batch build scripts to '\\%TARGET_HOST%\tfs\scripts\energyBOSS'
xcopy eboss-server-net-web-deploy.bat \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y
xcopy eboss-server-net-web-deploy-node.bat \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y
xcopy itradeworkbench_qa_r_deployment.bat \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y
xcopy itradeworkbench-st-deployment.bat \\%TARGET_HOST%\tfs\scripts\energyBOSS /S /y

REM THIS IS REMOVED WHILE THERE IS NO POWERSHELL SCRIPTS IN PLAY ON \\%TARGET_HOST%\tfs\scripts\energyBOSS
REM echo [INFO] Install batch build scripts to '\\%TARGET_HOST%\tfs\scripts\energyBOSS'

REM THIS IS REMOVED WHILE THERE IS NO PYTHON SCRIPTS IN PLAY ON %TARGET_HOST%
REM echo [INFO] Install python build scripts to '\\%TARGET_HOST%\tfs\scripts\energyBOSS'

@echo on
