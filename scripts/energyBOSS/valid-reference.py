###################################################################################
# 
#	@name:		eboss-server-net-web-deploy-node-production.bat
# @created: 24.10.2013
# @author: 	YND
#
# Script for deployment of sites to a specific node on IS
#
# Jenkins parameter(s) used: 
#	- 
# 
# Input parameter(s):
#	- %1 = Solution to evalute
#
# This scripts uses:
# -
#
# # Script will return:
#  0 if solution validated to true
#  0 if there is no 'solution-reference-white-list.txt' for the solution
#  1 if solution validated to false

###################################################################################

#
#! /usr/bin/env python
import xml.etree.ElementTree as ET
import os
import fileinput
import glob
import shutil
import sys
import string

#class Project 
class Project:
  def __init__(self, name):
    self.name = name
    self.projectfile=""
    self.valid = True
    self.whitelistexternalreferences = []
    self.whitelistinternalreferences = []    
    self.solutionprojectreferences = []
    self.notvalidreferences = []
  
  def addwhitelistreference(self, reference):
    if reference.endswith(".csproj"):
      self.whitelistinternalreferences.append(reference)
    else:
      self.whitelistexternalreferences.append(reference)
  
  def addnotvalidreference(self, reference):
    self.notvalidreferences.append(reference)
  
  def validate(self):    
    # Project valid, initial set to false    
    valid = False
    for reference in self.solutionprojectreferences:    
      if reference.endswith(".csproj"):
        reference = reference[reference.rfind('\\') +1:]
        if reference in self.whitelistinternalreferences:
          valid = True
      else:
        for validref in self.whitelistexternalreferences:      
          if(validref.find("*") > 0):
            index = validref.find("*")
            validref = validref[:index]       
            ix = reference.find(validref)          
            if(reference.find(validref) == 0):          
              valid = True         
          else:
            if validref == reference:          
              valid = True    
      
      #print("ref=" + reference + " valid=" + str(valid))
      # Add to list if not valid
      if not valid:
        self.notvalidreferences.append(reference)
      valid = False
    # return list
    if len(self.notvalidreferences) > 0:
      self.valid = False      

  def extractreferencesfromprojectfile(self):
    tree = ET.parse(self.projectfile)
    doc = tree.getroot()
    i = 0
    projectreflist = []
    for element in doc:    
      for item in doc[i]:           
        if(str(item).find("Reference") > 0):        
          split = str(item.attrib).split(",")
          for el in split:          
            if el.find("Include") > 0:            
              el = el.lstrip("{'Include'")                        
              el = el.lstrip(": '")            
              el = el.rstrip("'}")
              self.solutionprojectreferences.append(el)         
      
      # increment counter
      i = i + 1   
  
  def write(self):
    print("[INFO] " + self.name)
    if len(self.whitelistinternalreferences) > 0:
      print("[INFO]   Internal references:")    
      for reference in self.whitelistinternalreferences:
        print("[INFO]     " + reference)
    
    if len(self.whitelistexternalreferences) > 0:
      print("[INFO]   External references:")
      for reference in self.whitelistexternalreferences:
        print("[INFO]     " + reference)
  
  def writesolutionprojectreferences(self):
    for references in self.solutionprojectreferences:
      print("[INFO]    " + references)

#end class Project

# Global methods
def findfileoftype(type, file):          
  a = ""
  for infile in glob.glob(os.path.join(file, type)):
    a = infile    
  return a

def scandirs(path, type, list):
  for currentFile in glob.glob( os.path.join(path, '*') ):
    if os.path.isdir(currentFile):            
      file = findfileoftype(type, currentFile)            
      if file != "":
        list.append(file)                
      scandirs(currentFile, type, list)

def readwhitelist(whitelistfile):
  projectwhitelist = []  
  f = open(whitelistfile)
  project = None 
  while 1:
    line = f.readline()
    line = line.strip('\r\n')
    #print("line(" +line + ")")
    if not line:
      break            
    pass  
    if line.find("#") > -1:     
      continue
    elif line.startswith(" "):
      continue
    else:      
      if line.startswith("Project:"):
        if project is not None:          
          projectwhitelist.append(project)          
        
        #split line by delimeter ":"
        split = line.split(":")
        # Initiate a new Project        
        project = Project(split[1])        
      else:        
        #line = line[:-1]        
        project.addwhitelistreference(line)
  
  # Add the last project
  projectwhitelist.append(project)
  return projectwhitelist

