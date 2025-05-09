Azure VM Setup via Portal
This guide outlines how to create and access a Linux VM on Azure using the Azure portal.
Prerequisites

Azure account with an active subscription.
SSH key pair (generate with ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa).

Steps

Log in to Azure Portal:

Go to Azure Portal.


Create a Resource Group:

Navigate to Resource groups → Create.
Name: azure-vm-rg.
Region: East US.
Click Review + create → Create.


Create a Virtual Machine:

Go to Virtual machines → Create → Azure virtual machine.
Basics:
Subscription: Your subscription.
Resource group: azure-vm-rg.
Virtual machine name: ubuntu-vm.
Region: East US.
Image: Ubuntu Server 22.04 LTS.
Size: Standard_B1s (1 vCPU, 1 GiB memory).
Authentication type: SSH public key.
Username: azureuser.
SSH public key: Paste the contents of ~/.ssh/id_rsa.pub.


Networking:
Virtual network: Create new (vm-vnet, 10.0.0.0/16).
Subnet: Create new (vm-subnet, 10.0.1.0/24).
Public IP: Create new (vm-public-ip).
NIC NSG: Basic.
Public inbound ports: Allow selected ports (SSH - 22).


Review + create → Create.
Wait for deployment (5-10 minutes).


Configure Network Security Group:

Go to Network security groups → Select ubuntu-vm-nsg.
Inbound security rules → Add.
Source: Any.
Destination port ranges: 22.
Protocol: TCP.
Action: Allow.
Priority: 1000.
Name: AllowSSH.
Click Add.




Access the VM:

Go to Virtual machines → Select ubuntu-vm.
Note the Public IP address (e.g., 20.123.456.789).
Open a terminal and SSH:ssh azureuser@<public-ip>


If prompted, accept the host key.
Verify access with a command like uname -a.


Verify in Portal:

Check Virtual machines → ubuntu-vm → Overview (status: Running).
Check Networking → Confirm SSH rule.
Check Virtual networks → vm-vnet → Confirm subnet.


Clean Up:

To avoid charges, delete the resource group:
Go to Resource groups → azure-vm-rg → Delete resource group.
Confirm deletion.





Notes

Ensure your local firewall allows outbound SSH (port 22).
Save the public IP for SSH access.
For Windows VMs, use RDP instead (port 3389) and configure NSG rules accordingly.

