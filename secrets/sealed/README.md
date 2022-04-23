# Sealed Secrets

References:

https://github.com/bitnami-labs/sealed-secrets
https://docs.d2iq.com/dkp/dispatch/1.3/tutorials/cd_tutorials/storing-dispatch-secrets-with-gitops/
https://imsharadmishra.medium.com/exploring-sealed-secrets-in-minikube-7f517799413c
https://developer.okta.com/blog/2021/06/01/kubernetes-spring-boot-jhipster

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install sealed-secrets sealed-secrets/sealed-secrets
```

For more details please check the installation scripts in `/scripts`

# Step-By-Step
```
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/controller.yaml
```

```
mkdir -p /tmp/k8s
kubectl get secret -n kube-system | grep 'sealed-secrets-key' | awk '{print$1}' | \
    xargs -I {} kubectl get secret/{} -n kube-system  -o yaml | grep tls.crt | \
    awk -F: 'NR==1{print $2}' | base64 --decode >> /tmp/k8s/tls.crt
```

``` 
kubeseal --namespace default --cert  /tmp/k8s/tls.crt --format=yaml < k8s/k3d/sealed/secrets.yaml > k8s/k3d/sealed/sealed-secrets.yaml
```

``` 
kubectl apply -f k8s/k3d/sealed/sealed-secrets.yaml
```
