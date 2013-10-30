REM
REM Script for reconfigure and restart of Tomcat DEV/ST for ESCP
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

REM Location of the Tomcat instance files that were retrieved from TFS. Contains libraries, binaries etc. that are common for all Tomcat instances.
SET _TFS_TOMCAT_INSTANCE_DIR=%WORKSPACE%\application-server\tomcat\tomcat-instance-6.0.37

REM Location of the Tomcat config directory that was retrieved from TFS. Contains configs for each environment separated in sub-directories (Dev, SystemTest, etc).
SET _TFS_TOMCAT_CONFIG_DIR=%WORKSPACE%\application-server\tomcat\tomcat-config\escp

REM Base directory for instances on the Tomcat server. There are separate directories for each environment (Dev, SystemTest, etc) below the base directory.
SET _INSTANCES_BASE=tomcat-escp-instances

REM Base directory for instances locally on the Tomcat server
SET _LOCAL_INSTANCES_BASE=c:\application-server\tomcat-instances\escp

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

rem Stopping the Tomcat server
call E:\tfs\scripts\Common\service-scripts\safeServiceStop.bat %_TARGET_HOST% %_TARGET_SERVICE%

rem Removing the current Tomcat instance (except logs and webapps)
for %%F in (%_TARGET_INSTANCE_BASE%\*) do (
  del /F /Q "%%F"
)
if %ERRORLEVEL% NEQ 0 goto end
for /D %%D in (%_TARGET_INSTANCE_BASE%\*) do (
  set REMOVE_DIRECTORY=true
  if /i "%%~nD" NEQ "logs" set REMOVE_DIRECTORY=false
  if /i "%%~nD" NEQ "webapps" set REMOVE_DIRECTORY=false
  if "%REMOVE_DIRECTORY"=="true" (
    rmdir /S /Q "%%D"
  )
)

if %ERRORLEVEL% NEQ 0 goto end

rem Copying fresh Tomcat instance from TFS
xcopy %_TFS_TOMCAT_INSTANCE_DIR%\* %_TARGET_INSTANCE_BASE% /y /e
xcopy %_TFS_TOMCAT_CONFIG_DIR%\%_TARGET_INSTANCE%\*.* %_TARGET_INSTANCE_BASE%\conf /y

if %ERRORLEVEL% NEQ 0 goto end

rem Update the Tomcat service settings (in case they have changed)
call psexec.exe -w %_LOCAL_INSTANCES_BASE%\%_TARGET_INSTANCE%\bin \\%_TARGET_HOST% %_TARGET_INSTANCE_BASE%\bin\service.bat update

rem if %ERRORLEVEL% NEQ 0 goto end

rem Starting the Tomcat server
call E:\tfs\scripts\Common\service-scripts\safeServiceStart.bat %_TARGET_HOST% %_TARGET_SERVICE%

@ECHO ON
:end
