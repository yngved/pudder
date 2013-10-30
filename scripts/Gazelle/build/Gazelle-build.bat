@echo off

REM ##################################################################################
REM 
REM	@name:		Gazelle-build.bat
REM @created: 16.10.2013
REM @author: 	YND
REM
REM Orchestrate the VB 6 build. The script will also create the log folder needed in the build.
REM 
REM USAGE: Gazelle-build BRANCH CHANGEFILE TFSBRANCHROOT
REM
REM Jenkins parameter(s) used: 
REM 	- 
REM 
REM Input parameter(s):
REM		- %1=BRANCH, branch to build
REM 	- %2=CHANGEFILE, file to write the changes to
REM 	- %3=TFSBRANCHROOT, Local root on build server
REM This scripts uses:
REM 	- vb6-build.py
REM 
REM ##################################################################################

REM Assign input parameters
set BRANCH=%1
set CHANGEFILE=%2
set TFSBRANCHROOT=%3

REM Evaluate command line arguments
set INPUT_OK=true
if %BRANCH%X==X set INPUT_OK=false
if %CHANGEFILE%X==X set INPUT_OK=false
if %TFSBRANCHROOT%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	goto END	
)

echo [INFO] 
echo [INFO] %JOB_NAME% started. 
echo [INFO] param1(%BRANCH%) 
echo [INFO] param2(%CHANGEFILE%) 
echo [INFO] param3(%TFSBRANCHROOT%)
echo [INFO] 

set BUILDDIR=""
echo .
c:
cd \
if %BRANCH%==Main (		
	cd Appl\TFS\energyBOSS\Gazelle\Client\%BRANCH%	
	set BUILDDIR=c:\Appl\TFS\energyBOSS\Gazelle\Client\%BRANCH%
)
if not %BRANCH%==Main (		
	cd Appl\TFS\energyBOSS\Gazelle\Client\Release\%BRANCH%
	set BUILDDIR=c:\Appl\TFS\energyBOSS\Gazelle\Client\Release\%BRANCH%	
)

REM Set base log directory
SET BASE_LOG_FILE_DIR=E:\tfs\Gazelle\build\log
REM Create log directory for the branch if not exist
if not exist %BASE_LOG_FILE_DIR%\%BRANCH%\nul (
	mkdir %BASE_LOG_FILE_DIR%\%BRANCH%
)

REM Delete old makeerr.txt if exist
if exist makeerr.txt del makeerr.txt

REM Set date and time variables used
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
	 for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
			 set %%a=%%A&set %%b=%%B&set %%c=%%C))        
set DATETOUSE=%yy%%mm%%dd%
REM Change to "e" drive
e:
cd %BASE_LOG_FILE_DIR%\%BRANCH%
mkdir %DATETOUSE%.%BUILD_NUMBER%
REM Change to "c" drive
c:
cd %BUILDDIR%

REM Copy the change file to the log directory
xcopy E:\tfs\Gazelle\build\%CHANGEFILE% %BASE_LOG_FILE_DIR%\%BRANCH%\%DATETOUSE%.%BUILD_NUMBER%

REM Call the build script with correct parameters
python E:\tfs\Gazelle\scripts\vb6-build.py %BRANCH% %CHANGEFILE% %TFSBRANCHROOT%

REM Evaluate the build 
if %ERRORLEVEL% == 1 (  
	xcopy makeerr.txt %BASE_LOG_FILE_DIR%\%BRANCH%\%DATETOUSE%.%BUILD_NUMBER%
	goto ERROR
)

xcopy makeerr.txt %BASE_LOG_FILE_DIR%\%BRANCH%\%DATETOUSE%.%BUILD_NUMBER%
if %ERRORLEVEL% NEQ 0 (
	echo [INFO]
	echo [INFO] No projects build
	echo [INFO]
	echo [INFO] No dependent projects of the checked in proxy
	echo [INFO]
	echo [INFO] But not a error !!
	echo [INFO]
	set ERRORLEVEL=0
	goto END
)

goto END

:ERROR
exit 1

:END
exit 0
