#Author: Angelo San Ramon
#Date: June 9, 2013
#Purpose: Configure the manager workstation.
$tailorversion = "1.0"
$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
$scriptname = Split-Path -Leaf $myInvocation.MyCommand.Definition
$errorfound = $null
$computername = $null
$verifycounter = 0

#Set log file path
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$logPath = $tsenv.Value("_SMSTSLogPath") 
$logFile = "$logPath\$($myInvocation.MyCommand).log"

#Turns off SCCM task sequence progress bar.
$oTSProgressUI = New-Object -COMObject "Microsoft.SMS.TSProgressUI"
$oTSProgressUI.CloseProgressDialog()

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
#		[System.Windows.Forms.MessageBox]::Show("Invalid store number.", "Error")
		$labelMessage.Text = "Invalid store number."
		[System.Media.SystemSounds]::Beep.play()
		$txtBoxStoreNumber.Select()
		$txtBoxStoreNumber.SelectAll()
		$global:errorfound = $true
		return
	}

	#Validate workstation number
	if ($textBoxWorkstationNumber.Enabled) {
		[int]$workstation_number = $null
		[Int16]::TryParse($textBoxWorkstationNumber.Text, [ref]$workstation_number)
		if ($workstation_number -eq 0 -or ($workstation_number -lt 1 -or $workstation_number -gt 99)) {
#			[System.Windows.Forms.MessageBox]::Show("Invalid workstation number.", "Error")
			$labelMessage.Text = "Invalid workstation number."
			[System.Media.SystemSounds]::Beep.play()
			$textBoxWorkstationNumber.Select()
			$textBoxWorkstationNumber.SelectAll()
			$global:errorfound = $true
			return
		}
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
#		[System.Windows.Forms.MessageBox]::Show("Invalid brand.", "Error")
		$labelMessage.Text = "Invalid store brand."
		[System.Media.SystemSounds]::Beep.play()
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
#		[System.Windows.Forms.MessageBox]::Show("Invalid country.", "Error")
		$labelMessage.Text = "Invalid country."
		[System.Media.SystemSounds]::Beep.play()
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
#		[System.Windows.Forms.MessageBox]::Show("Invalid timezone.", "Error")
		$labelMessage.Text = "Invalid time zone."
		[System.Media.SystemSounds]::Beep.play()
		$comboBoxTimezone.Select()
		$comboBoxTimezone.SelectAll()
		$global:errorfound = $true
		return
	}
}

