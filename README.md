# Launch and Access a Virtual Machine on Azure

A project to launch a Linux VM on Azure, configure network settings, and access it via SSH.

# Project Structure
Create the following directory structure:

    azure-vm/
    ├── deploy_vm.sh
    ├── test_vm.sh
    ├── README.md
    └── azure-vm-setup.md

## Features
- Creates an Ubuntu 22.04 VM using Azure CLI or portal.
- Configures VNet, subnet, and NSG with SSH access.
- Tests VM creation and connectivity.
- Documents manual setup via Azure portal.

## Files
- `deploy_vm.sh`: Script to deploy VM with Azure CLI.
- `test_vm.sh`: Script to verify VM and SSH access.
- `azure-vm-setup.md`: Manual setup guide for Azure portal.

## Setup
1. Install Azure CLI: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`.
2. Log in: `az login`.
3. Generate SSH key: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa`.
4. Deploy VM: `bash deploy_vm.sh`.
5. Test: `bash test_vm.sh`.
6. Verify in Azure Portal and delete: `az group delete --name azure-vm-rg --yes --no-wait`.


