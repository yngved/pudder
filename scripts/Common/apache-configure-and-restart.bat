@ECHO OFF
REM ##################################################################################
REM 
REM	@name:		apache-configure-and-restart.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script to orchestrate configuration and restart of apache server(s)
REM in an environment.
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV 		= DEV1, DEV2, ST1, ST2, QA1, QA2, BAKQA1, BAKQA2
REM 
REM Input parameter(s):
REM
REM This scripts uses:
REM 	- apache-configure-and-restart-server.bat
REM 		- safeServiceStart.bat
REM 		- safeServiceStop.bat
REM 
REM ##################################################################################

REM ----------
REM CONFIGURATION START
REM ----------

REM Development Configuration
SET _DEV_HOST=st-w4184

REM SystemTest Configuration
SET _ST_HOST=st-tw666

REM QA Configuration
SET _QA_HOST_SERVER_1=st-w4196
SET _QA_HOST_SERVER_2=st-w4209

REM BAKU QA Configuration
SET _BAKU_QA_HOST_SERVER_1=bak-w27
SET _BAKU_QA_HOST_SERVER_2=bak-w28

set _TARGET_HOST_SERVER_1=
set _TARGET_HOST_SERVER_2=

if "%TARGET_ENV%"=="DEV" (  
  SET _TARGET_HOST_SERVER_1=%_DEV_HOST%
) else if "%TARGET_ENV%"=="ST" (  
  SET _TARGET_HOST_SERVER_1=%_ST_HOST%
) else if "%TARGET_ENV%"=="QA" (  
  SET _TARGET_HOST_SERVER_1=%_QA_HOST_SERVER_1%
  SET _TARGET_HOST_SERVER_2=%_QA_HOST_SERVER_2%
) else if "%TARGET_ENV%"=="QABAKU" (  
  SET _TARGET_HOST_SERVER_1=%_BAKU_QA_HOST_SERVER_1%
  SET _TARGET_HOST_SERVER_2=%_BAKU_QA_HOST_SERVER_2%
)else (
  goto end
)

echo TARGET_ENV=%TARGET_ENV%

set DEPLOY_SERVER_1=true
set DEPLOY_SERVER_2=true
if %_TARGET_HOST_SERVER_1%X==X set DEPLOY_SERVER_1=false
if %_TARGET_HOST_SERVER_2%X==X set DEPLOY_SERVER_2=false

if %DEPLOY_SERVER_1%==true (
	call %SCRIPT_HOME%\Common\apache-configure-and-restart-server.bat %_TARGET_HOST_SERVER_1%
)

if %DEPLOY_SERVER_2%==true (
	call %SCRIPT_HOME%\Common\apache-configure-and-restart-server.bat %_TARGET_HOST_SERVER_2%
)

@ECHO ON
:end