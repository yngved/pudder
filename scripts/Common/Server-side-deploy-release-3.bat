setlocal enabledelayedexpansion
:
: Job: Server-side-deploy-release
: Script: 3
: What: - Unmap working folder (prev mapped on Main)
:	- Get the code from the newly created branch
:	- Checkout pom's from release branch
:

: Unmap the old workingfolders
tf workfold /unmap /workspace:Jenkins-%JOB_NAME%-MASTER .
: Map working folder with the new branch
tf workfold -map %PROJECT_NAME%/Release/%BRANCH_NAME% . -workspace:Jenkins-%JOB_NAME%-MASTER -server:http://tfs.statoil.net:8080/tfs/DefaultCollection
: Get the latest version in the branch
tf get /recursive /version:T

: Checkout pom.xml files in the newly created branch 
SET _pname= 
if %ERRORLEVEL% NEQ 0 goto end
FOR /F "usebackq delims=" %%v IN (`dir /B /S pom.xml`) DO (
  if %ERRORLEVEL% NEQ 0 goto end
  SET _pname=!_pname! "%%v"
  if %ERRORLEVEL% NEQ 0 goto end
)

if %ERRORLEVEL% NEQ 0 goto end
set %_pname%
tf checkout %_pname%

if %ERRORLEVEL% EQU 0 goto end

:recover
tf undo %_pname%
exit 13

:end










