REM ##################################################################################
REM 
REM	@name:		generate-context-file.bat
REM @created: 22.10.2013
REM @author: 	YND
REM
REM Script for generating app context file for each web application
REM
REM Jenkins parameter(s) used: 
REM 	- JOB_NAME 			= Used deploy the generated file
REM 
REM Input parameter(s):
REM 	- %1 = FILE_NAME
REM 	- %2 = APPLICATION
REM 	- %3 = TARGET_ENV
REM 	- %4 = TARGET_HOST
REM 
REM This script is used by:
REM 	- deploy-to-tomcat-balancer.bat
REM 	- tomcat-configure-and-restart.bat
REM
REM ##################################################################################



REM Process each file
set _FILE_NAME=%1
set _APPLICATION=%2
set _TARGET_ENV=%3
set _TARGET_HOST=%4

REM substring of the file name to get the APPL_NAME.
REM All file name must end with '-context-template.xml' (21 chars)
set _APPL_NAME=%_FILE_NAME:~,-21%

echo "TARGET_ENV=%_TARGET_ENV%"
echo "File_NAME=%_FILE_NAME%" 
echo "APPL_NAME=%_APPL_NAME%"
echo "TARGET_HOST=%_TARGET_HOST%

SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances

echo %SCRIPT_HOME%\replace-in-template-env.ps1 -env %_TARGET_ENV% -templateFile %_FILE_NAME% -destinationFile \\%_TARGET_HOST%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_APPL_NAME%.xml -propertiesFile context.prop
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %_TARGET_ENV% -templateFile %_FILE_NAME% -destinationFile \\%_TARGET_HOST%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_APPL_NAME%.xml -propertiesFile context.prop
if %ERRORLEVEL% NEQ 0 goto failure

goto end

:failure
exit 13
:end




