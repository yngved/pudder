@ECHO OFF
setlocal enabledelayedexpansion
REM ##################################################################################
REM 
REM	@name:		deploy-to-tomcat-balancer-production.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script for deployment of artifacts to Tomcat (Production environment)
REM
REM Jenkins parameter(s) used: 
REM 	- JOB_NAME 			= Used for creating a temp app context directory
REM 	- TARGET_ENV 		= PROD, BAKPROD
REM 	- CONTEXT_ROOT  = '-', '-agsc-', '-scpc-')
REM 
REM Input parameter(s):
REM 	- %1 = APPLICATION: eboss/escp
REM 	- %2 = WEBAPP_NAME to deploy (without '-web' will be added in script)
REM 	- %3 = PASSWORD_FILE_PREFIX (energyboss, pfi)
REM
REM This scripts uses:
REM 	- deploy-to-tomcat-balancer-node.bat
REM 		- enable-disable-webapp.ps1
REM 
REM ##################################################################################
set _APPLICATION=%1
set _INPUT_PARAM=%2
set _PASSWORD_FILE_PREFIX=%3

REM Evaluate ENVIRONMENT argument
set INPUT_OK=true
if %TARGET_ENV%X==X set INPUT_OK=false
if %_APPLICATION%X==X set INPUT_OK=false
if %_INPUT_PARAM%X==X set INPUT_OK=false
if %_PASSWORD_FILE_PREFIX%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [ERROR]
	echo [ERROR] Input parameters missing in %0
	echo [ERROR]
	goto END	
)

set _PORT_PREFIX=
if "%_APPLICATION%"=="eboss" (
	set _PORT_PREFIX=80
) else if "%_APPLICATION%"=="escp" (
	set _PORT_PREFIX=81
) else (
  goto FAILURE
)

set _WEBAPP_NAME=%_INPUT_PARAM%%CONTEXT_ROOT%web
SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances

REM ----------
REM CONFIGURATION START
REM ----------

REM Configuration of hosts, directories, and services for the separate environments

REM PROD
SET _PROD_HOST_NODE_1=st-w4190
SET _PROD_HOST_NODE_2=st-w4201
SET _PROD_HOST_URL=eboss-prod.statoil.no
SET _PROD_INSTANCE_NODE_1=PROD1_1
SET _PROD_INSTANCE_NODE_2=PROD1_2
SET _PROD_SERVICE_NODE_1=Tomcat6-%_APPLICATION%-prod1-1
SET _PROD_SERVICE_NODE_2=Tomcat6-%_APPLICATION%-prod1-2
SET _PROD_SERVICE_PORT_NODE_1=%_PORT_PREFIX%01
SET _PROD_SERVICE_PORT_NODE_2=%_PORT_PREFIX%02

REM BAKU PROD
SET _BAKU_PROD_HOST_NODE_1=bak-w29
SET _BAKU_PROD_HOST_NODE_2=bak-w30
SET _BAKU_PROD_HOST_URL=eboss-prod.statoil.no
SET _BAKU_PROD_INSTANCE_NODE_1=PROD1_1
SET _BAKU_PROD_INSTANCE_NODE_2=PROD1_2
SET _BAKU_PROD_SERVICE_NODE_1=Tomcat6-%_APPLICATION%-prod1-1
SET _BAKU_PROD_SERVICE_NODE_2=Tomcat6-%_APPLICATION%-prod1-2
SET _BAKU_PROD_SERVICE_PORT_NODE_1=%_PORT_PREFIX%01
SET _BAKU_PROD_SERVICE_PORT_NODE_2=%_PORT_PREFIX%02

REM Setting target service/host/instance based on TARGET_ENV (specified as input to the job)
if "%TARGET_ENV%"=="PROD" (  
  SET _TARGET_HOST_NODE_1=%_PROD_HOST_NODE_1%
	SET _TARGET_HOST_NODE_2=%_PROD_HOST_NODE_2%
	SET _TARGET_HOST_URL=%_PROD_HOST_URL%
	SET _TARGET_INSTANCE_NODE_1=%_PROD_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_NODE_2=%_PROD_INSTANCE_NODE_2%
	SET _TARGET_SERVICE_NODE_1=%_PROD_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_PROD_SERVICE_NODE_2%
	SET _TARGET_SERVICE_PORT_NODE_1=%_PROD_SERVICE_PORT_NODE_1%
  SET _TARGET_SERVICE_PORT_NODE_2=%_PROD_SERVICE_PORT_NODE_2%
) else if "%TARGET_ENV%"=="BAKPROD" (
  SET _TARGET_HOST_NODE_1=%_BAKU_PROD_HOST_NODE_1%
	SET _TARGET_HOST_NODE_2=%_BAKU_PROD_HOST_NODE_2%
	SET _TARGET_HOST_URL=%_BAKU_PROD_HOST_URL%
	SET _TARGET_INSTANCE_NODE_1=%_BAKU_PROD_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_NODE_2=%_BAKU_PROD_INSTANCE_NODE_2%
	SET _TARGET_SERVICE_NODE_1=%_BAKU_PROD_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_BAKU_PROD_SERVICE_NODE_2%
	SET _TARGET_SERVICE_PORT_NODE_1=%_BAKU_PROD_SERVICE_PORT_NODE_1%
  SET _TARGET_SERVICE_PORT_NODE_2=%_BAKU_PROD_SERVICE_PORT_NODE_2%
) else (
  goto FAILURE
)

