#Author: Angelo San Ramon
#Date: 06/07/2013
#Purpose: Deploy SIM Java files and certificates to manager workstations.

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition

#Copy SIM Java client to all user profile.
$excludeProfiles = "Administrator","All Users","Default User","Public"
$userProfiles = Get-ChildItem -Force ($env:SystemDrive + "\Users") -Directory -Exclude $excludeProfiles | foreach { $_.Name }
ForEach ($userProfile in $userProfiles) {
	Copy-Item -Path ($scriptdir + "\AppData") -Destination ($env:SystemDrive + "\Users\" + $userProfile) -Force -Recurse
}

#Import SIM certificates to Internet Explorer.
Start-Process ($scriptdir + "\certmgr.exe") ("-add -c " + $scriptdir + "\pacgia02.cer -s -r localmachine root") -Wait
Start-Process ($scriptdir + "\certmgr.exe") ("-add -c " + $scriptdir + "\EGI_BFX_Trusted.cer -s -r localmachine root") -Wait
Start-Process ($scriptdir + "\certmgr.exe") ("-add -c " + $scriptdir + "\EGIPrdSIM_1024.cer -s -r localmachine root") -Wait