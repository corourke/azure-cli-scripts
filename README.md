Azure CLI Scripts to create demonstration instances

Assumes that you have an account on Azure, and have installed the Azure CLI onto your local machine.

First, login to your Azure account from the shell:

```bash
$ az login
```

Then run the `main.sh` script to create a resource group, virtual network, network security group, public IP, storage account, file share, and VM.

After the VM has been created, you can SSH to it:

```bash
ssh ${VM_ADMIN_USERNAME}@${VM_IP_ADDR}
```
