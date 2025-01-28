# AWS ECS Infrastructure with Terraform

This project contains Terraform configurations to set up AWS infrastructure with the following components:

## Infrastructure Components

- VPC with public subnet in 1 availability zone
- Internet Gateway and NAT Gateway for network routing

## Project Structure
AutoDocs-ecs/
├── backend.tf         # S3 backend configuration for remote state storage
├── main.tf           # Primary Terraform configuration file
├── variables.tf      # Variable definitions for the project
└── terraform.tfvars  # Variable values for the project
modules/          # Reusable Terraform modules
  ├── nat-gateway/  # NAT Gateway configuration
  │   ├── main.tf
  │   └── variables.tf
  │
  └── vpc/          # VPC and networking module
      ├── main.tf
      ├── variables.tf
      └── outputs.tf

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