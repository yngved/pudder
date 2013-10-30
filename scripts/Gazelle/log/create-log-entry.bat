@echo off
REM Set base log directory
SET BASE_LOG_FILE_DIR=C:\appl\tfs\log
REM Create log directory for the branch if not exist
if not exist %BASE_LOG_FILE_DIR%\%JOB_NAME%\nul (
	mkdir %BASE_LOG_FILE_DIR%\%JOB_NAME%
)

REM Set date and time variables used
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
	 for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
			 set %%a=%%A&set %%b=%%B&set %%c=%%C))        
set DATETOUSE=%yy%%mm%%dd%
REM Change to "e" drive
cd %BASE_LOG_FILE_DIR%\%JOB_NAME%
mkdir %DATETOUSE%.%BUILD_NUMBER%

REM Copy the change file to the log directory
xcopy c:\appl\tfs\LastFileCopyToDir\%JOB_NAME%.txt %BASE_LOG_FILE_DIR%\%JOB_NAME%\%DATETOUSE%.%BUILD_NUMBER%

