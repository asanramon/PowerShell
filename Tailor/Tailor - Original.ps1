#Author: Angelo San Ramon
#Date: June 9, 2013
#Purpose: Configure the manager workstation.

$tailorversion = "1.0"
$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$logfile = "$scriptdir\" + $scriptname.Split(".")[0] + ".log"
$errorfound = $null

function Write-Log {
	param (
		[String]$message
	)
	
	$currentdate = (Get-Date).ToString("MM/dd/yyyy hh:mm:ss")
	Add-Content -Path $logfile -Value ("$currentdate` -- $message") -Force
}

function ValidateStoreInformation {
	$global:errorfound = $false
	
	#Validate store number
	[int]$store_number = $null
	[Int16]::TryParse($txtBoxStoreNumber.Text, [ref]$store_number)
	if ($store_number -eq 0 -or ($store_number -lt 1 -or $store_number -gt 9999)) {
		[System.Windows.Forms.MessageBox]::Show("Invalid store number.", "Error")
		$txtBoxStoreNumber.Select()
		$txtBoxStoreNumber.SelectAll()
		$global:errorfound = $true
		return
	}

	#Validate brands
	$bln_found_brand = $false
	ForEach ($brand in $comboBoxBrands.Items) {
		if ($comboBoxBrands.Text -eq $brand) {
			$bln_found_brand = $true
			break
		}
	}
	if ($bln_found_brand -eq $false) {
		[System.Windows.Forms.MessageBox]::Show("Invalid brand.", "Error")
		$comboBoxBrands.Select()
		$comboBoxBrands.SelectAll()
		$global:errorfound = $true
		return
	}
	
	#Validate country
	$bln_found_country = $false
	ForEach ($country in $comboBoxCountry.Items) {
		if ($comboBoxCountry.Text -eq $country) {
			$bln_found_country = $true
			break
		}
	}
	if ($bln_found_country -eq $false) {
		[System.Windows.Forms.MessageBox]::Show("Invalid country.", "Error")
		$comboBoxCountry.Select()
		$comboBoxCountry.SelectAll()
		$global:errorfound = $true
		return
	}
	
	#Validate time zones
	$bln_found_timezone = $false
	ForEach ($timezone in $comboBoxTimezone.Items) {
		if ($comboBoxTimezone.Text -eq $timezone) {
			$bln_found_timezone = $true
			break
		}
	}
	if ($bln_found_timezone -eq $false) {
		[System.Windows.Forms.MessageBox]::Show("Invalid timezone.", "Error")
		$comboBoxTimezone.Select()
		$comboBoxTimezone.SelectAll()
		$global:errorfound = $true
		return
	}
}

function DisableControls {
	$radioBtnProd.Enabled = $false
	$radioButtonDev.Enabled = $false
	$txtBoxStoreNumber.Enabled = $false
	$textBoxStationNumber.Enabled = $false
	$comboBoxBrands.Enabled = $false
	$comboBoxCountry.Enabled = $false
	$comboBoxTimezone.Enabled = $false
	$btnProceed.Enabled = $false
	$btnShutdown.Enabled = $false
}

function EnableProgressBar {
	$lblProgressBar.Visible = $true
	$lblProgressMessage.Visible = $true
	$progressBar.Visible = $true
}

function SetAutoLogon {
	$localadminid = "$computername\Administrator"
	$localadminpassword = "password"

	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1 -Force
	} else {
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1 -Force
	}
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value $localadminid -Force
	} else {
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value $localadminid -Force
	}
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $localadminpassword -Force
	} else {
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $localadminpassword -Force
	}
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name Tailor -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name Tailor -Value "Powershell -ExecutionPolicy Unrestricted -File $scriptdir\Tailor.ps1"
	} else {
		New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion' -Name RunOnce -Force
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name Tailor -Value "Powershell -ExecutionPolicy Unrestricted -File $scriptdir\Tailor.ps1"
	}
}

function UnsetAutoLogon {
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 0 -Force
	} else {
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 0 -Force
	}
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value "" -Force
	} else {
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value "" -Force
	}
	Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -ErrorAction SilentlyContinue | Out-Null
	if ( $? -eq "True" ) {
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "" -Force
	} else {
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value "" -Force
	}
}

