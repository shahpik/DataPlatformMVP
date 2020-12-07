#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

function usage()
{
    echo "Usage: $0 args ..."
    echo "  --nsg-name  <string> [required]"
    echo "  --resource-group  <string> [required]"
    echo "  -h, --help                <flag>   [optional]"
    exit 1
}

# declare required arguments
declare nsgName=""
declare rg=""

# set help flag
declare help=0

while [[ "$#" > 0 ]]; do case $1 in
    -e|--nsg-name) nsgName="$2"; shift;;
    -g|--resource-group) rg="$2"; shift;;
    -h|--help) help=1;;
    *) echo "Unknown parameter passed: $1\n"; usage;;
esac; shift; done

# check for -h, --help flag and exit it present
if [ "$help" == 1 ]; then usage; fi;

# Create NSG rules
az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-worker-to-worker" \
    --priority 200 \
    --access Allow \
    --source-address-prefixes "VirtualNetwork" \
    --direction Inbound 

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-control-plane-ssh" \
    --priority 100 \
    --access Allow \
    --source-address-prefixes "13.70.105.50/32" \
    --direction Inbound \
    --destination-port-ranges 22 

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-control-plane-worker-proxy" \
    --priority 110 \
    --access Allow \
    --destination-address-prefixes "13.70.105.50/32" \
    --direction Outbound \
    --destination-port-ranges 5557 

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-worker-to-webapp" \
    --priority 100 \
    --access Allow \
    --destination-address-prefixes "13.75.218.172/32" \
    --direction Outbound  

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-worker-to-sql" \
    --priority 110 \
    --access Allow \
    --destination-address-prefixes "Sql" \
    --direction Outbound 

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-worker-to-storage" \
    --priority 120 \
    --access Allow \
    --destination-address-prefixes "Storage" \
    --direction Outbound 

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-worker-to-worker-outbound" \
    --priority 130 \
    --access Allow \
    --destination-address-prefixes "VirtualNetwork" \
    --direction Outbound 

az network nsg rule create \
    --nsg-name $nsgName \
    --resource-group $rg \
    --name "databricks-worker-to-any" \
    --priority 140 \
    --access Allow \
    --direction Outbound 

