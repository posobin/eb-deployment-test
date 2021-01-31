resource "aws_iam_role" "build" {
  name = "eb-deployment-test-build-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "eb-deployment-test-codebuild-policy"
  role = aws_iam_role.build.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:946702831620:secret:dockerhub-UiWcA0*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "fargate" {
  name = "eb-deployment-worker-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "fargate_policy" {
  name = "eb-deployment-fargate-policy"
  role = aws_iam_role.fargate.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsAccess",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:log-group:/ecs/eb-deployment-fargate"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "beanstalk_policy" {
  name = "eb-deployment-test-beanstalk-policy"
  role = aws_iam_role.build.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BucketAccess",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::elasticbeanstalk-*",
        "arn:aws:s3:::elasticbeanstalk-*/*"
      ]
    },
    {
      "Sid": "XRayAccess",
      "Action":[
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogsAccess",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"
      ]
    },
    {
      "Sid": "CloudWatchCodeBuildLogsAccess",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/codebuild*"
      ]
    },
    {
        "Sid": "AllowPassRoleToElasticBeanstalk",
        "Effect": "Allow",
        "Action": [
            "iam:PassRole"
        ],
        "Resource": "*",
        "Condition": {
            "StringLikeIfExists": {
                "iam:PassedToService": "elasticbeanstalk.amazonaws.com"
            }
        }
    },
    {
        "Sid": "AllowCloudformationOperationsOnElasticBeanstalkStacks",
        "Effect": "Allow",
        "Action": [
            "cloudformation:*"
        ],
        "Resource": [
            "arn:aws:cloudformation:*:*:stack/awseb-*",
            "arn:aws:cloudformation:*:*:stack/eb-*"
        ]
    },
    {
      "Sid": "LoadBalancer",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*" 
      ],
      "Resource": [
        "*"
      ]
    },
    {
        "Sid": "AllowDeleteCloudwatchLogGroups",
        "Effect": "Allow",
        "Action": [
            "logs:DeleteLogGroup"
        ],
        "Resource": [
            "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"
        ]
    },
    {
        "Sid": "AllowS3OperationsOnElasticBeanstalkBuckets",
        "Effect": "Allow",
        "Action": [
            "s3:*"
        ],
        "Resource": [
            "arn:aws:s3:::elasticbeanstalk-*",
            "arn:aws:s3:::elasticbeanstalk-*/*"
        ]
    },
    {
        "Sid": "AllowOperations",
        "Effect": "Allow",
        "Action": [
            "autoscaling:AttachInstances",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteScheduledAction",
            "autoscaling:DescribeAccountLimits",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeLoadBalancers",
            "autoscaling:DescribeNotificationConfigurations",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:DescribeScheduledActions",
            "autoscaling:DetachInstances",
            "autoscaling:PutScheduledUpdateGroupAction",
            "autoscaling:ResumeProcesses",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:SuspendProcesses",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "autoscaling:UpdateAutoScalingGroup",
            "cloudwatch:PutMetricAlarm",
            "ec2:AssociateAddress",
            "ec2:AllocateAddress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeImages",
            "ec2:DescribeInstances",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DisassociateAddress",
            "ec2:ReleaseAddress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:TerminateInstances",
            "ecs:CreateCluster",
            "ecs:DeleteCluster",
            "ecs:DescribeClusters",
            "ecs:RegisterTaskDefinition",
            "elasticbeanstalk:*",
            "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ConfigureHealthCheck",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DescribeInstanceHealth",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets",
            "iam:ListRoles",
            "logs:CreateLogGroup",
            "logs:PutRetentionPolicy",
            "rds:DescribeDBInstances",
            "rds:DescribeOrderableDBInstanceOptions",
            "rds:DescribeDBEngineVersions",
            "sns:ListTopics",
            "sns:GetTopicAttributes",
            "sns:ListSubscriptionsByTopic",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "codebuild:CreateProject",
            "codebuild:DeleteProject",
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
POLICY
}

resource "aws_iam_instance_profile" "build" {
  name = "eb-deployment-test-build-profile"
  role = aws_iam_role.build.name
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "eb-deployment-test-artifacts-policy",
  "Statement": [
    {
      "Sid": "eb-deployment-test-access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.build.arn}"
      },
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.artifacts.arn}"]
    },
    {
      "Sid": "eb-deployment-test-child-access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.build.arn}"
      },
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
      "Resource": ["${aws_s3_bucket.artifacts.arn}/*"]
    }
  ]
}
POLICY
}
