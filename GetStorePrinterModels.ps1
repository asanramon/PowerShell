$supported_printer_models = @("IPSiO SP 4300","IPSiO SP 4010","InfoPrint 1822","Infoprint 1222",
	"Phaser 8560","ColorQube 8870","Phaser 6600DN","WorkCentre 6605DN","Lexmark X548")
$printer_model = $null
$web = New-Object Net.WebClient

$file_path = "C:\Scripts\Powershell\StoresInfo\china_printers.txt"
foreach ($line in (Get-Content "C:\Scripts\Powershell\StoresInfo\china_iss_unique.txt")) {
	$ip_address = $null
	$ip_address = ([System.Net.Dns]::GetHostAddresses($line)).IPAddressToString
	if ($ip_address -eq $null) { continue }
	$octets = $ip_address.Split(".")
	$octet1 = $octets[0]
	$octet2 = $octets[1]
	$octet3 = $octets[2]
	$octet4 = $octets[3]
	$printer_ip_address = $octet1 + "." + $octet2 + "." + [String]([int]$octet3 + 1) + "." + "9"
	if (!(Test-Connection -Quiet -ComputerName $printer_ip_address -Count 1)) { continue }
	$url = "http://" + $printer_ip_address
	$htmlsource = $web.DownloadString($url)
	$printer_found = $false
	foreach ($printer in $supported_printer_models) {
		if ($htmlsource -like "*$printer*") {
			$printer_model = $printer
			$printer_found = $true
			break
		}
	}
	if ($printer_found) {
		$message = "$line|$printer_ip_address|$printer_model" 
		Add-Content -Path $file_path -Value $message
	} else {
		$message = "$line|$printer_ip_address|Unknown" 
		Add-Content -Path $file_path -Value $message
	}
}