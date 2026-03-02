terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "myorg-terraform-state-prod"
    key          = "vpc/prod/terraform.tfstate"
    region       = "us-east-1"
    
    use_lockfile = true
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-east-1:123456789012:key/your-kms-key-id-placeholder"
  }
}
