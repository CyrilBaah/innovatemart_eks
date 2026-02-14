# Data sources
data "aws_caller_identity" "current" {}

# Generate random suffix for unique resource naming
resource "random_id" "policy_suffix" {
  byte_length = 4
}

# Developer IAM User with unique naming to avoid conflicts
resource "aws_iam_user" "developer" {
  name = "${var.developer_username}-${random_id.policy_suffix.hex}"
  path = "/"

  tags = {
    Project     = "Bedrock"
    Role        = "Developer"
    OriginalName = var.developer_username
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create access key for the developer user
resource "aws_iam_access_key" "developer_key" {
  user = aws_iam_user.developer.name
  
  lifecycle {
    ignore_changes = []
  }
}

# Attach ReadOnlyAccess managed policy to developer user
resource "aws_iam_user_policy_attachment" "developer_readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Generate random suffix for unique policy naming
resource "random_id" "policy_suffix" {
  byte_length = 4
}

# Custom policy for S3 bucket access with unique naming
resource "aws_iam_policy" "s3_bucket_access" {
  name        = "bedrock-s3-bucket-access-${random_id.policy_suffix.hex}"
  description = "Allow PutObject access to the assets S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.assets_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.assets_bucket.arn
        ]
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

# Attach S3 bucket access policy to developer user
resource "aws_iam_user_policy_attachment" "developer_s3" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.s3_bucket_access.arn
}

# EKS access entry for developer user
resource "aws_eks_access_entry" "developer" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.developer.arn
  kubernetes_groups = ["bedrock-developers"]
  type              = "STANDARD"

  tags = {
    Project = "Bedrock"
  }

  depends_on = [module.eks]
}

# IAM role for Lambda function with unique naming
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-lambda-execution-role-${random_id.policy_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Lambda to access CloudWatch Logs with unique naming
resource "aws_iam_policy" "lambda_cloudwatch" {
  name        = "bedrock-lambda-cloudwatch-${random_id.policy_suffix.hex}"
  description = "CloudWatch Logs access for Lambda function"

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
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

# Attach CloudWatch policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch.arn
}