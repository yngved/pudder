setlocal enabledelayedexpansion
REM
REM Job: Get-Propfiles
REM 
REM What: - Get Propfiles from $/Statoil.energyBOSS/Propfiles/resources or $/Statoil.Valeo/Propfiles/resources 
REM				- XCOPY the propfiles for the correct project into /system/src/main/resources
REM 
REM Parameter PROJECT_NAME must be set in the build Jenkins job
REM 						 

REM Validate PROJECT_NAME parameter
set INPUT_OK=true
if %PROJECT_NAME%X==X set INPUT_OK=false

if %INPUT_OK%==false (
	echo [INFO]
	echo [INFO] Input parameters missing
	echo [INFO]
	goto END	
)

REM Set tfs server url
set TFSSERVERURL=http://tfs.statoil.net:8080/tfs/DefaultCollection
REM Get properties files from $/Statoil.energyBOSS/Propfiles/resources
cd E:\tfs\ci-propfiles
REM Delete the Propfiles workspace 
tf workspace -delete Jenkins-Propfiles-MASTER;STATOIL-NET\f_NGCrControl -noprompt -server:%TFSSERVERURL%

REM Create the Propfiles workspace
tf workspace -new Jenkins-Propfiles-MASTER;STATOIL-NET\f_NGCrControl -noprompt -server:%TFSSERVERURL%

REM
REM energyBOSS projects
REM 
if /I %PROJECT_NAME%==$/Statoil.energyBOSS/EBOSS_PFI (  
  tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
  tf get /version:T /force /overwrite  
  cd resources
  xcopy eBOSS-PFI*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)
if %PROJECT_NAME%==$/Statoil.energyBOSS/PFI (  
  tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
  tf get /version:T /force /overwrite  
  cd resources
  xcopy pfi*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)
if %PROJECT_NAME%==$/Statoil.energyBOSS/SD (
	tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
  tf get /version:T /force /overwrite  
  cd resources
  xcopy sd*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)
if %PROJECT_NAME%==$/Statoil.energyBOSS/SMS_GATEWAY (
	tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
  tf get /version:T /force /overwrite  
  cd resources
  xcopy smsg*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)
if %PROJECT_NAME%==$/Statoil.energyBOSS/eBOSS (
	tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
  tf get /version:T /force /overwrite  
  cd resources
  xcopy eboss*.* %WORKSPACE%\system\src\main\resources /y
  goto end 
)

if %PROJECT_NAME%==$/Statoil.Valeo/SMF (
	tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
	tf get /version:T /force /overwrite  
	cd resources
	xcopy smf*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)

if %PROJECT_NAME%==$/Statoil.energyBOSS/UKGIEG (
	tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
	tf get /version:T /force /overwrite  
	cd resources
	xcopy ukgieg*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)

if %PROJECT_NAME%==$/Statoil.energyBOSS/SMS_GATEWAY (
	tf workfold -map $/Statoil.energyBOSS/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
	tf get /version:T /force /overwrite  
	cd resources
	xcopy smsg*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)

REM Valeo projects
if %PROJECT_NAME%==$/Statoil.Valeo/SHAREDSERVICES (
	tf workfold -map $/Statoil.Valeo/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
	tf get /version:T /force /overwrite  
	cd resources
	xcopy valeo.sharedservices*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)

if %PROJECT_NAME%==$/Statoil.Valeo/CE (
	tf workfold -map $/Statoil.Valeo/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
	tf get /version:T /force /overwrite  
	cd resources
	xcopy ce*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)
if %PROJECT_NAME%==$/Statoil.Valeo/IMM (
	tf workfold -map $/Statoil.Valeo/Propfiles E:\tfs\ci-propfiles -workspace:Jenkins-Propfiles-MASTER -server:%TFSSERVERURL%
	tf get /version:T /force /overwrite  
	cd resources
	xcopy imm*.* %WORKSPACE%\system\src\main\resources /y
  goto end
)

if %PROJECT_NAME%==$/Statoil.Valeo/VALEO (
  goto end
)

if %PROJECT_NAME%==$/Statoil.CustomerAtStatoil/cp (
  goto end
)

:end

