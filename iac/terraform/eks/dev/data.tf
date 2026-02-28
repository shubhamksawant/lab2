data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state-dev"
    key    = "vpc/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
