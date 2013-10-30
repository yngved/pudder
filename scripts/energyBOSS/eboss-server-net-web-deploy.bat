@ECHO OFF
setlocal enabledelayedexpansion
REM ##################################################################################
REM 
REM	@name:		eboss-server-net-web-deploy.bat
REM @created: 24.10.2013
REM @author: 	YND
REM
REM Script for deployment of sites to IIS
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV = Environment to deploy to
REM 
REM Input parameter(s):
REM 	- %1 = PROJECT 	Site to deploy (invoicing, contract, sitehandling, process)
REM 	- %2 = JOB_NAME Used to get the correct project build from Jenkins
REM 
REM This scripts uses:
REM 	- eboss-server-net-web-deploy-node.bat
REM 	- replace-in-template-env.ps1
REM ##################################################################################

REM Assign input parameters
set PROJECT=%1
set JOB_NAME=%2

REM Evaluate command line arguments
set INPUT_OK=true
if %PROJECT%X==X set INPUT_OK=false
if %JOB_NAME%X==X set INPUT_OK=false


if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing in %0
	echo [INFO]
	exit 13
)

SET _JENKINS_URI=https://tr-w03.statoil.net:10945/jenkins-prod/job/%JOB_NAME%/

SET _HOST_EBOSS_SERVER_1=
SET _HOST_EBOSS_SERVER_2=
SET _HOST_EBOSS_DIR=""
SET _HOST_INETPUB_DIR=iis-inetpub

if "%PROJECT%" =="sitehandling" (
	SET _HOST_INT_PROJECT=server
) else (
	SET _HOST_INT_PROJECT=%PROJECT%
)

echo _HOST_INT_PROJECT=%_HOST_INT_PROJECT%

set _TARGET=
if "%TARGET_ENV%"=="DEV_RELEASE" (
  SET _HOST_EBOSS_SERVER_1=st-w4184
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_%TARGET_ENV%
  SET _TARGET=devrelease 
) else if "%TARGET_ENV%"=="DEV_PROD" (
  SET _HOST_EBOSS_SERVER_1=st-w4184
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_%TARGET_ENV%
  SET _TARGET=devprod
) else if "%TARGET_ENV%"=="ST_RELEASE" (
  SET _HOST_EBOSS_SERVER_1=st-tw666
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_%TARGET_ENV%
  SET _TARGET=strelease
) else if "%TARGET_ENV%"=="ST_PROD" (
  SET _HOST_EBOSS_SERVER_1=st-tw666
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_%TARGET_ENV%
  SET _TARGET=stprod
) else if "%TARGET_ENV%"=="QA_RELEASE" (
  SET _HOST_EBOSS_SERVER_1=st-w4196
  SET _HOST_EBOSS_SERVER_2=st-w4209
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_%TARGET_ENV%
  SET _TARGET=qarelease
) else if "%TARGET_ENV%"=="QA_PROD" (
  SET _HOST_EBOSS_SERVER_1=st-w4196
  SET _HOST_EBOSS_SERVER_2=st-w4209
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_%TARGET_ENV%
  SET _TARGET=qaprod
) else if "%TARGET_ENV%"=="QA_RELEASE_BAKU" (
  SET _HOST_EBOSS_SERVER_1=bak-w27
  SET _HOST_EBOSS_SERVER_2=bak-w28
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_qa_release
  SET _TARGET=qareleasebaku
) else if "%TARGET_ENV%"=="QA_PROD_BAKU" (
  SET _HOST_EBOSS_SERVER_1=bak-w27
  SET _HOST_EBOSS_SERVER_2=bak-w28
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%_qa_prod
  SET _TARGET=qaprodbaku
) else (
  goto failure
)

echo TARGET=%TARGET_ENV%

if "%BUILD_NUMBER%"=="" (
  SET _ARTIFACT_URI_EBOSS=%_JENKINS_URI%/lastSuccessfulBuild/artifact/target/*zip*/target.zip 
) else (
  SET _ARTIFACT_URI_EBOSS=%_JENKINS_URI%/%BUILD_NUMBER%/artifact/target/*zip*/target.zip 
)

del /f /q *.zip*
rmdir /S /Q target
if %ERRORLEVEL% NEQ 0 goto failure

echo %DEVVIEW%\bin\wget -nv %_ARTIFACT_URI_EBOSS%
%DEVVIEW%\bin\wget -nv %_ARTIFACT_URI_EBOSS%

if %ERRORLEVEL% NEQ 0 goto failure

unzip target.zip

if %ERRORLEVEL% NEQ 0 goto failure

set DEPLOY_SERVER_1=true
set DEPLOY_SERVER_2=true
if %_HOST_EBOSS_SERVER_1%X==X set DEPLOY_SERVER_1=false
if %_HOST_EBOSS_SERVER_2%X==X set DEPLOY_SERVER_2=false

if %DEPLOY_SERVER_1%==true (
	echo "[INFO] Start deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"
	call %SCRIPT_HOME%\energyBOSS\eboss-server-net-web-deploy-node.bat \\%_HOST_EBOSS_SERVER_1%\%_HOST_INETPUB_DIR%\%_HOST_EBOSS_DIR% %_HOST_INT_PROJECT% %_TARGET%
	if %ERRORLEVEL% NEQ 0 goto failure
	echo "[INFO] Finished deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"
)

if %DEPLOY_SERVER_2%==true (
	echo "[INFO] Start deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"
	call %SCRIPT_HOME%\energyBOSS\eboss-server-net-web-deploy-node.bat \\%_HOST_EBOSS_SERVER_2%\%_HOST_INETPUB_DIR%\%_HOST_EBOSS_DIR% %_HOST_INT_PROJECT% %_TARGET%
	if %ERRORLEVEL% NEQ 0 goto failure
	echo "[INFO] Finished deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"
)

goto end

:failure
exit 13

:end
@ECHO ON