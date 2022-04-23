# Manage AKS Cluster

## PreCondition
```bash
brew install azure-cli
brew install kns
brew install kubectx 
brew install shyiko/kubesec/kubesec
brew install sops
brew install gnupg
```

``` 
--------------------------------------------
:: Create or manage your AKS cluster
--------------------------------------------
 1) AZ Login
 2) Create Resource Group and new AKS Cluster
 3) Delete Resource Group and AKS Cluster
 4) Start Cluster
 5) Stop Cluster
 6) Show Cluster
 7) Show Public-IP
 8) Show Container Registry
 9) Login Container Registry
10) List Container Registry
11) Update .kube/config
12) Show Nodes
13) Create DEMO Namespace
14) Delete DEMO Namespace
15) Helm Repo Add Infrastructure Resources
16) Helm Install MongoDB
17) Helm Install Redis
18) Helm Install Prometheus
19) Helm Install Traefik
20) Install Secrets
21) Install RBAC
22) Quit
Please enter your choice:
```

Please aware the number can be different.
```bash
./scripts/aks-cluster.sh
```


# Traefik
https://ichi.pro/de/traefik-ingress-im-azure-kubernetes-dienst-275193782592692


## Update configuration with PublicIP
Update `service.spec.loadBalancerIP` in `traefik-values.yaml` file 
```bash
./scripts/aks-cluster.sh
vi traefik/helm/traefik-values.yaml
```

## Check Installation
```bash
kubectl get pods | grep traefik
```

## Expose Dashboard
```bash
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000
```
http://127.0.0.1:9000/dashboard/


## Install Sample Services
```bash
kubectl apply -f traefik/service2.yaml
kubectl apply -f traefik/service1.yaml
```

## Check :
http <Public IP>/service1
http <Public IP>/service2



```bash
export AKS_CLUSTER_NAME=aks-cluster-c3smonkey
export AKS_RESOURCE_GROUP=AKS
export PIP_RESOURCE_GROUP=aks-public-ip-c3smonkey
export CONTAINER_REGISTRY=c3smonkey
export LOCATION=eastus2
export NODE_SIZE=Standard_D1_V2
export NODE_COUNT=2

az aks create --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --node-count $NODE_COUNT --node-vm-size $NODE_SIZE --enable-addons monitoring --generate-ssh-keys


```
