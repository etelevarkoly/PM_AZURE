# SV3 RÜ - Projektmunka 01
# Azure AD DS + CORE SRV + W10 CLIENT DEPLOY

# these scripts does not require parameters, just run and have fun

# before running this script, first log in to Azure from your terminal
# f.e.: az login --use-device-code 

# SCRIPT FOR DEPLOYING VMs IN AZURE

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
$02_AD_DS_config="wget https://raw.githubusercontent.com/etelevarkoly/PM_AZURE/master/02_AD_DS_config.ps1 -outfile C:\02_AD_DS_config.ps1"
$03_DC1_DNS_DHCP_config="wget https://raw.githubusercontent.com/etelevarkoly/PM_AZURE/master/03_DC1_DNS_DHCP_config.ps1 -outfile C:\03_DC1_DNS_DHCP_config.ps1"
$04_DC1_OU_USERS="wget https://raw.githubusercontent.com/etelevarkoly/PM_AZURE/master/04_DC1_OU_USERS.ps1 -outfile C:\04_DC1_OU_USERS.ps1"
$05_FS1_config="wget https://raw.githubusercontent.com/etelevarkoly/PM_AZURE/master/05_FS1_config.ps1 -outfile C:\05_FS1_config.ps1"
$06_FS1_folders_SMB="wget https://raw.githubusercontent.com/etelevarkoly/PM_AZURE/master/06_FS1_folders_SMB.ps1 -outfile C:\06_FS1_folders_SMB.ps1"
$07_W10_config="wget https://raw.githubusercontent.com/etelevarkoly/PM_AZURE/master/07_W10_config.ps1 -outfile C:\07_W10_config.ps1"

# create VNET and SUBNET
Write-Host "creating VNET and SUBNET..."
az network vnet create --name $VNET `
--address-prefix 172.16.0.0/16 `
--subnet-name $SUBNET `
--subnet-prefix 172.16.0.0/24
Write-Host "VNET and SUBNET created."

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
Write-Host "DC1 deploy OK."

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
Write-Host "FS1 deploy OK."

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
Write-Host "W10 client deploy OK."

# set ip config for DC1
Write-Host "setting up DC1 VM ip config..."
$DC1_NIC= $VM_DC1 + "VMNic"
$DC1_IP_Config= "ipconfig" + $VM_DC1
az network nic ip-config update `
--name $DC1_IP_Config `
--nic-name $DC1_NIC `
--private-ip-address $DC1_PRIVATE_IP
Write-Host "DC1 ip config OK."

# set ip config for FS1
Write-Host "setting up FS1 VM ip config..."
$FS1_NIC= $VM_FS1 + "VMNic"
$FS1_IP_Config= "ipconfig" + $VM_FS1
az network nic ip-config update `
--name $FS1_IP_Config `
--nic-name $FS1_NIC `
--private-ip-address $FS1_PRIVATE_IP
Write-Host "FS1 ip config OK."

# set ip config for W10 client
Write-Host "setting up W10 CLIENT VM ip config..."
$W10_NIC= $VM_CLIENT + "VMNic"
$W10_IP_Config= "ipconfig" + $VM_CLIENT
az network nic ip-config update `
--name $W10_IP_Config `
--nic-name $W10_NIC `
--private-ip-address $W10_PRIVATE_IP
Write-Host "w10 client ip config OK."


# insert wget to download scripts to vms
# download AD DS config script
Write-Host "downloading malware..."
az vm run-command invoke --name $VM_DC1 --command-id RunPowerShellScript --scripts $02_AD_DS_config

# download DC DNS & DHCP config script
az vm run-command invoke --name $VM_DC1 --command-id RunPowerShellScript --scripts $03_DC1_DNS_DHCP_config

# download DC OU & user manage script
az vm run-command invoke --name $VM_DC1 --command-id RunPowerShellScript --scripts $04_DC1_OU_USERS

# download FS1 config & disk script
az vm run-command invoke --name $VM_FS1 --command-id RunPowerShellScript --scripts $05_FS1_config

# download FS1 folder and SMB script
az vm run-command invoke --name $VM_FS1 --command-id RunPowerShellScript --scripts $06_FS1_folders_SMB

# download w10 client config script
az vm run-command invoke --name $VM_CLIENT --command-id RunPowerShellScript --scripts $07_W10_config


# run scripts on VMs
# AD DS config
Write-Host "running scripts on VMs..."
az vm run-command invoke --name $VM_DC1 --command-id RunPowerShellScript --scripts "C:\02_AD_DS_config.ps1"

Write-Host "AD DS script done."
Write-Host "wait some time (estimated wait time: 8min) for DC1 to restart..."
Start-Sleep 480

# DC1 dns and dhcp config script
Write-Host "running DC1 dns dhcp script..."
az vm run-command invoke --name $VM_DC1 --command-id RunPowerShellScript --scripts "C:\03_DC1_DNS_DHCP_config.ps1"

# DC1 OU and User creator script
Write-Host "running DC1 ou and user script..."
az vm run-command invoke --name $VM_DC1 --command-id RunPowerShellScript --scripts "C:\04_DC1_OU_USERS.ps1"

# FS1 config script
Write-Host "running FS1 config script..."
az vm run-command invoke --name $VM_FS1 --command-id RunPowerShellScript --scripts "C:\05_FS1_config.ps1"

Write-Host "wait some time for FS1 to restart..."
Start-Sleep 120

# FS1 folder and SMB script
Write-Host "running FS1 folder and SMB script..."
az vm run-command invoke --name $VM_FS1 --command-id RunPowerShellScript --scripts "C:\06_FS1_folders_SMB.ps1"

# w10 client script
Write-Host "running w10 client config script..."
az vm run-command invoke --name $VM_CLIENT --command-id RunPowerShellScript --scripts "C:\07_W10_config.ps1"

# w10 client restarts here, so chill
Write-Host "scripts done."
Write-Host "wait a bit, w10 client restarting..."
Write-Host "process completed (and probably failed). done."

