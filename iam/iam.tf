data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "appserver_role" {
  name               = "appserver_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy" {
  # AmazonSSMManagedInstanceCore
  statement {
    effect    = "Allow"
    actions   = [
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*",
      "ssm:SendCommand",
      "ssm:StartSession",
      "ssm:TerminateSession"
    ]
    resources = ["*"]
  }

  # AmazonElasticFileSystemFullAccess
  statement {
    effect    = "Allow"
    actions   = [
      "elasticfilesystem:Describe*",
      "elasticfilesystem:List*",
      "elasticfilesystem:Create*",
      "elasticfilesystem:Delete*",
      "elasticfilesystem:MountTarget*"
    ]
    resources = ["*"]
  }

  # AmazonDynamoDBFullAccess
  statement {
    effect    = "Allow"
    actions   = [
      "dynamodb:Describe*",
      "dynamodb:List*",
      "dynamodb:Query",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["*"]
  }

  # AmazonS3FullAccess
  statement {
    effect    = "Allow"
    actions   = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*"
    ]
    resources = ["*"]
  }

  # CloudWatchLogsFullAccess
  statement {
    effect    = "Allow"
    actions   = [
      "logs:Describe*",
      "logs:Get*",
      "logs:List*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:PutSubscriptionFilter"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "appserver_policy" {
  name        = "appserver-policy"
  description = "Appserver Role Policy"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "appserver_role_attach" {
  role       = aws_iam_role.appserver_role.name
  policy_arn = aws_iam_policy.appserver_policy.arn
}

resource "aws_iam_instance_profile" "appserver_profile" {
  name = "appserver-instance-profile"
  role = aws_iam_role.appserver_role.name
}