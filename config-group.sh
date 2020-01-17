#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>

: "${AZURE_REGION:=westus2}"
: "${RESOURCE_GROUP:=incorta}" # makes it easy to delete everything later

Prompt AZURE_REGION RESOURCE_GROUP

# Virtual Networking
: "${VIRTUAL_NET:=${RESOURCE_GROUP}DLTestNet}"
: "${VIRTUAL_SUBNET:=${RESOURCE_GROUP}DLTestSubNet}"
: "${NET_SEC_GROUP:=${RESOURCE_GROUP}DLTestNSG}"


# Storage and file share
: "${STORAGE_NAME:=${RESOURCE_GROUP}storage}"
: "${FILE_SHARE_NAME:=${RESOURCE_GROUP}files}"

Prompt VIRTUAL_NET VIRTUAL_SUBNET NET_SEC_GROUP STORAGE_NAME FILE_SHARE_NAME
