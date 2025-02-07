# AWS ECS Infrastructure with Terraform

This project contains Terraform configurations to set up AWS infrastructure with the following components:

## Infrastructure Components

- VPC with public subnet in 1 availability zone
- Internet Gateway and NAT Gateway for network routing

## Project Structure
```sh
AutoDocs-ecs/
├── backend.tf         # S3 backend configuration for remote state storage
├── main.tf           # Primary Terraform configuration file
├── variables.tf      # Variable definitions for the project
├── terraform.tfvars  # Variable values for the project
│
└── modules/          # Reusable Terraform modules
    ├── vpc/          # VPC and networking module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── nat-gateway/  # NAT Gateway configuration
    │   ├── main.tf
    │   └── variables.tf
    │
    ├── s3-frontend/  # S3 bucket for React frontend hosting
    │   ├── main.tf
    │   └── outputs.tf
    │
    ├── ecr/          # Elastic Container Registry for Docker images
    │   ├── main.tf
    │   └── variables.tf
    │
    └── ecs-cluster/  # ECS Cluster configuration
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 0.12 or later)
- S3 bucket created for Terraform state and lock

## Configuration

1. Create in AutoDocs-ecs folder a terraform.tfvars file with the following variables (exemple):
```env
project_name            = "autodocs"
environment             = "production"
region                  = "il-central-1" 
vpc_cidr                = "10.0.0.0/16"
az1                     = "il-central-1a"
az2                     = "il-central-1b"
public_subnet_az1_cidr  = "10.0.0.0/24"
public_subnet_az2_cidr  = "10.0.1.0/24"
private_subnet_az1_cidr = "10.0.2.0/24"
private_subnet_az2_cidr = "10.0.3.0/24"
container_port          = 3000              // the continer port
mongodb_username        = "the username"
mongodb_password        = "the password"
```
2. Initialize Terraform:
```sh
terraform init
```

3. Review the planned changes:
```sh
terraform plan
```

4. Apply the configuration:
```sh
terraform apply
```

## ⚠️ Warning About Terraform Destroy

### IMPORTANT: Read Before Using `terraform destroy`

- This command will permanently delete ALL resources managed by this Terraform configuration
- There is NO WAY to undo this action once confirmed
- All data stored in:
  - VPC and Subnets
  - NAT Gateway
  - Internet Gateway
  - Will be PERMANENTLY DELETED

Before running destroy:
1. Backup any important data
2. Verify you're in the correct environment
3. Double check the workspace with `terraform workspace show`
4. Consider impact on dependent systems

```bash
# Safe destroy process
terraform plan -destroy    # Review what will be destroyed first
terraform destroy         # Only proceed if you're absolutely certain