function WriteToRegistryStoreInfo {
	$Error.Clear()
	try {
		$lblProgressMessage.Text = "Phase 1: Writing store information to registry..."
		$progressBar.PerformStep()
		Write-Log "Phase 1: Writing store information to registry..."
		sleep 5
		
		$regpath = "HKLM:\Software\GAPBuild\Platform"
		New-Item -Path HKLM:\Software\GAPBuild -Name Platform -Force | Out-Null
		New-ItemProperty $regpath -Force -Name TailorVersion -PropertyType String -Value $tailorversion | Out-Null
		$storenumber = [int]$txtBoxStoreNumber.Text
		New-ItemProperty $regpath -Force -Name StoreNumber -PropertyType String -Value $storenumber | Out-Null
		New-ItemProperty $regpath -Force -Name Brand -PropertyType String -Value $comboBoxBrands.Text | Out-Null
		New-ItemProperty $regpath -Force -Name Country -PropertyType String -Value $comboBoxCountry.Text | Out-Null
		New-ItemProperty $regpath -Force -Name Timezone -PropertyType String -Value $comboBoxTimezone.Text | Out-Null
		New-ItemProperty $regpath -Force -Name MachineType -PropertyType String -Value "Manager Workstation" | Out-Null
		$buildenv = if ($radioBtnProd.Checked) { "Production" } else { "Development" }
		New-ItemProperty $regpath -Force -Name BuildEnvironment -PropertyType String -Value $buildenv | Out-Null
	} catch {
		Write-Log $Error
	}
}

