resource "aws_elastic_beanstalk_application" "app" {
  name        = "eb-deployment-test-2"
  description = "Application to test out how to deploy to EB."
}

resource "aws_elastic_beanstalk_environment" "production" {
  name                = "production"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.3 running Docker"

  setting {
    name = "Protocol"
    namespace = "aws:elbv2:listener:80"
    value = "HTTP"
    resource = ""
  }

  setting {
    name = "ListenerEnabled"
    namespace = "aws:elbv2:listener:80"
    value = true
    resource = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "LoadBalancerType"
    value = "application"
    resource = ""
  }

  # Set environment variable
  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name = "NODE_ENV"
  #   value = "production"
  # }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.build.name
    resource = ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.small"
    resource = ""
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
    resource = ""
  }

  # Stream logs from the instance to cloudwatch
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "StreamLogs"
    value = true
    resource = ""
  }
}

output "url" {
  value = aws_elastic_beanstalk_environment.production.cname
}
