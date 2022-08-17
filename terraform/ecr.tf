resource "aws_ecr_repository" "main_repository" {
  name                 = "${var.ecr_repo_names[0]}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "second_repository" {
  name                 = "${var.ecr_repo_names[1]}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}