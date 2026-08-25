#Requires -RunAsAdministrator

# --------------------
# Variables
# --------------------
$Username = "david"
$Password = "Replace-With-Your-Password"
$Description = "Local administrator account"

# --------------------
# Check for user
# --------------------
$ExistingUser = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue

if ($null -ne $ExistingUser) {
    Write-Host "User '$Username' already exists. No changes were made."
    exit 0
}

# --------------------
# Create user
# --------------------
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

New-LocalUser `
    -Name $Username `
    -Password $SecurePassword `
    -Description $Description `
    -AccountNeverExpires

# Resolve the local Administrators group by SID so this also works
# on Windows installations where the group name is localized.
$AdministratorsGroup = Get-LocalGroup -SID "S-1-5-32-544"

Add-LocalGroupMember `
    -Group $AdministratorsGroup.Name `
    -Member $Username

Write-Host "User '$Username' was created and added to the local Administrators group."
exit 0