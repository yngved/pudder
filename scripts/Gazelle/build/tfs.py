#! /usr/bin/env python
from datetime import datetime
from datetime import date
from time import strftime, localtime
from systemfunctions import fPrint, run_system_command
import os
import fileinput
import glob
import shutil
import sys

#####################################################################################################
# @name: tfs.py
# @created: 24.10.2013
# @author: 	YND
#
# tfs function used by vb6-build.py
#
#######################################################################################################

# Variables for "history" in tfs
tfslocalpathroot="c:\\appl\\tfs\\Statoil.energyBOSS\\Gazelle\\History"

# Name: tfs_checkout
# Description: Method for checkout a file in Team Foundation Server
# Input: [file] = file to check out with full path
# Return: [none]
def tfs_checkout(file):
  cmd = "tf checkout " + file
  run_system_command(cmd)

# Name: tfs_checkin
# Description: Method for checkin a file in Team Foundation Server
# Input: [file] = file to check in with full path
# Return: [none]
def tfs_checkin(file):
  buildNumber = os.environ.get("BUILD_NUMBER")
  cmd = "tf checkin " + file + " /comment:JENKINS_BuildNr("+buildNumber +")"
  run_system_command(cmd)
  
def tfs_add_file(file):
  cmd = "tf add " + file + " /noprompt"
  run_system_command(cmd) 

# Name: tfs_update
# Description: Method for orchestrating an update of Team Foundation Server
# Input: [src] = the file to copy
#        [exedir] = the directory in 'Deploy' directory
#        [exename] = the name of the dll/exe to update
# Return: [none]
def tfs_update(tfsbranch, src, exedir, exename):    
  if (tfsbranch=="Main"):
    file = tfslocalpathroot + "\\" + tfsbranch + "\\Deploy\\" + exedir + "\\" + exename
    dst = tfslocalpathroot + "\\" + tfsbranch + "\\Deploy\\" + exedir
  else:
    file = tfslocalpathroot + "\\Release\\" + tfsbranch + "\\Deploy\\" + exedir + "\\" + exename
    dst = tfslocalpathroot + "\\Release\\" + tfsbranch + "\\Deploy\\" + exedir
  
  if (os.path.exists(file)):    
    fPrint("[INFO] checkout(" + file + ")...")
    tfs_checkout(file)
    fPrint("[INFO] Copy " + src + " to " + dst + "...")
    shutil.copy(src, dst)
  else:
    fPrint("[INFO] Copy " + src + " to " + dst + "...")
    shutil.copy(src, dst)
    fPrint("INFO] tfs add(" + file + ")...")
    tfs_add_file(file)  
  
  fPrint("[INFO] checkin(" + file + ")...")
  tfs_checkin(file)    

