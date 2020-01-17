#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>

# Modify these per external instance
: "${PUBLIC_NET:=${RESOURCE_GROUP}_public}" # public network name
: "${PUBLIC_DNS_PREFIX:=${RESOURCE_GROUP}}"

# Azure Dsv3 series use premium storage (fast SSDs) and Intel processors
# Standard_D4s_v3 -- 4 vCPU, 16GB RAM, 32GB storage
# Standard_D8s_v3 -- 8 vCPU, 32GB RAM, 64GB storage
: "${MACHINE_SIZE:=Standard_D4s_v3}"

: "${VM_NAME:=i${RESOURCE_GROUP}_vm}"
: "${VM_ADMIN_USERNAME:=vm_admin}"
: "${VM_ADMIN_PASSWORD:=vm_admin!234}"

Prompt PUBLIC_NET PUBLIC_DNS_PREFIX MACHINE_SIZE VM_NAME VM_ADMIN_USERNAME VM_ADMIN_PASSWORD
