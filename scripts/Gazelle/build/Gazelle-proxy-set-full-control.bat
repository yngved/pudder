@echo off

REM Assign input parameters
set BRANCH=%1

REM Evaluate command line arguments
set INPUT_OK=true
if %BRANCH%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	goto END	
)

echo [INFO] 
echo [INFO] param1(%BRANCH%) 
echo [INFO] 

set BUILDDIR=""
if %BRANCH%==Main (			
	set BUILDDIR=c:\Appl\TFS\energyBOSS\Gazelle\Client\%BRANCH%
)
if not %BRANCH%==Main (		
	set BUILDDIR=c:\Appl\TFS\energyBOSS\Gazelle\Client\Release\%BRANCH%
)

cacls %BUILDDIR%\Deploy\Proxies\*.* /P statoil.net\f_EOControl:F < E:\tfs\Gazelle\scripts\yes.txt
