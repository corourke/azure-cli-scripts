#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>

# initialize scripts
source ./initialize.sh

# --------
# set global configuration
source ./config-group.sh

# Create resource group
az configure --defaults location=$AZURE_REGION

az group create --name $RESOURCE_GROUP

# --------
# Create a virtual network
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VIRTUAL_NET \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $VIRTUAL_SUBNET \
  --subnet-prefix 10.0.88.0/24

# Create Network Security Group
az network nsg create --resource-group $RESOURCE_GROUP --name $NET_SEC_GROUP
  # Tie security group to subnet
  az network vnet subnet update \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VIRTUAL_NET \
    --name $VIRTUAL_SUBNET \
    --network-security-group $NET_SEC_GROUP

  # Open Required Ports
  priority=200 # priority is kind of arbitrary, but must be unique per port
  for port in 22 80 443 4040 5436 6060 6443 7077 7078 7777 8080 8443 9091 9092
  do
    az network nsg rule create \
      --resource-group $RESOURCE_GROUP \
      --nsg-name $NET_SEC_GROUP \
      --name "AllowPort$port" \
      --access allow \
      --protocol Tcp \
      --direction Inbound \
      --priority $priority \
      --source-address-prefix "*" \
      --source-port-range "*" \
      --destination-address-prefix "*" \
      --destination-port-ranges $port
    priority=$(expr $priority + 10)
  done

# --------
# Create the VM
source ./config-vm1.sh

# Create public IP
az network public-ip create --resource-group $RESOURCE_GROUP --name $PUBLIC_NET

# Create the VM
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image CentOS \
  --authentication-type password \
  --admin-username $VM_ADMIN_USERNAME \
  --admin-password $VM_ADMIN_PASSWORD \
  --size $MACHINE_SIZE \
  --vnet-name $VIRTUAL_NET \
  --subnet $VIRTUAL_SUBNET \
  --public-ip-address $PUBLIC_NET \
  --nsg $NET_SEC_GROUP

# Add the DNS Name label (prefix)
# Full DNS will be $PUBLIC_DNS_PREFIX.$AZURE_REGION.cloudapp.azure.com
az network public-ip update -g $RESOURCE_GROUP -n $PUBLIC_NET --dns-name $PUBLIC_DNS_PREFIX
VM_DNS=${PUBLIC_DNS_PREFIX}.${AZURE_REGION}.cloudapp.azure.com

# -------
# Get the public IP address
VM_IP_ADDR=$(az vm list-ip-addresses \
  --query "[?virutalMachine.name==${VM_NAME}].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

# SSH into the VM
echo -e "\n\nSSH into the VM using:\nssh ${VM_ADMIN_USERNAME}@${VM_DNS}"

# Create a shared storage account
#STORAGE_NAME=${RESOURCE_GROUP}storage
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name ${STORAGE_NAME} \
  --kind StorageV2 \
  --sku Standard_LRS

# Create a file share

STORAGE_CONN_STRING=$(az storage account show-connection-string \
--resource-group $RESOURCE_GROUP \
--name $STORAGE_NAME \
--query 'connectionString' -o tsv)

if [[ $STORAGE_CONN_STRING == "" ]]; then
   echo "Couldn't retrieve the connection string."
fi

#FILE_SHARE_NAME=${RESOURCE_GROUP}files
az storage share create \
  --name $FILE_SHARE_NAME \
  --quota 50 \
  --connection-string $STORAGE_CONN_STRING

STORAGE_KEY=`az storage account keys list --account-name $STORAGE_NAME --query "[0].value" -o tsv`
echo -e "\n\nconnect with:\n" \
 "smb://${STORAGE_NAME}.file.core.windows.net/${FILE_SHARE_NAME}\n" \
 "user: $STORAGE_NAME\n" \
 "key: ${STORAGE_KEY}"
