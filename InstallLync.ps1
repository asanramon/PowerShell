#Author: Angelo San Ramon
#Date: June 18, 2013
#Purpose: Install and configure Lync Basic 2013.

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$logfile = "$scriptdir\" + $scriptname.Split(".")[0] + ".log"
$errorfound = $false

$curdate = Get-Date -Format g
echo "Script started: $curdate" | Tee-Object -Append $logfile

#Install Lync
#Check if Lync is already installed. If so, do not reinstall
echo "Checking if Lync is already installed." | Tee-Object -Append $logfile
$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Microsoft LyncEntry”}).Name
if ($installed) {
	echo "Lync is already installed." | Tee-Object -Append $logfile
	$errorfound = $false
	break
}
echo "Lync is not installed yet." | Tee-Object -Append $logfile

#Install Lync
echo "Installing Lync." | Tee-Object -Append $logfile
Start-Process ($scriptdir + "\setup.exe") "/adminfile lync.msp" -Wait

#Check if JDK installed successfully.
echo "Checking if Lync installed successfully." | Tee-Object -Append $logfile
$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Microsoft LyncEntry”}).Name
if (!$installed) {
	echo "Failed to install Lync." | Tee-Object -Append $logfile
	$errorfound = $true
	break
}
echo "Lync installed successfully." | Tee-Object -Append $logfile

#Modify registry to prevent first time run wizard from appearing
echo "Modifying registry to prevent first time run wizard from running." | Tee-Object $logfile
if (!(Test-Path "HKCU:\Software\Microsoft\Office\15.0\Common\General")) {
	New-Item -Path "HKCU:\Software\Microsoft\Office\15.0\Common\General" -Force | Out-Null
}
New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\15.0\Common\General" -Force -Name ShownFirstRunOptin -PropertyType DWORD -Value "1" | Out-Null

$excludeProfiles = "All Users","Default User","Public","$env:USERNAME"
$userProfiles = Get-ChildItem -Force "$env:SystemDrive\Users" -Directory -Exclude $excludeProfiles | foreach { $_.Name }
ForEach ($userProfile in $userProfiles) {
	if (!(Test-Path Registry::HKU\ntuser)) {
		echo "Loading $userProfile registry hive." | Tee-Object -Append $logfile
		Reg load HKU\ntuser "$env:SystemDrive\Users\$userProfile\NTUSER.DAT" | Tee-Object -Append $logfile
		if (!$?) {
			echo "Error loading $userProfile registry hive." | Tee-Object -Append $logfile
			$errorfound = $true
			break
		}
	}
	if (!(Test-Path "Registry::HKU\ntuser\Software\Microsoft\Office\15.0\Common\General")) {
		New-Item -Path "Registry::HKU\ntuser\Software\Microsoft\Office\15.0\Common\General" -Force | Out-Null
	}
	New-ItemProperty -Path "Registry::HKU\ntuser\Software\Microsoft\Office\15.0\Common\General" -Name ShownFirstRunOptin -PropertyType DWORD -Value "1" | Out-Null
	[GC]::collect()
	Sleep 2
	if (Test-Path Registry::HKU\ntuser) {
		echo "Unloading $userProfile registry hive." | Tee-Object -Append $logfile
		Reg unload HKU\ntuser | Tee-Object -Append $logfile
		if (!$?) {
			echo "Error unloading $userProfile registry hive." | Tee-Object -Append $logfile
			$errorfound = $true
			break
		}
	}
}

if ($errorfound) {
	$curdate = Get-Date -Format g
	echo "Script did not run successfully." | Tee-Object -Append $logfile
	echo "Script ended: $curdate" | Tee-Object -Append $logfile
	exit 1
} else {
	$curdate = Get-Date -Format g
	echo "Script ran successfully." | Tee-Object -Append $logfile
	echo "Script ended: $curdate" | Tee-Object -Append $logfile
	exit 0
}