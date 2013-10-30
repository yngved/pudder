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

#####################################################################################################
# @name: vb6-build.py
# @created: 24.10.2013
# @author: 	YND
#
# Orchestrate a vb6 build 
# 
# - Get build directory  
# - Test TFS get. Get latest code from History  
# -	Get latest version of Deploy directory for branch  
# -	Set correct Build directory
# -	Find all project files      
# -	if Proxy -> add proxy file
# -	else -> find vbp    
# 		-	if no project file is found, check if this is the include directory.
#			-	if this is the include directory, we will continue to find 
#			-	dependent project, but not add it to the projectlist
#			-	Extract values from project file    
#			-	compile the project
# -	Check dependencies for Proxy
# -	Compile dependent projects of Proxy#
#
# example usage: .\vb6-build.py %BRANCH% %CHANGEFILE% %TFSBRANCHROOT%
#
# Input parameters:
#		- BRANCH, branch to build
#		- CHANGEFILE, file to write the changes to
#		- TFSBRANCHROOT, Local root on build server
#
#######################################################################################################

 
# Name: Main                                                                
# Description:
# Input:
# Return: [0] success
#         [1] build failed
def main():  
  # Parse input parameters 
  tfsbranch = sys.argv[1]
  buildchangefile = sys.argv[2]
  tfsbranchroot= sys.argv[3]  
  deploy="true"
  
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
  fPrint("[INFO] Build(" + buildNumber + ")...Start building from branch " + tfsbranch + "...")  
  projectlist = []
  proxylist = []
  
  # Find all project files      
  list = []
  curdir = os.getcwd()    
  scandirs(curdir, vbptype, list)
  
  # Initialize dependent list  
  dependentlist = []  
  
  f = open(buildchangefolder + "\\" + buildchangefile)
  while 1:
    line = f.readline()
    if not line:
      break            
    pass    
    if line.find(".") == -1:
      fPrint("[INFO] Skip line...")            
    else:
      # extract values from line
      val = decompose_line(line)
      filename = val['filename']
      dir = val['dir']
      folder = val['folder']
      fPrint("[INFO] Filname(" + filename + ") Directory(" + dir + ") Folder(" + folder + ")")
      
      if dir == "Proxies":        
        proxylist.append(filename)
        fPrint("[INFO] Added proxy file " + filename + "..."  )
      else:
        # find vbp    
        curdir = os.getcwd()
        projectfile = find_file_of_type(vbptype, curdir + folder)      
        
        # if no project file is found, check if this is the include directory.
        # if this is the include directory, we will continue to find 
        # dependent project, bit not add it to the projectlist
        if projectfile == "":
          if dir != "Include":          
            continue           
        
        # Check for compile dependencies
        fPrint("[INFO] Check dependencies for \\" + dir + "\\" + filename)
        check_for_compile_dependencies(list, dir, filename, dependentlist, projectlist)
        
        if projectfile == "":
          continue
        
        if find(projectfile, projectlist) == False:          
          fPrint("[INFO] Added project file " + projectfile + " for file " + line + "...")
          projectlist.append(projectfile)
        else:
          fPrint("[INFO] Skipped project file " + projectfile + " for file " + line + "...")  
   
  # Format output: projectlist
  if len(projectlist) > 0:    
    fPrint("[INFO] Compile project list...")
   
  if len(dependentlist) > 0:    
    fPrint("[INFO] Dump dependent list...")
   
  for item in dependentlist:
    fPrint(item)    
        
  for project in projectlist:
    # Extract values from project file    
    val = scan_project_file(project)      
    name = val['name']
    exename = val['exename']
    path = val['path']
  
    fPrint("[INFO] Start working with project " + name + " output(" + exename + ") path(" + path + ")...")
    
    # compile the project
    do_compile(project, exename, path, tfsbranch, deploy)    
    
    # We do not check for dependencies for other project than Proxies
    
    fPrint("[INFO] Finished building project " + name + "...")      

  #  Format output: proxylist
  if len(proxylist) > 0:    
    fPrint("[INFO] Loop through proxies list...")          
  
  for proxy in proxylist:
    fPrint("[INFO] Checking dependency for " + proxy + "...")    
    check_for_dependencies(list, proxy, dependentlist, projectlist)
    
    builddir = os.getcwd()
    fPrint("[INFO] REGSVR32 " + builddir +"\\Deploy\\Proxies\\" + proxy + "...")    
    # Register the proxy in registry
    os.chdir(builddir + "\\Deploy\\Proxies")  
    cmd = "regsvr32 " + proxy + " /s"
    run_system_command(cmd)
    os.chdir(builddir)
      
  
  #  Format output: dependentlist
  if len(dependentlist) > 0:          
    fPrint("[INFO] Compile dependent list...")    
    
  for item in dependentlist:          
    lindex = item.rfind("\\")      
    folder = item[:lindex]
    projectfile = find_file_of_type(vbptype, folder)          
    
    val = scan_project_file(projectfile)      
    name = val['name']
    exename = val['exename']
    path = val['path']    
    
    fPrint("[INFO] Start working with project " + name + " output(" + exename + ") path(" + path + ")...")
    # compile
    do_compile(projectfile, exename, path, tfsbranch, deploy)    
    
  fPrint("[INFO] Finished building projects...")    
  
  # Update compile log
  log(tfsbranch, tfsbranch, buildNumber)
  
  # Write summary to screen
  write_summary(buildNumber) 
  
  if len(projectsBuildFailed) > 0: 
    sys.exit(1)
    
main()    


    
    

  
  
  
      


