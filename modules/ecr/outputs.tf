output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.backend_repo.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.backend_repo.arn
}

output "ecr_role_arn" {
  description = "The ARN of the ECR IAM role"
  value       = aws_iam_role.ecr_role.arn
}

output "ecr_policy_arn" {
  description = "The ARN of the ECR IAM policy"
  value       = aws_iam_policy.ecr_policy.arn
}