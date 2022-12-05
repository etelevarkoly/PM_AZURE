# configure W10 client

# variables

$DC1_PRIVATE_IP = "172.16.0.10"
$W10_PRIVATE_IP = "172.16.0.20"
$GOOGLE_DNS = "8.8.8.8"
$DOMAIN_NAME = "project.local"
$USER_LOGIN = "etele.varkoly"
$PW = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($USER_LOGIN, $PW)

# set up dns
$IFIndex = (Get-NetIPAddress | Where-Object IPAddress -eq $W10_PRIVATE_IP).InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex $IFIndex -ServerAddresses ($DC1_PRIVATE_IP,$GOOGLE_DNS)

# enable network discovery and file & print share
netsh advfirewall firewall set rule group=”network discovery” new enable=yes
netsh firewall set service type=fileandprint mode=enable profile=all

# enter client to domain
Add-Computer -DomainName $DOMAIN_NAME -DomainCredential $cred -Restart