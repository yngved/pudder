@echo off
SETLOCAL ENABLEDELAYEDEXPANSION 

REM Get the input parameter
set "label=%~1" 

set SHADOW_FOLDER="\\statoil.net\dfs\common\I\IT-BAS\ENDUR\TFS\Shadow"

REM FastTrack Branch
if %label%==PRODUCTION goto PRODUCTION
if %label%==FT_READY_FOR_PRODUCTION goto FT_READY_FOR_PRODUCTION
if %label%==FT_UAT goto FT_UAT
if %label%==FT_ST goto FT_ST


REM Release6 Branch
if %label%==REL_READY_FOR_PRODUCTION_6 goto REL_READY_FOR_PRODUCTION_6
if %label%==REL_UAT_6 goto REL_UAT_6
if %label%==REL_ST_6 goto REL_ST_6



REM Fill Production environment
:PRODUCTION
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

REM Fill FT_READY_FOR_PRODUCTION environment
:FT_READY_FOR_PRODUCTION

tf get /version:LPRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

REM Fill FT_UAT environment
:FT_UAT
tf get /version:LPRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:LFT_READY_FOR_PRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

REM Fill FT_ST environment
:FT_ST
tf get /version:LPRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:LFT_READY_FOR_PRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:LFT_UAT /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"complete_codebase_by_environment\%label%" /Y
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

REM Fill REL_READY_FOR_PRODUCTION_6 environment
:REL_READY_FOR_PRODUCTION_6
tf get /version:LPRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

REM Fill REL_UAT_6 environment
:REL_UAT_6
tf get /version:LPRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:LREL_READY_FOR_PRODUCTION_6 /all /force /overwrite /noprompt
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

REM Fill REL_ST_6 environment
:REL_ST_6
tf get /version:LPRODUCTION /all /force /overwrite /noprompt
xcopy AVS\FastTrack\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:LREL_READY_FOR_PRODUCTION_6 /all /force /overwrite /noprompt
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:LREL_UAT_6 /all /force /overwrite /noprompt
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y
tf get /version:L%label% /all /force /overwrite /noprompt
xcopy AVS\Release6\scripts\*.* %SHADOW_FOLDER%"\complete_codebase_by_environment\%label%" /Y

goto end

:end
echo %label% is copied to "\\statoil.net\dfs\common\I\IT-EH-TR\PoM\TFS\Shadow\complete_codebase_by_environment\%label%"

