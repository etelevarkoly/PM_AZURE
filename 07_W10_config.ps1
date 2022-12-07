# configure W10 client

# variables

$DC1_PRIVATE_IP = "172.16.0.10"
$W10_PRIVATE_IP = "172.16.0.20"
$GOOGLE_DNS = "8.8.8.8"
$DOMAIN_NAME = "project.local"
$DOMAIN_LOGIN = "project\etele.varkoly"
$PW = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($DOMAIN_LOGIN, $PW)

# set up dns
$IFIndex = (Get-NetIPAddress | Where-Object IPAddress -eq $W10_PRIVATE_IP).InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex $IFIndex -ServerAddresses ($DC1_PRIVATE_IP,$GOOGLE_DNS)

# enable network discovery and file & print share
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# enter client to domain
Add-Computer -DomainName $DOMAIN_NAME -DomainCredential $cred -Restart
