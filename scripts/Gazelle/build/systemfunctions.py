import os

#####################################################################################################
# @name: tfs.py
# @created: 24.10.2013
# @author: 	YND
#
# System functions used by vb6-build.py
#
#######################################################################################################

# Name: fPrint
# Description: Extended print method with flush
# Input: [text] = text to print
# Return: [none]
def fPrint(*text):
  import sys
  print (text)
  sys.stdout.flush()
  
# Name: run_system_command
# Description: Method for running a command in command prompt
# Input: [cmd] = formated command
# Return: [none]
def run_system_command(cmd):    
  os.system(cmd)