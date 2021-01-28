resource "aws_s3_bucket" "artifacts" {
  bucket = "eb-deployment-test-artifacts"
  acl    = "private"
}

resource "aws_codebuild_project" "build" {
  name = "eb-deployment-test-project"
  description = "Builds the client files for the eb-deployment-test."
  build_timeout = "5"
  service_role = aws_iam_role.build.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.artifacts.bucket
    }

    environment_variable {
      name  = "dockerhub_username"
      value = "dockerhub:username"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "dockerhub_password"
      value = "dockerhub:password"
      type  = "SECRETS_MANAGER"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
