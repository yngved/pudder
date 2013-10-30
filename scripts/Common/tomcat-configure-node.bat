REM ##################################################################################
REM 
REM	@name:		tomcat-configure-and-node.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script for deploying configuration and 
REM restart of an environment (PROD, BAKPROD) server on Tomcat.
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV 		= PROD, BAKPROD
REM 
REM Input parameter(s):
REM 	- %1 = APPLICATION
REM 	- %2 = TARGET_SERVICE_NODE
REM 	- %3 = TARGET_INSTANCE_NODE
REM 	- %4 = TARGET_INSTANCE_BASE_NODE
REM 	- %5 = TARGET_HOST
REM
REM This script is used by:
REM 	- tomcat-configure-and-restart.bat
REM 	- tomcat-configure-and-restart-production.bat
REM 
REM This scripts uses:
REM		- safeServiceStart.bat
REM 	- safeServiceStop.bat
REM 
REM ##################################################################################

REM Input parameters
set _APPLICATION=%1
set _TARGET_SERVICE_NODE=%2
set _TARGET_INSTANCE_NODE=%3
set _TARGET_INSTANCE_BASE_NODE=%4
set _TARGET_HOST=%5

echo "[INFO] APPLICATION=%_APPLICATION%"
echo "[INFO] TARGET_SERVICE_NODE=%_TARGET_SERVICE_NODE%"
echo "[INFO] TARGET_INSTANCE_NODE=%_TARGET_INSTANCE_NODE%"
echo "[INFO] TARGET_INSTANCE_BASE_NODE=%_TARGET_INSTANCE_BASE_NODE%"
echo "[INFO] TARGET_HOST=%_TARGET_HOST%"

set INPUT_OK=true
if %_APPLICATION%X==X set INPUT_OK=false
if %_TARGET_SERVICE_NODE%X==X set INPUT_OK=false
if %_TARGET_INSTANCE_NODE%X==X set INPUT_OK=false
if %_TARGET_INSTANCE_BASE_NODE%X==X set INPUT_OK=false
if %_TARGET_HOST%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [ERROR]
	echo [ERROR] Input parameters missing in %0
	echo [ERROR]
	goto failure	
)

SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances

rem Stopping the Tomcat server
call %SCRIPT_HOME%\Common\service-scripts\safeServiceStop.bat %_TARGET_HOST% %_TARGET_SERVICE_NODE%
if %ERRORLEVEL% NEQ 0 goto end

echo.

powershell.exe %SCRIPT_HOME%\Common\replace-in-template.ps1 -env %TARGET_ENV% -node %_NODE% -templateFile tomcat-config\%_APPLICATION%\server-template.xml -destinationFile tomcat-config\%_APPLICATION%\server.xml -propertiesFile tomcat-config\%_APPLICATION%\server.prop
powershell.exe %SCRIPT_HOME%\Common\replace-in-template.ps1 -env %TARGET_ENV% -node %_NODE% -templateFile tomcat-config\%_APPLICATION%\setenv-template.bat -destinationFile tomcat-config\%_APPLICATION%\setenv.bat -propertiesFile tomcat-config\%_APPLICATION%\setenv.prop

echo "[INFO] Copy server.xml into %_TARGET_INSTANCE_BASE_NODE%\conf"
xcopy %WORKSPACE%\tomcat-config\%_APPLICATION%\server.xml %_TARGET_INSTANCE_BASE_NODE%\conf /y 
if %ERRORLEVEL% NEQ 0 goto failure

echo "[INFO] Copy setenv.bat into %_TARGET_INSTANCE_BASE_NODE%\conf"
xcopy %WORKSPACE%\tomcat-config\%_APPLICATION%\setenv.bat %_TARGET_INSTANCE_BASE_NODE%\conf /y 
if %ERRORLEVEL% NEQ 0 goto failure

echo "[INFO] Copy the generated application context files into %_TARGET_INSTANCE_BASE_NODE%\conf\Catalina\localhost"
xcopy \\%_TARGET_HOST%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-web.xml %_TARGET_INSTANCE_BASE_NODE%\conf\Catalina\localhost /y 
if %ERRORLEVEL% NEQ 0 goto failure

echo.
echo "[INFO] Update the Tomcat service settings (in case they have changed)"
echo "[INFO] TARGET_ENV=%TARGET_ENV%"
echo "[INFO] NODE=%_NODE%

echo "[INFO] psexec.exe \\%_TARGET_HOST% -d -w c:\%_LOCAL_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE%\bin %_TARGET_INSTANCE_BASE_NODE%\bin\service.bat update"
call psexec.exe \\%_TARGET_HOST% -d -w c:\%_LOCAL_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE%\bin %_TARGET_INSTANCE_BASE_NODE%\bin\service.bat update

rem Starting the Tomcat server
call %SCRIPT_HOME%\Common\service-scripts\safeServiceStart.bat %_TARGET_HOST% %_TARGET_SERVICE_NODE%
if %ERRORLEVEL% NEQ 0 goto failure

goto end

:failure
exit 13
:end