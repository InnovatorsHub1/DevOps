# AWS ECS Infrastructure with Terraform

This project contains Terraform configurations to set up a complete AWS ECS infrastructure with the following components:

## Infrastructure Components

- VPC with public and private subnets across 2 availability zones
- Internet Gateway and NAT Gateways for network routing
- Application Load Balancer (ALB) with target groups
- Security Groups for ALB and ECS tasks
- ECS Task Execution Role with proper IAM permissions

## Project Structure
```sh
AutoDocs-ecs/
├── backend.tf         # S3 backend configuration for remote state storage
├── main.tf            # Primary Terraform configuration file for overall infrastructure
├── variables.tf       # Variable definitions for the project
│
└── modules/           # Reusable Terraform modules
    ├── alb/           # Application Load Balancer module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ecm/           # Amazon Certificate Manager module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ecs-task-execution-role/  # IAM roles for ECS
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── nat-gateway/   # NAT Gateway configuration
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security-groups/  # Security group definitions
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── vpc/           # VPC and networking module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 0.12 or later)
- S3 bucket created for Terraform state
- DynamoDB table for state locking

## Configuration

1. Create an S3 bucket for Terraform state:
```sh
aws s3 mb s3://autodocs-terraform-remote-state
```
2. Create a DynamoDB table for state locking:
```sh
aws dynamodb create-table \
    --table-name autodocs-terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```
3. Create in AutoDocs-ecs folder a terraform.tfvars file with the following variables:
```env
region="il-central-1"
project_name="autodocs"
vpc_cidr="10.0.0.0/16"
public_subnet_az1_cidr="10.0.0.0/24"
public_subnet_az2_cidr="10.0.1.0/24"
private_app_subnet_az1_cidr="10.0.2.0/24"
private_app_subnet_az2_cidr="10.0.3.0/24"
private_data_subnet_az1_cidr="10.0.4.0/24"
private_data_subnet_az2_cidr="10.0.5.0/24"
```
4. Initialize Terraform:
```sh
terraform init
```

5. Review the planned changes:
```sh
terraform plan
```

6. Apply the configuration:
```sh
terraform apply
```

## ⚠️ Warning About Terraform Destroy

### IMPORTANT: Read Before Using `terraform destroy`

- This command will permanently delete ALL resources managed by this Terraform configuration
- There is NO WAY to undo this action once confirmed
- All data stored in:
  - ECS Services and Tasks
  - Load Balancers
  - VPC and Subnets
  - DynamoDB tables
  - Will be PERMANENTLY DELETED

Before running destroy:
1. Backup any important data
2. Verify you're in the correct environment (dev/staging/prod)
3. Double check the workspace with `terraform workspace show`
4. Consider impact on dependent systems

```bash
# Safe destroy process
terraform plan -destroy    # Review what will be destroyed first
terraform destroy         # Only proceed if you're absolutely certain
