@ECHO OFF
REM ##################################################################################
REM 
REM	@name:		tomcat-configure-and-restart-production.bat
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
REM		- %1 = APPLICATION, eboss/escp
REM
REM This scripts uses:
REM 	- find-and-delete-stfo-context-files.bat
REM 	- generate-context-file-prod.bat
REM 	- tomcat-configure-node.bat
REM 		- safeServiceStart.bat
REM 		- safeServiceStop.bat
REM 
REM ##################################################################################

REM Input parameters
set _APPLICATION=%1

set INPUT_OK=true
if %_APPLICATION%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [ERROR]
	echo [ERROR] Input parameters missing in %0
	echo [ERROR]
	goto failure	
)

echo.
echo "APPLICATION=%_APPLICATION%
echo.

REM Base directory for instances on the Tomcat server. There are separate directories for each environment (Dev, SystemTest, etc) below the base directory.
SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances
SET _LOCAL_INSTANCES_BASE=application-server\tomcat-instances\%_APPLICATION%

REM PRODUCTION Configuration 
SET _PROD_HOST_NODE_1=st-w4190
SET _PROD_HOST_NODE_2=st-w4201
SET _PROD_SERVICE_NODE_1=Tomcat6-%_APPLICATION%-prod1-1
SET _PROD_SERVICE_NODE_2=Tomcat6-%_APPLICATION%-prod1-2
SET _PROD_INSTANCE_NODE_1=PROD1_1
SET _PROD_INSTANCE_NODE_2=PROD1_2

REM BAKU PRODUCTION Configuration 
SET _BAKU_PROD_HOST_NODE_1=bak-w29
SET _BAKU_PROD_HOST_NODE_2=bak-w30
SET _BAKU_PROD_SERVICE_NODE_1=Tomcat6-%_APPLICATION%-prod1-1
SET _BAKU_PROD_SERVICE_NODE_2=Tomcat6-%_APPLICATION%-prod1-2
SET _BAKU_PROD_INSTANCE_NODE_1=PROD1_1
SET _BAKU_PROD_INSTANCE_NODE_2=PROD1_2

if "%TARGET_ENV%"=="PROD" (
  SET _TARGET_SERVICE_NODE_1=%_PROD_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_PROD_SERVICE_NODE_2%
	SET _TARGET_INSTANCE_NODE_1=%_PROD_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_NODE_2=%_PROD_INSTANCE_NODE_2%
	SET _TARGET_HOST_NODE_1=%_PROD_HOST_NODE_1%
  SET _TARGET_HOST_NODE_2=%_PROD_HOST_NODE_2%
) else if "%TARGET_ENV%"=="BAKPROD" (
  SET _TARGET_SERVICE_NODE_1=%_BAKU_PROD_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_BAKU_PROD_SERVICE_NODE_2%
	SET _TARGET_INSTANCE_NODE_1=%_BAKU_PROD_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_NODE_2=%_BAKU_PROD_INSTANCE_NODE_2%
	SET _TARGET_HOST_NODE_1=%_BAKU_PROD_HOST_NODE_1%
  SET _TARGET_HOST_NODE_2=%_BAKU_PROD_HOST_NODE_2%
) else (
  goto end
)

SET _TARGET_INSTANCE_BASE_HOST_1_NODE_1=\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_1%
SET _TARGET_INSTANCE_BASE_HOST_1_NODE_2=\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_2%

SET _TARGET_INSTANCE_BASE_HOST_2_NODE_1=\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_1%
SET _TARGET_INSTANCE_BASE_HOST_2_NODE_2=\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_2%

REM ----------
REM CONFIGURATION END
REM ----------

REM Create temp app-context on hosts
REM The generated 'xxx-web.xml' files will be generated here
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

REM Capture current directory and change to 'context' dir
set _CUR_DIR=%cd%
cd tomcat-config\%_APPLICATION%\context

REM SET the PASSWORD_FILE_PREFIX=CONFIGURE. The script 'generate-context-file-prod.bat' will
REM set the correct PREFIX based on input file name.
set _PASSWORD_FILE_PREFIX=CONFIGURE
REM Loop through the '*-template.xml' files and generate an application context file for each application
for %%f in (*-template.xml) do (
	call %SCRIPT_HOME%\Common\generate-context-file-prod.bat %%f %_APPLICATION% %TARGET_ENV% %_PASSWORD_FILE_PREFIX% %_TARGET_HOST_NODE_1% %_TARGET_HOST_NODE_2%
	if %ERRORLEVEL% NEQ 0 goto failure
)

REM Change directory back to current
cd %_CUR_DIR%

REM All app-context files are generated, remove the ones not needed.
if "%TARGET_ENV%"=="BAKPROD" (
	echo "Remove STFO app context files on %_TARGET_HOST_NODE_1%"	
	for %%f in (\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*.xml) do (
		call %SCRIPT_HOME%\Common\find-and-delete-stfo-context-files.bat %%f
	)
	
	echo "Remove STFO app context files on %_TARGET_HOST_NODE_2%"	
	for %%f in (\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*.xml) do (
			call %SCRIPT_HOME%\Common\find-and-delete-stfo-context-files.bat %%f
	)
	
) else (
	echo "Remove SCPC and AGSC app context files on %_TARGET_HOST_NODE_1% and %_TARGET_HOST_NODE_2%"
	del \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-scpc-*web.xml	
	del \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-scpc-*web.xml	
	del \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-agsc-*web.xml	
	del \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-agsc-*web.xml	
)

REM HOST1 NODE1
set _NODE=NODE1
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_1% %_TARGET_INSTANCE_NODE_1% %_TARGET_INSTANCE_BASE_HOST_1_NODE_1% %_TARGET_HOST_NODE_1%
if %ERRORLEVEL% NEQ 0 goto failure

REM HOST1 NODE2
set _NODE=NODE2
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_2% %_TARGET_INSTANCE_NODE_2% %_TARGET_INSTANCE_BASE_HOST_1_NODE_2% %_TARGET_HOST_NODE_1%
if %ERRORLEVEL% NEQ 0 goto failure

REM HOST2 NODE 1
set _NODE=NODE1
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_1% %_TARGET_INSTANCE_NODE_1% %_TARGET_INSTANCE_BASE_HOST_2_NODE_1% %_TARGET_HOST_NODE_2%
if %ERRORLEVEL% NEQ 0 goto failure

REM HOST2 NODE 2
set _NODE=NODE2
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_2% %_TARGET_INSTANCE_NODE_2% %_TARGET_INSTANCE_BASE_HOST_2_NODE_2% %_TARGET_HOST_NODE_2%
if %ERRORLEVEL% NEQ 0 goto failure

REM Cleanup the temp app-context working direcory
rmdir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /S /Q
if %ERRORLEVEL% NEQ 0 goto failure

rmdir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /S /Q
if %ERRORLEVEL% NEQ 0 goto failure

goto end

:failure
exit 13

:end
@ECHO ON