variable "ami_id" {
  type        = string
  description = "AMI ID for the instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the instance"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key for Ansible SSH connection"
}

variable "public_key" {
  type        = string
  description = "Public key content for EC2 KeyPair"
}
