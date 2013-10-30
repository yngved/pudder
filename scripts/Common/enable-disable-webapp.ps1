##################################################################################
# 
#	@name:		enable-disable-webapp.ps1
# @created: 16.10.2013
# @author: 	YND
#
# Script for enable/disable a webapp on tomcat.
#
# Example usage: .\enable-disable-app.ps1 -appl eboss-web -targetHost st-w4190 -targetPort 8001 -cmd Enable
# 
# Input parameters:
# 	- $appl
# 	- targetHost
# 	- $targetPort
# 	- $cmd = Enable/Disable
#
# Input parameter(s):
#		- $targetEnv : 
#		- $appl			 : 
#		- $targetHost: Host (st-w4190, st-w4209 etc)
#		- $targetPort: Port on host (8001, 8002 etc)
#		- $cmd: 			 Enable/Disable
#	This script is used by:
#		- deploy-to-tomcat-balancer-node.bat
#
#	This scripts uses:
#		- 
#
##################################################################################
# Resolve input parameters
param($targetEnv, $appl, $targetHost, $targetPort, $cmd)

Write-Host("TargetEnv=$targetEnv")
Write-Host("Appl=$appl")
Write-Host("TargetHost=$targetHost")
Write-Host("TargetPort=$targetPort")
Write-Host("Cmd=$cmd")


$command = 'wget https://' + $targetHost + '.statoil.net/balancer-manager?lf=1"&"ls=0"&"wr="&"rr="&"dw=' + $cmd + '"&"w=ajp%3A%2F%2Flocalhost%3A' + $targetPort + '%2F' + $appl + '%2F"&"b=' + $targetEnv + '-' + $appl + 'cluster"&"nonce=feaf9233-fa74-274c-a0e5-8b97630f2876'
# execute command
iex $command

