# variables 

# AZ uses the first IP address for the default gateway, but otherwise use 
# these to declare and initialize a variable with the def. gateway's IP
$AZ_GATEWAY = (Get-NetIPConfiguration).Ipv4Defaultgateway | Select-Object -ExpandProperty nexthop

# check if DNS role is installed
# Get-WindowsFeature
# Get-WindowsFeature | Where-Object {($_.name -like “DNS”)}

# if not installed run this (but probably it installed with AD DS)
# Install-WindowsFeature DNS -IncludeManagementTools
# DNS primary zone is created when the forest is generated

# define network ID and file entry
Add-DnsServerPrimaryZone -NetworkID "172.16.0.0/16" `
-ZoneName "project.local" `
-ReplicationScope "Forest" `
-PassThru

# add A records
Add-DnsServerResourceRecordA -Name "akarmi.hu" `
-ZoneName "project.local" `
-AllowUpdateAny `
-IPv4Address "172.16.0.10" `
-TimeToLive 01:00:00

Add-DnsServerResourceRecordA -Name "valami.akarmi.hu" `
-ZoneName "project.local" `
-AllowUpdateAny `
-IPv4Address "172.16.0.10" `
-TimeToLive 01:00:00

Add-DnsServerResourceRecordA -Name "server.akarmi.hu" `
-ZoneName "project.local" `
-AllowUpdateAny `
-IPv4Address "172.16.0.10" `
-TimeToLive 01:00:00

# add CNAME records
Add-DnsServerResourceRecordCName -Name "www.akarmi.hu" -HostNameAlias "server.akarmi.hu" -ZoneName "project.local"
Add-DnsServerResourceRecordCName -Name "mail.akarmi.hu" -HostNameAlias "server.akarmi.hu" -ZoneName "project.local"

# check A and CNAME DNS records
# Get-DnsServerResourceRecord -ZoneName "project.local"

# add DNS forwarder ; use GOOGLE DNS if DC DNS cannot resolve
Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru
# check if DNS server is working
Test-DnsServer -IPAddress 172.16.0.10 -ZoneName "project.local"

# check if DHCP server is installed
# Get-WindowsFeature | Where-Object  {($_.name -like “DHCP”)}

# I have to set a static IP for DC (if not set already) 
# edit: static ip set previously.

# check network interface index
# Get-NetIPConfiguration | Select-Object InterfaceIndex
# set static IP (if u're using AZ, then you can set it on the AZ platform)
# New-NetIPAddress -InterfaceIndex 3 -IPAddress 172.16.0.10 -PrefixLength 16 -DefaultGateway 172.16.0.1

# install DHCP server role
# yellow warning msgs are not important, we all know :D
Install-WindowsFeature DHCP -IncludeManagementTools

# after install, a security group has to be created using the netsh command
netsh dhcp add securitygroups

# restart the DHCP service
Write-Host "restarting DHCP server..."
Restart-Service dhcpserver

# IP address assign config
Add-DHCPServerv4Scope -Name “projekt_scope” `
-StartRange 172.16.0.100 `
-EndRange 172.16.0.200 `
-SubnetMask 255.255.255.0 `
-State Active

# set lease time 14 day if you want
# Set-DhcpServerv4Scope -ScopeId 172.168.0.0 -LeaseDuration 14.00:00:00

# authorize DHCP srv to do her stuff in the domain
Set-DHCPServerv4OptionValue -ScopeID 172.16.0.0 `
-DNSDomain "project.local" `
-DNSServer 172.16.0.10 `
-Router $AZ_GATEWAY

# add DHCP to domain 
Add-DhcpServerInDC -DNSName "project.local" -IpAddress 172.16.0.10

# check DHCP scope 
# Get-DhcpServerv4Scope

# check if DHCP is working in DC
# Get-DhcpServerInDC

# if you want to restart DHCP
# Restart-service dhcpserver

# ping 172.16.0.10
