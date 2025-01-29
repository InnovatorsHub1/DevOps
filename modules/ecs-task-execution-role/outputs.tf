output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_tasks_execution_role.arn
}

output "ecr_access_policy_arn" {
  value = aws_iam_policy.ecr_access_policy.arn
}