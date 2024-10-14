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

### Connect a repository

I couldn't be bothered with setting up secret management, so you'll have to connect the repository manually after
installing ArgoCD. Navigate to <https://localhost:8080/settings/repos>, click 'Connect repository' and connect however
you like it. For SSH, generate a new key pair using `ssh-keygen`, add the public part to GitHub under 'Deploy keys' without
write permissions and add the private part to ArgoCD.

## Links

- <https://taskfile.dev/>
- <https://kind.sigs.k8s.io/>
- <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/>
