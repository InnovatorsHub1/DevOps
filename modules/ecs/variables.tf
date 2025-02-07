variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
  
}

variable "region" {
  description = "AWS region"
  type        = string
  
}

variable "environment" {
  description = "Environment name (e.g., production)"
  type        = string  
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}   

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
  
}

variable "mongodb_username" {
  description = "MongoDB root username"
  type        = string
  default     = "admin"
}

variable "mongodb_password" {
  description = "MongoDB root password"
  type        = string
  sensitive   = true
}