function JoinToDomain {
	Import-Module ActiveDirectory
	
	$lblProgressMessage.Text = "Phase 1: Renaming and adding computer to domain..."
	Write-Log "Phase 1: Renaming and adding computer to domain..."
	sleep 2
	
	switch ($comboBoxBrands.Text) {
		"United States" {$countryou = "America"}
		"Canada (English)" {$countryou = "America"}
		"Canada (French)" {$countryou = "America"}
		"Puerto Rico" {$countryou = "America"}
		"United Kingdom" {$countryou = "Europe"}
		"France" {$countryou = "Europe"}
		"Italy" {$countryou = "Europe"}
		"Japan" {$countryou = "Asia"}
		"China (PRC)" {$countryou = "Asia"}
		"China (Hong Kong)" {$countryou = "Asia"}
	}
	
	switch ($comboBoxBrands.Text) {
		"GAP" {$bandou = "GP"}
		"GAP Outlet" {$bandou = "GPO"}
		"Banana Republic" {$bandou = "BR"}
		"Banana Republic Factory" {$bandou = "BRF"}
		"Old Navy" {$bandou = "ON"}
		"Piperlime" {$bandou = "PL"}
		"Athleta" {$bandou = "ATH"}
	}
	
	$storenumber = ([int]$txtBoxStoreNumber.Text).ToString("00000")
	if ($radioBtnProd.Checked) {
		$password = ConvertTo-SecureString "password" -AsPlainText -Force
		$pscredential = New-Object System.Management.Automation.PSCredential("adminuser", $password)
		$searchfilter = ("Name -like `"S" + $storenumber + "MGR*`"")
		$searchbase = "OU=Stores,DC=usa,DC=gaptest,DC=com"
		$computername_prefix = "S"
		$domain = "usa.gaptest.com"
		$oupath = "OU=$brandou,OU=ManagerWorkstations,OU=Computers,OU=$countryou,OU=Stores,DC=usa,DC=gaptest,DC=com"
	} else {
		$password = ConvertTo-SecureString "password" -AsPlainText -Force
		$pscredential = New-Object System.Management.Automation.PSCredential("adminuser", $password)
		$searchfilter = ("Name -like `"Q" + $storenumber + "MGR*`"")
		$searchbase = "OU=Stores,DC=usa,DC=gaptest,DC=com"
		$computername_prefix = "D"
		$domain = "usa.gaptest.com"
		$oupath = "OU=$brandou,OU=ManagerWorkstations,OU=Computers,OU=$countryou,OU=Stores,DC=usa,DC=gaptest,DC=com"
	}
	
	$colADComputers = Get-ADComputer -Filter $searchfilter -SearchBase $searchbase -Credential $pscredential -ErrorAction SilentlyContinue
	if ($colADComputers -ne $null) {
		$computernames = $colADComputers | ForEach-Object {$_.Name}
		for ($i = 1; $i -lt 100; $i++) {
			if ( $computernames -notcontains ($computername_prefix + $storenumber + "MGR" + $i)) {
				$computername = ($computername_prefix + $storenumber + "MGR" + $i)
				break
			}
		}
		Add-Computer -Credential $pscredential -DomainName $domain -NewName $computername -OUPath $oupath -Force
		if ($?) {
			$lblProgressMessage.Text = "Phase 1: Computer successfully joined to domain..."
			$progressBar.PerformStep()
			Write-Log "Phase 1: Computer successfully joined to domain..."
		} else {
			$lblProgressMessage.Text = "Phase 1: Computer did not successfully joined to domain..."
			$progressBar.PerformStep()
			Write-Log "Phase 1: Computer did not successfully joined to domain..."
		}
	} else {
		$computername = $computername_prefix + $storenumber + "MGR1"
		Rename-Computer -NewName $computername -Force
		if ($?) {
			$lblProgressMessage.Text = "Phase 1: Computer successfully renamed..."
			$progressBar.PerformStep()
			Write-Log "Phase 1: Computer successfully renamed..."
		} else {
			$lblProgressMessage.Text = "Phase 1: Computer did not successfully renamed..."
			$progressBar.PerformStep()
			Write-Log "Phase 1: Computer did not successfully renamed..."
		}
	}
	
	
	#Reboot
	$lblProgressMessage.Text = "Phase 1: Rebooting for phase 2..."
	$progressBar.PerformStep()
	Write-Log "Phase 1: Rebooting for phase 2..."
	
	#Save current progress bar location
	$progressBar.Value | Out-File -FilePath "$scriptdir\phase2.flag" -Force
	
	SetAutoLogon
	Sleep 5
	Restart-Computer -Force
}

function RestoreSettings {
	$regpath = "HKLM:\Software\GAPBuild\Platform"
	$storenumber = [int]((Get-ItemProperty -Path $regpath -Name StoreNumber).StoreNumber)
	$brand = (Get-ItemProperty -Path $regpath -Name Brand).Brand
	$country = (Get-ItemProperty -Path $regpath -Name Country).Country
	$timezone = (Get-ItemProperty -Path $regpath -Name Timezone).Timezone
	$buildenv = (Get-ItemProperty -Path $regpath -Name BuildEnvironment).BuildEnvironment

	$txtBoxStoreNumber.Text = $storenumber.ToString("00000")
	$comboBoxBrands.Text = $brand
	$comboBoxCountry.Text = $country
	$comboBoxTimezone.Text = $timezone
	if ($buildenv -eq "Production") {
		$radioBtnProd.Checked = $true
		$radioButtonDev.Checked = $false
	} else {
		$radioBtnProd.Checked = $false
		$radioButtonDev.Checked = $true
	}
}

function UpdateGroupPolicy {
	$lblProgressMessage.Text = "Phase 2: Updating group policy..."
	Write-Log "Phase 2: Updating group policy..."
	Start-Process "$env:SystemRoot\System32\gpupdate.exe" "/force" -Wait
	$lblProgressMessage.Text = "Phase 2: Group policy updated..."
	$progressBar.PerformStep()
	Write-Log "Phase 2: Group policy updated..."
}

function BeginTailorPhase1 {
	DisableControls
	EnableProgressBar
	WriteToRegistryStoreInfo
	JoinToDomain
}

function BeginTailorPhase2 {
	$progressBar.Value = [int](Get-Content -Path "$scriptdir\phase2.flag")
	RestoreSettings
	DisableControls
	EnableProgressBar
	UpdateGroupPolicy
}

#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 6/15/2013 12:07 AM
# Generated By: a-an0s34b
########################################################################

#Timezone definitions
$US_Timezones = "(UTC-08:00) Pacific Time (US & Canada)",
				"(UTC-07:00) Mountain Time (US & Canada)",
				"(UTC-06:00) Central Time (US & Canada)",
				"(UTC-05:00) Eastern Time (US & Canada)",
				"(UTC-09:00) Alaska",
				"(UTC-10:00) Hawaii",
				"(UTC-05:00) Indiana (East)",
				"(UTC-07:00) Arizona"
$CA_Timezones = "(UTC-08:00) Pacific Time (US & Canada)",
				"(UTC-07:00) Mountain Time (US & Canada)",
				"(UTC-06:00) Central Time (US & Canada)",
				"(UTC-05:00) Eastern Time (US & Canada)",
				"(UTC-04:00) Atlantic Time (Canada)",
				"(UTC-03:30) Newfoundland"				
$PR_Timezones = "(UTC-04:00) Atlantic Time (Canada)"
$UK_Timezones = "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"
$FR_Timezones = "(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb"
$IT_Timezones = "(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb"
$JP_Timezones = "(UTC+09:00) Osaka, Sapporo, Tokyo"
$CN_Timezones = "(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi"
$HK_Timezones = "(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi"

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects
$TailorForm = New-Object System.Windows.Forms.Form
$lblProgressMessage = New-Object System.Windows.Forms.Label
$lblTitle = New-Object System.Windows.Forms.Label
$btnShutdown = New-Object System.Windows.Forms.Button
$grpBoxEnvironment = New-Object System.Windows.Forms.GroupBox
$radioButtonDev = New-Object System.Windows.Forms.RadioButton
$radioBtnProd = New-Object System.Windows.Forms.RadioButton
$textBoxStationNumber = New-Object System.Windows.Forms.TextBox
$panel1 = New-Object System.Windows.Forms.Panel
$lblStationNumber = New-Object System.Windows.Forms.Label
$comboBoxTimezone = New-Object System.Windows.Forms.ComboBox
$lblProgressBar = New-Object System.Windows.Forms.Label
$txtBoxStoreNumber = New-Object System.Windows.Forms.TextBox
$lblStoreNumber = New-Object System.Windows.Forms.Label
$comboBoxCountry = New-Object System.Windows.Forms.ComboBox
$lblCountry = New-Object System.Windows.Forms.Label
$lblBrands = New-Object System.Windows.Forms.Label
$lblTimezone = New-Object System.Windows.Forms.Label
$comboBoxBrands = New-Object System.Windows.Forms.ComboBox
$progressBar = New-Object System.Windows.Forms.ProgressBar
$btnProceed = New-Object System.Windows.Forms.Button
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$handler_comboBoxTimezone_Click= 
{
#TODO: Place custom script here

}

$handler_comboBoxBrands_Click= 
{
#TODO: Place custom script here

}

$handler_TailorForm_Load= 
{
	if (Test-Path -Path "$scriptdir\phase2.flag") {
		BeginTailorPhase2
		Sleep 60
		$TailorForm.Close()
	}
}

$handler_txtBoxStoreNumber_TextChanged= 
{
#TODO: Place custom script here

}

$handler_txtBoxStoreNumber_Click= 
{
	$txtBoxStoreNumber.SelectAll()
}

$handler_textBoxStationNumber_Click= 
{
	$textBoxStationNumber.SelectAll()
}

$handler_comboBoxTimezone_SelectedIndexChanged= 
{
#TODO: Place custom script here

}

$handler_comboBoxCountry_SelectedIndexChanged= 
{
	switch ($comboBoxCountry.Text) {
		"United States" { $timezones = $US_Timezones }
		"Canada (English)" { $timezones = $CA_Timezones }
		"Canada (French)" { $timezones = $CA_Timezones }
		"Puerto Rico" { $timezones = $PR_Timezones }
		"United Kingdom" { $timezones = $UK_Timezones }
		"France" { $timezones = $FR_Timezones }
		"Italy" { $timezones = $IT_Timezones }
		"Japan" { $timezones = $JP_Timezones }
		"China (PRC)" { $timezones = $CN_Timezones }
		"China (Hong Kong)" { $timezones = $HK_Timezones }
	}
	$comboBoxTimezone.Items.Clear()
	ForEach ($timezone in $timezones) {
		$comboBoxTimezone.Items.Add($timezone)
	}
	$comboBoxTimezone.Text = $comboBoxTimezone.Items[0]
}

$handler_comboBoxCountry_Click= 
{
#TODO: Place custom script here

}

$handler_btnProceed_Click= 
{
	ValidateStoreInformation
	if ($global:errorfound) {
		return
	}
	BeginTailorPhase1
	$TailorForm.Close()
}

$handler_btnShutdown_Click= 
{
	$TailorForm.Close()
}

$handler_comboBoxBrands_SelectedIndexChanged= 
{
#TODO: Place custom script here

}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$TailorForm.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_SizeF = New-Object System.Drawing.SizeF
$System_Drawing_SizeF.Height = 96
$System_Drawing_SizeF.Width = 96
$TailorForm.AutoScaleDimensions = $System_Drawing_SizeF
$TailorForm.AutoScaleMode = 2
$TailorForm.AutoSize = $True
$TailorForm.AutoSizeMode = 0
$TailorForm.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,225)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 745
$System_Drawing_Size.Width = 1352
$TailorForm.ClientSize = $System_Drawing_Size
$TailorForm.DataBindings.DefaultDataSourceUpdateMode = 0
$TailorForm.Font = New-Object System.Drawing.Font("Segoe UI Symbol",15.75,0,3,0)
$TailorForm.FormBorderStyle = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = -196
$System_Drawing_Point.Y = -20
$TailorForm.Location = $System_Drawing_Point
$TailorForm.Name = "TailorForm"
$TailorForm.Text = "Tailor"
$TailorForm.WindowState = 2
$TailorForm.add_Load($handler_TailorForm_Load)

