#!/usr/bin/env bash

#export PIP_RESOURCE_GROUP=aks-public-ip-c3smonkey
#export AKS_RESOURCE_GROUP=AKS
#export AKS_CLUSTER_NAME=aks-c3smonkey
#export LOCATION=eastus2
#export NODE_COUNT=2
#export NODE_SIZE=Standard_D1_V2
#export CONTAINER_REGISTRY=c3smonkey

echo "Create AKS Cluster Press Enter for default values"
read -p "Enter Name for a new Resource Group on Azure [AKS]: " AKS_RESOURCE_GROUP
export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}
read -p "Enter Location [eastus2]: " LOCATION
export LOCATION=${LOCATION:-eastus2}
echo "The Azure Resource Group $AKS_RESOURCE_GROUP on location $LOCATION will be created"
echo
echo "Do you wish to continue ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          echo "Create $AKS_RESOURCE_GROUP group $LOCATION location"
          az group create --name $AKS_RESOURCE_GROUP --location $LOCATION
          echo "$AKS_RESOURCE_GROUP group created on location $LOCATION"; break;;
        No ) exit;;
    esac
done


echo "Create Cluster in Resource $AKS_RESOURCE_GROUP in location $LOCATION"
read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}
read -p "Enter Nodes need for the Cluster [2]: " NODE_COUNT
export NODE_COUNT=${NODE_COUNT:-2}
read -p "Enter Nodes VM Size [Standard_D1_V2]: " NODE_SIZE
export NODE_SIZE=${NODE_SIZE:-Standard_D1_V2}
echo "Create AKS CLuster $AKS_CLUSTER_NAME with $NODE_COUNT nodes with size $NODE_SIZE"
echo
echo "Do you wish to continue ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          az aks create --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --node-count $NODE_COUNT --node-vm-size $NODE_SIZE --enable-addons monitoring --generate-ssh-keys
          echo "AKS CLuster $AKS_CLUSTER_NAME created with $NODE_COUNT nodes"; break;;
        No ) exit;;
    esac
done

read -p "Enter Public IP Name [aks-public-ip-c3smonkey]: " PIP_RESOURCE_GROUP
export PIP_RESOURCE_GROUP=${PIP_RESOURCE_GROUP:-aks-public-ip-c3smonkey}
echo "Create Public IP for $AKS_RESOURCE_GROUP with name $PIP_RESOURCE_GROUP for Cluster $AKS_CLUSTER_NAME"
echo
echo "Do you wish to continue ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          az network public-ip create \
              --resource-group $AKS_RESOURCE_GROUP \
              --name $PIP_RESOURCE_GROUP \
              --sku Standard \
              --allocation-method static
          echo "Public IP created for $AKS_RESOURCE_GROUP with name $PIP_RESOURCE_GROUP"
          CLIENT_ID=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $AKS_RESOURCE_GROUP | jq -r .identity.principalId)
          SUB_ID=$(az account show --query "id" --output tsv)
          echo "Assign role for $CLIENT_ID and subscriptions $SUB_ID for $AKS_RESOURCE_GROUP"
          az role assignment create --role "Virtual Machine Contributor" --assignee $CLIENT_ID --scope /subscriptions/$SUB_ID/resourceGroups/$AKS_RESOURCE_GROUP
          echo "Role assigned for subscriptions $SUB_ID"
          echo "Show public IP $PIP_RESOURCE_GROUP for cluster $AKS_RESOURCE_GROUP"
          az network public-ip show -g $AKS_RESOURCE_GROUP -n $PIP_RESOURCE_GROUP | jq .ipAddress -r; break;;
        No ) exit;;
    esac
done

echo "Create Container Registry for Cluster $AKS_CLUSTER_NAME in Resource Group $AKS_RESOURCE_GROUP"
read -p "Enter Name for Container Registry [c3smonkey]: " CONTAINER_REGISTRY
export CONTAINER_REGISTRY=${CONTAINER_REGISTRY:-c3smonkey}
echo "Create Container Registry $CONTAINER_REGISTRY for Cluster $AKS_CLUSTER_NAME in Resource Group $AKS_RESOURCE_GROUP "
echo
echo "Do you wish to continue ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          az acr create --resource-group $AKS_RESOURCE_GROUP --name $CONTAINER_REGISTRY --sku Standard
          az aks update -n $AKS_CLUSTER_NAME -g $AKS_RESOURCE_GROUP --attach-acr $CONTAINER_REGISTRY
          echo "Enjoy your AKS Cluster"
          az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME
          echo "Update local ~/.kube/config for cluster $AKS_CLUSTER_NAME"
          echo "you can login to the Container Registry with :"
          echo "az acr login --name $CONTAINER_REGISTRY "; break;;
        No ) exit;;
    esac
done



