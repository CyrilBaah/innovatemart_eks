# Create ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/bedrock-asset-processor"
  output_path = "${path.root}/lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "asset_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  runtime     = "python3.11"
  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.assets_bucket.id
      LOG_LEVEL   = "INFO"
    }
  }

  tags = {
    Project = "Bedrock"
    Purpose = "Asset Processing"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_cloudwatch,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Project = "Bedrock"
  }
}

# Lambda permission to allow S3 to invoke the function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets_bucket.arn
}