$progressBar.BackColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$progressBar.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 271
$System_Drawing_Point.Y = 628
$progressBar.Location = $System_Drawing_Point
$progressBar.Name = "progressBar"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 48
$System_Drawing_Size.Width = 572
$progressBar.Size = $System_Drawing_Size
$progressBar.TabIndex = 11
$progressBar.Visible = $False
$progressBar.Maximum = 100
$progressBar.Step = 5
$TailorForm.Controls.Add($progressBar)

$lblProgressBar.AutoSize = $True
$lblProgressBar.DataBindings.DefaultDataSourceUpdateMode = 0
$lblProgressBar.Font = New-Object System.Drawing.Font("Segoe UI Symbol",15.75,0,3,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 637
$lblProgressBar.Location = $System_Drawing_Point
$lblProgressBar.Name = "lblProgressBar"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 97
$lblProgressBar.Size = $System_Drawing_Size
$lblProgressBar.TabIndex = 12
$lblProgressBar.Text = "Progress:"
$lblProgressBar.TextAlign = 64
$lblProgressBar.Visible = $False
$TailorForm.Controls.Add($lblProgressBar)

$lblProgressMessage.AutoSize = $True
$lblProgressMessage.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 271
$System_Drawing_Point.Y = 679
$lblProgressMessage.Location = $System_Drawing_Point
$lblProgressMessage.Name = "lblProgressMessage"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 500
$lblProgressMessage.Size = $System_Drawing_Size
$lblProgressMessage.TabIndex = 14
$lblProgressMessage.Text = "Phase 1: "
$lblProgressMessage.Visible = $False
$TailorForm.Controls.Add($lblProgressMessage)

#$lblTitle.Anchor = 15
$lblTitle.AutoSize = $True
$lblTitle.DataBindings.DefaultDataSourceUpdateMode = 0
$lblTitle.FlatStyle = 0
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI Symbol",48,1,3,1)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(255,0,102,204)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 100
$System_Drawing_Point.Y = 1
$lblTitle.Location = $System_Drawing_Point
$lblTitle.Name = "lblTitle"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 86
$System_Drawing_Size.Width = 838
$lblTitle.Size = $System_Drawing_Size
$lblTitle.TabIndex = 0
$lblTitle.Text = "WISE Manager Workstation"
$lblTitle.TextAlign = 32
$TailorForm.Controls.Add($lblTitle)

$btnShutdown.AutoSizeMode = 0
$btnShutdown.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 570
$System_Drawing_Point.Y = 537
$btnShutdown.Location = $System_Drawing_Point
$btnShutdown.Name = "btnShutdown"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 41
$System_Drawing_Size.Width = 112
$btnShutdown.Size = $System_Drawing_Size
$btnShutdown.TabIndex = 8
$btnShutdown.Text = "Shutdown"
$btnShutdown.BackColor = [System.Drawing.Color]::FromArgb(255,240,240,240)
$btnShutdown.UseVisualStyleBackColor = $True
$btnShutdown.add_Click($handler_btnShutdown_Click)
$TailorForm.Controls.Add($btnShutdown)

$grpBoxEnvironment.AutoSize = $True
$grpBoxEnvironment.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 163
$System_Drawing_Point.Y = 130
$grpBoxEnvironment.Location = $System_Drawing_Point
$grpBoxEnvironment.Name = "grpBoxEnvironment"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 107
$System_Drawing_Size.Width = 692
$grpBoxEnvironment.Size = $System_Drawing_Size
$grpBoxEnvironment.TabIndex = 0
$grpBoxEnvironment.TabStop = $False
$grpBoxEnvironment.Text = "Build Environment"
$grpBoxEnvironment.FlatStyle = 3
$TailorForm.Controls.Add($grpBoxEnvironment)

$radioButtonDev.Anchor = 1
$radioButtonDev.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 388
$System_Drawing_Point.Y = 40
$radioButtonDev.Location = $System_Drawing_Point
$radioButtonDev.Name = "radioButtonDev"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 33
$System_Drawing_Size.Width = 167
$radioButtonDev.Size = $System_Drawing_Size
$radioButtonDev.TabIndex = 2
$radioButtonDev.Text = "Development"
$radioButtonDev.UseVisualStyleBackColor = $True
$grpBoxEnvironment.Controls.Add($radioButtonDev)

$radioBtnProd.Anchor = 1
$radioBtnProd.Checked = $True
$radioBtnProd.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 171
$System_Drawing_Point.Y = 40
$radioBtnProd.Location = $System_Drawing_Point
$radioBtnProd.Name = "radioBtnProd"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 33
$System_Drawing_Size.Width = 139
$radioBtnProd.Size = $System_Drawing_Size
$radioBtnProd.TabIndex = 1
$radioBtnProd.TabStop = $True
$radioBtnProd.Text = "Production"
$radioBtnProd.UseVisualStyleBackColor = $True
$grpBoxEnvironment.Controls.Add($radioBtnProd)

$comboBoxTimezone.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxTimezone.Font = New-Object System.Drawing.Font("Segoe UI Symbol",15.75,0,3,0)
$comboBoxTimezone.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 322
$System_Drawing_Point.Y = 450
$comboBoxTimezone.Location = $System_Drawing_Point
$comboBoxTimezone.Name = "comboBoxTimezone"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 38
$System_Drawing_Size.Width = 521
$comboBoxTimezone.Size = $System_Drawing_Size
$comboBoxTimezone.TabIndex = 6
$comboBoxTimezone.Text = "<Select Time Zone>"
$comboBoxTimezone.add_SelectedIndexChanged($handler_comboBoxTimezone_SelectedIndexChanged)
$comboBoxTimezone.add_Click($handler_comboBoxTimezone_Click)
$TailorForm.Controls.Add($comboBoxTimezone)

$txtBoxStoreNumber.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 322
$System_Drawing_Point.Y = 274
$txtBoxStoreNumber.Location = $System_Drawing_Point
$txtBoxStoreNumber.Name = "txtBoxStoreNumber"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 35
$System_Drawing_Size.Width = 69
$txtBoxStoreNumber.Size = $System_Drawing_Size
$txtBoxStoreNumber.TabIndex = 3
$txtBoxStoreNumber.Text = "#####"
$txtBoxStoreNumber.MaxLength = 5
$txtBoxStoreNumber.add_TextChanged($handler_txtBoxStoreNumber_TextChanged)
$txtBoxStoreNumber.add_Click($handler_txtBoxStoreNumber_Click)
$TailorForm.Controls.Add($txtBoxStoreNumber)

$lblStoreNumber.AutoSize = $True
$lblStoreNumber.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 277
$lblStoreNumber.Location = $System_Drawing_Point
$lblStoreNumber.Name = "lblStoreNumber"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 148
$lblStoreNumber.Size = $System_Drawing_Size
$lblStoreNumber.TabIndex = 2
$lblStoreNumber.Text = "Store Number:"
$lblStoreNumber.TextAlign = 64
$TailorForm.Controls.Add($lblStoreNumber)

$comboBoxCountry.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxCountry.FormattingEnabled = $True
$comboBoxCountry.Items.Add("United States")|Out-Null
$comboBoxCountry.Items.Add("Canada (English)")|Out-Null
$comboBoxCountry.Items.Add("Canada (French)")|Out-Null
$comboBoxCountry.Items.Add("Puerto Rico")|Out-Null
$comboBoxCountry.Items.Add("United Kingdom")|Out-Null
$comboBoxCountry.Items.Add("France")|Out-Null
$comboBoxCountry.Items.Add("Italy")|Out-Null
$comboBoxCountry.Items.Add("Japan")|Out-Null
$comboBoxCountry.Items.Add("China (PRC)")|Out-Null
$comboBoxCountry.Items.Add("China (Hong Kong)")|Out-Null
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 322
$System_Drawing_Point.Y = 359
$comboBoxCountry.Location = $System_Drawing_Point
$comboBoxCountry.Name = "comboBoxCountry"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 38
$System_Drawing_Size.Width = 521
$comboBoxCountry.Size = $System_Drawing_Size
$comboBoxCountry.TabIndex = 5
$comboBoxCountry.Text = "<Select Country>"
$comboBoxCountry.add_SelectedIndexChanged($handler_comboBoxCountry_SelectedIndexChanged)
$comboBoxCountry.add_Click($handler_comboBoxCountry_Click)
$TailorForm.Controls.Add($comboBoxCountry)

$lblCountry.AutoSize = $True
$lblCountry.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 362
$lblCountry.Location = $System_Drawing_Point
$lblCountry.Name = "lblCountry"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 91
$lblCountry.Size = $System_Drawing_Size
$lblCountry.TabIndex = 6
$lblCountry.Text = "Country:"
$lblCountry.TextAlign = 64
$TailorForm.Controls.Add($lblCountry)

$lblBrands.AutoSize = $True
$lblBrands.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 483
$System_Drawing_Point.Y = 277
$lblBrands.Location = $System_Drawing_Point
$lblBrands.Name = "lblBrands"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 81
$lblBrands.Size = $System_Drawing_Size
$lblBrands.TabIndex = 4
$lblBrands.Text = "Brands:"
$lblBrands.TextAlign = 64
$TailorForm.Controls.Add($lblBrands)

$lblTimezone.AutoSize = $True
$lblTimezone.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 453
$lblTimezone.Location = $System_Drawing_Point
$lblTimezone.Name = "lblTimezone"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 30
$System_Drawing_Size.Width = 116
$lblTimezone.Size = $System_Drawing_Size
$lblTimezone.TabIndex = 8
$lblTimezone.Text = "Time Zone:"
$lblTimezone.TextAlign = 64
$TailorForm.Controls.Add($lblTimezone)

$comboBoxBrands.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxBrands.FormattingEnabled = $True
$comboBoxBrands.Items.Add("GAP")|Out-Null
$comboBoxBrands.Items.Add("GAP Outlet")|Out-Null
$comboBoxBrands.Items.Add("Banana Republic")|Out-Null
$comboBoxBrands.Items.Add("Banana Republic Factory")|Out-Null
$comboBoxBrands.Items.Add("Old Navy")|Out-Null
$comboBoxBrands.Items.Add("Piperlime")|Out-Null
$comboBoxBrands.Items.Add("Athleta")|Out-Null
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 570
$System_Drawing_Point.Y = 274
$comboBoxBrands.Location = $System_Drawing_Point
$comboBoxBrands.Name = "comboBoxBrands"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 38
$System_Drawing_Size.Width = 273
$comboBoxBrands.Size = $System_Drawing_Size
$comboBoxBrands.TabIndex = 4
$comboBoxBrands.Text = "<Select Brand>"
$comboBoxBrands.add_SelectedIndexChanged($handler_comboBoxBrands_SelectedIndexChanged)
$comboBoxBrands.add_Click($handler_comboBoxBrands_Click)
$TailorForm.Controls.Add($comboBoxBrands)

$btnProceed.AutoSizeMode = 0
$btnProceed.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 370
$System_Drawing_Point.Y = 537
$btnProceed.Location = $System_Drawing_Point
$btnProceed.Name = "btnProceed"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 41
$System_Drawing_Size.Width = 112
$btnProceed.Size = $System_Drawing_Size
$btnProceed.TabIndex = 7
$btnProceed.Text = "Proceed"
$btnProceed.BackColor = [System.Drawing.Color]::FromArgb(255,240,240,240)
$btnProceed.UseVisualStyleBackColor = $False
$btnProceed.add_Click($handler_btnProceed_Click)
$TailorForm.Controls.Add($btnProceed)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $TailorForm.WindowState
#Init the OnLoad event to correct the initial state of the form
$TailorForm.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$TailorForm.ShowDialog()| Out-Null

} #End Function

#MAIN

#Check if user is the local Administrator user.
#if ($env:USERNAME -ne "Administrator") {
#	echo "This script needs to run under the local Administrator account."
#	exit 1
#}

#Call the Function
GenerateForm
