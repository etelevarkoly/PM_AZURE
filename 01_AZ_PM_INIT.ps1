# SV3 RÜ - Projektmunka 01
# Azure AD DS + CORE SRV + W10 CLIENT DEPLOY
# created by Etele

# these scripts does not require parameters, just run and have fun

# before running this script, first log in to Azure from your terminal
# az login --use-device-code 

# SCRIPT FOR INSTALL AD DS, DHCP AND DNS ROLE
# AUTHOR: ETELE VÁRKOLY AND STACKOVERFLOW

Write-Host "Hi bro!"

# set defaults for AZ
az configure --defaults group=RG-user16
az configure --defaults location=westeurope

# variables
$VNET = "etele-pm-vnet1"
$SUBNET = "etele-pm-subnet1"
$VM_DC1 = "DC1"
$VM_FS1 = "FS1"
$VM_CLIENT = "W10Client"
$USER_LOGIN = "etele.varkoly"
$PW = "Password123!"
$DC1_PRIVATE_IP = "172.16.0.10"
$FS1_PRIVATE_IP = "172.16.0.11"
$W10_PRIVATE_IP = "172.16.0.20"

# create VNET and SUBNET
Write-Host "creating VNET and SUBNET..."
az network vnet create --name $VNET `
--address-prefix 172.16.0.0/16 `
--subnet-name $SUBNET `
--subnet-prefix 172.16.0.0/24

# create Win 2019 srv for AD DS
Write-Host "deploying DC1 VM..."
az vm create --name $VM_DC1 `
--image MicrosoftWindowsServer:WindowsServer:2019-datacenter-gensecond:latest `
--size Standard_D2as_v4 `
--authentication-type password `
--admin-username $USER_LOGIN `
--admin-password $PW `
--nsg-rule RDP `
--storage-sku StandardSSD_LRS `
--vnet-name $VNET `
--subnet $SUBNET `
--public-ip-sku Basic `
--public-ip-address-allocation dynamic `
--nic-delete-option Delete `
--os-disk-delete-option Delete `
--eviction-policy Deallocate `
--priority Spot `
--max-price -1

# create core srv
Write-Host "deploying core srv VM..."
az vm create --name $VM_FS1 `
--image MicrosoftWindowsServer:WindowsServer:2019-datacenter-core-g2:latest `
--size Standard_D2as_v4 `
--authentication-type password `
--admin-username $USER_LOGIN `
--admin-password $PW `
--nsg-rule RDP `
--storage-sku StandardSSD_LRS `
--vnet-name $VNET `
--subnet $SUBNET `
--public-ip-sku Basic `
--public-ip-address-allocation dynamic `
--nic-delete-option Delete `
--os-disk-delete-option Delete `
--eviction-policy Deallocate `
--priority Spot `
--max-price -1

# create extra disk for core srv
Write-Host "creating and attaching extra disk for core srv..."
az disk create --name "MEGHALYTO" --sku StandardSSD_LRS --size-gb 4
az vm disk attach --name "MEGHALYTO" --vm-name $VM_FS1

# create W10 Client
Write-Host "deploying W10 client VM..."
az vm create --name $VM_CLIENT `
--image MicrosoftWindowsDesktop:Windows-10:win10-21h2-pro-g2:latest `
--size Standard_D2as_v4 `
--authentication-type password `
--admin-username $USER_LOGIN `
--admin-password $PW `
--nsg-rule RDP `
--storage-sku StandardSSD_LRS `
--vnet-name $VNET `
--subnet $SUBNET `
--public-ip-sku Basic `
--public-ip-address-allocation dynamic `
--nic-delete-option Delete `
--os-disk-delete-option Delete `
--eviction-policy Deallocate `
--priority Spot `
--max-price -1

# set ip config for DC1
Write-Host "setting up DC1 VM ip config..."
$DC1_NIC= $VM_DC1 + "VMNic"
$DC1_IP_Config= "ipconfig" + $VM_DC1
az network nic ip-config update `
--name $DC1_IP_Config `
--nic-name $DC1_NIC `
--private-ip-address $DC1_PRIVATE_IP

# set ip config for FS1
Write-Host "setting up FS1 VM ip config..."
$FS1_NIC= $VM_FS1 + "VMNic"
$FS1_IP_Config= "ipconfig" + $VM_FS1
az network nic ip-config update `
--name $FS1_IP_Config `
--nic-name $FS1_NIC `
--private-ip-address $FS1_PRIVATE_IP

# set ip config for W10 client
Write-Host "setting up W10 CLIENT VM ip config..."
$W10_NIC= $VM_CLIENT + "VMNic"
$W10_IP_Config= "ipconfig" + $VM_CLIENT
az network nic ip-config update `
--name $W10_IP_Config `
--nic-name $W10_NIC `
--private-ip-address $W10_PRIVATE_IP



# insert wget scripts here to download scripts and 
#
#
#
# invoke them on the VMs.





