# Script for creating AD Organization Unit(s)
# and Users

# VARIABLES

$AD_OU_LIST=('PROJECT','Hallgatok','Oktatok','KliensGepek','Csoportok')
$AD_HALLGATOK_LIST=('Gipsz Jakab','Beton Béla')
$AD_OKTATOK_LIST=('Trainer')
$AD_GROUP_LIST=('Oktatok','Hallgatok')
$PW = "Password123!"
$SECURE_PW = ConvertTo-SecureString $PW -AsPlainText -Force

# create organization units
# Write-Host "creating organization units..."
foreach ($i in $AD_OU_LIST) {
    New-ADOrganizationalUnit $i -ProtectedFromAccidentalDeletion $false
}

# create groups
# Write-Host "creating groups for users..."
foreach ($i in $AD_GROUP_LIST) {
    New-ADGroup $i -Path 'OU=Csoportok,DC=project,DC=local' `
        -GroupScope Global
}

# create users and adding them to groups
# Write-Host "creating users and adding them to the groups..."
foreach ($i in $AD_HALLGATOK_LIST) {
    New-ADUser -Name $i `
        -AccountPassword $SECURE_PW `
        -PasswordNeverExpires $true `
        -path 'OU=Hallgatok,DC=project,DC=local'
    Add-ADGroupMember -Identity 'Hallgatok' `
        -Members $i
}

foreach ($i in $AD_OKTATOK_LIST) {
    New-ADUser -Name $i -Path 'OU=Oktatok,DC=project,DC=local' `
        -AccountPassword $SECURE_PW `
        -PasswordNeverExpires $true `
        -Enabled $true
    Add-ADGroupMember -Identity "Domain Admins" `
        -Members $i
}
