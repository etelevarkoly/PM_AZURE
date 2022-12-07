# variables 

$PW = "Password123!"
$SECURE_PW = ConvertTo-SecureString $PW -AsPlainText -Force

# list available windows server roles and features
# Get-WindowsFeature

# install AD DS
# Write-Host "installing AD Domain Services..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# list modules for AD DS deployment 
# Get-Command -Module ADDSDeployment

# install root forest for AD DS 
# don't bother with the errors, it's just windows.
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "project.local" `
-DomainNetbiosName "PROJECT" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-SafeModeAdministratorPassword $SECURE_PW `
-Force:$true

Restart-Computer -Force

# check if everything is ok
# Get-ADDomain

