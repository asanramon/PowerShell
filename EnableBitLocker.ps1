#Author: Angelo San Ramon
#Date: May 29, 2013
#Purpose: Script to enable BitLocker

#Check first if computer is in a domain
if((gwmi Win32_ComputerSystem).partofdomain -ne $true) {
    Write-Host "This computer is not joined to a domain."
	Write-Host "The computer must be joined to a domain before enabling BitLocker."
	Exit
}

#Pull GPO from AD
Start-Process "gpupdate.exe" "/force" -Wait

#Enable BitLocker
Enable-BitLocker -MountPoint "C:"

#Add a numeric recovery password key
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

#Save recovery password to Active Directory
$blv = Get-BitLockerVolume -MountPoint "C:"
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $blv.KeyProtector[2]