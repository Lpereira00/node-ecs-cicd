resource "aws_codestarconnections_connection" "github_connection" {
  name          = "github_connection"
  provider_type = "GitHub"
}


resource "aws_codepipeline" "project_pipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.demo-codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.code_pipeline_artifacts.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.demo-artifacts.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        BranchName = "master"
        ConnectionArn = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = "Lpereira00/node-redis"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "test-project"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.main_cluster.name
        ServiceName = aws_ecs_service.demo.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}



