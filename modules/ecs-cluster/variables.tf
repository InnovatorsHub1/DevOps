variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The VPC ID where the ECS cluster will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID where the ECS tasks will run"
  type        = string
}
