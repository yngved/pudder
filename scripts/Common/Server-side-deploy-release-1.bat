setlocal enabledelayedexpansion
:
: Job: Server-side-deploy-release
: Script: 1
: What: - Get code from Main branch
:	- Branch from Main to new release folder
:	- Check-out pom's on Main
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
tf workfold -map %PROJECT_NAME% . -workspace:Jenkins-%JOB_NAME%-MASTER -server:http://tfs.statoil.net:8080/tfs/DefaultCollection

set _label="Rel-%BUILD_ID%"

: Label the Main branch 
tf label %_label% %PROJECT_NAME%/Main /recursive /version:T 

: Get the latest code on Main branch
tf get /version:L%_label%


: Branch from the label
tf branch %PROJECT_NAME%/Main %PROJECT_NAME%/Release/%BRANCH_NAME% /version:L%_label%

tf checkin *.* /r /c:"Branched from label %_label%" /noprompt

: Remove the branch directory (BRANCH_NAME)
rd /S /Q %BRANCH_NAME%

: Checkout pom.xml files in Main
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
