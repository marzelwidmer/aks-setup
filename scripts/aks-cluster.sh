#!/usr/bin/env bash

echo "--------------------------------------------"
echo ":: Create or manage your AKS cluster"
echo "--------------------------------------------"


PS3='Please enter your choice: '
options=(
    "AZ Login"
    "Create Resource Group and new AKS Cluster"
    "Delete Resource Group and AKS Cluster"
    "Start Cluster"
    "Stop Cluster"
    "Show Cluster"
    "Show Public-IP"
    "Update .kube/config"
    "Show Nodes"
    "Create DEMO Namespace"
    "Delete DEMO Namespace"
    "Quit"
)
select opt in "${options[@]}"
do
    case $opt in
        "AZ Login")
            echo ""
            echo ": AZ Login :"
            echo "------------"
            az login --use-device-code
            break
            ;;

        "Create Resource Group and new AKS Cluster")
            echo ""
            echo ": Create Cluster :"
            echo "------------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}

            read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
            export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}

            read -p "Enter Public IP Resource Name [aks-public-ip-c3smonkey]: " PIP_RESOURCE_GROUP
            export PIP_RESOURCE_GROUP=${PIP_RESOURCE_GROUP:-aks-public-ip-c3smonkey}

            read -p "Enter Container Registry [c3smonkey]: " CONTAINER_REGISTRY
            export CONTAINER_REGISTRY=${CONTAINER_REGISTRY:-c3smonkey}

            read -p "Enter Location [eastus2]: " LOCATION
            export LOCATION=${LOCATION:-eastus2}

            read -p "Enter Node size [Standard_D1_V2]: " NODE_SIZE
            export NODE_SIZE=${NODE_SIZE:-Standard_D1_V2}

            read -p "Enter Node count [2]: " NODE_COUNT
            export NODE_COUNT=${NODE_COUNT:-2}



            az aks create --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --node-count $NODE_COUNT --node-vm-size $NODE_SIZE --enable-addons monitoring --generate-ssh-keys
            echo "AKS CLuster $AKS_CLUSTER_NAME created with $NODE_COUNT nodes"

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
            az network public-ip show -g $AKS_RESOURCE_GROUP -n $PIP_RESOURCE_GROUP | jq .ipAddress -r

            az acr create --resource-group $AKS_RESOURCE_GROUP --name $CONTAINER_REGISTRY --sku Standard
            az aks update -n $AKS_CLUSTER_NAME -g $AKS_RESOURCE_GROUP --attach-acr $CONTAINER_REGISTRY

            echo "Enjoy your AKS Cluster"
            az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME

            echo "Update local ~/.kube/config for cluster $AKS_CLUSTER_NAME"
            echo "you can login to the Container Registry with :"
            echo "az acr login --name $CONTAINER_REGISTRY "

            break
            ;;
        "Delete Resource Group and AKS Cluster")
            echo ""
            echo ": Delete Resource Group :"
            echo "-------------------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}
            az group delete --name $AKS_RESOURCE_GROUP
            break
            ;;


        "Start Cluster")
            echo ""
            echo ": Start Cluster :"
            echo "-----------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}

            read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
            export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}

            az aks start -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME
            break
            ;;

        "Stop Cluster")
            echo ""
            echo ": Stop Cluster :"
            echo "----------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}

            read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
            export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}

            az aks stop -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME
            break
            ;;

        "Show Cluster")
            echo ""
            echo ": Show Cluster: "
            echo "----------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}

            read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
            export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}

            az aks show --name $AKS_CLUSTER_NAME --resource-group  $AKS_RESOURCE_GROUP
            break
            ;;

         "Show Public-IP")
            echo ""
            echo ": Show Public-IP :"
            echo "------------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}

            read -p "Enter Public IP Resource Name [aks-public-ip-c3smonkey]: " PIP_RESOURCE_GROUP
            export PIP_RESOURCE_GROUP=${PIP_RESOURCE_GROUP:-aks-public-ip-c3smonkey}

            az network public-ip show -g $AKS_RESOURCE_GROUP -n $PIP_RESOURCE_GROUP | jq .ipAddress -r
            break
            ;;

          "Update .kube/config")
            echo ""
            echo ": Copy Credentials from AKS :"
            echo "-----------------------------"

            read -p "Enter Resource Group Name [AKS]: " AKS_RESOURCE_GROUP
            export AKS_RESOURCE_GROUP=${AKS_RESOURCE_GROUP:-AKS}

            read -p "Enter Cluster Name [aks-cluster-c3smonkey]: " AKS_CLUSTER_NAME
            export AKS_CLUSTER_NAME=${AKS_CLUSTER_NAME:-aks-cluster-c3smonkey}

            az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME
            echo "~/.kube/config for cluster $AKS_CLUSTER_NAME is updated"
            break
            ;;

         "Show Nodes")
            echo ""
            echo ": Show Nodes :"
            echo "-------------------------"
            kubectl get nodes
            break
            ;;

         "Create DEMO Namespace")
            echo ""
            echo ": Create Namespace DEMO :"
            echo "-------------------------"
            echo ""
            echo ": Current Namespaces :"
            echo ""
            kubectl get ns
            echo ""
            echo ": Perform Create Namespace :"
            kubectl create ns demo
            kubectl config set-context --current --namespace demo
            echo ""
            echo ": Current Namespaces :"
            echo ""
            kubectl get ns
            break
            ;;

         "Delete DEMO Namespace")
            echo ""
            echo ": Delete Namespace DEMO :"
            echo "-------------------------"
            echo ""
            echo ": Current Namespaces :"
            echo ""
            kubectl get ns
            echo ""
            echo ": Perform Delete Namespace :"
            echo ""
            kubectl delete ns demo
            echo ""
            echo ": Current Namespaces :"
            echo ""
            kubectl get ns
            break
            ;;



        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