function GenerateComputerName {
	$Error.Clear()
	$global:errorfound = $false
	
	try {
		Import-Module ActiveDirectory -ErrorAction SilentlyContinue
	} catch {
		Write-Log "Module import error: $Error"
	}

	Write-Log "Generating computer name..."
	$storenumber = ([int]$txtBoxStoreNumber.Text).ToString("00000")
	if ($radioBtnProd.Checked) {
		$username = "domadmin"
		$password = ConvertTo-SecureString -String "password" -AsPlainText -Force
		$computername_prefix = "S"
	} else {
		$username = "domadmin"
		$password = ConvertTo-SecureString -String "password" -AsPlainText -Force
		$computername_prefix = "Q"
	}
	$pscredential = New-Object System.Management.Automation.PSCredential($username, $password)
	$searchfilter = "Name -like `"" + $computername_prefix + $storenumber + "MGR*`""
	$searchbase = "OU=Stores,DC=usa,DC=gaptest,DC=com"
	$colADComputers = $null
	if ($global:verifycounter -eq 0) {
		$labelMessage.Text = "Querying Active Directory for available workstation number..."
		$labelMessage.Refresh()
		Sleep 3
	}
	$Error.Clear()
	try {
		$colADComputers = Get-ADComputer -Credential $pscredential -Filter $searchfilter -SearchBase $searchbase -ErrorAction SilentlyContinue
	} catch {
		Write-Log "AD query error: $Error"
	}
	if ($colADComputers -ne $null) {
		$computernames = $colADComputers | ForEach-Object {$_.Name}
		for ($i = 1; $i -lt 100; $i++) {
			if ( $computernames -notcontains ($computername_prefix + $storenumber + "MGR" + $i)) {
				$global:computername = ($computername_prefix + $storenumber + "MGR" + $i)
				break
			}
			if ($computername -eq $null) {
				$global:computername = $computername_prefix + $storenumber + "MGR1"			
			}
		}
	} else {
		if ($global:verifycounter -gt 0) {
			$global:computername = $computername_prefix + $storenumber + "MGR" + [int]($textBoxWorkstationNumber.Text)		
			return
		}			
		Write-Log "Failed to verify computer name in AD."
		$labelWorkstationNumber.Enabled = $true
		$textBoxWorkstationNumber.Enabled = $true
		$labelMessage.Text = "Unable to retrieve available workstation number from Active Directory. Please provide workstation number."
		[System.Media.SystemSounds]::Beep.play()
		$textBoxWorkstationNumber.Select()
		$textBoxWorkstationNumber.SelectAll()
		$global:errorfound = $true
	}
	$global:verifycounter += 1
}

function CreateTSVariables {
	switch ($comboBoxCountry.Text) {
		"United States" {$countryOU = "America"; $timezones = $US_Timezones}
		"Canada (English)" {$countryOU = "America"; $timezones = $CA_Timezones}
		"Canada (French)" {$countryOU = "America"; $timezones = $CA_Timezones}
		"Puerto Rico" {$countryOU = "America"; $timezones = $PR_Timezones}
		"United Kingdom" {$countryOU = "Europe"; $timezones = $UK_Timezones}
		"France" {$countryOU = "Europe"; $timezones = $FR_Timezones}
		"Italy" {$countryOU = "Europe"; $timezones = $IT_Timezones}
		"Japan" {$countryOU = "Asia"; $timezones = $JP_Timezones}
		"China (PRC)" {$countryOU = "Asia"; $timezones = $CN_Timezones}
		"China (Hong Kong)" {$countryOU = "Asia"; $timezones = $HK_Timezones}
	}
	
	switch ($comboBoxBrands.Text) {
		"GAP" {$brandOU = "GP"}
		"GAP Outlet" {$brandOU = "GPO"}
		"Banana Republic" {$brandOU = "BR"}
		"Banana Republic Factory" {$brandOU = "BRF"}
		"Old Navy" {$brandOU = "ON"}
		"Piperlime" {$brandOU = "PL"}
		"Athleta" {$brandOU = "ATH"}
	}
	
	if ($radioBtnProd.Checked) {
		$buildenv = "Production"
		$username = "domadmin"
		$password = "password"
		$domain = "DC=usa,DC=gaptest,DC=com"
	} else {
		$buildenv = "Development"
		$username = "domadmin"
		$password = "password"
		$domain = "DC=usa,DC=gaptest,DC=com"
	}
	$tsenv.Value("OSDJoinAccount") = $username
	$tsenv.Value("OSDJoinPassword") = $password
	$tsenv.Value("OSDDomainOUName") = ("LDAP://OU=" + $brandOU + ",OU=ManagerTablet,OU=Computers,OU=" + $countryOU + ",OU=Storesdev," + $domain)
	$tsenv.Value("TSVarBuildEnv") = $buildenv
	$tsenv.Value("TSVarStoreNumber") = ([int]$txtBoxStoreNumber.Text).ToString("00000")
	$tsenv.Value("TSVarBrand") = $comboBoxBrands.Text
	$tsenv.Value("TSVarCountry") = $comboBoxCountry.Text
	$tsenv.Value("TSVarTimeZone") = $timezones.get_Item($comboBoxTimezone.Text)
	$tsenv.Value("TSVarComputerName") = $global:computername
	
	$OSDJoinAccount = $tsenv.Value("OSDJoinAccount")
	$OSDJoinPassword = $tsenv.Value("OSDJoinPassword")
	$OSDDomainOUName = $tsenv.Value("OSDDomainOUName")
	$TSVarBuildEnv = $tsenv.Value("TSVarBuildEnv")
	$TSVarStoreNumber = $tsenv.Value("TSVarStoreNumber")
	$TSVarBrand = $tsenv.Value("TSVarBrand")
	$TSVarCountry = $tsenv.Value("TSVarCountry")
	$TSVarTimeZone = $tsenv.Value("TSVarTimeZone")
	$TSVarComputerName = $tsenv.Value("TSVarComputerName")
	
	Write-Log "OSDJoinAccount: $OSDJoinAccount"
	Write-Log "OSDJoinPassword: $OSDJoinPassword"
	Write-Log "OSDDomainOUName: $OSDDomainOUName"
	Write-Log "TSVarBuildEnv: $TSVarBuildEnv"
	Write-Log "TSVarStoreNumber: $TSVarStoreNumber"
	Write-Log "TSVarBrand: $TSVarBrand"
	Write-Log "TSVarCountry: $TSVarCountry"
	Write-Log "TSVarTimeZone: $TSVarTimeZone"
	Write-Log "TSVarComputerName: $TSVarComputerName"
}

function WriteToRegistryStoreInfo {
	Write-Log "Phase 1: Writing store information to registry..."
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
}

#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 6/15/2013 12:07 AM
# Generated By: a-an0s34b
########################################################################

#Timezone definitions
$US_Timezones = @{"(UTC-08:00) Pacific Time (US & Canada)" = "Pacific Standard Time";
				"(UTC-07:00) Mountain Time (US & Canada)" = "Mountain Standard Time";
				"(UTC-06:00) Central Time (US & Canada)" = "Central Standard Time";
				"(UTC-05:00) Eastern Time (US & Canada)" = "Eastern Standard Time";
				"(UTC-09:00) Alaska" = "Alaskan Standard Time";
				"(UTC-10:00) Hawaii" = "Hawaiian Standard Time";
				"(UTC-05:00) Indiana (East)" = "US Eastern Standard Time";
				"(UTC-07:00) Arizona" = "US Mountain Standard Time"}
$CA_Timezones = @{"(UTC-08:00) Pacific Time (US & Canada)" = "Pacific Standard Time";
				"(UTC-07:00) Mountain Time (US & Canada)" = "Mountain Standard Time";
				"(UTC-06:00) Central Time (US & Canada)" = "Central Standard Time";
				"(UTC-05:00) Eastern Time (US & Canada)" = "Eastern Standard Time";
				"(UTC-04:00) Atlantic Time (Canada)" = "Atlantic Standard Time";
				"(UTC-03:30) Newfoundland" = "Newfoundland Standard Time"}
$PR_Timezones = @{"(UTC-04:00) Georgetown, La Paz, Manaus, San Juan" = "SA Western Standard Time"}
$UK_Timezones = @{"(UTC) Dublin, Edinburgh, Lisbon, London" = "GMT Standard Time"}
$FR_Timezones = @{"(UTC+01:00) Brussels, Copenhagen, Madrid, Paris" = "Romance Standard Time"}
$IT_Timezones = @{"(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna" = "W. Europe Standard Time"}
$JP_Timezones = @{"(UTC+09:00) Osaka, Sapporo, Tokyo" = "(UTC+09:00) Osaka, Sapporo, Tokyo"}
$CN_Timezones = @{"(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi" = "China Standard Time"}
$HK_Timezones = @{"(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi" = "China Standard Time"}

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects
$TailorForm = New-Object System.Windows.Forms.Form
$textBoxWorkstationNumber = New-Object System.Windows.Forms.TextBox
$labelWorkstationNumber = New-Object System.Windows.Forms.Label
$lblTitle = New-Object System.Windows.Forms.Label
$grpBoxEnvironment = New-Object System.Windows.Forms.GroupBox
$radioButtonDev = New-Object System.Windows.Forms.RadioButton
$radioBtnProd = New-Object System.Windows.Forms.RadioButton
$txtBoxStoreNumber = New-Object System.Windows.Forms.TextBox
$lblStoreNumber = New-Object System.Windows.Forms.Label
$lblBrands = New-Object System.Windows.Forms.Label
$comboBoxBrands = New-Object System.Windows.Forms.ComboBox
$lblCountry = New-Object System.Windows.Forms.Label
$comboBoxCountry = New-Object System.Windows.Forms.ComboBox
$lblTimezone = New-Object System.Windows.Forms.Label
$comboBoxTimezone = New-Object System.Windows.Forms.ComboBox
$btnProceed = New-Object System.Windows.Forms.Button
$labelMessage = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$handler_TailorForm_Load= 
{
}

$handler_txtBoxStoreNumber_Click= 
{
	$txtBoxStoreNumber.SelectAll()
}

$handler_textBoxWorkstationNumber_Click= 
{
	$textBoxStationNumber.SelectAll()
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
	$timezones.Keys | %{ $comboBoxTimezone.Items.Add($_) }
	$comboBoxTimezone.Text = $comboBoxTimezone.Items[0]
}

$handler_btnProceed_Click= 
{
	ValidateStoreInformation
	if ($global:errorfound) {
		return
	}
	GenerateComputerName
	CreateTSVariables
	if (!$global:errorfound) {
		$TailorForm.Close()
	}
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
$lblTitle.Text = "WISE Manager Tablet"
$lblTitle.TextAlign = 32
$TailorForm.Controls.Add($lblTitle)

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
$txtBoxStoreNumber.add_Click($handler_txtBoxStoreNumber_Click)
$TailorForm.Controls.Add($txtBoxStoreNumber)

$labelWorkstationNumber.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 530
$System_Drawing_Point.Y = 275
$labelWorkstationNumber.Location = $System_Drawing_Point
$labelWorkstationNumber.Name = "labelWorkstationNumber"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 35
$System_Drawing_Size.Width = 213
$labelWorkstationNumber.Size = $System_Drawing_Size
$labelWorkstationNumber.TabIndex = 14
$labelWorkstationNumber.Text = "Workstation Number:"
$labelWorkstationNumber.TextAlign = 16
$labelWorkstationNumber.Enabled = $false
$labelWorkstationNumber.add_Click($handler_label1_Click)
$TailorForm.Controls.Add($labelWorkstationNumber)

$textBoxWorkstationNumber.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 754
$System_Drawing_Point.Y = 275
$textBoxWorkstationNumber.Location = $System_Drawing_Point
$textBoxWorkstationNumber.Name = "textBoxWorkstationNumber"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 35
$System_Drawing_Size.Width = 34
$textBoxWorkstationNumber.Size = $System_Drawing_Size
$textBoxWorkstationNumber.TabIndex = 15
$textBoxWorkstationNumber.Text = "##"
$textBoxWorkstationNumber.MaxLength = 2
$textBoxWorkstationNumber.Enabled = $false
$textBoxWorkstationNumber.add_Click($handler_textBoxWorkstationNumber_Click)
$TailorForm.Controls.Add($textBoxWorkstationNumber)

$lblBrands.AutoSize = $True
$lblBrands.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 348
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
$System_Drawing_Point.X = 322
$System_Drawing_Point.Y = 345
$comboBoxBrands.Location = $System_Drawing_Point
$comboBoxBrands.Name = "comboBoxBrands"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 38
$System_Drawing_Size.Width = 521
$comboBoxBrands.Size = $System_Drawing_Size
$comboBoxBrands.TabIndex = 4
$comboBoxBrands.Text = "<Select Brand>"
$comboBoxBrands.add_SelectedIndexChanged($handler_comboBoxBrands_SelectedIndexChanged)
$comboBoxBrands.add_Click($handler_comboBoxBrands_Click)
$TailorForm.Controls.Add($comboBoxBrands)

$lblCountry.AutoSize = $True
$lblCountry.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 425
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
$System_Drawing_Point.Y = 422
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

$lblTimezone.AutoSize = $True
$lblTimezone.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 168
$System_Drawing_Point.Y = 503
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

$comboBoxTimezone.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxTimezone.Font = New-Object System.Drawing.Font("Segoe UI Symbol",15.75,0,3,0)
$comboBoxTimezone.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 322
$System_Drawing_Point.Y = 500
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

$btnProceed.AutoSizeMode = 0
$btnProceed.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 470
$System_Drawing_Point.Y = 589
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

$labelMessage.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 225
$System_Drawing_Point.Y = 654
$labelMessage.Location = $System_Drawing_Point
$labelMessage.Name = "labelMessage"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 65
$System_Drawing_Size.Width = 600
$labelMessage.Size = $System_Drawing_Size
$labelMessage.TabIndex = 16
$labelMessage.TextAlign = 32
$TailorForm.Controls.Add($labelMessage)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $TailorForm.WindowState
#Init the OnLoad event to correct the initial state of the form
$TailorForm.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$TailorForm.ShowDialog()| Out-Null

} #End Function

#MAIN

#Call the Function
GenerateForm
