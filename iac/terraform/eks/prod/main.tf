provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.common_tags
  }
}

locals {
  env     = "prod"
  service = "eks"
  
  common_tags = {
    Environment = local.env
    Service     = local.service
    CostCenter  = "${local.env}-${local.service}-001"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "eks" {
  source = "../../modules/eks"

  env          = local.env
  cluster_name = "myorg-${local.env}-cluster"
  
  # Inject data bridge from the remote VPC state
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  on_demand_desired_size = 3
  spot_desired_size      = 5
  spot_min_size          = 2
  spot_instance_type     = "t3.medium"

  eks_addons = [
    { name = "vpc-cni", version = "v1.16.0-eksbuild.1" },
    { name = "kube-proxy", version = "v1.29.0-eksbuild.1" },
    { name = "aws-ebs-csi-driver", version = "v1.28.0-eksbuild.1" },
    { name = "coredns", version = "v1.11.1-eksbuild.4" }
  ]
}
