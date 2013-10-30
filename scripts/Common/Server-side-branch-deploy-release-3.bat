setlocal enabledelayedexpansion
:
: Job: Server-side-deploy-release
: Script: 5
: What: - Check-in pom's after bumping the release branch with SNAPSHOT version 
:

if %ERRORLEVEL% NEQ 0 goto end

tf checkin /recursive /comment:"Bump version to %NEXT_RELEASE_VERSION%-SNAPSHOT"
:end