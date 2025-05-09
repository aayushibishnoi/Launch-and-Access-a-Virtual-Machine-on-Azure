#!/bin/bash

# Script to deploy an Azure VM with SSH access

# Variables
RESOURCE_GROUP="azure-vm-rg"
LOCATION="eastus"
VNET_NAME="vm-vnet"
SUBNET_NAME="vm-subnet"
NSG_NAME="vm-nsg"
PUBLIC_IP_NAME="vm-public-ip"
NIC_NAME="vm-nic"
VM_NAME="ubuntu-vm"
VM_SIZE="Standard_B1s"
IMAGE="Ubuntu2204"
ADMIN_USER="azureuser"
SSH_KEY="$HOME/.ssh/id_rsa.pub"

# Check if Azure CLI is installed
echo "Checking for Azure CLI..."
if ! command -v az >/dev/null 2>&1; then
    echo "FAIL: Azure CLI not found. Install it with 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'."
    exit 1
fi
echo "PASS: Azure CLI found"

# Check if logged in to Azure
echo "Checking Azure login..."
if ! az account show >/dev/null 2>&1; then
    echo "FAIL: Not logged in to Azure. Run 'az login'."
    exit 1
fi
echo "PASS: Logged in to Azure"

# Create resource group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION
if [ $? -eq 0 ]; then
    echo "PASS: Resource group created"
else
    echo "FAIL: Resource group creation failed"
    exit 1
fi

# Create virtual network
echo "Creating virtual network..."
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefix 10.0.0.0/16 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix 10.0.1.0/24
if [ $? -eq 0 ]; then
    echo "PASS: Virtual network created"
else
    echo "FAIL: Virtual network creation failed"
    exit 1
fi

# Create network security group
echo "Creating network security group..."
az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name $NSG_NAME
if [ $? -eq 0 ]; then
    echo "PASS: Network security group created"
else
    echo "FAIL: Network security group creation failed"
    exit 1
fi

# Create NSG rule for SSH
echo "Creating NSG rule for SSH..."
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name $NSG_NAME \
    --name AllowSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access Allow \
    --source-address-prefix '*' \
    --direction Inbound
if [ $? -eq 0 ]; then
    echo "PASS: SSH rule created"
else
    echo "FAIL: SSH rule creation failed"
    exit 1
fi

# Create public IP
echo "Creating public IP..."
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IP_NAME \
    --sku Standard
if [ $? -eq 0 ]; then
    echo "PASS: Public IP created"
else
    echo "FAIL: Public IP creation failed"
    exit 1
fi

# Create network interface
echo "Creating network interface..."
az network nic create \
    --resource-group $RESOURCE_GROUP \
    --name $NIC_NAME \
    --vnet-name $VNET_NAME \
    --subnet $SUBNET_NAME \
    --network-security-group $NSG_NAME \
    --public-ip-address $PUBLIC_IP_NAME
if [ $? -eq 0 ]; then
    echo "PASS: Network interface created"
else
    echo "FAIL: Network interface creation failed"
    exit 1
fi

# Create VM
echo "Creating virtual machine..."
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --size $VM_SIZE \
    --image $IMAGE \
    --admin-username $ADMIN_USER \
    --ssh-key-values $SSH_KEY \
    --nic $NIC_NAME
if [ $? -eq 0 ]; then
    echo "PASS: Virtual machine created"
else
    echo "FAIL: Virtual machine creation failed"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(az network public-ip show --resource-group $RESOURCE_GROUP --name $PUBLIC_IP_NAME --query ipAddress --output tsv)
echo "VM Public IP: $PUBLIC_IP"
echo "You can SSH to the VM with: ssh $ADMIN_USER@$PUBLIC_IP"
