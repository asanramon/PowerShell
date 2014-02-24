#Author: Angelo San Ramon
#Date: 06/07/2013
#Purpose: Install Java to manager workstations.

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition

#Install Java.
Start-Process ($scriptdir + "\jre-1_5_0_10-windows-i586-p-s.exe") "/qn" -Wait

#Set registry entries.
Get-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Plug-in\1.5.0_10" -Name HideSystemTrayIcon -ErrorAction SilentlyContinue | Out-Null
if ( $? -eq "True" ) {
	Set-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Plug-in\1.5.0_10" -Name HideSystemTrayIcon -Value "1"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Plug-in\1.5.0_10" -Name HideSystemTrayIcon -PropertyType DWORD -Value "1" | Out-Null
}

Get-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy" -Name EnableJavaUpdate -ErrorAction SilentlyContinue | Out-Null
if ( $? -eq "True" ) {
	Set-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy" -Name EnableJavaUpdate -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy" -Name EnableJavaUpdate -PropertyType DWORD -Value "0" | Out-Null
}

Get-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy" -Name PromptAutoUpdateCheck -ErrorAction SilentlyContinue | Out-Null
if ( $? -eq "True" ) {
	Set-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy" -Name PromptAutoUpdateCheck -Value "0"
} else {
	New-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy" -Name PromptAutoUpdateCheck -PropertyType DWORD -Value "0" | Out-Null
}

#Copy Java policy files.
Copy-Item -Path ($scriptdir + "\gap.java.policy") -Destination ($env:ProgramFiles + "\Java\jre1.5.0_10\lib\security") -Force
Copy-Item -Path ($scriptdir + "\java.security") -Destination ($env:ProgramFiles + "\Java\jre1.5.0_10\lib\security") -Force