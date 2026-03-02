provider "aws" { region = "us-east-1" }

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

  env          = "qa"
  cluster_name = "myorg-qa-cluster"
  
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  on_demand_desired_size = 1
  spot_desired_size      = 2
  spot_min_size          = 1
  spot_instance_type     = "t3.small"

  eks_addons = [
    { name = "vpc-cni", version = "v1.16.0-eksbuild.1" },
    { name = "kube-proxy", version = "v1.29.0-eksbuild.1" },
    { name = "aws-ebs-csi-driver", version = "v1.28.0-eksbuild.1" }
  ]
}

