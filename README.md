# Workshop Kubernetes GitOps

This workshop is built around deploying on Kubernetes using a GitOps approach.

## Setup

```shell
# Install Helm and Helmfile
yay -S helm helmfile
# Install diff plugin
helm plugin install https://github.com/databus23/helm-diff
```

## Links

- <https://taskfile.dev/>
- <https://kind.sigs.k8s.io/>
- <https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/>
