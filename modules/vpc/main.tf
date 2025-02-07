module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.cidr_block

  azs             = var.azs
  private_subnets = [for i, az in var.azs : cidrsubnet(var.cidr_block, 4, i)]
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.cidr_block, 8, 48 + i)]

  enable_nat_gateway = true
  single_nat_gateway = true

    tags = merge({
    Environment = var.environment
  })
}