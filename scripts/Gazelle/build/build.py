#! /usr/bin/env python
from datetime import datetime
from datetime import date
from time import strftime, localtime
from tfs import *
from systemfunctions import fPrint, run_system_command
import os
import fileinput
import glob
import shutil
import sys

# Global paths and exe files on build server
buildchangefolder = "E:\\tfs\\Gazelle\\build"
vb6exe='"C:\\Program Files\\Microsoft Visual Studio\\VB98\\VB6.EXE"'
tfexe='"C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe"'
logfilefolder="E:\\tfs\\Gazelle\\build\log"

# Variables for distribution
dropfolder="\\\\tr-w03\\m2_repo\\mainline\\snapshot\\Gazelle"
# Variables for "history" in tfs
tfslocalpathroot="c:\\appl\\tfs\\Statoil.energyBOSS\\Gazelle\\History"                  

# Type variables
vbptype="*.vbp"
frmtype="*.frm"

# Initialize build list variables
projectsBuildFailed = []
projectsBuildSuccess = []  

# Name: find_file_of_type
# Description: Find firs file of type in folder
# Input: [type] = type of the file to search for
#        [folder] = absolute path of folder to search in
# Return: [none]
def find_file_of_type(type, folder):        
  a = ""
  for infile in glob.glob(os.path.join(folder, type)):
    a = infile        
  return a   

# Name: scandirs
# Description: Method for scanning directories recursively and
# and add files of file type to list
# Input: [path] = path to start from
#        [type] = type of files to scan for
#        [list] = return list
# Return: [none]
def scandirs(path, type, list):        
  for currentFile in glob.glob( os.path.join(path, '*') ):
    if os.path.isdir(currentFile):            
      file = find_file_of_type(type, currentFile)            
      if file != "":
        list.append(file)                
      scandirs(currentFile, type, list)    

# Name: scan_project_file
# Description: Method for scanning a vbp project file 
# and extract return these values
# Input: [projectfile] = full path of projectfile to scab 
# Return: ['name']
#         ['exename']
#         ['path']
def scan_project_file(projectfile):
  file = open(projectfile)
  while 1:
    line = file.readline()
    if not line:
      break

    if line.startswith("ExeName32"):
      split = line.split("=")
      exename = split[len(split)-1]      
    if line.startswith("Path32"):
      split = line.split("=")
      path= split[len(split)-1]
    if line.startswith("Name"):
      split = line.split("=")
      name = split[len(split)-1]
      
  name = name.strip('"')            
  name = name.strip('"\n')            
  
  if path == "":
    fPrint("[ERROR] Path32 in project file " + projectfile +  "is empty")

  path = path.strip('"')
  path = path.strip('"\n')
  
  exename = exename.strip('"')
  exename = exename.strip('"\n')
  
  return {'name':name, 'path':path, 'exename':exename} 

# Name: decompose_line
# Description: Method for decomposing a line 
# and extract return these values
# Input: [projectfile] = full path of projectfile to scab 
# Return: ['dir']
#         ['filename']
#         ['folder']
def decompose_line(line):
  split = line.split("\\")
  dir = split[len(split) -2]
  filename = split[len(split)-1]
  # first index of
  findex = line.find("\\")
  # last index of 
  lindex = line.rfind("\\")      
  folder = line[findex:lindex]
  
  lindex = filename.rfind("\n")
  if lindex > 0:
    filename = filename[0:lindex]  
  
  # return values
  return {'dir':dir, 'filename':filename, 'folder':folder} 

# Name: build_success
# Description: Method for examing if the build was a success
# Input: [exename] = name of the exe/dll compiled
#        [file] = output file from the compilation to check for success
# Return: [none]
def build_success(exename, file):
  errors = False
  file = open(file)
  while 1:
    line = file.readline()
    if not line:
      break
  
    if line.find(exename) > 0:
      if line.find("succeeded") > 0:
        errors = True
        break  
  return errors

# Name: find
# Description: Method for searching a list for a given element
# Input: [f] = item to search for
#        [seq] = list of elements 
# Return: [True] if 'f' is found in 'seq'
#         [False] if 'f' not found in 'seq'
def find(f, seq):
  for item in seq:
    if f == item:
      return True    
  return False

# Name: check_for_dependencies
# Description: Method for checking the dependency of a dll/exe
# Input: [list] = list of projects to check for dependency
#        [searchfor] = the name of the project to search for
#        [dependentlist] = list of the dependent project to be compiled
#        [projectlist] = list of projects which will be compiled. These projects
#                        should not be added to dependent list
# Return: [none]
def check_for_dependencies(list, searchfor, dependentlist, projectlist): 
  for item in list:
    file = open(item)                    
    while 1:          
      line = file.readline()
      if not line:
        break                  
      if line.startswith("Reference"):
        if (line.find(searchfor) > 0):                  
          # check if dependency is added before
          if find(item, dependentlist) == False and find(item, projectlist) == False:
            fPrint("[INFO] Added dependent reference " + item + " for project " + searchfor + "...")
            dependentlist.append(item) 

