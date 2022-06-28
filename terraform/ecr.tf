resource "aws_ecr_repository" "main_repository" {
  name                 = "${var.ecr_repo_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}