# S3 bucket for assets
resource "aws_s3_bucket" "assets_bucket" {
  bucket = "bedrock-assets-${var.student_id}"

  tags = {
    Project = "Bedrock"
    Purpose = "Asset Storage"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "assets_bucket_versioning" {
  bucket = aws_s3_bucket.assets_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "assets_bucket_encryption" {
  bucket = aws_s3_bucket.assets_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block (keep private)
resource "aws_s3_bucket_public_access_block" "assets_bucket_pab" {
  bucket = aws_s3_bucket.assets_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket notification for Lambda trigger
resource "aws_s3_bucket_notification" "assets_bucket_notification" {
  bucket = aws_s3_bucket.assets_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}