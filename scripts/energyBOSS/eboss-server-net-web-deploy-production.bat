@ECHO OFF
setlocal enabledelayedexpansion

REM Input parameter
REM  - invoicing
REM  - contract

REM Assign input parameters
set PROJECT=%1
set JOB_NAME=%2

REM Evaluate command line arguments
set INPUT_OK=true
if %PROJECT%X==X set INPUT_OK=false


if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	exit 13
)


SET _JENKINS_URI=https://tr-w03.statoil.net:10945/jenkins-prod/job/%JOB_NAME%/

SET _HOST_EBOSS=""
SET _HOST_EBOSS_DIR=""
SET _HOST_INETPUB_DIR=iis-inetpub

if "%PROJECT%" =="sitehandling" (
	SET _HOST_INT_PROJECT=server
) else (
	SET _HOST_INT_PROJECT=%PROJECT%
)

echo TARGET_ENV=%TARGET_ENV%
echo _HOST_INT_PROJECT=%_HOST_INT_PROJECT%

if "%TARGET_ENV%"=="PRODUCTION" (
  SET _HOST_EBOSS_SERVER_1=st-w4190
  SET _HOST_EBOSS_SERVER_2=st-w4201
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%
  SET _TARGET=prod
) else if "%TARGET_ENV%"=="PRODUCTION_BAKU" (
  SET _HOST_EBOSS_SERVER_1=bak-w29
  SET _HOST_EBOSS_SERVER_2=bak-w30
  SET _HOST_EBOSS_DIR=eboss_%PROJECT%
  SET _TARGET=prodbaku
) else (
  goto failure
)
if "%BUILD_NUMBER%"=="" (
  SET _ARTIFACT_URI_EBOSS=%_JENKINS_URI%/lastSuccessfulBuild/artifact/target/*zip*/target.zip 
) else (
  SET _ARTIFACT_URI_EBOSS=%_JENKINS_URI%/%BUILD_NUMBER%/artifact/target/*zip*/target.zip 
)

Rem -----------------------

del /f /q *.zip*
rmdir /S /Q target

if %ERRORLEVEL% NEQ 0 goto failure

%DEVVIEW%\bin\wget -nv %_ARTIFACT_URI_EBOSS%

if %ERRORLEVEL% NEQ 0 goto failure

unzip target.zip



if %ERRORLEVEL% NEQ 0 goto end

REM Server 1
echo "[INFO] Start deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"
call %SCRIPT_HOME%\energyBOSS\eboss-server-net-web-deploy-node-production.bat \\%_HOST_EBOSS_SERVER_1%\%_HOST_INETPUB_DIR%\%_HOST_EBOSS_DIR% %_HOST_INT_PROJECT% %_TARGET%
if %ERRORLEVEL% NEQ 0 goto failure
echo "[INFO] Finished deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"

REM SERVER 2
echo "[INFO] Start deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"
call %SCRIPT_HOME%\energyBOSS\eboss-server-net-web-deploy-node-production.bat \\%_HOST_EBOSS_SERVER_2%\%_HOST_INETPUB_DIR%\%_HOST_EBOSS_DIR% %_HOST_INT_PROJECT% %_TARGET%
if %ERRORLEVEL% NEQ 0 goto failure
echo "[INFO] Finished deploying %PROJECT% to %_TARGET% (%TARGET_ENV%)"

goto end

:failure
exit 13

:end
@ECHO ON