$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
Add-Content -Path C:\Temp\WirelessSet.txt -Value "Wireless is set."
Add-Content -Path C:\Temp\WirelessIsSet.txt -Value "$env:SystemRoot\System32\Netsh wlan add profile filename=$scriptdir\NA_GAP_Non-trans.xml user=all >>$env:SystemDrive\Temp\WirelessIsSet.txt"
Start-Process "$env:SystemRoot\System32\Netsh" "wlan add profile filename=$scriptdir\NA_GAP_Non-trans.xml user=all >>$env:SystemDrive\Temp\WirelessIsSet.txt" -Wait
