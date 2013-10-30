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
set _DESTPATH=%TARGET_DIR%
@echo Destination path=[%_DESTPATH%]

if %ERRORLEVEL% NEQ 0 goto end

@echo Clearing destination files...
for %%F in (%_DESTPATH%\*) do (
  del /F /Q "%%F"
)

if %ERRORLEVEL% NEQ 0 goto end

@echo Remaining files...
dir %_DESTPATH%

@echo Copying source to destination...
copy /Y %_SRCPATH%\*.* %_DESTPATH%

if %ERRORLEVEL% NEQ 0 goto end

if %ERRORLEVEL% NEQ 0 goto end

@echo Display build number in log for post-build action to find...
@echo.
@echo Build %_TARGET_BUILD% copied to %_DESTPATH%

type buildNumber

@ECHO ON
:end