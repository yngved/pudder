REM ##################################################################################
REM 
REM	@name:		find-and-delete-stfo-context-files.bat
REM @created: 22.10.2013
REM @author: 	YND
REM
REM Script to remove app-context for stfo applications
REM
REM Jenkins parameter(s) used: 
REM 
REM Input parameter(s):
REM 	- %1 = FILE_NAME (full path)
REM 
REM This script is used by:
REM 	- tomcat-configure-and-restart.bat
REM 	- tomcat-configure-and-restart-production.bat
REM
REM ##################################################################################
set _FILE_NAME=%1
echo "FILE_NAME=%_FILE_NAME%

set _DELETE=true
if not x%_FILE_NAME:agsc=%==x%_FILE_NAME% (
	set _DELETE=false	
)

if not x%_FILE_NAME:scpc=%==x%_FILE_NAME% (
	set _DELETE=false	
)

if "%_DELETE%"=="true" (
	echo "Delete %_FOLDER%\%_FILE_NAME%"
	del %_FILE_NAME%
)


