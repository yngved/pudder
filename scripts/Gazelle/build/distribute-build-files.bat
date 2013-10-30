@echo off

REM ***********************************************************************************
REM 
REM This script will distribute the jenkins build scripts to the jenkins build servers 
REM used for vb6. The user who distribute the scripts must have write permission to the 
REM following folders:	\\st-w281\tfs\Gazelle\scripts
REM 										\\st-w289\tfs\Gazelle\scripts
REM											\\tr-w05\tfs\Gazelle\scripts
REM 
REM 
REM ***********************************************************************************

REM First copy the python scripts
echo [INFO] Install python build scripts to '\\st-w281\tfs\Gazelle\scripts'
xcopy *.py \\st-w281\tfs\Gazelle\scripts /y
echo [INFO] Install python scripts to '\\st-w289\tfs\Gazelle\scripts'
xcopy *.py \\st-w289\tfs\Gazelle\scripts /y
echo [INFO] Install python scripts to '\\tr-w05\tfs\Gazelle\scripts'
xcopy *.py \\tr-w05\tfs\Gazelle\scripts /y

echo [INFO] Install bat build scripts to '\\st-w281\tfs\Gazelle\scripts'
xcopy Gazelle*.bat \\st-w281\tfs\Gazelle\scripts /y
echo [INFO] Install bat build scripts to '\\st-w289\tfs\Gazelle\scripts'
xcopy Gazelle*.bat \\st-w289\tfs\Gazelle\scripts /y
echo [INFO] Install bat build scripts to '\\tr-w05\tfs\Gazelle\scripts'
xcopy Gazelle*.bat \\tr-w05\tfs\Gazelle\scripts /y

echo [INFO] Install txt files to '\\st-w281\tfs\Gazelle\scripts'
xcopy yes.txt \\st-w281\tfs\Gazelle\scripts /y
echo [INFO] Install txt files to '\\st-w289\tfs\Gazelle\scripts'
xcopy yes.txt \\st-w289\tfs\Gazelle\scripts /y
echo [INFO] Install txt files to '\\tr-w05\tfs\Gazelle\scripts'
xcopy yes.txt \\tr-w05\tfs\Gazelle\scripts /y