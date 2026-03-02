variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "env" {
  type        = string
  description = "Environment name (dev, qa, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS tasks are run"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ECS task execution"
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service"
  default     = "app-service"
}

variable "container_image" {
  type        = string
  description = "Container image to run"
}

variable "container_port" {
  type        = number
  description = "Port the container responds on"
  default     = 80
}

variable "desired_count" {
  type        = number
  description = "Desired number of tasks"
  default     = 1
}
