@ECHO OFF
REM ##################################################################################
REM 
REM	@name:		apache-configure-and-restart-server.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script for deploying index.html and 'httpd-proxy-mappings-xxx'.conf on
REM target server
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV 		= PROD, BAKPROD
REM 
REM Input parameter(s):
REM 	- %1 = TARGET_HOST
REM
REM This script is used by:
REM 	- apache-configure-and-restart.bat
REM 	- apache-configure-and-restart-production.bat
REM 
REM This scripts uses:
REM		- safeServiceStart.bat
REM 	- safeServiceStop.bat
REM 
REM ##################################################################################


REM Input parameters
set TARGET_HOST=%1

REM Evaluate command line arguments
set INPUT_OK=true
if %TARGET_HOST%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	goto failure
)

REM ----------
REM CONFIGURATION START
REM ----------


REM Base directory for instances on the Apache web server. 
SET _INSTANCE_PROXY_MAPPING=apache-proxy-mappings
SET _INSTANCE_HTDOCS=apache-htdocs

SET _TARGET_SERVICE=Apache2.2

SET _TARGET_INSTANCE_PROXY_MAPPING=\\%TARGET_HOST%\%_INSTANCE_PROXY_MAPPING%

REM ----------
REM CONFIGURATION END
REM ----------


REM Stopping the Apache server
call %SCRIPT_HOME%\Common\service-scripts\safeServiceStop.bat %TARGET_HOST% %_TARGET_SERVICE%

if %ERRORLEVEL% NEQ 0 goto failure

echo.
echo "Copy apache configuration files into %_TARGET_INSTANCE_PROXY_MAPPING%"
echo f | xcopy /f /y %WORKSPACE%\apache-config\httpd-proxy-mappings-eboss-%TARGET_ENV%.conf %_TARGET_INSTANCE_PROXY_MAPPING%\httpd-proxy-mappings-eboss.conf 
if %ERRORLEVEL% NEQ 0 goto failure
echo f | xcopy /f /y %WORKSPACE%\apache-config\httpd-proxy-mappings-escp-%TARGET_ENV%.conf %_TARGET_INSTANCE_PROXY_MAPPING%\httpd-proxy-mappings-escp.conf 
if %ERRORLEVEL% NEQ 0 goto failure

echo.
echo "Copy apache index.html file into \\%TARGET_HOST%\%_INSTANCE_HTDOCS%\"
echo f | xcopy /f /y %WORKSPACE%\apache-docs\index-%TARGET_ENV%.html \\%TARGET_HOST%\%_INSTANCE_HTDOCS%\index.html
if %ERRORLEVEL% NEQ 0 goto failure

rem Starting the Apache server
call %SCRIPT_HOME%\Common\service-scripts\safeServiceStart.bat %TARGET_HOST% %_TARGET_SERVICE%

goto end

:failure
exit 13

:end
@ECHO ON