@echo off
REM This script will upgrade of the following Jenkins services with the 
REM version of jenkins found in 'C:\dropshare\ci-jenkins'. The name of
REM the war file must be 'jenkins.war'
REM - jenkins-prod
REM - jenkins-prod-deploy
REM - jenkins-stage
REM - jenkins-cp-prod
REM - jenkins-cp-prod-deploy
REM 
REM The script will use 3 more scripts to perform the upgrade:
REM - upgrade-jenkins-service.bat
REM - safeServiceStart.bat
REM - safeServiceStop.bat
REM 

SET _WEBAPPS_DIR=webapps

SET _JENKINS_WAR_SOURCE_DIR=C:\dropshare\ci-jenkins
SET _JENKINS_BASE_DIR=C:\devtools\jenkins

SET _JENKINS_PROD_SERVICE=jenkins-prod
SET _JENKINS_PROD_DEPLOY_SERVICE=jenkins-prod-deploy
SET _JENKINS_STAGE_SERVICE=jenkins-stage
SET _JENKINS_CP_PROD_SERVICE=jenkins-cp
SET _JENKINS_CP_PROD_DEPLOY_SERVICE=jenkins-cp-prod-deploy

SET _JENKINS_PROD_DIR=%_JENKINS_BASE_DIR%\prod\%_WEBAPPS_DIR%
SET _JENKINS_PROD_DEPLOY_DIR=%_JENKINS_BASE_DIR%\prod-deploy\%_WEBAPPS_DIR%
SET _JENKINS_STAGE_DIR=%_JENKINS_BASE_DIR%\stage\%_WEBAPPS_DIR%
SET _JENKINS_CP_PROD_DIR=%_JENKINS_BASE_DIR%\cp\%_WEBAPPS_DIR%
SET _JENKINS_CP_PROD_DEPLOY_DIR=%_JENKINS_BASE_DIR%\cp-prod-deploy\%_WEBAPPS_DIR%

echo.
echo ------------------------------------------------------
echo - Start upgrading jenkins services on tr-w03					
echo ------------------------------------------------------
echo.

call upgrade-jenkins-service.bat %_JENKINS_STAGE_SERVICE% %_JENKINS_STAGE_DIR% %_JENKINS_WAR_SOURCE_DIR%
call upgrade-jenkins-service.bat %_JENKINS_PROD_DEPLOY_SERVICE% %_JENKINS_PROD_DEPLOY_DIR% %_JENKINS_WAR_SOURCE_DIR%
call upgrade-jenkins-service.bat %_JENKINS_PROD_SERVICE% %_JENKINS_PROD_DIR% %_JENKINS_WAR_SOURCE_DIR%
call upgrade-jenkins-service.bat %_JENKINS_CP_PROD_DEPLOY_SERVICE% %_JENKINS_CP_PROD_DEPLOY_DIR% %_JENKINS_WAR_SOURCE_DIR%
call upgrade-jenkins-service.bat %_JENKINS_CP_PROD_SERVICE% %_JENKINS_CP_PROD_DIR% %_JENKINS_WAR_SOURCE_DIR%

@echo off
echo.
echo ----------------------------------------------------------
echo - The following Jenkins services on tr-w03 are upgraded:	
echo - 	-%_JENKINS_PROD_SERVICE%
echo -	-%_JENKINS_PROD_DEPLOY_SERVICE%
echo -	-%_JENKINS_STAGE_SERVICE%
echo -	-%_JENKINS_CP_PROD_SERVICE%
echo - 	-%_JENKINS_CP_PROD_DEPLOY_SERVICE%
echo -
echo ----------------------------------------------------------
echo.

:end
@echo on