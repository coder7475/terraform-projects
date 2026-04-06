# IAM Roles
locals {
  lambda_function_name = "${local.bucket_prefix}-image-processor-${random_id.suffix.hex}"
}

# IAM Roles for lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${local.lambda_function_name}-role"

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
}


# IAM Policy for Lambda to access S3 buckets and cloudwatch logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.lambda_function_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Cloudwatch log permissions
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:ap-southeast-1:*:*"
      },
      # Read from upload bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          aws_s3_bucket.upload_bucket.arn,
          "${aws_s3_bucket.upload_bucket.arn}/*",
        ]
      },
      # write to processed bucket
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.processed_bucket.arn,
          "${aws_s3_bucket.processed_bucket.arn}/*",
        ]
      }
    ]
  })
}

# Create Lambda function for image processing
# Package the Lambda function code as zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function resource
resource "aws_lambda_function" "image_processor" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = local.lambda_function_name
  role = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"
  timeout = 60
  memory_size = 1024

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_bucket.id
      LOG_LEVEL = "INFO"
    }
  }
}

# CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 7
}