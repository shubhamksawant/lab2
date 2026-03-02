data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "myorg-terraform-state-qa"
    key    = "vpc/qa/terraform.tfstate"
    region = "us-east-1"
  }
}
