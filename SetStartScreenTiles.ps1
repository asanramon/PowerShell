param (
	[String]$env
)

#Check parameter
$env = $env.ToLower()
if ($env.ToLower() -ne "dev" -and $env.ToLower() -ne "prod") {
	Write-Host "Invalid argument."
	ShowUsage
}

# Copy appsFolder.itemdata-ms to default profile so that all new users will have the same tiles configuration.
Copy-Item -Path C:\SSE\Tiles\appsFolder.itemdata-ms -Force `
		  -Destination C:\Users\Default\AppData\Local\Microsoft\Windows\appsFolder.itemdata-ms
$file = Get-Item C:\Users\Default\AppData\Local\Microsoft\Windows\appsFolder.itemdata-ms
$file.Attributes = "ReadOnly"

#Create Oblytile shortcuts directory in default profile.
if (!(Test-Path "C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile")){
	New-Item -ItemType directory -Path "C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile"
}

$languageCode = (Get-Culture).Name
switch ($languageCode) {
	"en-US" { CopyAmericaTiles } 
	"en-CA" { CopyAmericaTiles }
	"fr-CA" { CopyAmericaTiles }
	"es-PR" { CopyAmericaTiles }
	"en-GB" { CopyEuropeTiles }
	"fr-FR" { CopyEuropeTiles }
	"it-IT" { CopyEuropeTiles }
	"en-IE" { CopyEuropeTiles }
	"ja-JP" { CopyAsiaTiles }
	"zh-CN" { CopyAsiaTiles }
	"zh-HK" { CopyAsiaTiles }
	default { CopyCommonTiles }
}

reg load HKU\ntuser C:\Users\Default\NTUSER.DAT
reg add HKEY_USERS\ntuser\Software\Microsoft\Windows\CurrentVersion\RunOnce
reg add HKEY_USERS\ntuser\Software\Microsoft\Windows\CurrentVersion\RunOnce `
	/v Tiles /t REG_SZ /d 'C:\Windows\System32\attrib.exe %USERPROFILE%\appdata\local\microsoft\windows\appsfolder.itemdata-ms -R'
reg unload HKU\ntuser

function CopyAmericaTiles {
	CopyCommonTiles
}

function CopyEuropeTiles {
	CopyCommonTiles
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM - Breakfix- OblyTile00000007.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM - Breakfix- OblyTile00000007.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM - INT- OblyTile00000008.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM - INT- OblyTile00000008.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM- OblyTile00000009.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM- OblyTile00000009.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM - Sys- OblyTile00000010.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM - Sys- OblyTile00000010.lnk'
	
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000007\Launcher.vbs-Europe" `
			  -Destination 'C:\Program Files\OblyTile\00000007\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000008\Launcher.vbs-Europe" `
			  -Destination 'C:\Program Files\OblyTile\00000008\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000009\Launcher.vbs-Europe" `
			  -Destination 'C:\Program Files\OblyTile\00000009\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000010\Launcher.vbs-Europe" `
			  -Destination 'C:\Program Files\OblyTile\00000010\Launcher.vbs'
}

function CopyAsiaTiles {
	CopyCommonTiles
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM - Breakfix- OblyTile00000007.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM - Breakfix- OblyTile00000007.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM - INT- OblyTile00000008.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM - INT- OblyTile00000008.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM- OblyTile00000009.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM- OblyTile00000009.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\SIM - Sys- OblyTile00000010.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\SIM - Sys- OblyTile00000010.lnk'
	
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000007\Launcher.vbs-Asia" `
			  -Destination 'C:\Program Files\OblyTile\00000007\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000008\Launcher.vbs-Asia" `
			  -Destination 'C:\Program Files\OblyTile\00000008\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000009\Launcher.vbs-Asia" `
			  -Destination 'C:\Program Files\OblyTile\00000009\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000010\Launcher.vbs-Asia" `
			  -Destination 'C:\Program Files\OblyTile\00000010\Launcher.vbs'
}

function CopyCommonTiles {
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\CES- OblyTile00000000.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\CES- OblyTile00000000.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\EOS- OblyTile00000001.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\EOS- OblyTile00000001.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\FMR- OblyTile00000002.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\FMR- OblyTile00000002.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Focus- OblyTile00000003.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Focus- OblyTile00000003.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\LPRM- OblyTile00000004.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\LPRM- OblyTile00000004.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Manager Self Service- OblyTile00000005.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Manager Self Service- OblyTile00000005.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Personnel Management- OblyTile00000006.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Personnel Management- OblyTile00000006.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Store Performance- OblyTile00000011.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Store Performance- OblyTile00000011.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Store Support- OblyTile00000012.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Store Support- OblyTile00000012.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Success Factors- OblyTile00000013.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Success Factors- OblyTile00000013.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Taleo- OblyTile00000014.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Taleo- OblyTile00000014.lnk'
	Copy-Item -Path 'C:\SSE\Tiles\OblyTile\Application Shortcuts\Vista Plus Reports- OblyTile00000015.lnk' `
			  -Destination 'C:\Users\Default\AppData\Local\Microsoft\Windows\Application Shortcuts\Oblytile\Vista Plus Reports- OblyTile00000015.lnk'
	
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000000\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000000\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000001\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000001\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000002\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000002\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000003\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000003\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000004\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000004\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000005\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000005\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000006\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000006\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000011\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000011\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000012\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000012\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000013\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000013\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000014\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000014\Launcher.vbs'
	Copy-Item -Path "C:\SSE\Tiles\OblyTile\Launchers\00000015\Launcher.vbs-$env" `
			  -Destination 'C:\Program Files\OblyTile\00000015\Launcher.vbs'
}

function ShowUsage {
	Write-Host "Syntax:"
	Write-Host "	SetStartScreenTiles.ps1 -env [prod | dev]"
}