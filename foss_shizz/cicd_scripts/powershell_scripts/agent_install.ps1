param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
if ($elevated)
{
# could not elevate, quit
}
 else {
 Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}

Copy-S3Object -BucketName "<<bucket_name>>" -Key "agentInstaller-x86_64.msi" -LocalFile c:\temp\agentInstaller-x86_64.msi

Copy-S3Object -BucketName "<<bucket_name>>" -Key "installer_vista_win7_win8-64.msi" -LocalFile c:\temp\installer_vista_win7_win8-64.msi

cd c:\temp

sleep 60
msiexec /i agentInstaller-x86_64.msi /quiet
sleep 60
msiexec.exe /q /i "installer_vista_win7_win8-64.msi" COMPANY_CODE=<<COMPANY_CODE>> GROUP_NAME="Default"
