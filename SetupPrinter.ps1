#Author: Angelo San Ramon
#Date: July 2, 2013
#Purpose: Configure the manager workstation.

#GLOBAL Variables
$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$logfile = "$scriptdir\" + $scriptname.Split(".")[0] + ".log"
$printer_ip_address = $null
$printer_name = $null
$printer_driver = $null
$printer_model = $null
$error_found = $false
$supported_printer_models = @{"IPSiO SP 4300" = "Universal Laser Printer PS3";
	"IPSiO SP 4010" = "Universal Laser Printer PS3";
	"IPSiO SP C320" = "Universal Laser Printer PS3";
	"InfoPrint 1822" = "Universal Laser Printer PS3";
	"Infoprint 1222" = "Universal Laser Printer PS3";
	"Infoprint 1622" = "Universal Laser Printer PS3";
	"Infoprint 1336J" = "Universal Laser Printer PS3";
	"Phaser 8560" = "Xerox Global Print Driver PS";
	"ColorQube 8870" = "Xerox Global Print Driver PS";
	"Phaser 6600DN" = "Xerox Global Print Driver PS";
	"WorkCentre 6605DN" = "Xerox Global Print Driver PS";
	"Lexmark X548" = "Lexmark Universal v2 PS3"}


function Write-Log {
	param (
		[String]$message
	)
	
	$currentdate = (Get-Date).ToString("MM/dd/yyyy hh:mm:ss")
	Add-Content -Path $logfile -Value ("$currentdate` -- $message") -Force
}

function GetIPAddress {
	Write-Log "Determining printer IP address."
	$ip_addresses = Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -InterfaceAlias "Ethernet"
	$ip_address = $ip_addresses[0].IPAddress
	$octets = $ip_address.Split(".")
	$octet1 = $octets[0]
	$octet2 = $octets[1]
	$octet3 = $octets[2]
	$octet4 = $octets[3]

	$languageCode = (Get-Culture).Name
	switch ($languageCode) {
		"en-US" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + [string]([int]$octet3 - 1) + "." + "9" } 
		"en-CA" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + [string]([int]$octet3 - 1) + "." + "9" }
		"fr-CA" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + [string]([int]$octet3 - 1) + "." + "9" }
		"es-PR" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + [string]([int]$octet3 - 1) + "." + "9" }
		"en-GB" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		"fr-FR" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		"it-IT" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		"en-IE" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		"ja-JP" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		"zh-CN" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		"zh-HK" { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
		default { $global:printer_ip_address = $octet1 + "." + $octet2 + "." + $octet3 + "." + "9" }
	}

	#Check if printer is connected.
	Write-Log "Pinging printer connection at $global:printer_ip_address..."
	if (!(Test-Connection $global:printer_ip_address -Quiet)) {
		Write-Log "Unable to ping the printer at $global:printer_ip_address."
		$global:error_found = $true
		return
	}
	Write-Log "Printer IP Address is $global:printer_ip_address"
}

function GetPrinterModel {
	$ipsio_url = "http://" + $printer_ip_address + "/web/guest/en/websys/webArch/header.cgi"
	$infoprint1822_url = "http://" + $printer_ip_address + "/cgi-bin/dynamic/topbar.html"
	$infoprint1622_url = "http://" + $printer_ip_address + "/cgi-bin/dynamic/topFrame.html"
	$infoprint1336_url = "http://" + $printer_ip_address + "/top_head.cgi"
	$other_url = "http://" + $printer_ip_address
	$urls_to_search = @($other_url, $ipsio_url, $infoprint1822_url, $infoprint1622_url, $infoprint1336_url)
	$web = New-Object Net.WebClient
	foreach ($url in $urls_to_search) {
		$printer_found = $false
		$htmlsource = $web.DownloadString($url)
		foreach ($printer in $global:supported_printer_models.Get_Keys()) {
			if ($htmlsource -like "*$printer*") {
				$global:printer_model = $printer
				$global:printer_driver = $global:supported_printer_models.Get_Item($printer)
				$printer_found = $true
				break
			}
		}
		if ($printer_found) {
			return
		}
	}
}

function SetPrinterName {
	$computer_name = $env:COMPUTERNAME
	$global:printer_name = $computer_name.SubString(0,6) + "PRT1"
}

function AddPrinterDevice {
	#Check if printer driver is installed.
	$printer_driver = $global:supported_printer_models.Get_Item("$global:printer_model")
	$Error.Clear()
	echo "Checking if printer driver for $global:printer_model is installed."
	Get-PrinterDriver -Name $printer_driver -ErrorAction SilentlyContinue > $null
	if(!($?)) {
		echo "Driver for $global:printer_model model is not found. Please install the driver first."
		echo $Error
		$global:error_found = $true
		return
	} else {
		echo "Printer driver is installed for $global:printer_model."
	}

	#Create TCP/IP Port
	echo "Checking if printer port $global:printer_ip_address already exist."
	Get-PrinterPort -Name $global:printer_ip_address -ErrorAction SilentlyContinue > $null
	if (!($?)) {
		echo "Printer port $global:printer_ip_address does not exist. Creating new printer port."
		$Error.Clear()
		Add-PrinterPort -Name $global:printer_ip_address -PrinterHostAddress $global:printer_ip_address -ErrorAction SilentlyContinue
		if (!($?)) {
			echo "Error creating new printer port."
			echo $Error
			$global:error_found = $true
			return
		} else {
			echo "Printer port $global:printer_ip_address created successfully."
		}
	} else {
		echo "Printer port $global:printer_ip_address already exist."
	}

	#Check if printer already exist
	echo "Checking if printer device $global:printer_name already exist. If so, delete the device."
	Get-Printer -Name $global:printer_name -ErrorAction SilentlyContinue > $null
	if ($?) {
		echo "Printer device $global:printer_name already exist. Deleting it."
		$Error.Clear()
		Remove-Printer -Name $global:printer_name -ErrorAction SilentlyContinue
		if (!($?)) {
			echo "Error deleting the printer device $global:printer_name."
			echo $Error
			$global:error_found = $true
			return
		}
	}
	echo "Printer device $global:printer_name does not yet exist. Creating new printer device."
	$Error.Clear()
	Add-Printer -Name $global:printer_name -DriverName $global:printer_driver -PortName $global:printer_ip_address -ErrorAction SilentlyContinue
	if (!($?)) {
		echo "Error creating printer device $global:printer_name."
		echo $Error
		$global:error_found = $true
		return
	}
	$global:error_found = $false
}

#MAIN
GetIPAddress
if ($global:error_found) {
	exit 1
}
GetPrinterModel
if ($global:error_found) {
	exit 1
}
SetPrinterName
AddPrinterDevice
if ($global:error_found) {
	exit 1
}