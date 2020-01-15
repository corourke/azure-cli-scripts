#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>


# Modify these per external instance
PUBLIC_NET=incorta_public     # public network name
PUBLIC_DNS_PREFIX=incorta1

# Azure Dsv3 series use premium storage (fast SSDs) and Intel processors
# Standard_D4s_v3 -- 4 vCPU, 16GB RAM, 32GB storage
# Standard_D8s_v3 -- 8 vCPU, 32GB RAM, 64GB storage

MACHINE_SIZE=Standard_D4s_v3

VM_NAME=incorta_vm1                # VM name
VM_ADMIN_USERNAME=vm1_admin         # VM user
VM_ADMIN_PASSWORD='vm1_admin!234'    # VM pass
