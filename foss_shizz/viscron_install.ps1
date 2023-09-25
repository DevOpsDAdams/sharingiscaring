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
cd c:\
mkdir temp
cd c:\temp\
rm *.txt
$outname = "VisualCron.zip"
$url = "https://www.visualcron.com/files/VisualCron.zip"
Invoke-WebRequest -Uri $url -OutFile $outname
Expand-Archive -Path c:\temp\VisualCron.zip
cd c:\temp\VisualCron
$dirname = (ls -Name) | Out-String
$dirname = $dirname -replace '\s',''
cd $dirname
msiexec /i VisualCron.msi /q INSTALLMODE="1"
Get-Service VisualCron
$servicestatus = (echo $?) | Out-String
$servicestatus = $servicestatus -replace '\s',''
while ($servicestatus -eq 'False'){
  'VisualCron Not Found. Waiting.'
  Get-Service VisualCron
  $servicestatus = (echo $?) | Out-String
  $servicestatus = $servicestatus -replace '\s',''
  Start-Sleep -s 5
}
Get-Service VisualCron
'VisualCron Service Found.'
$vcron = (Test-Path 'C:\Program Files (x86)\VisualCron\VCCommand\') | Out-String
while ($vcron -eq 'False'){
  'Path Not Yet Valid. Waiting.'
  $vcron = (Test-Path 'C:\Program Files (x86)\VisualCron\VCCommand\') | Out-String
  Start-Sleep -s 10
}
'Starting Visual Cron Services.'
Start-Service VisualCron
Start-Sleep -s 10
Get-Service VisualCron
cd 'C:\Program Files (x86)\VisualCron\VCCommand\'
'Activating VisualCron Server'
.\VCCommand --action activate --r <<license_id>> --connectionmode local --username admin
Start-Sleep -Milliseconds 500
cd C:\temp
Stop-Service VisualCron
Expand-Archive .\VC-Settings.zip
cd 'C:\Program Files (x86)\VisualCron\settings\'
cp C:\temp\VC-Settings\* .
Start-Service VisualCron
cd 'C:\Program Files (x86)\VisualCron\VCCommand\'
'Attempting Reactivation VisualCron Server'
.\VCCommand --action activate --r <<license_id>> --connectionmode local --username admin
Start-Sleep -Seconds 5
'VisualCron Installation Complete'
echo $null >> c:\temp\complete.txt
exit
