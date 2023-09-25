$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer
Write-Host “IE Enhanced Security Configuration (ESC) has been disabled.” -ForegroundColor Green

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled false
$server = $Env:Computername
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -ComputerName $server -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
Start-Process -filepath "C:\windows\regedit.exe" -ArgumentList "/s C:\temp\SSL_TLS.reg"
$DefenderKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection"
Set-ItemProperty -Path $DefenderKey -Name "ForcePassiveMode" -Type DWORD -Value 1

Get-CimInstance -ClassName 'Win32_NetworkAdapterConfiguration' | Where-Object -Property 'TcpipNetbiosOptions' -ne $null | Invoke-CimMethod -MethodName 'SetTcpipNetbios' -Arguments @{ 'TcpipNetbiosOptions' = [UInt32](2) }