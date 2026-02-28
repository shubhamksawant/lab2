data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state-prod"
    key    = "vpc/prod/terraform.tfstate"
    region = "us-east-1"
  }
}
