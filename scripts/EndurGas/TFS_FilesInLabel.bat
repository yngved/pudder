@echo off
SETLOCAL ENABLEDELAYEDEXPANSION 

REM Get the input parameter
set "label=%~1" 

SET LOGTIME=%TIME: =0%
set hour=%LOGTIME:~0,2%
set min=%LOGTIME:~3,2%

set currentdate=%date%
set current=%date:~0,3%

REM Not a number format
set year=%currentdate:~10,4%
set tdate=%currentdate:~7,2%
set month=%currentdate:~4,2%

set filename=
SET /A cur="%current%"*1
IF %cur% GTR 0 (
	REM Date format '12.01.2012'
	set filename=%label%_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt	
)
IF %cur% EQU 0 (	
	REM Date format 'Thu 01/12/2012'	
	set filename=%label%_%year%%month%%tdate%_%hour%%min%.txt
)

set SHADOW_FOLDER="\\statoil.net\dfs\common\I\IT-BAS\ENDUR\TFS\Shadow"

set cmd=labels /owner:ynd /format:detailed %label% > %filename%
echo %cmd%
tf labels /owner:ynd /format:detailed %label% > %filename%
xcopy %filename% %SHADOW_FOLDER%\content_of_labels\%label% /Y
:end