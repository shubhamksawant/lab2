terraform {
  required_version = ">= 1.10.0"

  # S3 buckets should be pre-created with:
  # versioning_configuration { status = "Enabled" }
  backend "s3" {
    bucket       = "myorg-terraform-state-<ENV>"
    key          = "eks/<ENV>/terraform.tfstate"
    region       = "us-east-1"
    
    # S3 Native State Locking (Terraform 1.10+)
    # Replaces the need for DynamoDB
    use_lockfile = true
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-east-1:123456789012:key/<YOUR-KMS-KEY-ID>"
  }
}
