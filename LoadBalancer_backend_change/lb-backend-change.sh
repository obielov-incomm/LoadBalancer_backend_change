#!/bin/bash

# this script uses jq to parse JSON, so you neet to download it using
# sudo apt-get install jq
#
# ./lb-backend-change.sh -o operation -g ResourceGroupName -l LoadBalancerName -n VirtuaMachineName
# For example:
#./lb-backend-change.sh -o add -g ob-lb-ph-demo-rsg -l lb-demo-lb -n lb-demo-vm2 

resourceGroupName=""
loadBalancerName=""
vmName=""

while test $# -gt 0
do
    case "$1" in
    -o|--op)        shift ; operation=$1
            ;;
    -g|--rg)        shift ; resourceGroupName=$1
            ;;
    -n|--vmname)    shift ; vmName=$1
            ;;
    -l|--lb)        shift ; loadBalancerName=$1
            ;;
    esac
    shift
done

if [ -z "$resourceGroupName" ]; then
  echo "resourceGroupName not specified"
  exit 1
fi

if [ -z "$loadBalancerName" ]; then
  echo "loadBalancerName not specified"
  exit 1
fi

function LoadBalancerAddOrRemove() {
  if [ -z "$vmName" ]; then
    echo "vmName not specified"
    exit 1
  fi

  echo "Getting NIC for VM $vmName"
  nicID=$(az vm show -g $resourceGroupName -n $vmName | jq '.networkProfile.networkInterfaces[0].id')
# remove double quotes at start/end
  nicID="${nicID%\"}"
  nicID="${nicID#\"}"

  nicName=$(echo $nicID | cut -f9 -d '/')

# get id of LB BE pool
  echo "Getting LoadBalancer $loadBalancerName"
  lbbeID=$(az network lb address-pool list  -g $resourceGroupName --lb-name $loadBalancerName | jq '.[0].id')
  # remove double quotes at start/end
  lbbeID="${lbbeID%\"}"
  lbbeID="${lbbeID#\"}"

  ipconfigName=$(az network nic ip-config list --nic-name $nicName --resource-group $resourceGroupName  | jq '.[0].name')
# remove double quotes at start/end
  ipconfigName="${ipconfigName%\"}"
  ipconfigName="${ipconfigName#\"}"

  if [ "$operation" == "remove" ]; then
    # remove nic from lb by passing nothing as the id
    echo "Removing NIC from LoadBalancer..."
    az network nic ip-config address-pool remove -g $resourceGroupName --nic-name $nicName --address-pool $lbbeID  --ip-config-name $ipconfigName
  fi

  if [ "$operation" == "add" ]; then
    # add nic to lb
    echo "Adding NIC to LoadBalancer..."
    az network nic ip-config address-pool add -g $resourceGroupName --nic-name $nicName --address-pool $lbbeID  --ip-config-name $ipconfigName
  fi
}

case "$operation" in
   "remove")    LoadBalancerAddOrRemove
          ;;
   "add")       LoadBalancerAddOrRemove
          ;;
   *)           echo "bad -o switch"
          ;;
esac
