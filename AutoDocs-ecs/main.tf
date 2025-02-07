# configure aws provider

provider "aws" {
  region = var.region
}

# Create a VPC
module "vpc" {
  source          = "../modules/vpc"
  project_name    = var.project_name
  cidr_block      = var.vpc_cidr
  azs             = ["${var.az1}", "${var.az2}"]  # Add at least two AZs
  environment     = var.environment
}

# Create ECR
module "ecr" {
  source       = "../modules/ecr"
  project_name = var.project_name
}

# S3 bucket for frontend
module "s3_frontend" {
  source       = "../modules/s3-frontend"
  project_name = var.project_name
}

# Create NLB
module "nlb" {
  source            = "../modules/nlb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  environment       = var.environment
  container_port    = var.container_port
}

module "ecs" {
  source                = "../modules/ecs"
  project_name          = var.project_name
  region                = var.region
  ecr_repository_url    = module.ecr.ecr_repository_url
  environment           = var.environment
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  vpc_id                = module.vpc.vpc_id
  azs                   = ["${var.az1}", "${var.az2}"]
  container_port        = var.container_port
  target_group_arn      = module.nlb.target_group_arn
  mongodb_username      = var.mongodb_username
  mongodb_password      = var.mongodb_password
}