SET _TARGET_INSTANCE_BASE_HOST_1_NODE_1=\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_1%
SET _TARGET_INSTANCE_BASE_HOST_1_NODE_2=\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_2%

SET _TARGET_INSTANCE_BASE_HOST_2_NODE_1=\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_1%
SET _TARGET_INSTANCE_BASE_HOST_2_NODE_2=\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_2%


REM ----------
REM CONFIGURATION END
REM ----------

REM Create temporary app-context on deployment server if not exists
dir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context >nul 2>nul
if errorlevel 1 (
  echo "Create \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context"
	mkdir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context
)

dir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context >nul 2>nul
if errorlevel 1 (
  echo "Create \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context"
	mkdir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context
)


REM Generate context file for application
set _CUR_DIR=%cd%
cd tomcat-config\%_APPLICATION%\context
echo %SCRIPT_HOME%\Common\generate-context-file-prod.bat %_WEBAPP_NAME%-context-template.xml %_APPLICATION% %TARGET_ENV% %_PASSWORD_FILE_PREFIX% %_TARGET_HOST_NODE_1% %_TARGET_HOST_NODE_2%
call %SCRIPT_HOME%\Common\generate-context-file-prod.bat %_WEBAPP_NAME%-context-template.xml %_APPLICATION% %TARGET_ENV% %_PASSWORD_FILE_PREFIX% %_TARGET_HOST_NODE_1% %_TARGET_HOST_NODE_2%
if %ERRORLEVEL% NEQ 0 goto FAILURE

REM Change directory back to current
cd %_CUR_DIR%

REM HOST1 NODE1
echo.
echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_1%\%_TARGET_SERVICE_NODE_1%"
echo %SCRIPT_HOME%\Common\deploy-to-tomcat-balancer-node.bat %_APPLICATION% %_WEBAPP_NAME% %_TARGET_HOST_NODE_1% %_TARGET_SERVICE_PORT_NODE_1% %_TARGET_INSTANCE_BASE_HOST_1_NODE_1%
call %SCRIPT_HOME%\Common\deploy-to-tomcat-balancer-node.bat %_APPLICATION% %_WEBAPP_NAME% %_TARGET_HOST_NODE_1% %_TARGET_SERVICE_PORT_NODE_1% %_TARGET_INSTANCE_BASE_HOST_1_NODE_1%

if %ERRORLEVEL% NEQ 0 goto FAILURE

echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_1%\%_TARGET_SERVICE_NODE_1% FINISHED"

REM HOST1 NODE2
echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_1%\%_TARGET_SERVICE_NODE_2%"
call %SCRIPT_HOME%\Common\deploy-to-tomcat-balancer-node.bat %_APPLICATION% %_WEBAPP_NAME% %_TARGET_HOST_NODE_1% %_TARGET_SERVICE_PORT_NODE_2% %_TARGET_INSTANCE_BASE_HOST_1_NODE_2% 

if %ERRORLEVEL% NEQ 0 goto FAILURE

echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_1%\%_TARGET_SERVICE_NODE_2% FINISHED"

REM HOST2 NODE 1
echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_2%\%_TARGET_SERVICE_NODE_1%"
call %SCRIPT_HOME%\Common\deploy-to-tomcat-balancer-node.bat %_APPLICATION% %_WEBAPP_NAME% %_TARGET_HOST_NODE_2% %_TARGET_SERVICE_PORT_NODE_1% %_TARGET_INSTANCE_BASE_HOST_2_NODE_1% 

if %ERRORLEVEL% NEQ 0 goto FAILURE

echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_2%\%_TARGET_SERVICE_NODE_1% FINISHED"

REM HOST2 NODE 2
echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_2%\%_TARGET_SERVICE_NODE_2%"
call %SCRIPT_HOME%\Common\deploy-to-tomcat-balancer-node.bat %_APPLICATION% %_WEBAPP_NAME% %_TARGET_HOST_NODE_2% %_TARGET_SERVICE_PORT_NODE_2% %_TARGET_INSTANCE_BASE_HOST_2_NODE_2% 

if %ERRORLEVEL% NEQ 0 goto FAILURE

echo "[INFO] HOST\SERVICE: %_TARGET_HOST_NODE_2%\%_TARGET_SERVICE_NODE_2% FINISHED"

REM Remove temp app-context directory on deployment server 
rmdir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /S /Q
if %ERRORLEVEL% NEQ 0 goto failure

REM Remove temp app-context for application on deployment server 
rmdir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /S /Q
if %ERRORLEVEL% NEQ 0 goto failure

goto end

:FAILURE
exit 13

@ECHO ON
:END