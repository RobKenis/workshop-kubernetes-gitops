resource "helm_release" "argocd" {
  namespace        = "argocd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.6.12"
  wait             = false
  create_namespace = true


  values = [
    templatefile("${path.module}/templates/argocd.values.yaml", {
      sshPrivateKey = indent(8, data.aws_secretsmanager_secret_version.github_ssh_key.secret_string)
    })
  ]

  depends_on = [module.eks]
}

data "aws_secretsmanager_secret" "github_ssh_key" {
  name = "github/robkenis/workshop-kubernetes-gitops/deploy-key"
}

data "aws_secretsmanager_secret_version" "github_ssh_key" {
  secret_id = data.aws_secretsmanager_secret.github_ssh_key.id
}
