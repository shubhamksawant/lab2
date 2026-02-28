provider "aws" { region = "us-east-1" }

module "ecs" {
  source          = "../../modules/ecs"
  cluster_name    = "myorg-prod-cluster"
  env             = "prod"
  vpc_id          = "vpc-12345"
  subnet_ids      = ["subnet-123", "subnet-456"]
  container_image = "nginx:latest"
  desired_count   = 2
}

