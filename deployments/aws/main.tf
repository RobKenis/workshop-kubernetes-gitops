data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

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

  vpc_id                   = data.aws_vpc.default.id
  subnet_ids               = data.aws_subnets.default.ids
  control_plane_subnet_ids = data.aws_subnets.default.ids

  eks_managed_node_group_defaults = {
    instance_types = ["t4g.medium", "t4g.large"]
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
      principal_arn     = "arn:aws:iam::840471932663:user/rob"
      type              = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
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
