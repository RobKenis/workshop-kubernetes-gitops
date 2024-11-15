module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "workshop-gitops"
  cluster_version = "1.31"
  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = aws_vpc.workshop.id
  subnet_ids               = aws_subnet.workshop[*].id
  control_plane_subnet_ids = aws_subnet.workshop[*].id

  node_security_group_tags = {
    "karpenter.sh/discovery" = "workshop-gitops"
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t4g.small"]
  }

  eks_managed_node_groups = {
    default = {
      ami_type = "BOTTLEROCKET_ARM_64"

      min_size     = 1
      max_size     = 1
      desired_size = 1

      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

  access_entries = {
    rob = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::211125550721:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_AdministratorAccess_e6f4d2702fc60d5a"
      type              = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Project   = "git@github.com:RobKenis/workshop-kubernetes-gitops.git"
    Terraform = "true"
  }
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  create_pod_identity_association = true
  namespace                       = "karpenter"

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "aws_iam_role" "lb_controller" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lb_controller" {
  role   = aws_iam_role.lb_controller.name
  policy = file("${path.module}/policies/lb_controller.json")
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller.arn
}

resource "aws_iam_role" "external_dns" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "external_dns" {
  role   = aws_iam_role.external_dns.name
  policy = file("${path.module}/policies/external_dns.json")
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns.arn
}
