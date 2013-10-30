@ECHO OFF
REM ##################################################################################
REM 
REM	@name:		tomcat-configure-and-restart.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script for deploying configuration and 
REM restart of an environment (Dev1, DEV2, ST1, ST2 ) server on Tomcat.
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV 		= DEV1, DEV2, ST1, ST2, QA1, QA2, BAKQA1, BAKQA2
REM 
REM Input parameter(s):
REM		- %1 = APPLICATION, eboss/escp
REM 
REM This scripts uses:
REM 	- find-and-delete-stfo-context-files.bat
REM 	- generate-context-file.bat
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

REM ----------
REM CONFIGURATION START
REM ----------

REM Base directory for instances on the Tomcat server. There are separate directories for each environment (Dev, SystemTest, etc) below the base directory.
SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances
SET _LOCAL_INSTANCES_BASE=application-server\tomcat-instances\%_APPLICATION%

REM Common Development Configuration
SET _DEV_HOST=st-w4184

REM Development Configuration DEV1
SET _DEV1_SERVICE_NODE_1=tomcat6-%_APPLICATION%-dev1-1
SET _DEV1_SERVICE_NODE_2=tomcat6-%_APPLICATION%-dev1-2
SET _DEV1_INSTANCE_NODE_1=Dev1_1
SET _DEV1_INSTANCE_NODE_2=Dev1_2

REM Development Configuration DEV2
SET _DEV2_SERVICE_NODE_1=tomcat6-%_APPLICATION%-dev2-1
SET _DEV2_SERVICE_NODE_2=tomcat6-%_APPLICATION%-dev2-2
SET _DEV2_INSTANCE_NODE_1=Dev2_1
SET _DEV2_INSTANCE_NODE_2=Dev2_2

REM Common SystemTest Configuration
SET _ST_HOST=st-tw666

REM SystemTest Configuration ST1
SET _ST1_SERVICE_NODE_1=Tomcat6-%_APPLICATION%-st1-1
SET _ST1_SERVICE_NODE_2=Tomcat6-%_APPLICATION%-st1-2
SET _ST1_INSTANCE_NODE_1=ST1_1
SET _ST1_INSTANCE_NODE_2=ST1_2

REM SystemTest Configuration ST2
SET _ST2_SERVICE_NODE_1=Tomcat6-%_APPLICATION%-st2-1
SET _ST2_SERVICE_NODE_2=Tomcat6-%_APPLICATION%-st2-2
SET _ST2_INSTANCE_NODE_1=ST2_1
SET _ST2_INSTANCE_NODE_2=ST2_2

REM QA Configuration QA1
SET _QA1_HOST_NODE_1=st-w4196
SET _QA1_HOST_NODE_2=st-w4209
SET _QA1_SERVICE_NODE_1=tomcat6-%_APPLICATION%-qa1-1
SET _QA1_SERVICE_NODE_2=tomcat6-%_APPLICATION%-qa1-2
SET _QA1_INSTANCE_NODE_1=QA1_1
SET _QA1_INSTANCE_NODE_2=QA1_2

REM QA Configuration QA2
SET _QA2_HOST_NODE_1=st-w4196
SET _QA2_HOST_NODE_2=st-w4209
SET _QA2_SERVICE_NODE_1=tomcat6-%_APPLICATION%-qa2-1
SET _QA2_SERVICE_NODE_2=tomcat6-%_APPLICATION%-qa2-2
SET _QA2_INSTANCE_NODE_1=QA2_1
SET _QA2_INSTANCE_NODE_2=QA2_2

REM BAKU QA Configuration QA1
SET _BAKU_QA1_HOST_NODE_1=bak-w27
SET _BAKU_QA1_HOST_NODE_2=bak-w28
SET _BAKU_QA1_SERVICE_NODE_1=tomcat6-%_APPLICATION%-qa1-1
SET _BAKU_QA1_SERVICE_NODE_2=tomcat6-%_APPLICATION%-qa1-2
SET _BAKU_QA1_INSTANCE_NODE_1=QA1_1
SET _BAKU_QA1_INSTANCE_NODE_2=QA1_2

REM BAKU QA Configuration QA2
SET _BAKU_QA2_HOST_NODE_1=bak-w27
SET _BAKU_QA2_HOST_NODE_2=bak-w28
SET _BAKU_QA2_SERVICE_NODE_1=tomcat6-%_APPLICATION%-qa2-1
SET _BAKU_QA2_SERVICE_NODE_2=tomcat6-%_APPLICATION%-qa2-2
SET _BAKU_QA2_INSTANCE_NODE_1=QA2_1
SET _BAKU_QA2_INSTANCE_NODE_2=QA2_2

SET _SINGLE_SERVER_ENVIRONMENT=false

