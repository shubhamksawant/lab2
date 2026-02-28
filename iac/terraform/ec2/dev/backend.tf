terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "myorg-terraform-state-dev"
    key          = "ec2/dev/terraform.tfstate"
    region       = "us-east-1"
    
    use_lockfile = true
    encrypt      = true
  }
}
