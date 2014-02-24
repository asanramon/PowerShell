foreach ($hostname in Get-Content('C:\Scripts\Powershell\StoresInfo\europe_manager_workstations_unique - Copy.txt')) {
	if (Test-Connection -Quiet -ComputerName $hostname -Count 1) {
		Add-Content -Path C:\Scripts\Powershell\StoresInfo\europe_manager_workstations_unique_final.txt -Value $hostname
	} else {
		Add-Content -Path C:\Scripts\Powershell\StoresInfo\europe_manager_workstations_unreachable.txt -Value $hostname	
	}
}