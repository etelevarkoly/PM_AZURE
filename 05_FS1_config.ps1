# variables
# the extra drives are the last in the list, and we have only one,
# so the index [-1] catches this extra drive
$DISKS = Get-Disk
$EXTRA_DISK_ID = $DISKS[-1].Number
$DC1_PRIVATE_IP = "172.16.0.10"
$FS1_PRIVATE_IP = "172.16.0.11"
$GOOGLE_DNS = "8.8.8.8"
$DOMAIN_NAME = "project.local"
$DOMAIN_LOGIN = "project\etele.varkoly"
$PW = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($DOMAIN_LOGIN, $PW)

# partitioning and formatting extra disk
# Write-Host "partitioning and formatting extra disk..."
Initialize-Disk -Number $EXTRA_DISK_ID -PartitionStyle GPT
New-Partition -DiskNumber $EXTRA_DISK_ID -Driveletter "S" -UseMaximumSize
Format-Volume -DriveLetter "S" -FileSystem NTFS -Confirm: $false

# set DNS for core srv
# because I know the static IP, I can grab the NIC ID to 
# change the DNS settings. 
# if you can RDP or SSH, you can use sconfig to set this.
$IFIndex = (Get-NetIPAddress | Where-Object IPAddress -eq $FS1_PRIVATE_IP).InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex $IFIndex -ServerAddresses ($DC1_PRIVATE_IP,$GOOGLE_DNS)

# enter core srv to domain
Add-Computer -DomainName $DOMAIN_NAME -DomainCredential $cred -Restart

# check domain
# systeminfo | findstr /i "domain"
