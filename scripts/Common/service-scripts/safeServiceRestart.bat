:: This script originally authored by Eric Falsken
:: http://stackoverflow.com/questions/1405372/stopping-starting-a-remote-windows-service-and-waiting-for-it-to-open-close

if [%1]==[] GOTO usage
if [%2]==[] GOTO usage

ping -n 1 %1 | FIND "TTL=" >NUL
IF errorlevel 1 GOTO SystemOffline
SC \\%1 query %2 | FIND "STATE" >NUL
IF errorlevel 1 GOTO SystemOffline

:ResolveInitialState
SC \\%1 query %2 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StopService
SC \\%1 query %2 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartService
SC \\%1 query %2 | FIND "STATE" | FIND "PAUSED" >NULL
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline
echo Service State is changing, waiting for service to resolve its state before making changes
sc \\%1 query %2 | Find "STATE"
ping 127.0.0.1 -n 2 -w 000 > nul
GOTO ResolveInitialState

:StopService
echo Stopping %2 on \\%1
sc \\%1 stop %2 %3 >NUL

GOTO StopingService
:StopingServiceDelay
echo Waiting for %2 to stop
ping 127.0.0.1 -n 10 -w 1000 > nul
:StopingService
SC \\%1 query %2 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 1 GOTO StopingServiceDelay

:StopedService
echo %2 on \\%1 is stopped
GOTO StartService

:StartService
echo Starting %2 on \\%1
sc \\%1 start %2 >NUL

GOTO StartingService
:StartingServiceDelay
echo Waiting for %2 to start
ping 127.0.0.1 -n 2 -w 200 > nul
:StartingService
SC \\%1 query %2 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 1 GOTO StartingServiceDelay

:StartedService
echo %2 on \\%1 is started
GOTO:eof

:SystemOffline
echo Server \\%1 or service %2 is not accessible or is offline
GOTO:eof

:usage
echo Will restart a remote service, waiting for the service to stop/start (if necessary)
echo.
echo %0 [system name] [service name] {reason}
echo Example: %0 server1 MyService
echo.
echo For reason codes, run "sc stop"
GOTO:eof