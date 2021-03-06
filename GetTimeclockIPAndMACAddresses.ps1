# Author: Angelo San Ramon
# Date: 09/16/2013
# Purpose: Get the MAC address and IP address of the stores' Windows time clocks.

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$logfile = "$scriptdir\" + $scriptname.Split(".")[0] + ".log"
$failedlog = "$scriptdir\failed.log"
$successlog = "$scriptdir\success.log"

Clear-Host

Write-Host "Timeclock_Hostname			MAC_Address			IP_Address			ISS_IP_Address"
Write-Host "------------------			-----------			----------			--------------"
ForEach ($store_number in (Get-Content -Path $scriptdir\store_list.txt)) {
	For($count = 1; $count -le 9; $count++) {
		$tc_hostname = "S${store_number}CLK${count}.stores.gap.com"
		$username = "$tc_hostname\admin"
		$password = ConvertTo-SecureString -String "password" -AsPlainText -Force
		$pscredential = New-Object System.Management.Automation.PSCredential($username, $password)

		$colNetworkAdapter = Get-WmiObject -Namespace root\CIMV2 -Class Win32_NetworkAdapterConfiguration -Credential $pscredential -Impersonation Impersonate -ComputerName $tc_hostname -ErrorAction SilentlyContinue | Where {$_.IPEnabled -eq $true -and $_.Caption -inotlike "*Wireless*"}
		if($colNetworkAdapter -eq $null) { continue }
		foreach ($adapter in $colNetworkAdapter) {
			$tc_mac_address = $adapter.MACAddress
			$tc_ip_address = $adapter.IPAddress
		}
		
		$iss_hostname = "`$${store_number}ISP1.stores.gap.com"
		$octets = $tc_ip_address.Split(".")
		$octet1 = [int]$octets[0]
		$octet2 = [int]$octets[1]
		$octet3 = ([int]$octets[2]) - 1
		$iss_ip_address = "${octet1}.${octet2}.${octet3}.11"

		Write-Host "$tc_hostname		$tc_mac_address		$tc_ip_address		$iss_ip_address"
	}
}