if "%TARGET_ENV%"=="DEV1" (
  SET _TARGET_SERVICE_NODE_1=%_DEV1_SERVICE_NODE_1%
  SET _TARGET_SERVICE_NODE_2=%_DEV1_SERVICE_NODE_2%
  SET _TARGET_INSTANCE_NODE_1=%_DEV1_INSTANCE_NODE_1%
  SET _TARGET_INSTANCE_NODE_2=%_DEV1_INSTANCE_NODE_2%
  SET _TARGET_HOST_NODE_1=%_DEV_HOST%
  SET _SINGLE_SERVER_ENVIRONMENT=true
) else if "%TARGET_ENV%"=="DEV2" (
  SET _TARGET_SERVICE_NODE_1=%_DEV2_SERVICE_NODE_1%
  SET _TARGET_SERVICE_NODE_2=%_DEV2_SERVICE_NODE_2%
  SET _TARGET_INSTANCE_NODE_1=%_DEV2_INSTANCE_NODE_1%
  SET _TARGET_INSTANCE_NODE_2=%_DEV2_INSTANCE_NODE_2%
  SET _TARGET_HOST_NODE_1=%_DEV_HOST%
  SET _SINGLE_SERVER_ENVIRONMENT=true
) else if "%TARGET_ENV%"=="ST1" (
  SET _TARGET_SERVICE_NODE_1=%_ST1_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_ST1_SERVICE_NODE_2%
	SET _TARGET_INSTANCE_NODE_1=%_ST1_INSTANCE_NODE_1%
  SET _TARGET_INSTANCE_NODE_2=%_ST1_INSTANCE_NODE_2%
  SET _TARGET_HOST_NODE_1=%_ST_HOST%
  SET _SINGLE_SERVER_ENVIRONMENT=true
) else if "%TARGET_ENV%"=="ST2" (
  SET _TARGET_SERVICE_NODE_1=%_ST2_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_ST2_SERVICE_NODE_2%
	SET _TARGET_INSTANCE_NODE_1=%_ST2_INSTANCE_NODE_1%
  SET _TARGET_INSTANCE_NODE_2=%_ST2_INSTANCE_NODE_2%
  SET _TARGET_HOST_NODE_1=%_ST_HOST%
  SET _SINGLE_SERVER_ENVIRONMENT=true
) else if "%TARGET_ENV%"=="QA1" (
  SET _TARGET_SERVICE_NODE_1=%_QA1_SERVICE_NODE_1%
  SET _TARGET_SERVICE_NODE_2=%_QA1_SERVICE_NODE_2%
  SET _TARGET_INSTANCE_NODE_1=%_QA1_INSTANCE_NODE_1%
  SET _TARGET_INSTANCE_NODE_2=%_QA1_INSTANCE_NODE_2%
  SET _TARGET_HOST_NODE_1=%_QA1_HOST_NODE_1%
  SET _TARGET_HOST_NODE_2=%_QA1_HOST_NODE_2%
) else if "%TARGET_ENV%"=="QA2" (
  SET _TARGET_SERVICE_NODE_1=%_QA2_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_QA2_SERVICE_NODE_2%
	SET _TARGET_INSTANCE_NODE_1=%_QA2_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_NODE_2=%_QA2_INSTANCE_NODE_2%
	SET _TARGET_HOST_NODE_1=%_QA2_HOST_NODE_1%
  SET _TARGET_HOST_NODE_2=%_QA2_HOST_NODE_2%
) else if "%TARGET_ENV%"=="BAKQA1" (
  SET _TARGET_SERVICE_NODE_1=%_BAKU_QA1_SERVICE_NODE_1%
  SET _TARGET_SERVICE_NODE_2=%_BAKU_QA1_SERVICE_NODE_2%
  SET _TARGET_INSTANCE_NODE_1=%_BAKU_QA1_INSTANCE_NODE_1%
  SET _TARGET_INSTANCE_NODE_2=%_BAKU_QA1_INSTANCE_NODE_2%
  SET _TARGET_HOST_NODE_1=%_BAKU_QA1_HOST_NODE_1%
  SET _TARGET_HOST_NODE_2=%_BAKU_QA1_HOST_NODE_2%
) else if "%TARGET_ENV%"=="BAKQA2" (
  SET _TARGET_SERVICE_NODE_1=%_BAKU_QA2_SERVICE_NODE_1%
	SET _TARGET_SERVICE_NODE_2=%_BAKU_QA2_SERVICE_NODE_2%
	SET _TARGET_INSTANCE_NODE_1=%_BAKU_QA2_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_NODE_2=%_BAKU_QA2_INSTANCE_NODE_2%
	SET _TARGET_HOST_NODE_1=%_BAKU_QA2_HOST_NODE_1%
  SET _TARGET_HOST_NODE_2=%_BAKU_QA2_HOST_NODE_2%  
)else (
  goto failure
)

