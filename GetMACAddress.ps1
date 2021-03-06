Clear-Host
$username = "S08028CLK2.stores.gap.com\administrator"
$password = ConvertTo-SecureString -String "password" -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($username, $password)

$wireless_mac_address = $null
$colNetworkAdapter = Get-WmiObject -Namespace root\CIMV2 -Class Win32_NetworkAdapterConfiguration -Credential $pscredential -Impersonation Impersonate -ComputerName S08028CLK2.stores.gap.com | Where {$_.IPEnabled -eq $true -and $_.Caption -like "*Wireless*"}
foreach ($adapter in $colNetworkAdapter) {
	Write-Host $adapter.MACAddress
	Write-Host $adapter.IPAddress
}