def main():
  # parse input parameter
  solution = sys.argv[1]
  # whitelist file name
  whitelistfile = "solution-reference-white-list.txt"
  
  print("[INFO]")
  print("[INFO] Init project reference script for solution '" + solution + "'")
  print("[INFO]")
  
  # 1. Find the solution file  
  # 2  Check if there exists an 'solution-reference-white-list.txt' file
  # if true -> run validation
  # else exit(0), success 
  
  solutiontype="*.sln"
  curdir = os.getcwd()
  solutionlist = []
  print("[INFO] CurrentDirectory '" + curdir + "'")
  scandirs(curdir, solutiontype, solutionlist)
  
  if len(solutionlist) == 0:
    print("[INFO] Did not find a *.sln file in the subdirectory, check the toplevel directory (CurDir): " + curdir )    
    a = ""
    for infile in glob.glob(os.path.join(curdir, solutiontype)):
      a = infile
    if a != "":
      solutionlist.append(a)
  
  # loop through solution list and see if the solution to validate exists and
  # chech if a 'solution-reference-white-list.txt' file exists.
  validatesolution = False
  for item in solutionlist:
    sol = item[item.rfind('\\') +1:]
    if sol == solution:      
      # is there a whitelist file here
      directory = item[:item.rfind('\\') +1]
      whitelistfilepath = directory + whitelistfile
      if os.path.exists(whitelistfilepath):
        print("[INFO] Found solution '" + solution + "' and whitelistfile '" + whitelistfile + "'")
        print("[INFO] Solution '" + item + "'")
        print("[INFO] Whitelistfile '" + whitelistfilepath + "'")        
        validatesolution = True
        break
    
  if not validatesolution:
    print("[INFO] No solution or whitelist found for solution '" + solution +"'")
    print("[INFO] No reference validation will be done")
    sys.exit(0)
  
  # change working directory to solution directory 
  os.chdir(directory)  
  curdir = os.getcwd()
  print("[INFO] CurrentDirectory '" + curdir + "'")
  
  # Read whitelist
  print("[INFO]...")
  print("[INFO] Start validation of solution '" + solution + "'")
  print("[INFO] Parse whitelistfile '" + whitelistfile + "'")
  # projectwhitelist will contain instances of project to validate
  projectwhitelist = readwhitelist(whitelistfilepath)
  print("[INFO] Whitlelist contains " + str(len(projectwhitelist)) + " project(s):")
  
  for project in projectwhitelist:    
    project.write()
  
  # find project files in solution 
  projecttype="*.csproj"      
  solutionprojectlist = []
  scandirs(curdir, projecttype, solutionprojectlist)
  
  print("[INFO] Solution '" + solution + "' contains " + str(len(solutionprojectlist)) + " project(s)")
  print("[INFO]")    
  
  # Find project path for the projects to validate  
  for project in projectwhitelist:    
    for solutionproject in solutionprojectlist:
      solprojectname = solutionproject[solutionproject.rfind('\\') +1:]
      if project.name == solprojectname:
        project.projectfile = solutionproject
    
  # validate
  solutionvalid = True
  print("[INFO] Start validation of solution '" + solution + "'")
  for project in projectwhitelist:
    # extract values from projectfile
    print("[INFO] Validate project '" + project.name + "'")
    project.extractreferencesfromprojectfile()
    print("[INFO] Found " + str(len(project.solutionprojectreferences)) + " references in '" + project.name + "'")    
    project.writesolutionprojectreferences()     
  
    # validate projectreferences against the whitelist  
    print("[INFO] Validate projectreferences against the whitelist for project '" + project.name + "'")    
    project.validate() 
  
    
    # List the unvalid references in project    
    if project.valid is False:
      solutionvalid = False
      print("[INFO] List unvalid references for project '" + project.name + "'")
      for element in project.notvalidreferences:
        print("[ERROR] " + element + " is not a valid reference")
      print("[ERROR] Project '" + project.name + "' is not valid")
    else:
      print("[INFO] Project '" + project.name + "' is valid") 
    
    print("[INFO]")        
    
  # Return
  if solutionvalid is True:
    print("[INFO] Solution '" + solution + "' is valid")
    sys.exit(0)
  else:
    print("[ERROR] Solution '" + solution + "' is not valid")
    sys.exit(1)      
    
main()    