# Name: check_for_compile_dependencies
# Description: Method for checking the dependency of a dll/exe
# Input: [filename] = list of filenames to check for compile dependency
#        [dependentlist] = list of the dependent project to be compiled
#        [projectlist] = list of projects which will be compiled. These projects
#                        should not be added to dependent list
# Return: [none]
def check_for_compile_dependencies(list, directory, filename, dependentlist, projectlist):    
  filenamewithdirectory = directory + "\\" + filename
  fPrint("[INFO] Check for dependencies for " + filenamewithdirectory)
  for item in list:
    file = open(item)                    
    while 1:          
      line = file.readline()
      if not line:
        break                  
      if line.startswith("Form") or line.startswith("Module") or line.startswith("Class"):        
        if (line.find(filenamewithdirectory) > 0):                  
          # check if dependency is added before
          if find(item, dependentlist) == False and find(item, projectlist) == False:
            fPrint("[INFO] Added dependent reference " + item + " for filename " + filename + "...")
            dependentlist.append(item)

# Name: onsuccessfulbuild
# Description: Method for deploying and updating tfs after a successful build
# Input: [path] = name of the folder in the 'Deploy' directory
#                 [exename] = then name of the built exe/dll
# Return: [none]
def on_successful_build(tfsbranch, path, exename):
  # Find the source dir of the file
  curdir = os.getcwd()      
  index = curdir.rfind("\\")      
  curdir = curdir[:index]         
  index = path.rfind("\\")      
  exedir = path[index+1:]
  # Set 'Src' for copy
  src = curdir + "\\" + tfsbranch + "\\Deploy\\" + exedir + "\\" + exename

  #  Upload to '\\tr-w03'        
  dst = dropfolder + "\\" + tfsbranch + "\\Deploy\\" + exedir
  # Does dst folder exists
  if (os.path.isdir(dst)!=True):
    os.mkdir(dst)        
  fPrint("[INFO] Uploading: " + exename + " -> " + dst)
  shutil.copy(src, dst)

  #  - Team Foundation Server(st-w844) (check-out\copy\check-in)
  fPrint("[INFO] Update Team Foundation Server")
  tfs_update(tfsbranch, src, exedir, exename)

# Name: do_compile
# Description: Method for compiling a vb project
# Input: [project] =   name of the project to compile
# Return: [none]
def do_compile(project, exename, path, tfsbranch, deploy):
  # compile vbp  
  fPrint("[INFO] Compile " + project)    
  cmd = vb6exe + " /m " + project + " /out makeerr.txt"
  run_system_command(cmd)
  fPrint("[INFO] ")
  
  if (build_success(exename, "makeerr.txt")):
    fPrint("[INFO] " + exename + " successfully built...")    
    if(deploy=="true"):
    	on_successful_build(tfsbranch, path, exename)
    projectsBuildSuccess.append(exename)
  else:
    fPrint("[ERROR] " + path + "\\" + exename + " failed...")    
    projectsBuildFailed.append(exename)

# Name: log
# Description: Method for logging to file the summary of a build to screen
# Input:   [tfsbranch] = tfs branch we are logging
#          [logfolder] = the local folder to log to
#          [buildNumber] =   the buildnumber of the Jenkins build
# Return: [none]  
def log(tfsbranch, logfolder, buildNumber):
  fPrint("[INFO] Update compile log...")
  logfile = logfilefolder + "\\" + logfolder + "\\Buildlog.txt"
  file = open(logfile, 'a')
  file.write("\n[INFO] \n")
  file.write("[INFO] ---------------------------------------------\n")
  file.write("[INFO] " + os.environ.get("JOB_NAME") + " #" + buildNumber + "\n")
  file.write("[INFO] Branch " + tfsbranch + "\n")
  datetimenow = datetime.now()   
  file.write("[INFO] " + strftime("%d %b %Y %H:%M:%S", localtime()) + "\n")
  file.write("[INFO] \n")
  file.write("[INFO] Summary of Build #" + buildNumber + "\n")
  if len(projectsBuildSuccess) > 0:    
    file.write("[INFO] Project(s) built successfully\n")
    for project in projectsBuildSuccess:
      file.write("[INFO] " + project + " built successfully\n")      
  
  if len(projectsBuildFailed) > 0:
    file.write("[INFO] Project(s) failed to build")
    # Summary of failed projects to build
    for project in projectsBuildFailed:
      file.write("[ERROR] " + project + " failed to build\n")
  file.write("[INFO] \n")
  file.write("[INFO] ---------------------------------------------\n")  
  file.close()
  
  
# Name: write_summary
# Description: Method for writing the summary of a build to screen
# Input: [buildNumber] =   the buildnumber of the Jenkins build
# Return: [none]  
def write_summary(buildNumber):
  fPrint("[INFO] ----------------------------------------")
  fPrint("[INFO] Summary of Build(" + buildNumber + ")...")
  if len(projectsBuildSuccess) > 0:
    fPrint("[INFO] Project(s) built successfully")
    for project in projectsBuildSuccess:
      fPrint("[INFO] " + project + " built successfully")    
    fPrint("[INFO] ----------------------------------------")  
  
  if len(projectsBuildFailed) > 0:
    # Summary of failed projects to build    
    fPrint("[ERROR] Project(s) failed to build")    
    for project in projectsBuildFailed:
      fPrint("[ERROR] " + project + " failed to build")    
    fPrint("[INFO] ----------------------------------------")        