# install file-stuff
# Write-Host "installing file share resource manager..."
Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools
# Write-Host "installing file share data deduplication stuff..."
Install-WindowsFeature -Name FS-Data-Deduplication

# have to install AD DS, otherwise cannot use Get-ADUser
# cmdlet to set up quotas.
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# creating folders
$folders=@('Hallgatok','Oktatok','Vizsga','Users')
foreach ($i in $folders) {
    New-Item -Type Directory `
    -Path "S:\Shares\$i"
}

# creating SMB share
New-SmbShare -name Hallgatok_SMB `
-Path "S:\Shares\Hallgatok" `
-FullAccess "administrators" `
-ChangeAccess "Hallgatok"

New-SmbShare -name Oktatok_SMB `
-Path "S:\Shares\Oktatok" `
-FullAccess "administrators" `
-ChangeAccess "Oktatok"

New-SmbShare -name Vizsga_SMB `
-Path "S:\Shares\Vizsga" `
-FullAccess "administrators" `
-ChangeAccess "Hallgatok" `
-ReadAccess "Oktatok"

New-SmbShare -name Users_SMB `
-Path "S:\Shares\Users" `
-FullAccess "administrators" , "Hallgatok" , "Oktatok"

# create quota template 
# idk if soft-limit is better here
New-FsrmQuotaTemplate -Name "PM_QUOTA_500MB" `
-Size 500MB `
-Threshold (New-FsrmQuotaThreshold -Percentage 90) `
-Description "500MB max; threshold at 450MB"

# check fsrm quota
# Get-Fsrmquotatemplate | Where-Object name -match PM*

# -expandproperty kell, különben hibára fut, ez stringként adja vissza a neveket
$ADUsers = Get-ADUser -Filter * | Select-Object -ExpandProperty Name
foreach ($ADUser in $ADUsers) {
    New-item -ItemType Directory -path "S:\Shares\Users\$ADUser"
    $PATH = "S:\Shares\Users\$ADUser"
    New-FsrmQuota -Path $PATH -Description "500MB max; threshold at 450MB" `
    -Template "PM_QUOTA_500MB"
}

# define home drive and home folders for users
# "~" + $ADUser = error.
foreach ($ADUser in $ADUsers) {
    Set-ADUser $ADUser `
    -HomeDrive "Z:" `
    -HomeDirectory "\\FS1\Users_SMB\$ADUser"
}

# check quotas
# Get-FsrmQuota

# enable network discovery and file & print share
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

