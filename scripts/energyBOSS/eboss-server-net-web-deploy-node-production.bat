REM ##################################################################################
REM 
REM	@name:		eboss-server-net-web-deploy-node-production.bat
REM @created: 24.10.2013
REM @author: 	YND
REM
REM Script for generating Web.config file for a site in production. The script
REM will decrypt the 'AES' password file ON target server. Do a replacement
REM and delete the decrypted password file.
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

echo "HOST_DIR=%HOST_DIR%"
echo "HOST_INT_PROJECT=%HOST_INT_PROJECT%
echo "TARGET=%TARGET%"

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
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %TARGET% -templateFile %HOST_DIR%\Web.template.config -destinationFile %HOST_DIR%\Web.template.config.%TARGET% -propertiesFile %HOST_DIR%\Web.prop
if %ERRORLEVEL% NEQ 0 goto failure

echo "Decrypt password file 'Web.prod.prop.aes' to Web.prod.prop"
E:\tools\AESCrypt\aescrypt.exe -d -p %ENCRYPT_PASSWORD% %HOST_DIR%\Web.prod.prop.aes
if %ERRORLEVEL% NEQ 0 goto failure

echo "Create 'Web.config' file on %HOST_DIR%"
powershell.exe %SCRIPT_HOME%\Common\replace-in-template-env.ps1 -env %TARGET% -templateFile %HOST_DIR%\Web.template.config.%TARGET% -destinationFile %HOST_DIR%\Web.config.%TARGET% -propertiesFile %HOST_DIR%\Web.prod.prop
if %ERRORLEVEL% NEQ 0 goto failure

echo "Delete Web.*.config files deployed on %HOST_DIR%"
del %HOST_DIR%\Web.config
echo "Rename %HOST_DIR%\Web.config.%TARGET% to Web.config
rename %HOST_DIR%\Web.config.%TARGET% Web.config
if %ERRORLEVEL% NEQ 0 goto failure
del %HOST_DIR%\Web.*.config
del %HOST_DIR%\Web.prop
del %HOST_DIR%\Web.*.prop
del %HOST_DIR%\Web.*.aes
del %HOST_DIR%\Web.*.prod

REM Create App_Data directory
if not exist %HOST_DIR%\App_Data\logs mkdir %HOST_DIR%\App_Data\logs

goto end

:failure
exit 13

:end