SET _TARGET_INSTANCE_BASE_HOST_1_NODE_1=\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_1%
SET _TARGET_INSTANCE_BASE_HOST_1_NODE_2=\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_2%

REM Create temp app-context host on host
REM The generated 'xxx-web.xml' files will be generated here
dir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context >nul 2>nul
if errorlevel 1 (
  echo "Create \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context"
	mkdir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context	
)

if %_SINGLE_SERVER_ENVIRONMENT%==false (
	SET _TARGET_INSTANCE_BASE_HOST_2_NODE_1=\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_1%
	SET _TARGET_INSTANCE_BASE_HOST_2_NODE_2=\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%_TARGET_INSTANCE_NODE_2%
	
	dir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context >nul 2>nul
	if errorlevel 1 (
  	echo "Create \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context"
		mkdir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context		
	)	
)

REM --------------------
echo CONFIGURATION END
REM ---------------------


REM Capture current directory
set _CUR_DIR=%cd%
cd tomcat-config\%_APPLICATION%\context
REM Loop through the '*-template.xml' files and generate an application context file for each application
for %%f in (*-template.xml) do (
	call %SCRIPT_HOME%\Common\generate-context-file.bat %%f %_APPLICATION% %TARGET_ENV% %_TARGET_HOST_NODE_1%
	if %ERRORLEVEL% NEQ 0 goto failure
)

REM Change directory back to current
cd %_CUR_DIR%
set _REMOVE_STFO_WEB=false
if "%TARGET_ENV%"=="BAKQA1" set _REMOVE_STFO_WEB=true
if "%TARGET_ENV%"=="BAKQA2" set _REMOVE_STFO_WEB=true

if "%_REMOVE_STFO_WEB%"=="true" (
	echo "Remove STFO app context files on %_TARGET_HOST_NODE_1%"	
	for %%f in (\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*.xml) do (
		call %SCRIPT_HOME%\Common\find-and-delete-stfo-context-files.bat %%f
	)	
) else (	
	echo "Remove SCPC and AGSC app context files on %_TARGET_HOST_NODE_1%"
	del \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-scpc-*web.xml	
	del \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-agsc-*web.xml	
)

REM HOST 1 NODE 1
set _NODE=NODE1
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_1% %_TARGET_INSTANCE_NODE_1% %_TARGET_INSTANCE_BASE_HOST_1_NODE_1% %_TARGET_HOST_NODE_1%
REM HOST 1 NODE 2
set _NODE=NODE2
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_2% %_TARGET_INSTANCE_NODE_2% %_TARGET_INSTANCE_BASE_HOST_1_NODE_2% %_TARGET_HOST_NODE_1%

REM Cleanup the working direcory
rmdir \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /S /Q
if %ERRORLEVEL% NEQ 0 goto failure

REM If this is a single server environment, goto end
if %_SINGLE_SERVER_ENVIRONMENT%==true goto end

REM Capture current directory
set _CUR_DIR=%cd%
cd tomcat-config\%_APPLICATION%\context
REM Loop through the '*-template.xml' files and generate an application context file for each application
for %%f in (*-template.xml) do (
	call %SCRIPT_HOME%\Common\generate-context-file.bat %%f %_APPLICATION% %TARGET_ENV% %_TARGET_HOST_NODE_2%
	if %ERRORLEVEL% NEQ 0 goto failure
)

REM Change directory back to current
cd %_CUR_DIR%

if "%_REMOVE_STFO_WEB%"=="true" (
	echo "Remove STFO app context files on %_TARGET_HOST_NODE_2%"	
	for %%f in (\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*.xml) do (
		call %SCRIPT_HOME%\Common\find-and-delete-stfo-context-files.bat %%f
	)	
) else (	
	echo "Remove SCPC and AGSC app context files on %_TARGET_HOST_NODE_2%"	
	del \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-scpc-*web.xml	
	del \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\*-agsc-*web.xml
)
	
REM HOST2 NODE 1
set _NODE=NODE1
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_1% %_TARGET_INSTANCE_NODE_1% %_TARGET_INSTANCE_BASE_HOST_2_NODE_1% %_TARGET_HOST_NODE_2%

REM HOST2 NODE 2
set _NODE=NODE2
call %SCRIPT_HOME%\Common\tomcat-configure-node.bat %_APPLICATION% %_TARGET_SERVICE_NODE_2% %_TARGET_INSTANCE_NODE_2% %_TARGET_INSTANCE_BASE_HOST_2_NODE_2% %_TARGET_HOST_NODE_2%

REM Cleanup the temp app-context working direcory
rmdir \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /S /Q
if %ERRORLEVEL% NEQ 0 goto failure

goto end

:failure
exit 13

:end





@ECHO ON