# configure aws provider

provider "aws" {
  region = var.region
}

# Create a VPC
module "vpc" {
  source                 = "../modules/vpc"
  region                 = var.region
  project_name           = var.project_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
}

# Create a NAT Gateway
module "nat_gateway" {
  source               = "../modules/nat-gateway"
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  internet_gateway     = module.vpc.internet_gateway
  vpc_id               = module.vpc.vpc_id
}

# Create ECS task execution role
module "ecs-task-execution-role" {
  source       = "../modules/ecs-task-execution-role"
  project_name = module.vpc.project_name
}
# Create ECS cluster
module "ecr" {
  source       = "../modules/ecr"
  project_name = module.vpc.project_name
}

# S3 bucket for frontend
module "s3_frontend" {
  source       = "../modules/s3-frontend"
  project_name = module.vpc.project_name
}