resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.project_name}-backend-repo"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-backend-repo"
  }
}