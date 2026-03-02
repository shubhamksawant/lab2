variable "env" {
  type        = string
  description = "Environment name (dev, qa, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Set to true to provision a single NAT Gateway (dev/qa), false for Multi-AZ (prod)"
  default     = true
}
