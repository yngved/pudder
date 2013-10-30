setlocal enabledelayedexpansion
:
: Job: Server-side-deploy-release
: Script: 2
: What: - Check-in pom's on Main to NEXT_MAIN_VERSION
:


if %ERRORLEVEL% NEQ 0 goto end

tf checkin *.* /recursive /comment:"Bump version to %NEXT_MAIN_VERSION%-SNAPSHOT /noprompt
if %ERRORLEVEL% EQU 0 goto end

:recover
REM tf undo %_pname%
REM exit 13
exit 0
:end
