#Author: Angelo San Ramon
#Date: June 8, 2013
#Purpose: Configure Symantec Endpoint Protection to point to specific server based on IP address range.

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition

#Get first Ethernet interface IP address
$ipaddresses = Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -InterfaceAlias "Ethernet"
$ipaddress = $ipaddresses[0].IPAddress
$octets = $ipaddress.Split(".")
$octet1 = [int]$octets[0]
$octet2 = [int]$octets[1]
$octet3 = [int]$octets[2]
$octet4 = [int]$octets[3]

#Eval first two octets. First two octets determine the server for SEP.
if ($octet1 -eq 10 -and ($octet2 -ge 128 -and $octet2 -le 159)) {
	$syslink = $scriptdir + "\sylink.rcc"
} elseif ($octet1 -eq 10 -and ($octet2 -ge 160 -and $octet2 -le 191)) {
	$syslink = $scriptdir + "\sylink.sdc"
} elseif ($octet1 -eq 10 -and ($octet2 -ge 192 -and $octet2 -le 199)) {
	$syslink = $scriptdir + "\sylink.ja"
} elseif ($octet1 -eq 10 -and ($octet2 -ge 233 -and $octet2 -le 236)) {
	$syslink = $scriptdir + "\sylink.uk"
} elseif ($octet1 -eq 10 -and $octet2 -eq 238) {
	$syslink = $scriptdir + "\sylink.uk"
} elseif ($octet1 -eq 10 -and $octet2 -eq 72) {
	$syslink = $scriptdir + "\sylink.chn"
} else {
	$syslink = $scriptdir + "\sylink.mb"
}

Start-Process ($scriptdir + "\SylinkDrop.exe") ("-silent " + $syslink) -Wait
