@echo off

REM **********************************************************************************************************************************
REM 
REM Orchestrate the VB 6 build. 
REM 
REM The script will also create the log folder needed in the build.
REM If DEPLOY=false, means this is a nightly build, so we do not update tfs and will not deploy
REM to target folder used by SwitchEnv.
REM 
REM USAGE: Gazelle-rebuild-all BRANCH TFSBRANCHROOT DEPLOY
REM
REM *********************************************************************************************************************************

REM Assign input parameters
set BRANCH=%1
set TFSBRANCHROOT=%2
set DEPLOY=%3

REM Evaluate command line arguments
set INPUT_OK=true
if %BRANCH%X==X set INPUT_OK=false
if %TFSBRANCHROOT%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	goto END	
)

REM If no input parameter this is a true rebuild
if %DEPLOY%X==X set DEPLOY=true

echo [INFO] 
echo [INFO] %JOB_NAME% started. 
echo [INFO] param1(%BRANCH%) 
echo [INFO] param2(%TFSBRANCHROOT%) 
echo [INFO] param3(%DEPLOY%)
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

REM Delete old makeerr.txt if exist
if exist makeerr.txt del makeerr.txt

REM Set base log directory
SET BASE_LOG_FILE_DIR=E:\tfs\Gazelle\build\log
Set LOG_DIRECTORY=%BASE_LOG_FILE_DIR%\%BRANCH%

if %DEPLOY%==true (
	Set LOG_DIRECTORY=%LOG_DIRECTORY%-rebuild-all
)
if %DEPLOY%==false (
	Set LOG_DIRECTORY=%LOG_DIRECTORY%-rebuild-all-nightly
)

REM Create log directory for the branch if not exist
REM First time build of a new branch this will be called
if not exist %LOG_DIRECTORY%\nul (
	mkdir %LOG_DIRECTORY%
)

REM Set date and time variables used
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
	 for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
			 set %%a=%%A&set %%b=%%B&set %%c=%%C))        
set DATETOUSE=%yy%%mm%%dd%
REM Change to "e" drive
e:
REM cd into log directory and create build directory
cd %LOG_DIRECTORY%
mkdir %DATETOUSE%.%BUILD_NUMBER%

REM Change to "c" drive
c:
cd %BUILDDIR%

REM Call the build script with correct parameters
python E:\tfs\Gazelle\scripts\vb6-rebuild-all.py %BRANCH% %TFSBRANCHROOT% %DEPLOY%

REM Evaluate the build 
if %ERRORLEVEL% == 1 (  
	xcopy makeerr.txt %LOG_DIRECTORY%\%DATETOUSE%.%BUILD_NUMBER%
	goto ERROR
)

xcopy makeerr.txt %LOG_DIRECTORY%\%DATETOUSE%.%BUILD_NUMBER%

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
REM exit 0
