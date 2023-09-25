param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
if ($elevated)
{
}
 else {
 Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}
cd 'C:\Program Files (x86)\VisualCron\VCCommand\'
.\VCCommand --action activate --r <<license_id>> --connectionmode local --username admin
Unregister-ScheduledJob -Name ActivateVisualCron
