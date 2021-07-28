#!/usr/bin/env bash

read -p "Enter Name for a new Resource Group on Azure [AKS]: " AKS_RESOURCE_GROUP
export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}
read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}
read -p "Enter Name of Public IP Resource [aks-public-ip-c3smonkey]: " PIP_RESOURCE_GROUP
export PIP_RESOURCE_GROUP=${PIP_RESOURCE_GROUP:-aks-public-ip-c3smonkey}
PS3='Please enter your choice: '
options=("Start Cluster" "Stop Cluster" "Show Cluster" "Show Public-IP" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Start Cluster")
            echo "Start Cluster"
            az aks stop -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME
            break
            ;;
        "Stop Cluster")
            echo "Stop Cluster"
            az aks start -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME
            break
            ;;
        "Show Cluster")
            echo "Show Cluster"
            az aks show --name $AKS_CLUSTER_NAME --resource-group  $AKS_RESOURCE_GROUP
            break
            ;;
         "Show Public-IP")
            echo "Show Public-IP"
            az network public-ip show -g $AKS_RESOURCE_GROUP -n $PIP_RESOURCE_GROUP | jq .ipAddress -r
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



