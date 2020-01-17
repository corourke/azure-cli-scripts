#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>

# initialize scripts
source ./initialize.sh

# --------
# set configuration
source ./config-group.sh
source ./config-vm1.sh

Status "Set default region to ${AZURE_REGION}"
az configure --defaults location=$AZURE_REGION

Status "Create Resource Group"
az group create --name $RESOURCE_GROUP

# --------
Status "Create Virtual Network..."
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VIRTUAL_NET \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $VIRTUAL_SUBNET \
  --subnet-prefix 10.0.88.0/24

Status "Create Network Security Group"
az network nsg create --resource-group $RESOURCE_GROUP --name $NET_SEC_GROUP
  Status "Tie security group to subnet"
  az network vnet subnet update \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VIRTUAL_NET \
    --name $VIRTUAL_SUBNET \
    --network-security-group $NET_SEC_GROUP

  Status "Open Required Ports"
  priority=200 # priority is kind of arbitrary, but must be unique per port
  for port in 22 80 3306 443 4040 5436 6060 6443 7077 7078 7777 8080 8443 9091 9092
  do
    Status "  Port ${port}"
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

Status "Create public IP"
az network public-ip create --resource-group $RESOURCE_GROUP --name $PUBLIC_NET

Status "Create the VM"
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

Status "Add the DNS Name label (prefix)"
# Full DNS will be $PUBLIC_DNS_PREFIX.$AZURE_REGION.cloudapp.azure.com
az network public-ip update -g $RESOURCE_GROUP -n $PUBLIC_NET --dns-name $PUBLIC_DNS_PREFIX
VM_DNS=${PUBLIC_DNS_PREFIX}.${AZURE_REGION}.cloudapp.azure.com
Status "\nDNS name is: ${VM_DNS}\n"

# -------
# Get the public IP address
VM_IP_ADDR=$(az vm list-ip-addresses \
  --query "[?virtualMachine.name=='${VM_NAME}'].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

# SSH into the VM
printf -- "\n${_GREEN}SSH into the VM using:\nssh ${VM_ADMIN_USERNAME}@${VM_DNS}${_NOCOLOR}\n\n"

Status "Create shared storage account"
#STORAGE_NAME=${RESOURCE_GROUP}storage
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name ${STORAGE_NAME} \
  --kind StorageV2 \
  --sku Standard_LRS

Status "Create file share"
STORAGE_CONN_STRING=$(az storage account show-connection-string \
--resource-group $RESOURCE_GROUP \
--name $STORAGE_NAME \
--query 'connectionString' -o tsv)

if [[ $STORAGE_CONN_STRING == "" ]]; then
   printf -- "${_RED}Couldn't retrieve the connection string.${_NOCOLOR}\n"
   exit 1
fi

#FILE_SHARE_NAME=${RESOURCE_GROUP}files
az storage share create \
  --name $FILE_SHARE_NAME \
  --quota 50 \
  --connection-string $STORAGE_CONN_STRING

# Use the file share
STORAGE_KEY=`az storage account keys list --account-name $STORAGE_NAME --query "[0].value" -o tsv`
Status "\n\nConnect to file share with:"
Status "  smb://${STORAGE_NAME}.file.core.windows.net/${FILE_SHARE_NAME}"
Status "  user: $STORAGE_NAME"
Status "  key: ${STORAGE_KEY}"

 # Now ready to start Incorta install
 Status "\nReady to start Incorta install"
