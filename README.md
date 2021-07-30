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
10) Update .kube/config
11) Show Nodes
12) Create DEMO Namespace
13) Delete DEMO Namespace
14) Helm Repo Add Infrastructure Resources
15) Helm Install MongoDB
16) Helm Install Redis
17) Helm Install Prometheus
18) Helm Install Traefik
19) Install Secrets
20) Install RBAC
21) Quit
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
kubectl apply -f traefik/service1.yaml
kubectl apply -f traefik/service2.yaml
```

## Check :
http <Public IP>/service1
http <Public IP>/service2
