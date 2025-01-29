terraform {
  backend "s3" {
    bucket       = "autodocs-terraform-remote-state" // Need to create the bucket manually
    key          = "autodocs.tfstate"                // Exemple - projectName.tfstate
    region       = "il-central-1"                    // Exemple - us-east-1
    encrypt      = true                              //Recommended for security
    use_lockfile = true                              //S3 native locking
  }
}