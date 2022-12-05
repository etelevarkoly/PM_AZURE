# variables 

$PW = "Password123!"
$SECURE_PW = ConvertTo-SecureString $PW -AsPlainText -Force

# list available windows server roles and features
# Get-WindowsFeature

# install AD DS
Write-Host "installing AD Domain Services..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# list modules for AD DS deployment 
# Get-Command -Module ADDSDeployment

# install root forest for AD DS 
# don't bother with the errors, it's just windows.
Install-ADDSForest -DomainName “project.local” `
-ForestMode "7" `
-CreateDnsDelegation: $false `
-NoRebootOnCompletion: $True `
-SafeModeAdministratorPassword $SECURE_PW `
-Force

Write-Host "need restart, because this is not linux..."
Restart-Computer -Force

# check if everything is ok
# Get-ADDomain
