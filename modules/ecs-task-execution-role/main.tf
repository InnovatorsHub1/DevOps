# Generates an IAM policy document in JSON format for the ECS task execution role
data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create an IAM role for ECS Task Execution
resource "aws_iam_role" "ecs_tasks_execution_role" {
  name                = "${var.project_name}-ecs-task-execution-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json
}

# Attach the ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create an additional policy for ECR access
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${var.project_name}-ecr-access-policy"
  description = "Allows ECS tasks to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the ECR access policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_ecr_access" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}
