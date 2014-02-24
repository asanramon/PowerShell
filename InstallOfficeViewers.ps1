#Author: Angelo San Ramon
#Date: 06/07/2013
#Purpose: Installs Office Word, Excel, PowerPoint Viewers.

$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition

$languageCode = (Get-Culture).Name
switch ($languageCode) {
	"en-US" { $lang = "English" ; $langcode = "en-us" } 
	"en-CA" { $lang = "English" ; $langcode = "en-us" }
	"fr-CA" { $lang = "French" ; $langcode = "fr-fr" }
	"es-PR" { $lang = "Spanish" ; $langcode = "es-es" }
	"en-GB" { $lang = "English" ; $langcode = "en-us" }
	"fr-FR" { $lang = "French" ; $langcode = "fr-fr" }
	"it-IT" { $lang = "Italian" ; $langcode = "it-it" }
	"en-IE" { $lang = "English" ; $langcode = "en-us" }
	"ja-JP" { $lang = "Japanese" ; $langcode = "ja-jp" }
	"zh-CN" { $lang = "Chinese" ; $langcode = "zh-cn" }
	"zh-HK" { $lang = "English" ; $langcode = "en-us" }
	default { $lang = "English" ; $langcode = "en-us" }
}

$installdir = $scriptdir + "\" + $lang
Start-Process "$installdir\Wordview_$langcode.exe" "/quiet /passive /norestart" -Wait
Start-Process "$installdir\ExcelViewer.exe" "/quiet /passive /norestart" -Wait
Start-Process "$installdir\PowerPointViewer.exe" "/quiet /passive /norestart" -Wait
