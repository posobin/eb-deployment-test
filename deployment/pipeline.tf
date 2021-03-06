resource "aws_codepipeline" "pipeline" {
  name     = "eb-deployment-test-pipeline"
  role_arn = aws_iam_role.build.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        OAuthToken = var.github_oauth_token
        Owner      = var.github_organization
        Repo       = var.github_repository
        Branch     = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source"]
      output_artifacts = ["artifact"]
      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "eb-deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ElasticBeanstalk"
      input_artifacts = ["artifact"]
      version = "1"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.app.name
        EnvironmentName = aws_elastic_beanstalk_environment.production.name
      }
    }

    action {
      name = "ecs-deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ECS"
      input_artifacts = ["artifact"]
      version = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.worker.name
        ServiceName = aws_ecs_service.worker.name
        FileName = "ecs-imagedefinitions.json"
      }
    }
  }
}
