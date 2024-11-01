resource "helm_release" "argocd" {
  namespace        = "argocd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.6.12"
  wait             = false
  create_namespace = true

  values = [templatefile("${path.module}/argocd.values.yaml", {})]

  depends_on = [ module.eks ]
}
