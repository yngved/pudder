REM 
REM Script: pm-deploy.bat
REM Jenkins job using script: PM-Shadowfolder-deploy-PROD
REM Requirements: User need read/write/delete privilegies for folder 
REM \\statoil.net\dfs\common\GAS\Portfolio_Management\Reporting\Qlikview\PROD
REM 
@echo off

REM Initialize parameters
set DEPLOY_DIR=\\statoil.net\dfs\common\GAS\Portfolio_Management\Reporting\Qlikview\PROD
set LOG_DIR=C:\appl\tfs\log\PM-Shadowfolder-deploy-PROD

REM Change directory
echo [INFO] Change to working directory %DEPLOY_DIR%
pushd %DEPLOY_DIR%

REM Delete old build directory
echo [INFO] Delete content of %DEPLOY_DIR%
REM This for loop display a 'The system cannot find the file specified.'message.
REM I really don't know what is wrong, because all the directories are 
REM Removed
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S *.*') DO RMDIR /S /Q "%%G"

REM Set date and time variables used
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
    for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
        set %%a=%%A&set %%b=%%B&set %%c=%%C))        
set DATETOUSE=%yy%%mm%%dd%

REM Create build directory
echo [INFO] Create directory %DEPLOY_DIR%\%DATETOUSE%.%BUILD_NUMBER%
mkdir %DATETOUSE%.%BUILD_NUMBER%
popd

REM Copy files to shadow folder
echo [INFO] Copy files to %DEPLOY_DIR%\%DATETOUSE%.%BUILD_NUMBER%
xcopy /S /D /C . "%DEPLOY_DIR%\%DATETOUSE%.%BUILD_NUMBER%" /y > %LOG_DIR%\%JOB_NAME%_%BUILD_NUMBER%.txt

@echo on