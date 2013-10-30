@echo off
SETLOCAL ENABLEDELAYEDEXPANSION 

REM Get the input parameter
set "label=%~1" 

REM clean the workspace directory
if EXIST AVS\nul (	
	echo Remove directory AVS and it's contents
	rd /S /Q AVS
)

set SHADOW_FOLDER=\\statoil.net\dfs\common\I\IT-BAS\ENDUR\TFS\Shadow

echo clean
echo %USERNAME%
REM Clean the shadow directory
dir %SHADOW_FOLDER%\files_in_lables\%label%\
echo Y | del %SHADOW_FOLDER%\files_in_lables\%label%\*.*
echo finished clean


echo Copy files from label %label%

REM FastTrack Branch
if %label%==PRODUCTION goto FastTrack
if %label%==FT_UAT goto FastTrack
if %label%==FT_ST goto FastTrack
if %label%==FT_READY_FOR_PRODUCTION goto FastTrack

REM Release6 Branch
if %label%==REL_UAT_6 goto RELEASE6
if %label%==REL_ST_6 goto RELEASE6
if %label%==REL_READY_FOR_PRODUCTION_6 goto RELEASE6


:FastTrack
tf get /version:L%label% /all /overwrite /force /noprompt

if exist AVS\FastTrack\scripts\*.* (
	xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%\files_in_lables\%label% /Y
)
goto end

:Release_6
tf get /version:L%label% /all /overwrite /noprompt

if exist AVS\Release6\scripts\*.* (
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%\files_in_lables\%label% /Y
)
goto end

:end
echo Finished copying label %label%
