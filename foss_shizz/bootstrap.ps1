Import-Module Dism

$featureSet = "IIS-DefaultDocument", "IIS-DirectoryBrowsing", "IIS-HttpErrors", "IIS-StaticContent", "IIS-HttpRedirect", "IIS-HttpLogging", "IIS-HttpCompressionStatic", "IIS-RequestFiltering", "IIS-BasicAuthentication", "IIS-ClientCertificateMappingAuthentication", "IIS-DigestAuthentication", "IIS-IISCertificateMappingAuthentication", "IIS-Security", "IIS-URLAuthorization", "IIS-WindowsAuthentication", "NetFx4Extended-ASPNET45", "IIS-NetFxExtensibility45", "IIS-ASPNET45", "IIS-ISAPIExtensions", "IIS-ISAPIFilter"

foreach ($feature in featureSet) {
  Enable-WindowsOptionalFeature -Online -FeatureName $feature
}

Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?LinkId=863265" -OutFile NDP472-KB4054530-x86-x64-AllOS-ENU.exe

.\NDP472-KB4054530-x86-x64-AllOS-ENU.exe /q /passive 

restart-computer -Force
