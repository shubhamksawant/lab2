provider "aws" { region = "us-east-1" }

module "ecs" {
  source          = "../../modules/ecs"
  cluster_name    = "myorg-qa-cluster"
  env             = "qa"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnets
  container_image = "nginx:latest"
  desired_count   = 1
}

