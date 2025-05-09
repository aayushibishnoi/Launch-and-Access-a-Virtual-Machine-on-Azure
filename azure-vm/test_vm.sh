#!/bin/bash

# Test script for Azure VM Project

# Variables
RESOURCE_GROUP="azure-vm-rg"
VM_NAME="ubuntu-vm"
PUBLIC_IP_NAME="vm-public-ip"

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

# Test 1: Verify VM exists
echo "Testing VM existence..."
if az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --query "provisioningState" --output tsv | grep -q "Succeeded"; then
    echo "PASS: VM exists and is in Succeeded state"
else
    echo "FAIL: VM not found or not in Succeeded state"
    exit 1
fi

# Test 2: Verify NSG rule for SSH
echo "Testing NSG rule for SSH..."
if az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name vm-nsg --query "[?name=='AllowSSH'].{port:destinationPortRange}" --output tsv | grep -q "22"; then
    echo "PASS: SSH rule exists for port 22"
else
    echo "FAIL: SSH rule not found"
    exit 1
fi

# Test 3: Test SSH connectivity
echo "Testing SSH connectivity..."
PUBLIC_IP=$(az network public-ip show --resource-group $RESOURCE_GROUP --name $PUBLIC_IP_NAME --query ipAddress --output tsv)
if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no azureuser@$PUBLIC_IP "echo 'SSH successful'" >/dev/null 2>&1; then
    echo "PASS: SSH connection successful"
else
    echo "FAIL: SSH connection failed"
    exit 1
fi

echo "All tests completed!"
# Note: Resources are not deleted to allow manual verification in Azure Portal
# To delete: az group delete --name $RESOURCE_GROUP --yes --no-wait
