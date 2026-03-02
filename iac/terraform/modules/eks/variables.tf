variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "env" {
  type        = string
  description = "Environment name (e.g. dev, qa, prod)"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster and node groups"
}

variable "on_demand_desired_size" {
  type        = number
  description = "Desired size of the on-demand node group"
}

variable "spot_desired_size" {
  type        = number
  description = "Desired size of the spot node group"
}

variable "spot_min_size" {
  type        = number
  description = "Minimum size of the spot node group"
  default     = 0
}

variable "spot_instance_type" {
  type        = string
  description = "Instance type for spot instances (e.g., t3.small or t3.medium)"
  default     = "t3.small"
}

variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))
  description = "List of EKS add-ons to install"
  default     = []
}
