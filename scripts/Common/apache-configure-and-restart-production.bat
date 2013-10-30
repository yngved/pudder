@ECHO OFF
REM ##################################################################################
REM 
REM	@name:		apache-configure-and-restart.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script to orchestrate configuration and restart of apache server(s)
REM in an production environment.
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV 		= PROD/BAKPROD
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

REM Production Configuration
SET _PROD_HOST_SERVER_1=st-w4190
SET _PROD_HOST_SERVER_2=st-w4201

REM BAKU Production Configuration
SET _BAKU_PROD_HOST_SERVER_1=bak-w29
SET _BAKU_PROD_HOST_SERVER_2=bak-w30


if "%TARGET_ENV%"=="PROD" (  
  SET _TARGET_HOST_SERVER_1=%_PROD_HOST_SERVER_1%
  SET _TARGET_HOST_SERVER_2=%_PROD_HOST_SERVER_2%
) else if "%TARGET_ENV%"=="PROD-BAKU" (  
  SET _TARGET_HOST_SERVER_1=%_BAKU_PROD_HOST_SERVER_1%
  SET _TARGET_HOST_SERVER_2=%_BAKU_PROD_HOST_SERVER_2%
) else (
  exit 13
)

REM ----------
REM CONFIGURATION END
REM ----------

echo TARGET_ENV=%TARGET_ENV%

REM Server 1
call %SCRIPT_HOME%\Common\apache-configure-and-restart-server.bat %_TARGET_HOST_SERVER_1%


REM SERVER 2
call %SCRIPT_HOME%\Common\apache-configure-and-restart-server.bat %_TARGET_HOST_SERVER_2%

@ECHO ON
:end