resource "aws_s3_bucket" "code_pipeline_artifacts" {
  bucket = "pipeline-bucket-ecs"
}

resource "aws_s3_bucket" "env_bucket_storage" {
  bucket = "env-bucket-storage"

}
resource "aws_s3_bucket" "codebuild-cache" {
  bucket = "${var.project_name}-codebuild-cache"
}

resource "aws_s3_object" "env_bucket_file" {
  bucket = aws_s3_bucket.env_bucket_storage.bucket
  key    = "parameters.env"
  source = "parameters.env"
}