REM ##################################################################################
REM 
REM	@name:		eboss-server-net-web-deploy-node.bat
REM @created: 24.10.2013
REM @author: 	YND
REM
REM Script for generating Web.config for a site for a target environment. The generated
REM Web.config file will be deployed to target server.
REM
REM Jenkins parameter(s) used: 
REM 	- 
REM 
REM Input parameter(s):
REM 	- %1 = HOST_DIR 	Networkpath to the target directory on target server
REM 	- %2 = HOST_INT_PROJECT (contract, invoicing, process, sitehandling)
REM 	- %3 = TARGET Target environment (PROD, BAKPROD)
REM 
REM This scripts uses:
REM 	- 
REM This script is used by:
REM 
REM 	- 
REM 
REM ##################################################################################

set HOST_DIR=%1
set HOST_INT_PROJECT=%2
set TARGET=%3

REM Evaluate command line arguments
set INPUT_OK=true
if %HOST_DIR%X==X set INPUT_OK=false
if %HOST_INT_PROJECT%X==X set INPUT_OK=false
if %TARGET%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	exit 13	
)

for %%F in (%HOST_DIR%\*) do (
  del /F /Q "%%F"
)

if %ERRORLEVEL% NEQ 0 goto failure

for /D %%D in (%HOST_DIR%\*) do (
  if /i "%%~nD" NEQ "aspnet_client" (
    if /i "%%~nD" NEQ "App_data" (
      rmdir /S /Q "%%D"
    )
  )
)

if %ERRORLEVEL% NEQ 0 goto failure

dir target /b
unzip -o target/eboss-%HOST_INT_PROJECT%-*.zip -d %HOST_DIR%

if %ERRORLEVEL% NEQ 0 goto failure

echo "Create template file 'Web.template.config.%TARGET%'"
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %TARGET% -templateFile %HOST_DIR%\Web.template.config -destinationFile %HOST_DIR%\Web.config.%TARGET% -propertiesFile %HOST_DIR%\Web.prop
if %ERRORLEVEL% NEQ 0 goto failure

echo "Delete Web.*.config files deployed on %HOST_DIR%"
del %HOST_DIR%\Web.config
rename %HOST_DIR%\Web.config.%TARGET% Web.config
del %HOST_DIR%\Web.*.config
del %HOST_DIR%\Web.prop
del %HOST_DIR%\Web.*.aes

REM Create App_Data directory
if not exist %HOST_DIR%\App_Data\logs mkdir %HOST_DIR%\App_Data\logs

goto end

:failure
exit 13

:end