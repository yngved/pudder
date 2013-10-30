@ECHO off
REM##################################################################################
REM 
REM	@name:		replicate-build-prop-dev.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Script for setting parameters for Jenkins replicate build jobs for Forus
REM
REM Jenkins parameter(s) used: 
REM 	- TARGET_ENV 		= DEV_RELEASE, DEV_PROD, ST_RELEASE, ST_PROD, QA_RELEASE, QA_PROD
REM 										PROD, BAKU_QA_RELEASE, BAKU_QA_PROD, BAKU_PROD
REM 
REM Input parameter(s):
REM
REM##################################################################################

set TARGET_ENV=%1

REM Evaluate Jenkins paramter
set INPUT_OK=true
if %TARGET_ENV%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing in %0
	echo [INFO]
	exit failure
)

REM Common Values for all environments
set BUILD_BRANCH=DEV
set FROM_ENV=eboss-dev

if "%TARGET_ENV%"=="DEV_RELEASE" (	
	set IIS_SERVER_URL=NOT_SET
	set IIS_SERVER_URL_ENDPOINT=NOT_SET
	set IIS_USER=NOT_SET
	set WAS_SERVER_URL=NOT_SET
	set TOMCAT_SERVER_URL=NOT_SET
	set CONTEXT_ROOT=NOT_SET
) else if "%TARGET_ENV%"=="DEV_PROD" (	
	set IIS_SERVER_URL=NOT_SET
	set IIS_SERVER_URL_ENDPOINT=NOT_SET
	set IIS_USER=NOT_SET
	set WAS_SERVER_URL=NOT_SET
	set TOMCAT_SERVER_URL=NOT_SET
	set CONTEXT_ROOT=NOT_SET
)else if "%TARGET_ENV%"=="ST_RELEASE" (	
	set IIS_SERVER_URL=NOT_SET
	set IIS_SERVER_URL_ENDPOINT=NOT_SET
	set IIS_USER=NOT_SET
	set WAS_SERVER_URL=NOT_SET
	set TOMCAT_SERVER_URL=NOT_SET
	set CONTEXT_ROOT=NOT_SET
) else if "%TARGET_ENV%"=="ST_PROD" (
	set IIS_SERVER_URL=NOT_SET
	set IIS_SERVER_URL_ENDPOINT=NOT_SET
	set IIS_USER=NOT_SET
	set WAS_SERVER_URL=NOT_SET
	set TOMCAT_SERVER_URL=NOT_SET
	set CONTEXT_ROOT=NOT_SET
) else if "%TARGET_ENV%"=="QA_RELEASE" (
	set IIS_SERVER_URL=NOT_SET
	set IIS_SERVER_URL_ENDPOINT=NOT_SET
	set IIS_USER=NOT_SET
	set WAS_SERVER_URL=NOT_SET
	set TOMCAT_SERVER_URL=NOT_SET
	set CONTEXT_ROOT=NOT_SET
) else if "%TARGET_ENV%"=="QA_PROD" (
	set IIS_SERVER_URL=NOT_SET
	set IIS_SERVER_URL_ENDPOINT=NOT_SET
	set IIS_USER=NOT_SET
	set WAS_SERVER_URL=NOT_SET
	set TOMCAT_SERVER_URL=NOT_SET
	set CONTEXT_ROOT=NOT_SET
) else if "%TARGET_ENV%"=="BAK_ST" (
	set BUILD_BRANCH=DEV
	set FROM_ENV=eboss-dev
	set IIS_SERVER_URL=eboss-dev
	set IIS_SERVER_URL_ENDPOINT=bak-w27
	set IIS_USER=f_ukgieg_qa
	set WAS_SERVER_URL=wasbakust
	set TOMCAT_SERVER_URL=eboss-baku-qa
	set CONTEXT_ROOT=-agsc-
) else (
	goto failure
)

goto end

:failure
exit 13

:end
@ECHO on