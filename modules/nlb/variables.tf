variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
  
}

variable "environment" {
  description = "Environment name (e.g., production)"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}