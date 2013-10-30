REM ##################################################################################
REM 
REM	@name:		generate-context-file-prod.bat
REM @created: 22.10.2013
REM @author: 	YND
REM
REM Script for generating app context file for each web application
REM
REM Jenkins parameter(s) used: 
REM 	- JOB_NAME 					= Used deploy the generated file
REM 	- ENCRYPT_PASSWORD 	= Password used to decrypt properties files
REM 
REM Input parameter(s):
REM 	- %1 = FILE_NAME
REM 	- %2 = APPLICATION
REM 	- %3 = PASSWORD_FILE_PREFIX (tomcat-configure-and-restart-production.bat will set this value to CONFIGURE
REM 	- %4 = TARGET_ENV
REM 	- %5 = TARGET_HOST_NODE_1
REM 	- %6 = TARGET_HOST_NODE_2
REM 
REM This script is used by:
REM 	- deploy-to-tomcat-balancer-production.bat
REM 	- tomcat-configure-and-restart-production.bat
REM
REM ##################################################################################

set _FILE_NAME=%1
set _APPLICATION=%2
set _TARGET_ENV=%3
set _PASSWORD_FILE_PREFIX=%4
set _TARGET_HOST_NODE_1=%5
set _TARGET_HOST_NODE_2=%6

REM substring of the file name to get the APPL_NAME.
REM All file name ends with '-context-template.xml' (21 chars)
set _APPL_NAME=%_FILE_NAME:~,-21%

echo "APPLICATION=%_APPLICATION%"
echo "TARGET_ENV=%_TARGET_ENV%"
echo "PASSWORD_FILE_PREFIX=%_PASSWORD_FILE_PREFIX%
echo "File_NAME=%_FILE_NAME%" 
echo "APPL_NAME=%_APPL_NAME%"
echo "TARGET_HOST_NODE_1=%_TARGET_HOST_NODE_1%
echo "TARGET_HOST_NODE_2=%_TARGET_HOST_NODE_2%

SET _INSTANCES_BASE=tomcat-%_APPLICATION%-instances

if "%_PASSWORD_FILE_PREFIX%"=="CONFIGURE" (
	goto setpasswordprefix
) else (
	goto generate
)

:setpasswordprefix
if "%_APPL_NAME%"=="eb-pfi-web"	(
	set _PASSWORD_FILE_PREFIX=pfi
) else if "%_APPL_NAME%"=="eb-sd-web"	(
	set _PASSWORD_FILE_PREFIX=pfi
) else if "%_APPL_NAME%"=="eb-smsg-web"	(
	set _PASSWORD_FILE_PREFIX=pfi
) else if "%_APPL_NAME%"=="escp-web"	(
	set _PASSWORD_FILE_PREFIX=escp
) else (
	set _PASSWORD_FILE_PREFIX=energyboss
)
echo 
echo.
echo "PASSWORD_FILE_PREFIX updated to %_PASSWORD_FILE_PREFIX% for appl %_APPL_NAME%"
echo. 

:generate

echo.
echo xcopy Production\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /y
xcopy Production\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /y
echo.
echo xcopy Production\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /y
xcopy Production\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context /y

echo "Create template file '%_APPL_NAME%-template-web.xml'"
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %_TARGET_ENV% -templateFile %_FILE_NAME% -destinationFile %_APPL_NAME%-template-web.xml -propertiesFile context.prop
if %ERRORLEVEL% NEQ 0 goto failure

echo "Decrypt password file 'context.prod.prop.aes' to context.prod.prop to '\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context'"
echo E:\tools\AESCrypt\aescrypt.exe -d -p %ENCRYPT_PASSWORD% \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes
call E:\tools\AESCrypt\aescrypt.exe -d -p %ENCRYPT_PASSWORD% \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes
if %ERRORLEVEL% NEQ 0 goto failure

echo "Decrypt password file 'context.prod.prop.aes' to context.prod.prop to '\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context'"
echo E:\tools\AESCrypt\aescrypt.exe -d -p %ENCRYPT_PASSWORD% \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes
call E:\tools\AESCrypt\aescrypt.exe -d -p %ENCRYPT_PASSWORD% \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes
if %ERRORLEVEL% NEQ 0 goto failure

echo "Create '%_APPL_NAME%.xml' file on '\\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context'"
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %_TARGET_ENV% -templateFile %_APPL_NAME%-template-web.xml -destinationFile \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_APPL_NAME%.xml -propertiesFile \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop
if %ERRORLEVEL% NEQ 0 goto failure

echo "Create '%_APPL_NAME%.xml' file on '\\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context'"
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %_TARGET_ENV% -templateFile %_APPL_NAME%-template-web.xml -destinationFile \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_APPL_NAME%.xml -propertiesFile \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop
if %ERRORLEVEL% NEQ 0 goto failure

echo "Remove prop and password files"
del \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes
del \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop.aes
del \\%_TARGET_HOST_NODE_1%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop
del \\%_TARGET_HOST_NODE_2%\%_INSTANCES_BASE%\%JOB_NAME%-app-context\%_PASSWORD_FILE_PREFIX%-context.prod.prop
echo "Remove prop and password files finished"
goto end

:failure
exit 13
:end




