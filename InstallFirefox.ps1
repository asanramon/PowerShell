#Author: Angelo San Ramon
#Date: June 2, 2013
#Purpose: Script to lockdown Firefox settings.

param (
	[String]$build
)

function ShowUsage {
	Write-Host "Invalid argument."
	Write-Host "Syntax:"
	Write-Host "	SetFirefoxPreferences.ps1 -build [prod | dev]"
}

function SetLanguage {
	$languageCode = (Get-Culture).Name
	switch ($languageCode) {
		"en-US" { $langpref = 'user_pref("general.useragent.locale", "en-US");' } 
		"en-CA" { $langpref = 'user_pref("general.useragent.locale", "en-CA");' }
		"fr-CA" { $langpref = 'user_pref("general.useragent.locale", "fr-CA");' }
		"es-PR" { $langpref = 'user_pref("general.useragent.locale", "es-PR");' }
		"en-GB" { $langpref = 'user_pref("general.useragent.locale", "en-GB");' }
		"fr-FR" { $langpref = 'user_pref("general.useragent.locale", "fr-FR");' }
		"it-IT" { $langpref = 'user_pref("general.useragent.locale", "it-IT");' }
		"en-IE" { $langpref = 'user_pref("general.useragent.locale", "en-IE");' }
		"ja-JP" { $langpref = 'user_pref("general.useragent.locale", "ja-JP");' }
		"zh-CN" { $langpref = 'user_pref("general.useragent.locale", "zh-CN");' }
		"zh-HK" { $langpref = 'user_pref("general.useragent.locale", "en-US");' }
		default { $langpref = 'user_pref("general.useragent.locale", "en-US");' }
	}

	Get-Content("$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js") | ForEach-Object {$_ -replace '^.*"general.useragent.locale".*$',($langpref)} | Set-Content("$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js.tmp")
	Copy-Item -Path '$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js.tmp' -Destination '$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js' -Force
	Remove-Item '$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js.tmp'
}

#MAIN

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition

#Check parameter
$build = $build.ToLower()
if ($build.ToLower() -ne "dev" -and $build.ToLower() -ne "prod") {
	ShowUsage
	exit
}

#Copy pre-configured profile
if (!(Test-Path "$env:ProgramFiles\Mozilla Firefox\defaults\Profile")){
	Copy-Item "$scriptdir\Profile" "$env:ProgramFiles\Mozilla Firefox\defaults\Profile" -Recurse
}
Copy-Item -Path "$scriptdir\Profile\override.ini" -Destination "$env:ProgramFiles\Mozilla Firefox"

#Set Homepage.
if($build -eq "dev") {
	$homepage = 'user_pref("browser.startup.homepage", "https://storesportalstage.gap.com");'
}
else {
	$homepage = 'user_pref("browser.startup.homepage", "https://storesportal.gap.com");'
}

Get-Content("$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js") | 
	ForEach-Object {$_ -replace '^.*"browser.startup.homepage".*$',($homepage)} | Set-Content("$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js.tmp")
Copy-Item -Path "$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js.tmp" -Destination "$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js" -Force
Remove-Item "$env:ProgramFiles\Mozilla Firefox\defaults\Profile\prefs.js.tmp"
SetLanguage