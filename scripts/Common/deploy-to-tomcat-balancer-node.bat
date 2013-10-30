setlocal enabledelayedexpansion
REM ##################################################################################
REM 
REM	@name:		deploy-to-tomcat-balancer-node.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script for deployment of artifacts to Tomcat for a node. The script will
REM copy the app-context file generated from the calling script.
REM
REM Jenkins parameter(s) used: 
REM 	- JOB_NAME 			= Used to find the generated app context file to deploy
REM 	- TARGET_ENV 		= Used for setting the correct disable/enable command
REM 
REM Input parameter(s):
REM 	- %1 = APPLICATION 
REM 	- %2 = WEBAPP_NAME to deploy
REM 	- %3 = TARGET_HOST
REM 	- %4 = TARGET_PORT
REM 	- %5 = TARGET_INSTANCE_BASE_NODE
REM 
REM This script is used by:
REM 	- deploy-to-tomcat-balancer.bat
REM 	- deploy-to-tomcat-balancer-production.bat
REM This scripts uses:
REM 	- enable-disable-webapp.ps1
REM
REM ##################################################################################
SET _APPLICATION=%1
set _WEBAPP_NAME=%2
set _TARGET_HOST=%3
set _TARGET_PORT=%4
set _TARGET_INSTANCE_BASE_NODE=%5

SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances

REM Evaluate input parameters argument
set INPUT_OK=true
if %_WEBAPP_NAME%X==X set INPUT_OK=false
if %_TARGET_HOST%X==X set INPUT_OK=false
if %_TARGET_PORT%X==X set INPUT_OK=false
if %_TARGET_INSTANCE_BASE_NODE%X==X set INPUT_OK=false

echo.
echo "[INFO] Start deployment of %_WEBAPP_NAME% to %_TARGET_INSTANCE_BASE_NODE%"
echo "[INFO] TARGET_ENV=%TARGET_ENV%"
echo "[INFO] TARGET_HOST=%_TARGET_HOST%"
echo "[INFO] TARGET_PORT=%_TARGET_PORT%"
echo.

if %INPUT_OK%==false (
	echo [ERROR]
	echo [ERROR] Input parameters missing in %0
	echo [ERROR]
	goto FAILURE
)

SET _DISABLE=Disable
SET _ENABLE=Enable

echo.
echo "Start deployment of %_WEBAPP_NAME% on %_TARGET_INSTANCE_BASE_NODE%"
echo.

REM Copying war file to the webapps directory
echo "[INFO] Copy %WORKSPACE%\deploy\%_WEBAPP_NAME%.war to %_TARGET_INSTANCE_BASE_NODE%\webapps
copy %WORKSPACE%\deploy\%_WEBAPP_NAME%.war %_TARGET_INSTANCE_BASE_NODE%\webapps\%_WEBAPP_NAME%.war.bck

if %ERRORLEVEL% NEQ 0 goto FAILURE

REM Disable application on node
echo "[INFO] Disable application %_WEBAPP_NAME%"
powershell.exe %SCRIPT_HOME%\Common\enable-disable-webapp.ps1 -targetEnv %TARGET_ENV% -appl %_WEBAPP_NAME% -targetHost %_TARGET_HOST% -targetPort %_TARGET_PORT% -cmd %_DISABLE%
if %ERRORLEVEL% NEQ 0 goto FAILURE

REM Delete old war and rename the copied war
echo "[INFO] Delete %_TARGET_INSTANCE_BASE_NODE%\webapps\%_WEBAPP_NAME%.war"
del %_TARGET_INSTANCE_BASE_NODE%\webapps\%_WEBAPP_NAME%.war
if %ERRORLEVEL% NEQ 0 goto FAILURE

echo "[INFO] Rename %_WEBAPP_NAME%.war.bck -> %_WEBAPP_NAME%.war
rename %_TARGET_INSTANCE_BASE_NODE%\webapps\%_WEBAPP_NAME%.war.bck %_WEBAPP_NAME%.war
if %ERRORLEVEL% NEQ 0 goto FAILURE

echo "[INFO] Copy the generated application context file into %_TARGET_INSTANCE_BASE_NODE%\conf\Catalina\localhost"
xcopy \\%_TARGET_HOST%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_WEBAPP_NAME%.xml %_TARGET_INSTANCE_BASE_NODE%\conf\Catalina\localhost /y 
if %ERRORLEVEL% NEQ 0 goto FAILURE

REM Enable node application
echo.
echo "[INFO] Enable application %_WEBAPP_NAME%"
powershell.exe %SCRIPT_HOME%\Common\enable-disable-webapp.ps1 -targetEnv %TARGET_ENV% -appl %_WEBAPP_NAME% -targetHost %_TARGET_HOST% -targetPort %_TARGET_PORT% -cmd %_Enable%
if %ERRORLEVEL% NEQ 0 goto FAILURE

echo.
echo "[INFO] Deployment of %_WEBAPP_NAME% to %_TARGET_INSTANCE_BASE_NODE% finished successfully"
echo.

goto END

:FAILURE
exit 13

:END