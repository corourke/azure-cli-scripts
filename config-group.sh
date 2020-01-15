#!/usr/bin/env bash
# @author Cameron O'Rourke <cameron.orourke@incorta.com>


AZURE_REGION=westus2
RESOURCE_GROUP=incorta        # makes it easy to delete everything later

# Virtual Networking
VIRTUAL_NET=incortaDLTestNet
VIRTUAL_SUBNET=incortaDLTestSubNet
NET_SEC_GROUP=incortaDLTestNSG

STORAGE_NAME=${RESOURCE_GROUP}storage
FILE_SHARE_NAME=${RESOURCE_GROUP}files
