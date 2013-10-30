setlocal enabledelayedexpansion

@echo Running as [%USERNAME%]

@echo Clear temporary files...
del /f /q buildNumber*

if %ERRORLEVEL% NEQ 0 goto end

@echo Fetch file called buildNumber containing source build number...
%DEVVIEW%\bin\wget -nv %DEPLOY_BUILD%buildNumber

if %ERRORLEVEL% NEQ 0 goto end

@echo. 
@echo Create parameter for build number...
set /p _TARGET_BUILD= < buildNumber

if %ERRORLEVEL% NEQ 0 goto end

@echo Create parameter for source path...
set _SRCPATH=%SOURCE_DIR%%_TARGET_BUILD%
@echo Source path=[%_SRCPATH%]

@echo Create parameter for destination path...
set _DESTPATH_LOCAL=%TARGET_DIR_LOCAL%_TEMP
set _ORG_LOCAL_FOLDER=%TARGET_DIR_LOCAL%

@echo Destination forus path=[%_DESTPATH_LOCAL%]

@echo Create parameter for destination path...
set _DESTPATH_LOCAL_2=%TARGET_DIR_LOCAL_2%_TEMP
set _ORG_BAKU_FOLDER=%TARGET_DIR_LOCAL_2%

SET LOGTIME=%TIME: =0%
set hour=%LOGTIME:~0,2%
set min=%LOGTIME:~3,2%

set currentdate=%date%
set current=%date:~0,3%

REM Not a number format
set year=%currentdate:~10,4%
set tdate=%currentdate:~7,2%
set month=%currentdate:~4,2%

@echo Errorlevel=[%ERRORLEVEL%]

SET /A cur="%current%"*1
IF %cur% GTR 0 (
        @echo Set Date for Norwegian... 
	REM Date format '12.01.2012'
	set _NEW_LOCAL_NAME=%_ORG_LOCAL_FOLDER%_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%	
        set _NEW_BAKU_NAME=%_ORG_BAKU_FOLDER%_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%
)
IF %cur% EQU 0 (	
        @echo Set Date for English... 
	REM Date format 'Thu 01/12/2012'	
	set _NEW_LOCAL_NAME=%_ORG_LOCAL_FOLDER%_%year%%month%%tdate%_%hour%%min%
        set _NEW_BAKU_NAME=%_ORG_BAKU_FOLDER%_%year%%month%%tdate%_%hour%%min%
)

@echo Path name forus=[%_NEW_LOCAL_NAME%]
@echo Path name Mechelen=[%_NEW_BAKU_NAME%]

@echo Errorlevel=[%ERRORLEVEL%]


@echo Destination mechelen path=[%_DESTPATH_LOCAL_2%]

if %ERRORLEVEL% NEQ 0 goto end

if exist %_DESTPATH_LOCAL% (
        @echo Clearing destination files...
   for %%F in (%_DESTPATH_LOCAL%\*) do (
     del /F /Q "%%F"
   )

   if %ERRORLEVEL% NEQ 0 goto end

   @echo Remaining files...
   dir %_DESTPATH_LOCAL%

) else (
      mkdir %_DESTPATH_LOCAL%
 )

if exist %_DESTPATH_LOCAL_2% (  
        @echo Clearing destination files...
   for %%F in (%_DESTPATH_LOCAL_2%\*) do (
     del /F /Q "%%F"
   )

   if %ERRORLEVEL% NEQ 0 goto end

   @echo Remaining files...
   dir %_DESTPATH_LOCAL_2%
) else (
     mkdir %_DESTPATH_LOCAL_2%
)

if %ERRORLEVEL% NEQ 0 goto end

@echo Copying source to forus destination...
copy /Y %_SRCPATH%\*.* %_DESTPATH_LOCAL%

if %ERRORLEVEL% NEQ 0 goto end

@echo Copying source to forus destination...
copy /Y %_SRCPATH%\*.* %_DESTPATH_LOCAL_2%

if %ERRORLEVEL% NEQ 0 goto end

@echo Renaming Forus folders

move %_ORG_LOCAL_FOLDER% %_NEW_LOCAL_NAME%
move %_ORG_LOCAL_FOLDER%_TEMP %_ORG_LOCAL_FOLDER%

move %_ORG_BAKU_FOLDER% %_NEW_BAKU_NAME%
move %_ORG_BAKU_FOLDER%_TEMP %_ORG_BAKU_FOLDER%

if %ERRORLEVEL% NEQ 0 goto end


@echo Display build number in log for post-build action to find...
@echo.
@echo Build %_TARGET_BUILD% copied to %_DESTPATH_LOCAL%
@echo Build %_TARGET_BUILD% copied to %_DESTPATH_LOCAL_2%

type buildNumber

@ECHO ON
:end