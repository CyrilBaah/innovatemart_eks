# Observability Configuration
# This file contains additional observability resources for the EKS cluster

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = 7

  tags = {
    Project = "Bedrock"
    Type    = "ApplicationLogs"
  }
}

# CloudWatch Log Group for FluentBit
resource "aws_cloudwatch_log_group" "fluentbit_logs" {
  name              = "/aws/eks/${var.cluster_name}/fluentbit"
  retention_in_days = 3

  tags = {
    Project = "Bedrock"
    Type    = "FluentBitLogs"
  }
}

# IAM role for FluentBit (if we need to deploy it manually)
resource "aws_iam_role" "fluentbit_role" {
  name = "${var.cluster_name}-fluentbit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

# IAM policy for FluentBit
resource "aws_iam_policy" "fluentbit_policy" {
  name        = "${var.cluster_name}-fluentbit-policy"
  description = "Policy for FluentBit to send logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.application_logs.arn,
          "${aws_cloudwatch_log_group.application_logs.arn}:*",
          aws_cloudwatch_log_group.fluentbit_logs.arn,
          "${aws_cloudwatch_log_group.fluentbit_logs.arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "autoScaling:DescribeAutoScalingGroups"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

# Attach policy to FluentBit role
resource "aws_iam_role_policy_attachment" "fluentbit_policy_attachment" {
  role       = aws_iam_role.fluentbit_role.name
  policy_arn = aws_iam_policy.fluentbit_policy.arn
}

# EKS Pod Identity Association for FluentBit
# NOTE: Commented out to avoid trust policy errors
# Pod Identity may need to be configured separately
# FluentBit can be installed manually with IRSA instead
# resource "aws_eks_pod_identity_association" "fluentbit" {
#   cluster_name    = module.eks.cluster_name
#   namespace       = "amazon-cloudwatch"
#   service_account = "aws-for-fluent-bit"
#   role_arn        = aws_iam_role.fluentbit_role.arn
#
#   tags = {
#     Project = "Bedrock"
#   }
#
#   depends_on = [module.eks]
# }