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

# use wget to get the source of the balancer-amanger, put it into a file called 'nonce.txt'
$commandNonce = 'wget https://' + $targetHost + '.statoil.net/balancer-manager -O nonce.txt'
iex $commandNonce

# Find the first href line
$hrefline = (Get-Content nonce.txt) | Where-Object {$_ -like "*href=*" } | Select-Object -first 1
# Find the nonce value
$regex = "(?<=nonce=)[^""]*(?="")"
$nonce = $hrefline | select-string -Pattern $regex | % { $_.Matches } | % { $_.Value } 	

# initialize command
$command = 'wget https://' + $targetHost + '.statoil.net/balancer-manager?lf=1"&"ls=0"&"wr="&"rr="&"dw=' + $cmd + '"&"w=ajp%3A%2F%2Flocalhost%3A' + $targetPort + '%2F' + $appl + '%2F"&"b=' + $targetEnv + '-' + $appl + 'cluster"&"nonce=' + $nonce
# execute command
iex $command