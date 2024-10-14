# Workshop Kubernetes GitOps

This workshop is built around deploying on Kubernetes using a GitOps approach.

## Setup

```shell
# Install Helm and Helmfile
yay -S helm helmfile
# Install diff plugin
helm plugin install https://github.com/databus23/helm-diff
```

## ArgoCD

After installing ArgoCD on Kind, access the UI

```shell
# Get the password
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
# Port forward the server
kubectl port-forward -n argocd deployments/argocd-server 8080:8080
```

## Links

- <https://taskfile.dev/>
- <https://kind.sigs.k8s.io/>
- <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/>
