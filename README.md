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
 8) Update .kube/config
 9) Show Nodes
10) Create DEMO Namespace
11) Delete DEMO Namespace
12) Quit
Please enter your choice:
```

Please aware the number can be different.
```bash
./scripts/aks-cluster.sh
```








# Install Infrastructure Resources
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## MongoDB
```bash
helm install mongodb --set architecture=replicaset bitnami/mongodb
```
## Redis
```bash
helm install redis bitnami/redis
```
## Prometheus
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false  prometheus-community/kube-prometheus-stack
```

## Install Secrets
```bash
kubesec decrypt secret/secret.enc.yaml | kubectl apply -n demo -f -
```
### Check Secrets
```bash
k get secrets -l 'secret in (kboot-infra)' -n demo -ojson | jq '.items[].data'
```

## Install RBAC for ConfigMaps/Secrets
```bash
k apply -f rbac/roles.yaml
```


# Traefik
https://ichi.pro/de/traefik-ingress-im-azure-kubernetes-dienst-275193782592692

```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
```

## Update configuration with PublicIP
Update `service.spec.loadBalancerIP` in `traefik-values.yaml` file 
```bash
./scripts/aks-cluster.sh
vi traefik/helm/traefik-values.yaml
```
## Install Traefik 
```bash
helm install traefik traefik/traefik -f traefik/helm/traefik-values.yaml
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
