$scriptdir = Split-Path -Parent $myInvocation.MyCommand.Definition
Start-Process "install_flash_player_11_plugin.msi" "/qn" -Wait
Copy-Item -Path "$scriptdir\mms.cfg" -Destination "$env:SystemRoot\System32\Macromed\Flash" -Force