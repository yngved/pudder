REM Evaluate build i.e. count *.err files in build dir
set /a count=0 
for /f "tokens=* delims= " %%a in ('dir/s/b/a-d "%WORKSPACE%\Centura\*.err"') do ( 
set /a count+=1 
) 

if %count% NEQ 0 (goto :errors) else (goto :noerrors)

:errors
echo .
echo List error(s)
REM dir/s/b/a-d %WORKSPACE%\source\*.err

REM Set date and time variables used
for /f "skip=1 tokens=2-4 delims=(-)" %%a in ('"echo.|date"') do (
    for /f "tokens=1-3 delims=/.- " %%A in ("%date:* =%") do (
        set %%a=%%A&set %%b=%%B&set %%c=%%C))        
set DATETOUSE=%yy%%mm%%dd%
cd E:\tfs\SPORT\build\%JOB_NAME%
mkdir "%DATETOUSE%.%BUILD_NUMBER%
xcopy %WORKSPACE%\Centura\*.err E:\tfs\SPORT\build\%JOB_NAME%\%DATETOUSE%.%BUILD_NUMBER%
echo .
echo Error file(s) can be found here: \\st-w281\tfs\SPORT\build\%JOB_NAME%\%DATETOUSE%.%BUILD_NUMBER%
echo .
exit 1
:noerrors
echo .
echo No error(s) found. Build success....
echo .
:eof