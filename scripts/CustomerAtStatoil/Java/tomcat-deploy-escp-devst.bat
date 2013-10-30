REM
REM Script for deployment of ESCP artifacts to Tomcat DEV/ST
REM
REM Input parameter:
REM %1: Target environment (DEV/ST/WT)
REM 

REM Get target environment as input to the script
SET TARGET_ENV=%1
if %TARGET_ENV%X==X (
    echo "TARGET_ENV is not set"
    goto end
)

REM ----------
REM CONFIGURATION START
REM ----------

REM URI of the Jenkins job that has the artifact to be deployed
SET _JENKINS_URI=https://tr-w03.statoil.net:10946/jenkins-cp/job/%ARTIFACT_JOB_NAME%/

REM The name of the folder that will be created in the webapps directory on the Tomcat server.
SET _WEBAPP_NAME=escp-web

REM Base directory for instances on the Tomcat server. There are separate directories for each environment (Dev, SystemTest, etc) below the base directory.
SET _INSTANCES_BASE=tomcat-escp-instances

REM Configuration of hosts, directories, and services for the separate environments
SET _DEV_HOST=st-w4184
SET _DEV_INSTANCE=Dev1_1
SET _DEV_SERVICE=tomcat6-escp-dev1-1
SET _ST_HOST=st-w4184
SET _ST_INSTANCE=SystemTest
SET _ST_SERVICE=tomcat6-escp-st
SET _WEBTEST_HOST=st-w4184
SET _WEBTEST_INSTANCE=Webtest
SET _WEBTEST_SERVICE=tomcat6-escp-wt

REM Setting target service/host/instance based on TARGET_ENV (specified as input to the job)
if "%TARGET_ENV%"=="DEV" (
  SET _TARGET_SERVICE=%_DEV_SERVICE%
  SET _TARGET_HOST=%_DEV_HOST%
  SET _TARGET_INSTANCE=%_DEV_INSTANCE%
) else if "%TARGET_ENV%"=="ST" (
  SET _TARGET_SERVICE=%_ST_SERVICE%
  SET _TARGET_HOST=%_ST_HOST%
  SET _TARGET_INSTANCE=%_ST_INSTANCE%
) else if "%TARGET_ENV%"=="WEBTEST" (
  SET _TARGET_SERVICE=%_WEBTEST_SERVICE%
  SET _TARGET_HOST=%_WEBTEST_HOST%
  SET _TARGET_INSTANCE=%_WEBTEST_INSTANCE%
) else (
  goto end
)

REM ----------
REM CONFIGURATION END
REM ----------


SET _TARGET_INSTANCE_BASE=\\%_TARGET_HOST%\%_INSTANCES_BASE%\%_TARGET_INSTANCE%

echo "Target instance is %_TARGET_INSTANCE_BASE%"

if "%BUILD_NUMBER%"=="" (
  SET _ARTIFACT_URI=%_JENKINS_URI%/lastSuccessfulBuild/artifact/system/target/*zip*/target.zip
) else (
  SET _ARTIFACT_URI=%_JENKINS_URI%/%BUILD_NUMBER%/artifact/system/target/*zip*/target.zip
)

rem Retrieving the deployment artifact
mkdir %WORKSPACE%\deploy
%DEVVIEW%\bin\wget -O %WORKSPACE%\deploy\target.zip -nv %_ARTIFACT_URI%

if %ERRORLEVEL% NEQ 0 goto end

rem Unpacking the target.zip file that contains the deployment artifact
unzip %WORKSPACE%\deploy\target.zip -d %WORKSPACE%\deploy\
del %WORKSPACE%\deploy\target.zip

if %ERRORLEVEL% NEQ 0 goto end

rem Unpacking the deployment artifact
dir %WORKSPACE%\deploy\target /b
unzip -o %WORKSPACE%\deploy\target\*.zip -d %WORKSPACE%\deploy\target
del %WORKSPACE%\deploy\target\*.zip

if %ERRORLEVEL% NEQ 0 goto end

rem Getting the artifact directory name, e.g. "escp-system-1.2.0"
dir /b %WORKSPACE%\deploy\target > directoryname.txt
SET /p DIRECTORY_NAME= < directoryname.txt
del directoryname.txt

if %ERRORLEVEL% NEQ 0 goto end

rem Unpacking the ear file
unzip -o %WORKSPACE%\deploy\target\%DIRECTORY_NAME%\*.ear -d %WORKSPACE%\deploy\target\%DIRECTORY_NAME%
del %WORKSPACE%\deploy\target\%DIRECTORY_NAME%\*.ear

if %ERRORLEVEL% NEQ 0 goto end

rem Stopping the Tomcat server
call E:\tfs\scripts\Common\service-scripts\safeServiceStop.bat %_TARGET_HOST% %_TARGET_SERVICE%

if %ERRORLEVEL% NEQ 0 goto end

rem Deleting old war file and directory below webapps
del %_TARGET_INSTANCE_BASE%\webapps\%_WEBAPP_NAME%.war
rmdir %_TARGET_INSTANCE_BASE%\webapps\%_WEBAPP_NAME% /s /q

if %ERRORLEVEL% NEQ 0 goto end

rem Copying war file to the webapps directory
dir /b %WORKSPACE%\deploy\target\%DIRECTORY_NAME%\%_WEBAPP_NAME%-*.war > warfilename.txt
SET /p WARFILE_NAME= < warfilename.txt
del warfilename.txt
copy %WORKSPACE%\deploy\target\%DIRECTORY_NAME%\%WARFILE_NAME% %_TARGET_INSTANCE_BASE%\webapps\%_WEBAPP_NAME%.war

if %ERRORLEVEL% NEQ 0 goto end

rem Starting the Tomcat server
call E:\tfs\scripts\Common\service-scripts\safeServiceStart.bat %_TARGET_HOST% %_TARGET_SERVICE%

if %ERRORLEVEL% NEQ 0 goto end

@ECHO ON
:end
