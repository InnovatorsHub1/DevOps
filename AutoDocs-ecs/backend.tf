terraform {
  backend "s3" {
    bucket         = "autodocs-terraform-remote-state" // Need to create the bucket manually
    key            = "autodocs.tfstate" // Exemple - projectName.tfstate
    region         = "il-central-1" // Exemple - us-east-1
    profile        = "terraform" // The user profile Exemple - terraform
    dynamodb_table = "autodocs-terraform-state-lock" # Table must be created manually with partition key "LockID" (String)
    encrypt        = true                           # Recommended for security
  }
}