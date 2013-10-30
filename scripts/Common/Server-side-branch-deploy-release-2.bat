setlocal enabledelayedexpansion
:
: Job: Server-side-deploy-release
: Script: 4
: What: - Check-in pom's after release build
: 	- Check-out poms for bumping version number to next snapshot version
:


if %ERRORLEVEL% NEQ 0 goto end

tf checkin *.* /recursive /comment:"Release version %RELEASE_VERSION%"

if %ERRORLEVEL% NEQ 0 goto recover


SET _pname= 
if %ERRORLEVEL% NEQ 0 goto end
FOR /F "usebackq delims=" %%v IN (`dir /B /S pom.xml`) DO (
  if %ERRORLEVEL% NEQ 0 goto end
  SET _pname=!_pname! "%%v"
  if %ERRORLEVEL% NEQ 0 goto end
)

if %ERRORLEVEL% NEQ 0 goto end
tf checkout %_pname%

if %ERRORLEVEL% EQU 0 goto end

:recover
tf undo %_pname%
exit 13

:end