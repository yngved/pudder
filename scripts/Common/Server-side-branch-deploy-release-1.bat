setlocal enabledelayedexpansion
:
: Job: Server-side-deploy-release
: Script: 1
: What: - Get code from branch
:	- Check-out pom's on branch
:

: List tfs workspaces for user
tf workspaces
: Delete the BUILD workspace 
tf workspace -delete Jenkins-%JOB_NAME%-MASTER;STATOIL-NET\f_NGCrControl -noprompt -server:http://tfs.statoil.net:8080/tfs/DefaultCollection
: Create the Build workspace
tf workspace -new Jenkins-%JOB_NAME%-MASTER;STATOIL-NET\f_NGCrControl -noprompt -server:http://tfs.statoil.net:8080/tfs/DefaultCollection

REM Reomove everything in the workspace
rd /S /Q .


: Map working folder
tf workfold -map %PROJECT_NAME%/Release/%BRANCH_NAME% . -workspace:Jenkins-%JOB_NAME%-MASTER -server:http://tfs.statoil.net:8080/tfs/DefaultCollection

set _label="Rel-%BUILD_ID%"

: Label the Main branch 
tf label %_label% %PROJECT_NAME%/Release/%BRANCH_NAME% /recursive /version:T 

: Get the latest code on branch
tf get /version:L%_label%

: Checkout pom.xml files in Branch
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
