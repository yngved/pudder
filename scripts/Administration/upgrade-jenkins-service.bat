@echo off

set _JENKINS_SERVICE=%1
set _JENKINS_DIR=%2
set _JENKINS_WAR_SOURCE_DIR=%3

if "%_JENKINS_SERVICE%"=="" goto USAGE
if "%_JENKINS_DIR%"=="" goto USAGE
if "%_JENKINS_WAR_SOURCE_DIR%"=="" goto USAGE

set _HOST=localhost

SET _TIME=%TIME: =0%
set _HOUR=%_TIME:~0,2%
set _MIN=%_TIME:~3,2%

set _CURRENT_DATE=%date%
set _CURRENT=%date:~0,3%

REM Not a number format
set _YEAR=%_CURRENT_DATE:~10,4%
set _TDATE=%_CURRENT_DATE:~7,2%
set _MONTH=%_CURRENT_DATE:~4,2%

set _DATE_TIME=
SET /A cur="%_CURRENT%"*1
IF %cur% GTR 0 (
	REM Date format '12.01.2012'
	set _DATE_TIME=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%
)
IF %cur% EQU 0 (	
	REM Date format 'Thu 01/12/2012'	
	set _DATE_TIME=%_YEAR%%_MONTH%%_TDATE%_%_HOUR%%_MIN%
)

echo.
echo Start upgrading service '%_JENKINS_SERVICE%'"
echo.

call E:\tfs\ci_scripts\service-scripts\safeServiceStop.bat %_HOST% %_JENKINS_SERVICE%

echo.
echo RENAME existing war with todays date-time in directory '%_JENKINS_DIR%'
rename %_JENKINS_DIR%\jenkins.war jenkins.war.%_DATE_TIME%.bck
echo Copy new jenkins.war into directory '%_JENKINS_DIR%'
copy %_JENKINS_WAR_SOURCE_DIR%\jenkins.war %_JENKINS_DIR%

echo.
call E:\tfs\ci_scripts\service-scripts\safeServiceStart.bat %_HOST% %_JENKINS_SERVICE%

echo.
echo Jenkins service '%_JENKINS_SERVICE%' upgraded successfully
echo.

goto end

:usage

echo "Missing input parameteres"

:end

@echo on