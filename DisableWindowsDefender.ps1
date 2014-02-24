#Author: Angelo San Ramon
#Date: June 8, 2013
#Purpose: Script to disable Windows Defender Service.

#Create a scheduled task running under "NT Authority\System" account to disable Windows Defender service.
$action = New-ScheduledTaskAction -Execute "net stop windefend"
$trigger = New-ScheduledTaskTrigger