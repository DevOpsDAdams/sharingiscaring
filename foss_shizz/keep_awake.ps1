while (1) {
    $wsh = New-Object -ComObject Wscript.Shell 
    $wsh.SendKeys('+{F15}')
    Start-Sleep -seconds 59
}
