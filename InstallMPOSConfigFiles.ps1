#Author: Angelo San Ramon
#Date: June 13, 2013
#Purpose: Script to install MPOS configuration files.

param (
	[ValidateSet("yes","no")]
	[String]$rollback
)

$ErrorActionPreference = "Stop"
$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$logfile = "$scriptdir\" + $scriptname.Split(".")[0] + ".log"
$errorfound = $null

function ShowUsage {
	Write-Host "Invalid argument."
	Write-Host "Syntax:"
	Write-Host "	$scriptname [-rollback [yes | no]]"
}

function InstallJDK {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if JDK is already installed. If so, do not reinstall
		echo "Checking if Java DK 1.6 is already installed." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) SE Development Kit 6”}).Name
		if ($installed) {
			echo "Java DK 1.6 is already installed." | Tee-Object -Append $logfile
			$global:errorfound = $false
			return
		}
		echo "Java DK 1.6 is not installed yet." | Tee-Object -Append $logfile
	
		#Check if JRE 1.6 is installed. If so uninstall.
		echo "Checking if Java RE 1.6 is installed." | Tee-Object -Append $logfile
		$installed = Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) 6”}
		if ($installed) {
			echo "Java RE 1.6 is installed. Uninstalling it." | Tee-Object -Append $logfile
			$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) 6”}).IdentifyingNumber
			Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait
		}
	
		#Install JDK
		echo "Installing Java DK 1.6."
		Start-Process "$scriptdir\jdk-6u21-windows-i586.exe" "/s /v /qn /norestart /L javasetup.log" -Wait
	
		#Check if JDK installed successfully.
		echo "Checking if Java DK 1.6 installed successfully." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) SE Development Kit 6”}).Name
		if (!$installed) {
			echo "Failed to install JDK." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Java DK 1.6 installed successfully." | Tee-Object -Append $logfile
	
		#Create system environment variable
		echo "Creating environment variables JAVA_HOME and JRE_HOME." | Tee-Object -Append $logfile 
		[Environment]::SetEnvironmentVariable("JAVA_HOME", "$env:ProgramFiles\Java\JDK1.6.0_21", "Machine")
		[Environment]::SetEnvironmentVariable("JRE_HOME", "$env:ProgramFiles\Java\JRE6", "Machine")
	
		#Copy GAP Java security files
		echo "Copying GAP Java security files."
		Copy-Item -Path "$scriptdir\gap.java.policy" -Destination "$env:ProgramFiles\Java\jre6\lib\security" -Force
		Copy-Item -Path "$scriptdir\java.security" -Destination "$env:ProgramFiles\Java\jre6\lib\security" -Force
		Copy-Item -Path "$scriptdir\gap.java.policy" -Destination "$env:ProgramFiles\Java\jdk1.6.0_21\jre\lib\security" -Force
		Copy-Item -Path "$scriptdir\java.security" -Destination "$env:ProgramFiles\Java\jdk1.6.0_21\jre\lib\security" -Force
	
		#Configure Registry
		echo "Configuring registry to turn off Java updates." | Tee-Object -Append $logfile
		Get-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_21" -Name HideSystemTrayIcon -ErrorAction SilentlyContinue | Out-Null
		if ( $? -eq "True" ) {
			Set-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_21" -Name HideSystemTrayIcon -Value "1" | Out-Null
		} else {
			New-ItemProperty -Path "HKLM:\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_21" -Name HideSystemTrayIcon -PropertyType DWORD -Value "1" | Out-Null
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
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function UninstallJDK {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if JDK is already uninstalled.
		echo "Checking if Java DK 1.6 is already uninstalled." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) SE Development Kit 6”}).Name
		if (!$installed) {
			echo "Java DK 1.6 is already uninstalled." | Tee-Object -Append $logfile
			$global:errorfound = $false
			return
		}
		echo "Java DK 1.6 is installed." | Tee-Object -Append $logfile
		
		#Uninstall JDK
		echo "Uninstalling Java DK 1.6."
		$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) SE Development Kit 6”}).IdentifyingNumber
		Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait
	
		#Check if Java DK successfully uninstalled.
		echo "Checking if Java DK 1.6 successfully uninstalled." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java\(TM\) SE Development Kit 6”}).Name
		if ($installed) {
			echo "Failed to uninstall Java DK." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Java DK 1.6 successfully uninstalled." | Tee-Object -Append $logfile
	
		#Uninstall Java Database
		echo "Uninstalling Java Database"
		$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java DB”}).IdentifyingNumber
		Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait

		#Check if Java DB successfully uninstalled.
		echo "Checking if Java DB successfully uninstalled." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Java DB”}).Name
		if ($installed) {
			echo "Failed to uninstall Java DB." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Java DB successfully uninstalled." | Tee-Object -Append $logfile
		
		
		#Remove system environment variable
		echo "Removing environment variables JAVA_HOME and JRE_HOME." | Tee-Object -Append $logfile 
		[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "Machine")
		[Environment]::SetEnvironmentVariable("JRE_HOME", $null, "Machine")
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function InstallAppleApplicationSupport {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if Apple Application Support is already installed. If so, do not reinstall
		echo "Checking if Apple Application Support is already installed." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Application Support”}).Name
		if ($installed) {
			echo "Apple Application Support is already installed." | Tee-Object -Append $logfile
			$global:errorfound = $false
			return
		}
		echo "Apple Application Support is not installed yet." | Tee-Object -Append $logfile
	
		#Install Apple Application Support
		echo "Installing Apple Application Support" | Tee-Object -Append $logfile
		Start-Process "$scriptdir\AppleApplicationSupport.msi" "/qn /norestart /l AppleApplicationSupport.log" -Wait
	
		#Check if Apple Application Support installed successfully.
		echo "Checking if Apple Application Support installed successfully." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Application Support”}).Name
		if (!$installed) {
			echo "Failed to install Apple Application Support." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Apple Application Support installed successfully." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function UninstallAppleApplicationSupport {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if Apple Application Support is already uninstalled.
		echo "Checking if Apple Application Support is already uninstalled." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Application Support”}).Name
		if (!$installed) {
			echo "Apple Application Support is already uninstalled." | Tee-Object -Append $logfile
			$global:errorfound = $false
			return
		}
		echo "Apple Application Support is still installed." | Tee-Object -Append $logfile
	
		#Uninstall Apple Application Support
		echo "Uninstalling Apple Application Support" | Tee-Object -Append $logfile
		$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Application Support”}).IdentifyingNumber
		Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait
	
		#Check if Apple Application Support installed successfully.
		echo "Checking if Apple Application Support installed successfully." | Tee-Object -Append $logfile
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Application Support”}).Name
		if ($installed) {
			echo "Failed to uninstall Apple Application Support." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Apple Application Support successfully uninstalled." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function InstallAppleMobileDeviceSupport {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if Apple Mobile Device Support is already installed. If so, do not reinstall
		echo "Checking if Apple Mobile Device Support is already installed."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Mobile Device Support”}).Name
		if ($installed) {
			echo "Apple Mobile Device Support is already installed."
			$global:errorfound = $false
			return
		}
		echo "Apple Mobile Device Support is not installed yet." | Tee-Object -Append $logfile
	
		#Install Apple Mobile Device Support
		echo "Installing Apple Mobile Device Support"
		Start-Process "$scriptdir\AppleMobileDeviceSupport.msi" "/qn /norestart /l AppleMobileDeviceSupport.log" -Wait
	
		#Check if Apple Mobile Device Support installed successfully.
		echo "Checking if Apple Mobile Device Support installed successfully."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Mobile Device Support”}).Name
		if (!$installed) {
			echo "Failed to install Apple Mobile Device Support."
			$global:errorfound = $true
			return
		}
		echo "Apple Mobile Device Support installed successfully." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function UninstallAppleMobileDeviceSupport {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if Apple Mobile Device Support is already uninstalled.
		echo "Checking if Apple Mobile Device Support is already uninstalled."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Mobile Device Support”}).Name
		if (!$installed) {
			echo "Apple Mobile Device Support is already uninstalled."
			$global:errorfound = $false
			return
		}
		echo "Apple Mobile Device Support is still installed." | Tee-Object -Append $logfile
	
		#Uninstall Apple Mobile Device Support
		echo "Uninstalling Apple Mobile Device Support"
		$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Mobile Device Support”}).IdentifyingNumber
		Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait
	
		#Check if Apple Mobile Device Support is successfully uninstalled.
		echo "Checking if Apple Mobile Device Support successfully uninstalled."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Apple Mobile Device Support”}).Name
		if ($installed) {
			echo "Failed to uninstall Apple Mobile Device Support."
			$global:errorfound = $true
			return
		}
		echo "Apple Mobile Device Support successfully uninstalled." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function InstallBonjour {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if Bonjour is already installed. If so, do not reinstall
		echo "Checking if Bonjour is already installed."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Bonjour”}).Name
		if ($installed) {
			echo "Bonjour is already installed."
			$global:errorfound = $false
			return
		}
		echo "Bonjour is not installed yet." | Tee-Object -Append $logfile
	
		#Install Bonjour
		echo "Installing Bonjour."
		Start-Process "$scriptdir\Bonjour.msi" "/qn /norestart /l Bonjour.log" -Wait
	
		#Check if Bonjour installed successfully.
		echo "Checking if Bonjour installed successfully."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Bonjour”}).Name
		if (!$installed) {
			echo "Failed to install Bonjour."
			$global:errorfound = $true
			return
		}
		echo "Bonjour installed successfully." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function UninstallBonjour {
	$Error.Clear()
	$global:errorfound = $false
	Try {
		#Check if Bonjour is already uninstalled.
		echo "Checking if Bonjour is already uninstalled."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Bonjour”}).Name
		if (!$installed) {
			echo "Bonjour is already uninstalled."
			$global:errorfound = $false
			return
		}
		echo "Bonjour is still installed." | Tee-Object -Append $logfile
	
		#Uninstall Bonjour
		echo "Uninstalling Bonjour."
		$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Bonjour”}).IdentifyingNumber
		Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait
	
		#Check if Bonjour installed successfully.
		echo "Checking if Bonjour successfully uninstalled."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “Bonjour”}).Name
		if ($installed) {
			echo "Failed to uninstall Bonjour."
			$global:errorfound = $true
			return
		}
		echo "Bonjour successfully uninstalled." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function InstalliPhoneConfigurationUtility {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if iPhone Configuration Utility is already installed. If so, do not reinstall
		echo "Checking if iPhone Configuration Utility is already installed."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “iPhone Configuration Utility”}).Name
		if ($installed) {
			echo "iPhone Configuration Utility is already installed."
			$global:errorfound = $false
			return
		}
		echo "iPhone Configuration Utility is not installed yet." | Tee-Object -Append $logfile
	
		#Install iPhone Configuration Utility
		echo "Installing iPhone Configuration Utility"
		Start-Process "$scriptdir\iPhoneConfigUtility.msi" "/qn /norestart /l iPhoneConfigurationUtility.log" -Wait
	
		#Check if iPhone Configuration Utility installed successfully.
		echo "Checking if iPhone Configuration Utility installed successfully."
		$apps = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “iPhone Configuration Utility”}).Name
		if (!$apps) {
			echo "Failed to install iPhone Configuration Utility."
			$global:errorfound = $true
			return
		}
		echo "iPhone Configuration Utility installed successfully." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function UninstalliPhoneConfigurationUtility {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Check if iPhone Configuration Utility is already uninstalled.
		echo "Checking if iPhone Configuration Utility is already uninstalled."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “iPhone Configuration Utility”}).Name
		if (!$installed) {
			echo "iPhone Configuration Utility is already uninstalled."
			$global:errorfound = $false
			return
		}
		echo "iPhone Configuration Utility is still installed." | Tee-Object -Append $logfile
	
		#Install iPhone Configuration Utility
		echo "Uninstalling iPhone Configuration Utility"
		$productcode = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “iPhone Configuration Utility”}).IdentifyingNumber
		Start-Process "msiexec.exe" "/x $productcode /quiet /norestart" -Wait
	
		#Check if iPhone Configuration Utility successfully uninstalled.
		echo "Checking if iPhone Configuration Utility successfully uninstalled."
		$installed = (Get-WmiObject -Class Win32_Product | Where { $_.Name -match “iPhone Configuration Utility”}).Name
		if ($installed) {
			echo "Failed to uninstall iPhone Configuration Utility."
			$global:errorfound = $true
			return
		}
		echo "iPhone Configuration Utility successfully uninstalled." | Tee-Object -Append $logfile
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function InstallTomcat {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Copy Tomcat files
		echo "Copying Tomcat files..." | Tee-Object -Append $logfile
		Copy-Item -Path "$scriptdir\apache-tomcat-6.0.29" -Destination "$env:SystemDrive\apache-tomcat-6.0.29" -Force -Recurse
		Copy-Item -Path "$scriptdir\mobile_prod.war" -Destination "$env:SystemDrive\apache-tomcat-6.0.29\webapps\mobile.war" -Force
		echo "Tomcat files copied successfully." | Tee-Object -Append $logfile
	
		#Install Tomcat service
		echo "Installing Tomcat 6 service." | Tee-Object -Append $logfile
		Start-Process "$env:SystemDrive\apache-tomcat-6.0.29\bin\service.bat" "install" -Wait -WorkingDirectory "$env:SystemDrive\apache-tomcat-6.0.29\bin"
		Get-Service -Name "Tomcat6" -ErrorAction SilentlyContinue | Out-Null
		if (!$?) {
			echo "Tomcat 6 service did not install successfully." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Tomcat 6 service successfully installed." | Tee-Object -Append $logfile
		Set-Service -Name "Tomcat6" -StartupType Automatic
		echo "Starting Tomcat service." | Tee-Object -Append $logfile
		Start-Service -Name "Tomcat6"
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function UninstallTomcat {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Remove Tomcat service.
		echo "Checking if Tomcat 6 service is already removed." | Tee-Object -Append  $logfile
		Get-Service -Name "Tomcat6" -ErrorAction SilentlyContinue | Out-Null
		if (!$?) {
			echo "Tomcat 6 service is alredy removed." | Tee-Object -Append $logfile
			$global:errorfound = $false
			return
		}
		echo "Tomcat 6 service is still installed." | Tee-Object -Append $logfile
		Stop-Service -Name "Tomcat6"
		echo "Removing Tomcat 6 service." | Tee-Object -Append $logfile
		Start-Process "$env:SystemDrive\apache-tomcat-6.0.29\bin\service.bat" "uninstall" -Wait -WorkingDirectory "$env:SystemDrive\apache-tomcat-6.0.29\bin" | Tee-Object -Append $logfile
		Sleep 3
		Get-Service -Name "Tomcat6" -ErrorAction SilentlyContinue | Out-Null
		if ($?) {
			echo "Failed to remove Tomcat 6 service." | Tee-Object -Append $logfile
			$global:errorfound = $true
			return
		}
		echo "Tomcat 6 service successfully removed." | Tee-Object -Append $logfile

		#Delete Tomcat files
		echo "Deleting Tomcat files..." | Tee-Object -Append $logfile
		Remove-Item -Path "$env:SystemDrive\apache-tomcat-6.0.29" -Force -Recurse -ErrorAction SilentlyContinue
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function CopyGAPMPOSConfigFiles {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Copy config files
		echo "Copying GAP MPOS Configuration files."
		Copy-Item "$scriptdir\__MACOSX" "$env:SystemDrive\Users\Public\Documents" -Force -Recurse
		Copy-Item "$scriptdir\GAP_POS2.app" "$env:SystemDrive\Users\Public\Documents" -Force -Recurse

		#Create links to the config file for all users.
		echo "Creating symbolic links for all users." | Tee-Object -Append $logfile
		$excludeProfiles = "All Users","Default User","Public","Default"
		$userProfiles = Get-ChildItem -Force "$env:SystemDrive\Users" -Directory -Exclude $excludeProfiles | foreach { $_.Name }
		ForEach ($userProfile in $userProfiles) {
			New-Item -Path "$env:SystemDrive\Users\$userProfile\AppData\Local\Apple Computer\MobileDevice" -ItemType Directory -Force | Out-Null
			Start-Process "cmd" "/c mklink /J $env:SystemDrive\Users\$userProfile\AppData\Local\`"Apple Computer`"\MobileDevice\Applications $env:SystemDrive\Users\Public\Documents" -Wait
		}
		if (!(Test-Path Registry::HKU\ntuser)) {
			echo "Loading Default User registry hive." | Tee-Object -Append $logfile
			Reg load HKU\ntuser "$env:SystemDrive\Users\Default\NTUSER.DAT" | Tee-Object -Append $logfile
			if (!$?) {
				echo "Error loading Default User registry hive." | Tee-Object -Append $logfile
				$global:errorfound = $true
				return
			}
		}
		New-Item -Path Registry::HKU\ntuser\Software\Microsoft\Windows\CurrentVersion -Name RunOnce -Force | Out-Null
		New-ItemProperty Registry::HKU\ntuser\Software\Microsoft\Windows\CurrentVersion\RunOnce -Force -Name iPCULink `
			-PropertyType String -Value "cmd /c mklink /J %USERPROFILE%\AppData\Local\`"Apple Computer`"\MobileDevice\Applications %SystemDrive%\Users\Public\Documents" | Out-Null
		[GC]::collect()
		Sleep 2
		if (Test-Path Registry::HKU\ntuser) {
			echo "Unloading Default Users registry hive." | Tee-Object -Append $logfile
			Reg unload HKU\ntuser | Tee-Object -Append $logfile
			if (!$?) {
				echo "Error unloading Default Users registry hive." | Tee-Object -Append $logfile
				$global:errorfound = $true
				return
			}
		}
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function RemoveGAPMPOSConfigFiles {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Delete symbolic links
		echo "Removing symbolic links on all users profile." | Tee-Object -Append $logfile
		$excludeProfiles = "Administrator","All Users","Default User","Public","Default"
		$userProfiles = Get-ChildItem -Force "$env:SystemDrive\Users" -Directory -Exclude $excludeProfiles | foreach { $_.Name }
		ForEach ($userProfile in $userProfiles) {
			Start-Process "cmd" "/c rmdir /s /q $env:SystemDrive\Users\$userProfile\AppData\Local\`"Apple Computer`"\MobileDevice" -Wait
		}
		if (!(Test-Path Registry::HKU\ntuser)) {
			echo "Loading Default User registry hive." | Tee-Object -Append $logfile
			Reg load HKU\ntuser "$env:SystemDrive\Users\Default\NTUSER.DAT" | Tee-Object -Append $logfile
			if (!$?) {
				echo "Error loading Default User registry hive." | Tee-Object -Append $logfile
				$global:errorfound = $true
				return
			}
		}
		if (Test-Path Registry::HKU\ntuser\Software\Microsoft\Windows\CurrentVersion\RunOnce) {
			Remove-Item -Path Registry::HKU\ntuser\Software\Microsoft\Windows\CurrentVersion\RunOnce | Out-Null
		}
		[GC]::collect()
		Sleep 2
		if (Test-Path Registry::HKU\ntuser) {
			echo "Unloading Default Users registry hive." | Tee-Object -Append $logfile
			Reg unload HKU\ntuser | Tee-Object -Append $logfile
			if (!$?) {
				echo "Error unloading Default Users registry hive." | Tee-Object -Append $logfile
				$global:errorfound = $true
				return
			}
		}

		#Remove config files
		echo "Deleting GAP MPOS Configuration files."
		Remove-Item -Path "$env:SystemDrive\Users\Public\Documents\__MACOSX"  -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
		Remove-Item -Path "$env:SystemDrive\Users\Public\Documents\GAP_POS2.app" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function CopyPrinterDrivers {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Copy Zebra drivers
		echo "Copying Zebra printer drivers." | Tee-Object -Append $logfile
		Copy-Item -Path "$scriptdir\MZ320" -Destination $env:SystemDrive\Drivers\Zebra -Force -Recurse
		$devicepath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion").DevicePath
		$devicepath = $devicepath -replace ";$env:SystemDrive\\Drivers\\Zebra",""
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name DevicePath `
			-Value "$devicepath;$env:SystemDrive\Drivers\Zebra" | Out-Null
		Copy-Item -Path "$scriptdir\Device_Utility" -Destination "$env:SystemDrive\Device_Utility" -Force -Recurse
		New-Item -Path "$env:SystemDrive\Device_Utility\logs" -ItemType Directory -Force | Out-Null
		Copy-Item -Path "$scriptdir\msvcr100.dll" -Destination $env:SystemRoot -Force
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function RemovePrinterDrivers {
	$Error.Clear()
	$global:errorfound = $false
	try {
		#Remove Zebra drivers
		echo "Removing Zebra printer drivers." | Tee-Object -Append $logfile
		Remove-Item -Path "$env:SystemDrive\Drivers\Zebra" -Force -Recurse
		$devicepath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion").DevicePath
		$devicepath = $devicepath -replace ";$env:SystemDrive\\Drivers\\Zebra",""
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name DevicePath `
			-Value "$devicepath" | Out-Null
		Remove-Item -Path "$env:SystemDrive\Device_Utility" -Force -Recurse
		Remove-Item -Path "$env:SystemRoot\msvcr100.dll" -Force
	} catch {
		echo $Error | Tee-Object -Append $logfile
		$global:errorfound = $true
	}
}

function DoInstall {
	InstallJDK
	if ($errorfound) { return }
	InstallAppleApplicationSupport
	if ($errorfound) { return }
	InstallAppleMobileDeviceSupport
	if ($errorfound) { return }
	InstallBonjour
	if ($errorfound) { return }
	InstalliPhoneConfigurationUtility
	if ($errorfound) { return }
	InstallTomcat
	if ($errorfound) { return }
	CopyGAPMPOSConfigFiles
	if ($errorfound) { return }
	CopyPrinterDrivers
}

function DoRollback {
	UninstallJDK
	if ($errorfound) { return }
	UninstallAppleApplicationSupport
	if ($errorfound) { return }
	UninstallAppleMobileDeviceSupport
	if ($errorfound) { return }
	UninstallBonjour
	if ($errorfound) { return }
	UninstalliPhoneConfigurationUtility
	if ($errorfound) { return }
	UninstallTomcat
	if ($errorfound) { return }
	RemoveGAPMPOSConfigFiles
	if ($errorfound) { return }
	RemovePrinterDrivers
}

#MAIN

$curdate = Get-Date -Format g
echo "Script started: $curdate" | Tee-Object -Append $logfile

if ($rollback -eq "yes") {
	DoRollback
} else {
	DoInstall
}

if ($errorfound) {
	$curdate = Get-Date -Format g
	echo "Script ran unsuccessfully." | Tee-Object -Append $logfile
	echo "Script ended: $curdate" | Tee-Object -Append $logfile
	exit(1)
} else {
	$curdate = Get-Date -Format g
	echo "Script ran successfully." | Tee-Object -Append $logfile
	echo "Script ended: $curdate" | Tee-Object -Append $logfile
	exit(0)
}