#! /usr/bin/env python
from datetime import datetime
from datetime import date
from time import strftime, localtime
from build import *
from systemfunctions import fPrint, run_system_command
import os
import fileinput
import glob
import shutil
import sys

# Set build file
buildfile = "Make_All_Jenkins.txt"
 
# Name: Main                                                                
# Description:
# Input: [0] Branch
#				 [1] tfs branch root
#				 [2] deploy [true/false]
# Return: [0] success
#         [1] build failed
def main():
  builddir=""  
  # Parse input parameters 
  tfsbranch = sys.argv[1]  
  tfsbranchroot= sys.argv[2]
  deploy= sys.argv[3] 
  
  # Get build directory
  builddir = os.getcwd()
  fPrint("[INFO] Build Directory(" + builddir + ")")
  
  # Test TFS get. Get latest code from History  
  os.chdir(tfslocalpathroot)  
  currentdir = os.getcwd()    
  fPrint("[INFO] Directory(" + currentdir + ") used for tfs extract")
  
  # Get latest version of Deploy directory for branch
  fPrint("[INFO] Extract " + tfsbranchroot + "/Deploy from tfs")
  cmd = "tf get " + tfsbranchroot + "/Deploy /recursive"  
  run_system_command(cmd)
  
  # Before we start the build we need to set the correct Build directory
  os.chdir(builddir)
  
  fPrint("[INFO]")
  buildNumber = os.environ.get("BUILD_NUMBER")  
  fPrint("[INFO] Build(" + buildNumber + ")...Start building from branch " + tfsbranch + " Deploy(" + deploy + ")...")
  
  f = open(buildfile)
  while 1:
    line = f.readline()
    if not line:
      break            
    pass    
    if line.find(".") == -1:
      fPrint("[INFO] Skip line...")            
    else:      
      # Remove '\n' if found    
      lindex = line.rfind("\n")
      if lindex > 0:
        filename = line[0:lindex]
      else:
        filename = line      
      
      if os.path.exists(filename):      	     
        # Extract values from project file
        val = scan_project_file(filename)      
        name = val['name']
        exename = val['exename']
        path = val['path']
  
        fPrint("[INFO] Start working with project " + name + " output(" + exename + ") path(" + path + ")...")
  
        # compile the project
        do_compile(filename, exename, path, tfsbranch, deploy)
      else:
        fPrint("[INFO] File " + filename + " does not exists. Skip compiling and continue.")
           
  # Update compile log
  logfolder=tfsbranch + "-rebuild-all"
  if deploy=="false":
  	logfolder = logfolder + "-nightly"
  log(tfsbranch, logfolder, buildNumber) 
  
  # Write summary to screen
  write_summary(buildNumber)
  
  # Exit with error if one or more project failed to build
  if len(projectsBuildFailed) > 0:    
    sys.exit(1)
    
    
main()    