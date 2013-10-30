@echo off

REM *********************************************************************************************************************************
REM
REM Deploy artifacts to system test environment
REM 
REM Usage: CopyToEnvironment BRIO|RAF MAIN|DEV
REM 
REM Param 1=Project 
REM Param 2=Branch 
REM 
REM *********************************************************************************************************************************


echo .
REM -----------------------------------------------------------------------------------------------
REM Evaluate command line arguments
REM -----------------------------------------------------------------------------------------------
IF %1X==X goto EOF
IF %2X==X goto EOF

REM -----------------------------------------------------------------------------------------------
REM Get command line arguments
REM -----------------------------------------------------------------------------------------------
set TFS_PROJECT=%1
set TFS_BRANCH=%2

REM -----------------------------------------------------------------------------------------------
REM Set build directory. DO NOT CHANGE
REM 
REM -----------------------------------------------------------------------------------------------
set BUILD_DIR=E:\tfs\SPORT\appl\Build52\MAN
REM -----------------------------------------------------------------------------------------------
REM Set distribution folder, i.e.
REM 
REM \\statoil.net\dfs\common\appl\SPORT\<<EXE_FOLDER>>
REM 
REM Do a if a test on %TFS_BRANCH% if different environment
REM -----------------------------------------------------------------------------------------------
set DEPLOY_DIR=E:\tfs\SPORT\appl\Deploy\%TFS_PROJECT%\%TFS_BRANCH%

REM -----------------------------------------------------------------------------------------------
REM Set Source and Target for xcopy
REM -----------------------------------------------------------------------------------------------
set SRC=%BUILD_DIR%\%TFS_PROJECT%\%TFS_BRANCH%
set TAR=%DEPLOY_DIR%

echo Deploy excecutables from %SRC% to %TAR%

REM -----------------------------------------------------------------------------------------------
REM xcopy from source (cur dir) to target (distr)
REM -----------------------------------------------------------------------------------------------
cd %SRC%
echo Copying files from %SRC% to %TAR%
xcopy /D *.exe %TAR% /Y			

echo Finished deploying excecutables to %TAR%

:EOF