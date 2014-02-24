$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$logFile = "$scriptdir\$scriptname.log"
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$OSDTargetSystemDrive = $tsenv.Value("OSDTargetSystemDrive")
Add-Content -Path $logFile -Value $OSDTargetSystemDrive -Force
Add-Content -Path $logFile -Value "Dism.exe /Image:$OSDTargetSystemDrive\ /ScratchDir:$OSDTargetSystemDrive\Windows\Temp /Add-Package /PackagePath:fr-fr\Windows8-KB2607607-x86-FRA.cab" -Force
cd $scriptdir
Start-Process "Dism.exe" "/Image:$OSDTargetSystemDrive\ /ScratchDir:$OSDTargetSystemDrive\Windows\Temp /Add-Package /PackagePath:Windows8-KB2607607-x86-FRA.cab" -Wait